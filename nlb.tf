# This health check determines if the BIG-IP VE is "ready" to accept traffic from
# Google's front end; it is expected to fail and recover *fast* so that the
# user experience is optimal.
resource "google_compute_region_health_check" "readyz" {
  project             = var.project_id
  name                = format("%s-readyz", var.name)
  region              = var.region
  check_interval_sec  = 5
  timeout_sec         = 1
  healthy_threshold   = 2
  unhealthy_threshold = 2
  http_health_check {
    port               = 26000
    request_path       = "/"
    response           = "OK"
    port_specification = "USE_FIXED_PORT"
  }
}

# Add a firewall rule to allow the above health check to reach the BIG-IP instances;
# without this rule the Google front end will determine the BIG-IP instances are not
# ready to recieve data plane traffic.
#
# NOTE: This is similar to (and overlaps with) the "livez" firewall rule but has
# some different source CIDRs used by NLB checks.
resource "google_compute_firewall" "readyz" {
  project = var.project_id
  name    = format("%s-allow-readyz", var.name)
  network = module.external.self_link
  source_ranges = [
    "35.191.0.0/16",
    "209.85.152.0/22",
    "209.85.204.0/22",
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

# Create a backend service for the BIG-IP cluster.
resource "google_compute_region_backend_service" "bigip" {
  project               = var.project_id
  name                  = var.name
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "EXTERNAL"
  health_checks = [
    google_compute_region_health_check.readyz.id,
  ]
  backend {
    group = google_compute_region_instance_group_manager.bigip.instance_group
  }
}

# Finally, tie the reserved public IPv4 address to this forwarding rule; all
# matching packes will be sent to the backend service defined above.
resource "google_compute_forwarding_rule" "nlb" {
  project     = var.project_id
  name        = var.name
  region      = var.region
  ip_address  = google_compute_address.vip.address
  ip_protocol = "TCP"
  ports = [
    443,
    8443,
  ]
  load_balancing_scheme = "EXTERNAL"
  labels                = var.labels
  backend_service       = google_compute_region_backend_service.bigip.id
}
