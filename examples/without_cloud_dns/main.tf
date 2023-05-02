module "fullstory_relay" {
  source     = "../.." #TODO: change to absolute reference
  relay_fqdn = "fsrelay.your-company.com"
}

output "relay_ip_address" {
  value = module.fullstory_relay.relay_ip_address
}
