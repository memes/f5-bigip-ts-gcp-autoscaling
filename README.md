# Autoscaling BIG-IP in Google Cloud using Telemetry Streaming

![GitHub release](https://img.shields.io/github/v/release/memes/f5-bigip-ts-gcp-autoscaling?sort=semver)
![Maintenance](https://img.shields.io/maintenance/yes/2023)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

TBA

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for guidelines.

<!-- markdownlint-disable no-inline-html no-bare-urls -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5)

- <a name="requirement_google"></a> [google](#requirement\_google) (>= 4.82)

- <a name="requirement_http"></a> [http](#requirement\_http) (>= 3.3)

- <a name="requirement_tls"></a> [tls](#requirement\_tls) (>= 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_google"></a> [google](#provider\_google) (4.83.0)

- <a name="provider_http"></a> [http](#provider\_http) (3.4.0)

- <a name="provider_tls"></a> [tls](#provider\_tls) (4.0.4)

## Modules

The following Modules are called:

### <a name="module_admin_password"></a> [admin\_password](#module\_admin\_password)

Source: memes/secret-manager/google

Version: 2.1.1

### <a name="module_bastion"></a> [bastion](#module\_bastion)

Source: memes/private-bastion/google

Version: 2.3.5

### <a name="module_external"></a> [external](#module\_external)

Source: memes/multi-region-private-network/google

Version: 2.0.0

### <a name="module_internal"></a> [internal](#module\_internal)

Source: memes/multi-region-private-network/google

Version: 2.0.0

### <a name="module_management"></a> [management](#module\_management)

Source: memes/multi-region-private-network/google

Version: 2.0.0

### <a name="module_restricted_apis_dns"></a> [restricted\_apis\_dns](#module\_restricted\_apis\_dns)

Source: memes/restricted-apis-dns/google

Version: 1.2.0

## Resources

The following resources are used by this module:

- [google_compute_address.vip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) (resource)
- [google_compute_firewall.app_livez](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) (resource)
- [google_compute_firewall.bigip_app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) (resource)
- [google_compute_firewall.bigip_livez](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) (resource)
- [google_compute_firewall.iap](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) (resource)
- [google_compute_firewall.public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) (resource)
- [google_compute_firewall.readyz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) (resource)
- [google_compute_forwarding_rule.nlb](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) (resource)
- [google_compute_health_check.app_livez](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) (resource)
- [google_compute_health_check.bigip_livez](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) (resource)
- [google_compute_instance_template.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) (resource)
- [google_compute_instance_template.bigip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) (resource)
- [google_compute_region_autoscaler.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_autoscaler) (resource)
- [google_compute_region_backend_service.bigip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) (resource)
- [google_compute_region_health_check.readyz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check) (resource)
- [google_compute_region_instance_group_manager.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) (resource)
- [google_compute_region_instance_group_manager.bigip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) (resource)
- [google_project_iam_member.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) (resource)
- [google_project_iam_member.bigip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) (resource)
- [google_service_account.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) (resource)
- [google_service_account.bigip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) (resource)
- [tls_cert_request.app](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) (resource)
- [tls_locally_signed_cert.app](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) (resource)
- [tls_private_key.app](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) (resource)
- [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) (resource)
- [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) (resource)
- [google_compute_image.bigip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) (data source)
- [google_compute_image.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) (data source)
- [google_compute_zones.zones](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) (data source)
- [http_http.my_address](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password)

Description: The admin user password to embed in a Google Secret Manager secret.

Type: `string`

### <a name="input_project_id"></a> [project\_id](#input\_project\_id)

Description: The GCP project identifier where the VPC network will be created.

Type: `string`

### <a name="input_region"></a> [region](#input\_region)

Description: The Compute Engine region where the resources will be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name)

Description: The DNS domain name to use when onboarding BIG-IP and generating TLS certificates. Default is 'example.com'.

Type: `string`

Default: `"example.com"`

### <a name="input_image"></a> [image](#input\_image)

Description: The self-link URI for a BIG-IP image to use as a base for the VM cluster. This
can be an official F5 image from GCP Marketplace, or a customized image.

Type: `string`

Default: `"projects/f5-7626-networks-public/global/images/f5-bigip-17-1-0-2-0-0-2-payg-good-25mbps-230616041956"`

### <a name="input_labels"></a> [labels](#input\_labels)

Description: An optional map of key:value string pairs that will be added to resources that accept labels.

Type: `map(string)`

Default: `{}`

### <a name="input_name"></a> [name](#input\_name)

Description: The name to use when creating resources managed by this module, when combined with a random suffix.
Must be RFC1035 compliant, between 1 and 55 characters in length, and end with an alphanumeric character.

Type: `string`

Default: `"restricted"`

### <a name="input_permitted_cidrs"></a> [permitted\_cidrs](#input\_permitted\_cidrs)

Description: An optional set of CIDRs that will be allowed to access the service through the VIP; e.g.
permitted\_cidrs = ["0.0.0.0/0"] would allow anyone to access the published services through
BIG-IP. Default is an empty set which will trigger the use of detected IPv4 address of module user.

Type: `set(string)`

Default: `[]`

### <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys)

Description: An optional set of SSH public keys to install on the BIG-IP instances.

Type: `set(string)`

Default: `[]`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: An optional set of network tags to apply to the BIG-IP instances.

Type: `set(string)`

Default: `[]`

## Outputs

The following outputs are exported:

### <a name="output_bastion_commands"></a> [bastion\_commands](#output\_bastion\_commands)

Description: n/a

### <a name="output_vip"></a> [vip](#output\_vip)

Description: n/a
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html no-bare-urls -->
