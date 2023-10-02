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

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.82 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.3 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_admin_password"></a> [admin\_password](#module\_admin\_password) | memes/secret-manager/google | 2.1.1 |
| <a name="module_bastion"></a> [bastion](#module\_bastion) | memes/private-bastion/google | 2.3.5 |
| <a name="module_external"></a> [external](#module\_external) | memes/multi-region-private-network/google | 2.0.0 |
| <a name="module_internal"></a> [internal](#module\_internal) | memes/multi-region-private-network/google | 2.0.0 |
| <a name="module_management"></a> [management](#module\_management) | memes/multi-region-private-network/google | 2.0.0 |
| <a name="module_restricted_apis_dns"></a> [restricted\_apis\_dns](#module\_restricted\_apis\_dns) | memes/restricted-apis-dns/google | 1.2.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.vip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.app_livez](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.bigip_app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.bigip_livez](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.iap](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.readyz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_forwarding_rule.nlb](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_health_check.app_livez](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_health_check.bigip_livez](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_instance_template.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_compute_instance_template.bigip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_compute_region_autoscaler.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_autoscaler) | resource |
| [google_compute_region_backend_service.bigip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) | resource |
| [google_compute_region_health_check.readyz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check) | resource |
| [google_compute_region_instance_group_manager.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) | resource |
| [google_compute_region_instance_group_manager.bigip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) | resource |
| [google_project_iam_member.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.bigip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.bigip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [tls_cert_request.app](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.app](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.app](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [google_compute_image.bigip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_compute_image.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_compute_zones.zones](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [http_http.my_address](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The admin user password to embed in a Google Secret Manager secret. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project identifier where the VPC network will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The Compute Engine region where the resources will be created. | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The DNS domain name to use when onboarding BIG-IP and generating TLS certificates. Default is 'example.com'. | `string` | `"example.com"` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | The TCP port to use for Google health check(s). A BIG-IP virtual server must be listening on this port configured to<br>respond with 200 when alive and/or ready.<br>Default value is 26000. | `number` | `26000` | no |
| <a name="input_image"></a> [image](#input\_image) | The self-link URI for a BIG-IP image to use as a base for the VM cluster. This<br>can be an official F5 image from GCP Marketplace, or a customized image. | `string` | `"projects/f5-7626-networks-public/global/images/f5-bigip-17-1-0-2-0-0-2-payg-good-25mbps-230616041956"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional map of key:value string pairs that will be added to resources that accept labels. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | The name to use when creating resources managed by this module, when combined with a random suffix.<br>Must be RFC1035 compliant, between 1 and 55 characters in length, and end with an alphanumeric character. | `string` | `"restricted"` | no |
| <a name="input_permitted_cidrs"></a> [permitted\_cidrs](#input\_permitted\_cidrs) | An optional set of CIDRs that will be allowed to access the service through the VIP; e.g.<br>permitted\_cidrs = ["0.0.0.0/0"] would allow anyone to access the published services through<br>BIG-IP. Default is an empty set which will trigger the use of detected IPv4 address of module user. | `set(string)` | `[]` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | An optional set of SSH public keys to install on the BIG-IP instances. | `set(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | An optional set of network tags to apply to the BIG-IP instances. | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_commands"></a> [bastion\_commands](#output\_bastion\_commands) | n/a |
| <a name="output_vip"></a> [vip](#output\_vip) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html no-bare-urls -->
