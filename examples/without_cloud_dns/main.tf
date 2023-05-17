module "fullstory_relay" {
  source     = "fullstorydev/fullstory-cloud-relay/google"
  relay_fqdn = "fsrelay.your-company.com"
}

output "relay_ip_address" {
  value = module.fullstory_relay.relay_ip_address
}
