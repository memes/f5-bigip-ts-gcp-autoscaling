# Create a CA for TLS certificates; enforcing TLS end-to-end helps trigger autoscaling
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem
  subject {
    common_name         = "F5 BIG-IP autoscaling with Telemetry Streaming CA"
    organization        = "F5, Inc."
    organizational_unit = "Demos"
    locality            = "Seattle"
    province            = "Washington"
    country             = "US"
  }
  validity_period_hours = 720
  early_renewal_hours   = 2
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
  ]
}

# Create a TLS certificate and key for the backend application
resource "tls_private_key" "app" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "app" {
  private_key_pem = tls_private_key.app.private_key_pem
  subject {
    common_name         = "PiService"
    organization        = "F5, Inc."
    organizational_unit = "Demos"
    locality            = "Seattle"
    province            = "Washington"
    country             = "US"
  }
  dns_names = [
    format("*.%s", var.domain_name),
    var.domain_name,
    format("*.c.%s.internal", var.project_id),
    "localhost",
    "localhost.localdomain",
  ]
}

resource "tls_locally_signed_cert" "app" {
  cert_request_pem      = tls_cert_request.app.cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 720
  early_renewal_hours   = 2
  is_ca_certificate     = false
  allowed_uses = [
    "key_encipherment",
    "server_auth",
  ]
}
