variable "relay_fqdn" {
  type        = string
  description = "The fully qualified domain name for the relay. Example: `fsrelay.your-company.com`."
}

variable "target_fqdn" {
  type        = string
  description = "(optional) The fully qualified domain name that the relay targets. Defaults to `fullstory.com`."
  default     = "fullstory.com"
}

variable "cloud_dns_zone_name" {
  type        = string
  description = "(optional) The Cloud DNS zone name for placing the DNS A record."
  default     = null
}

variable "cloud_dns_project_id" {
  type        = string
  description = "(optional) The project in which the Cloud DNS zone lives in. Defaults to provider project."
  default     = null
}
