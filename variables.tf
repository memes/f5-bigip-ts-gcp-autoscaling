variable "project_id" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id variable must must be 6 to 30 lowercase letters, digits, or hyphens; it must start with a letter and cannot end with a hyphen."
  }
  description = <<-EOD
  The GCP project identifier where the VPC network will be created.
  EOD
}

variable "name" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,53}[a-z0-9]$", var.name))
    error_message = "The name variable must be RFC1035 compliant, between 1 and 55 characters in length, and ending in alphanumeric character."
  }
  default     = "restricted"
  description = <<-EOD
  The name to use when creating resources managed by this module, when combined with a random suffix.
  Must be RFC1035 compliant, between 1 and 55 characters in length, and end with an alphanumeric character.
  EOD
}

variable "region" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[a-z]{2,}-[a-z]{2,}[0-9]$", var.region))
    error_message = "The region variable must be a valid Google Cloud region name."
  }
  description = <<-EOD
  The Compute Engine region where the resources will be created.
  EOD
}

variable "image" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^(?:https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/global/images/[a-z][a-z0-9-]{0,61}[a-z0-9]", var.image))
    error_message = "The image variable must be a fully-qualified URI."
  }
  default     = "projects/f5-7626-networks-public/global/images/f5-bigip-17-1-0-2-0-0-2-payg-good-25mbps-230616041956"
  description = <<-EOD
The self-link URI for a BIG-IP image to use as a base for the VM cluster. This
can be an official F5 image from GCP Marketplace, or a customized image.
EOD
}

variable "labels" {
  type     = map(string)
  nullable = false
  validation {
    # GCP resource labels must be lowercase alphanumeric, underscore or hyphen,
    # and the key must be <= 63 characters in length
    condition     = length(compact([for k, v in var.labels : can(regex("^[a-z][a-z0-9_-]{0,62}$", k)) && can(regex("^[a-z0-9_-]{0,63}$", v)) ? "x" : ""])) == length(keys(var.labels))
    error_message = "Each label key:value pair must match expectations."
  }
  default     = {}
  description = <<-EOD
  An optional map of key:value string pairs that will be added to resources that accept labels.
  EOD
}

variable "tags" {
  type     = set(string)
  nullable = false
  validation {
    condition     = length(compact([for tag in var.tags : can(regex("^[a-z][a-z0-9-]{0,53}[a-z0-9]$", tag)) ? "x" : ""])) == length(var.tags)
    error_message = "Each tag value must match expectations."
  }
  default     = []
  description = <<-EOD
  An optional set of network tags to apply to the BIG-IP instances.
  EOD
}

variable "admin_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = <<-EOD
  The admin user password to embed in a Google Secret Manager secret.
  EOD
}

variable "ssh_keys" {
  type        = set(string)
  nullable    = false
  default     = []
  description = <<-EOD
  An optional set of SSH public keys to install on the BIG-IP instances.
  EOD
}

variable "domain_name" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^(?:[a-z][a-z0-9-]{0,62}\\.)+[a-z][a-z0-9-]{0,62}$", var.domain_name))
    error_message = "The domain_name must be a valid DNS name."
  }
  default     = "example.com"
  description = <<-EOD
  The DNS domain name to use when onboarding BIG-IP and generating TLS certificates. Default is 'example.com'.
  EOD
}

variable "permitted_cidrs" {
  type        = set(string)
  nullable    = false
  default     = []
  description = <<-EOD
  An optional set of CIDRs that will be allowed to access the service through the VIP; e.g.
  permitted_cidrs = ["0.0.0.0/0"] would allow anyone to access the published services through
  BIG-IP. Default is an empty set which will trigger the use of detected IPv4 address of module user.
  EOD
}

variable "health_check_port" {
  type     = number
  nullable = false
  validation {
    condition     = floor(var.health_check_port) == var.health_check_port && var.health_check_port > 0 && var.health_check_port < 65536
    error_message = "The health_check_port must be an integer between 1 and 65535 inclusive."
  }
  default     = 26000
  description = <<-EOD
  The TCP port to use for Google health check(s). A BIG-IP virtual server must be listening on this port configured to
  respond with 200 when alive and/or ready.
  Default value is 26000.
  EOD
}
