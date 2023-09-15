data "google_compute_image" "default" {
  project = "cos-cloud"
  family  = "cos-stable"
}

# Define a service account for the backend application
resource "google_service_account" "app" {
  project      = var.project_id
  account_id   = format("%s-app", var.name)
  display_name = "Application service account"
}

# Give the app service account minimal project permissions
resource "google_project_iam_member" "app" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ])
  project = var.project_id
  role    = each.value
  member  = google_service_account.app.member

  depends_on = [
    google_service_account.app,
  ]
}

# Defines a template for application instances under a MIG
resource "google_compute_instance_template" "app" {
  project              = var.project_id
  name_prefix          = format("%s-app-", var.name)
  description          = "Application instance template"
  instance_description = "Application instance"
  region               = var.region
  labels = merge(var.labels, {
    service = "pi"
  })
  tags = [
    "allow-int-nat",
  ]

  machine_type = "e2-medium"
  scheduling {
    automatic_restart   = true
    on_host_maintenance = ""
    preemptible         = false
  }

  advanced_machine_features {
    enable_nested_virtualization = false
  }

  service_account {
    email = google_service_account.app.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  disk {
    auto_delete  = true
    boot         = true
    source_image = data.google_compute_image.default.self_link
    disk_type    = "pd-balanced"
    disk_size_gb = 20
    labels       = var.labels
  }

  network_interface {
    subnetwork = module.internal.subnets_by_region[var.region].self_link
    nic_type   = "VIRTIO_NET"
    stack_type = "IPV4_ONLY"
  }

  metadata = {
    enable-oslogin = "TRUE"
    user-data = templatefile(format("%s/templates/application/cloud-config.yaml", path.module), {
      ca_pem   = tls_self_signed_cert.ca.cert_pem
      cert_pem = tls_locally_signed_cert.app.cert_pem
      key_pem  = tls_private_key.app.private_key_pem
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    google_service_account.app,
  ]
}

# This health check determines if the application VE is "healthy"; it is expected to fail slowly
# so that VEs are not killed before they have a chance to onboard.
resource "google_compute_health_check" "app_livez" {
  project             = var.project_id
  name                = format("%s-app-livez", var.name)
  check_interval_sec  = 60
  timeout_sec         = 2
  healthy_threshold   = 2
  unhealthy_threshold = 3
  # gRPC check is failing
  tcp_health_check {
    port               = 8443
    port_specification = "USE_FIXED_PORT"
  }
  # grpc_health_check {
  #   port = 8443
  #   grpc_service_name = "grpc.health.v1.Health.Check"
  #   port_specification = "USE_FIXED_PORT"
  # }
  log_config {
    enable = false
  }
}

# Add a firewall rule to allow the above health check to reach the BIG-IP instances;
# without this rule the MIG will determine the BIG-IP instances are unhealthy and
# start recreating the instances.
resource "google_compute_firewall" "app_livez" {
  project = var.project_id
  name    = format("%s-allow-app-livez", var.name)
  network = module.internal.self_link
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]
  target_service_accounts = [
    google_service_account.app.email,
  ]
  allow {
    protocol = "TCP"
    ports = [
      8443,
    ]
  }

  depends_on = [
    google_service_account.app,
  ]
}

resource "google_compute_region_instance_group_manager" "app" {
  project            = var.project_id
  name               = format("%s-app", var.name)
  description        = "Backend application"
  base_instance_name = format("%s-app", var.name)
  region             = var.region
  wait_for_instances = false
  version {
    instance_template = google_compute_instance_template.app.self_link
  }
  auto_healing_policies {
    health_check      = google_compute_health_check.app_livez.id
    initial_delay_sec = 30
  }
  update_policy {
    type                           = "PROACTIVE"
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    replacement_method             = "SUBSTITUTE"
    instance_redistribution_type   = "PROACTIVE"
    max_surge_fixed                = length(data.google_compute_zones.zones.names)
    max_unavailable_fixed          = length(data.google_compute_zones.zones.names)
  }
  instance_lifecycle_policy {
    force_update_on_repair = "YES"
  }
}

# Attach an autoscaler for the application
resource "google_compute_region_autoscaler" "app" {
  project = var.project_id
  name    = format("%s-app", var.name)
  region  = var.region
  target  = google_compute_region_instance_group_manager.app.id
  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 5
    cooldown_period = 30
    mode            = "ON"
    # PiService is usually CPU bound, so use default metric for autoscaling
    cpu_utilization {
      target = 0.5
    }
  }
}

# Allow IAP access to application for debugging.
resource "google_compute_firewall" "iap" {
  project = var.project_id
  name    = format("%s-allow-app-iap", var.name)
  network = module.internal.self_link
  source_ranges = [
    "35.235.240.0/20",
  ]
  target_service_accounts = [
    google_service_account.app.email,
  ]
  allow {
    protocol = "TCP"
    ports = [
      22,
    ]
  }

  depends_on = [
    google_service_account.app,
  ]
}
