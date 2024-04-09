<a href="https://fullstory.com"><img src="https://github.com/fullstorydev/terraform-google-fullstory-cloud-relay/blob/main/assets/fs-logo.png?raw=true"></a>

# terraform-google-fullstory-cloud-relay

[![GitHub release](https://img.shields.io/github/release/fullstorydev/terraform-google-fullstory-cloud-relay.svg)](https://github.com/fullstorydev/terraform-google-fullstory-cloud-relay/releases/)


This module creates a relay that allows you to route all captured fullstory traffic
from your users’ browser directly through your own domain. More information on the philosophy and 
script configuration can be found in [this KB article](https://help.fullstory.com/hc/en-us/articles/360046112593-How-to-send-captured-traffic-to-your-First-Party-Domain-using-fullstory-Relay).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.32.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_dns_project_id"></a> [cloud\_dns\_project\_id](#input\_cloud\_dns\_project\_id) | (optional) The project in which the Cloud DNS zone lives in. Defaults to provider project. | `string` | `null` | no |
| <a name="input_cloud_dns_zone_name"></a> [cloud\_dns\_zone\_name](#input\_cloud\_dns\_zone\_name) | (optional) The Cloud DNS zone name for placing the DNS A record. | `string` | `null` | no |
| <a name="input_logging_enabled"></a> [logging\_enabled](#input\_logging\_enabled) | (optional) If enabled, logging will be active on the backend service. Defaults to false. | `bool` | `false` | no |
| <a name="input_relay_fqdn"></a> [relay\_fqdn](#input\_relay\_fqdn) | The fully qualified domain name for the relay. Example: `fsrelay.your-company.com`. | `string` | n/a | yes |
| <a name="input_target_fqdn"></a> [target\_fqdn](#input\_target\_fqdn) | (optional) The fully qualified domain name that the relay targets. Defaults to `fullstory.com`. | `string` | `"fullstory.com"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_relay_ip_address"></a> [relay\_ip\_address](#output\_relay\_ip\_address) | The IP address of the relay load balancer. |

## Usage

### With Cloud DNS Record Creation

```hcl
module "fullstory_relay" {
  source               = "fullstorydev/fullstory-cloud-relay/google"
  relay_fqdn           = "fsrelay.your-company.com"
  cloud_dns_zone_name  = "your-company-com"
  cloud_dns_project_id = "gcp-your-company"
}
```

> :warning: **Note:** SSL Certificates can take 10-15 minutes to become active after creation. Errors may be returned during this time.

### Without Cloud DNS Record Creation

By default, the module will not create a DNS record in Cloud DNS. An example of which is below.

```hcl
module "fullstory_relay" {
  source     = "fullstorydev/fullstory-cloud-relay/google"
  relay_fqdn = "fsrelay.your-company.com"
}

output "relay_ip_address" {
  value = module.fullstory_relay.relay_ip_address
}
```

Once the resources have been successfully created, the IP address can be extracted from the Terraform state using the command below.

```bash
terraform output relay_ip_address
```

If the above command does not work, ensure that the `output "relay_ip_address"` block is present as shown in the example above.

Next, create an `A` DNS record that routes the `relay_fqdn` to the IP address found in the previous command.

Once the DNS record has been created, the SSL certificate can take up to 15 minutes to become active. The status can be checked using the command below.

```bash
gcloud compute ssl-certificates list
```

### European Realm Target

```hcl
module "fullstory_relay" {
  source      = "fullstorydev/fullstory-cloud-relay/google"
  relay_fqdn  = "fsrelay.your-company.com"
  target_fqdn = "eu1.fullstory.com"
}
```

### Validation
Once an instance of the fullstory Relay has been successfully created, the health endpoint at `https://<relay_fqdn>/healthz` should return a `200 OK`.

## Resources

| Name | Type |
|------|------|
| [google_compute_backend_service.fullstory_relay](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_global_address.fullstory_relay](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_global_forwarding_rule.fullstory_relay](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_global_network_endpoint.fullstory_relay](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_network_endpoint) | resource |
| [google_compute_global_network_endpoint_group.fullstory_relay](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_network_endpoint_group) | resource |
| [google_compute_managed_ssl_certificate.fullstory_relay](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_managed_ssl_certificate) | resource |
| [google_compute_target_https_proxy.fullstory_relay](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) | resource |
| [google_compute_url_map.fullstory_relay](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |
| [google_dns_record_set.fullstory_relay](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_managed_zone.fullstory_relay](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/dns_managed_zone) | data source |
<!-- END_TF_DOCS -->

## Troubleshooting

This module includes a troubleshooting endpoint that can be used to debug any communications issues. The endpoint can be found out `https://<relay_fqdn>/echo` and returns the headers of the request.

## Contributing
See [CONTRIBUTING.md](https://github.com/fullstorydev/terraform-google-fullstory-cloud-relay/blob/main/.github/CONTRIBUTING.md) for best practices and instructions on setting up your dev environment.
