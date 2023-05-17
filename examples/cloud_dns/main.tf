module "fullstory_relay" {
  source               = "fullstorydev/fullstory-cloud-relay/google"
  relay_fqdn           = "fsrelay.your-company.com"
  cloud_dns_zone_name  = "your-company-com"
  cloud_dns_project_id = "gcp-your-company"
}
