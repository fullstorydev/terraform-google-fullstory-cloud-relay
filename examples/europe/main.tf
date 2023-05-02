module "fullstory_relay" {
  source      = "../.." #TODO: change to absolute reference
  relay_fqdn  = "fsrelay.your-company.com"
  target_fqdn = "eu1.fullstory.com"
}
