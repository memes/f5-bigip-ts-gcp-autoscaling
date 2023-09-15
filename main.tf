terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.82"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }
}

data "google_compute_zones" "zones" {
  project = var.project_id
  region  = var.region
}

# Reserve a public IP address for the VIP
resource "google_compute_address" "vip" {
  project      = var.project_id
  name         = var.name
  region       = var.region
  description  = "Public IPv4 address for Telemetry Streaming autoscaling example"
  address_type = "EXTERNAL"
}
