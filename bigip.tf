data "http" "my_address" {
  url = "https://checkip.amazonaws.com"
  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Failed to get local IP address"
    }
  }
}

data "google_compute_image" "bigip" {
  project = try(element(regex("projects/([^/]+)/global/", var.image), 0), var.project_id)
  family  = try(element(regex("family/(.*)$", var.image), 0), null)
  name    = try(element(regex("images/(.*)$", var.image), 0), null)
}

locals {
  # Official published images have a common naming convention that can be used to infer the release
  inferred_version = element(coalescelist(regexall("/f5-bigip-((?:[0-9]{1,2}-){5,6}[0-9]+)-[^0-9].*$", data.google_compute_image.bigip.name), ["unknown-version"]), 0)
  # HACK - the service account name is predictable, so just specify it rather than relying on resource creation
  bigip_sa = format("%s-bigip@%s.iam.gserviceaccount.com", var.name, var.project_id)
}

# Define a service account for the BIG-IP instances
resource "google_service_account" "bigip" {
  project      = var.project_id
  account_id   = format("%s-bigip", var.name)
  display_name = "BIG-IP service account"
}

resource "google_project_iam_member" "bigip" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/compute.viewer",
  ])
  project = var.project_id
  role    = each.value
  member  = google_service_account.bigip.member

  depends_on = [
    google_service_account.bigip,
  ]
}

# Create a secret containing the admin user password
module "admin_password" {
  source     = "memes/secret-manager/google"
  version    = "2.1.1"
  project_id = var.project_id
  id         = format("%s-bigip", var.name)
  secret     = var.admin_password
  accessors = [
    format("serviceAccount:%s", local.bigip_sa),
  ]

  depends_on = [
    google_service_account.bigip,
  ]
}

