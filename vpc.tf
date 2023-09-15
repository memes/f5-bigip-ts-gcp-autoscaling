#
# Creates the VPC networks used for BIG-IP external, internal, and management interfaces
#

module "external" {
  source      = "memes/multi-region-private-network/google"
  version     = "2.0.0"
  name        = format("%s-external", var.name)
  description = "External network (public facing)"
  project_id  = var.project_id
  regions = [
    var.region,
  ]
  cidrs = {
    primary_ipv4_cidr        = "10.1.0.0/16"
    primary_ipv4_subnet_size = 24
    primary_ipv6_cidr        = null
    secondaries              = null
  }
  options = {
    mtu                   = 1500
    delete_default_routes = true
    restricted_apis       = true
    routing_mode          = "REGIONAL"
    nat                   = false
    nat_tags              = null
    flow_logs             = true
    nat_logs              = true
    ipv6_ula              = false
  }
}

module "management" {
  source      = "memes/multi-region-private-network/google"
  version     = "2.0.0"
  name        = format("%s-management", var.name)
  description = "Management network (control plane)"
  project_id  = var.project_id
  regions = [
    var.region,
  ]
  cidrs = {
    primary_ipv4_cidr        = "10.2.0.0/16"
    primary_ipv4_subnet_size = 24
    primary_ipv6_cidr        = null
    secondaries              = null
  }
  options = {
    mtu                   = 1460
    delete_default_routes = true
    restricted_apis       = true
    routing_mode          = "REGIONAL"
    nat                   = true
    nat_tags = [
      "allow-mgmt-nat",
    ]
    flow_logs = true
    nat_logs  = true
    ipv6_ula  = false
  }
}

module "internal" {
  source      = "memes/multi-region-private-network/google"
  version     = "2.0.0"
  name        = format("%s-internal", var.name)
  description = "Internal network (applications)"
  project_id  = var.project_id
  regions = [
    var.region,
  ]
  cidrs = {
    primary_ipv4_cidr        = "10.3.0.0/16"
    primary_ipv4_subnet_size = 24
    primary_ipv6_cidr        = null
    secondaries              = null
  }
  options = {
    mtu                   = 1460
    delete_default_routes = true
    restricted_apis       = true
    routing_mode          = "REGIONAL"
    nat                   = true
    nat_tags = [
      "allow-int-nat",
    ]
    flow_logs = true
    nat_logs  = true
    ipv6_ula  = false
  }
}

module "restricted_apis_dns" {
  source     = "memes/restricted-apis-dns/google"
  version    = "1.2.0"
  project_id = var.project_id
  name       = format("%s-restricted-apis", var.name)
  labels     = var.labels
  network_self_links = [
    module.external.self_link,
    module.management.self_link,
    module.internal.self_link,
  ]
  depends_on = [
    module.external,
    module.management,
    module.internal,
  ]
}

module "bastion" {
  source     = "memes/private-bastion/google"
  version    = "2.3.5"
  project_id = var.project_id
  prefix     = format("%s-mgmt", var.name)
  zone       = element(data.google_compute_zones.zones.names, 0)
  subnet     = module.management.subnets_by_region[var.region].self_link
  labels     = var.labels
  tags = [
    "allow-mgmt-nat",
  ]

  # NAT is enabled on management VPC so image can be pulled directly from GitHub container registry
  proxy_container_image = "ghcr.io/memes/terraform-google-private-bastion/forward-proxy:2.3.5"

  # Add firewall to allow bastion to connect to BIG-IPs
  bastion_targets = {
    service_accounts = [
      local.bigip_sa,
    ]
    cidrs    = null
    tags     = null
    priority = null
  }
}
