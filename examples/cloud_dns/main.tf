module "fullstory_relay" {
  source               = "../.." #TODO: change to absolute reference
  relay_fqdn           = "fsrelay.your-company.com"
  cloud_dns_zone_name  = "your-company-com"
  cloud_dns_project_id = "gcp-your-company"
}