# Defines a template to be used by all BIG-IP instances in the MIG
resource "google_compute_instance_template" "bigip" {
  project              = var.project_id
  name_prefix          = format("%s-bigip-", var.name)
  description          = format("BIG-IP instance template for version %s", local.inferred_version)
  instance_description = format("BIG-IP %s", local.inferred_version)
  region               = var.region
  labels = merge(var.labels, {
    service = "big-ip"
  })
  tags = setunion(["allow-mgmt-nat"], var.tags)

  machine_type = "n2-standard-4"
  scheduling {
    automatic_restart   = true
    on_host_maintenance = ""
    preemptible         = false
  }

  advanced_machine_features {
    enable_nested_virtualization = false
  }

  service_account {
    email = google_service_account.bigip.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  disk {
    auto_delete  = true
    boot         = true
    source_image = data.google_compute_image.bigip.self_link
    disk_type    = "pd-balanced"
    disk_size_gb = 100
    labels       = var.labels
  }

  can_ip_forward = true
  network_interface {
    subnetwork = module.external.subnets_by_region[var.region].self_link
    nic_type   = "VIRTIO_NET"
    stack_type = "IPV4_ONLY"
  }

  network_interface {
    subnetwork = module.management.subnets_by_region[var.region].self_link
    nic_type   = "VIRTIO_NET"
    stack_type = "IPV4_ONLY"
  }

  network_interface {
    subnetwork = module.internal.subnets_by_region[var.region].self_link
    nic_type   = "VIRTIO_NET"
    stack_type = "IPV4_ONLY"
  }

  metadata = {
    user-data = templatefile(format("%s/templates/big-ip/cloud-config.yaml", path.module), {
      onboard_sh                = file(format("%s/files/big-ip/onboard.sh", path.module))
      reset_management_route_sh = file(format("%s/files/big-ip/reset_management_route.sh", path.module))
      onboard_env               = {}
      management_route_env      = {}
      runtime_init_conf_yaml = templatefile(format("%s/templates/big-ip/runtime-init-conf.yaml", path.module), {
        admin_pass_secret = module.admin_password.secret_id
        do_yaml = templatefile(format("%s/templates/big-ip/do.yaml", path.module), {
          domain_name = var.domain_name
          ssh_keys    = var.ssh_keys
          livez_port  = 26000
        })
        as3_initial_yaml = templatefile(format("%s/templates/big-ip/as3_initial.yaml", path.module), {
          livez_port = 26000
        })
        ts_yaml = templatefile(format("%s/templates/big-ip/ts.yaml", path.module), {
          project_id      = var.project_id
          service_account = google_service_account.bigip.email
        })
        as3_app_yaml = templatefile(format("%s/templates/big-ip/as3_app.yaml", path.module), {
          vip         = google_compute_address.vip.address
          readyz_port = 26000
          ca_cert     = tls_self_signed_cert.ca.cert_pem
          region      = var.region
        })
      })
    })
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    google_service_account.bigip,
  ]
}

# This health check determines if the BIG-IP VE is "healthy"; it is expected to fail slowly
# so that VEs are not killed before they have a chance to onboard
resource "google_compute_health_check" "bigip_livez" {
  project             = var.project_id
  name                = format("%s-bigip-livez", var.name)
  check_interval_sec  = 60
  timeout_sec         = 2
  healthy_threshold   = 2
  unhealthy_threshold = 3
  http_health_check {
    port               = 26000
    request_path       = "/"
    response           = "OK"
    port_specification = "USE_FIXED_PORT"
  }
}

resource "google_compute_region_instance_group_manager" "bigip" {
  project            = var.project_id
  name               = format("%s-bigip", var.name)
  description        = "Example MIG to show autoscaling from Telemetry Streaming"
  base_instance_name = format("%s-bigip", var.name)
  region             = var.region
  wait_for_instances = false
  version {
    instance_template = google_compute_instance_template.bigip.self_link
  }
  auto_healing_policies {
    health_check      = google_compute_health_check.bigip_livez.id
    initial_delay_sec = 600
  }
  update_policy {
    type                           = "PROACTIVE"
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    replacement_method             = "SUBSTITUTE"
    instance_redistribution_type   = "PROACTIVE"
    max_surge_fixed                = length(data.google_compute_zones.zones.names)
    max_unavailable_fixed          = 0
  }
  instance_lifecycle_policy {
    force_update_on_repair = "YES"
  }
}

# Attach an autoscaler that uses an exported Telemetry Streaming metric.
# resource "google_compute_region_autoscaler" "bigip" {
#   project = var.project_id
#   name =  format("%s-bigip", var.name)
#   region = var.region
#   target = google_compute_region_instance_group_manager.bigip.id
#   autoscaling_policy {
#     min_replicas = 1
#     max_replicas = 5
#     cooldown_period = 600
#     mode = "ON"
#     metric {
#       name = "custom.googleapis.com/system/tmmCpu"
#       target = 50
#       type = "GAUGE"
#     }
#   }
# }

# Add a firewall rule to allow traffic from the public internet to land on the BIG-IPs.
#
# NOTE: This demo is allowing access from any source address; this should be changed
# if the exposed service is not meant to be universally available.
resource "google_compute_firewall" "public" {
  project       = var.project_id
  name          = format("%s-allow-bigip-public", var.name)
  network       = module.external.self_link
  source_ranges = length(var.permitted_cidrs) > 0 ? var.permitted_cidrs : [format("%s/32", trimspace(data.http.my_address.response_body))]
  target_service_accounts = [
    google_service_account.bigip.email,
  ]
  allow {
    protocol = "TCP"
    ports = [
      443,
      8443,
    ]
  }
}

# Add a firewall rule to allow the above health check to reach the BIG-IP instances;
# without this rule the MIG will determine the BIG-IP instances are unhealthy and
# start recreating the instances.
resource "google_compute_firewall" "bigip_livez" {
  project = var.project_id
  name    = format("%s-allow-bigip-livez", var.name)
  network = module.external.self_link
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]
  target_service_accounts = [
    google_service_account.bigip.email,
  ]
  allow {
    protocol = "TCP"
    ports = [
      26000,
    ]
  }
}

# Add a firewall rule to allow traffic from BIG-IP to the application.
resource "google_compute_firewall" "bigip_app" {
  project = var.project_id
  name    = format("%s-allow-bigip-app", var.name)
  network = module.internal.self_link
  source_service_accounts = [
    google_service_account.bigip.email,
  ]
  target_service_accounts = [
    google_service_account.app.email,
  ]
  allow {
    protocol = "TCP"
    ports = [
      8080,
      8443,
    ]
  }
}
