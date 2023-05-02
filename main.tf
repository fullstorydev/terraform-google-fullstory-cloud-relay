locals {
  version           = "0.1.0" #TODO: Dynamically inject?
  create_dns_record = tobool(var.cloud_dns_zone_name != null)
  name              = "fullstory-relay"
  endpoints         = {
    edge : "edge.${var.target_fqdn}",
    rs : "rs.${var.target_fqdn}",
    services : "services.fullstory.com"
  }
}

resource "google_compute_url_map" "fullstory_relay" {

  name            = local.name
  default_service = google_compute_backend_service.fullstory_relay["rs"].id

  host_rule {
    hosts        = [var.relay_fqdn]
    path_matcher = "main"
  }

  path_matcher {
    name            = "main"
    default_service = google_compute_backend_service.fullstory_relay["rs"].id

    path_rule {
      paths   = ["/s/fs.js"]
      service = google_compute_backend_service.fullstory_relay["edge"].id
    }
    path_rule {
      paths   = ["/rec/bundle"]
      service = google_compute_backend_service.fullstory_relay["rs"].id
    }
    path_rule {
      paths   = ["/echo"]
      service = google_compute_backend_service.fullstory_relay["services"].id
    }
  }
}

resource "google_compute_managed_ssl_certificate" "fullstory_relay" {
  name = "${local.name}-${replace(var.relay_fqdn, ".", "-")}"
  managed {
    domains = [var.relay_fqdn]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_global_address" "fullstory_relay" {
  name         = local.name
  address_type = "EXTERNAL"
}

data "google_dns_managed_zone" "fullstory_relay" {
  count   = local.create_dns_record ? 1 : 0
  name    = var.cloud_dns_zone_name
  project = var.cloud_dns_project_id
}

resource "google_dns_record_set" "fullstory_relay" {
  count        = local.create_dns_record ? 1 : 0
  name         = "${var.relay_fqdn}."
  project      = var.cloud_dns_project_id
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.fullstory_relay[0].name
  rrdatas      = [
    google_compute_global_address.fullstory_relay.address,
  ]
}

resource "google_compute_global_forwarding_rule" "fullstory_relay" {
  name                  = local.name
  ip_protocol           = "TCP"
  ip_address            = google_compute_global_address.fullstory_relay.address
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_https_proxy.fullstory_relay.id
}

resource "google_compute_target_https_proxy" "fullstory_relay" {
  name             = local.name
  url_map          = google_compute_url_map.fullstory_relay.id
  ssl_certificates = [google_compute_managed_ssl_certificate.fullstory_relay.id]
}

resource "google_compute_backend_service" "fullstory_relay" {
  for_each              = local.endpoints
  name                  = "${local.name}-${each.key}"
  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTPS"
  enable_cdn            = tobool(each.key == "edge")

  custom_request_headers = [
    "X-Forwarded-Host: ${var.relay_fqdn}",
    "X-Relay-Origin: GCP",
    "X-Relay-Version: ${local.version}"
  ]

  log_config {
    enable      = true
    sample_rate = 1
  }

  backend {
    group = google_compute_global_network_endpoint_group.fullstory_relay[each.key].id
  }
}

resource "google_compute_global_network_endpoint_group" "fullstory_relay" {
  for_each              = local.endpoints
  name                  = "${local.name}-${each.key}"
  network_endpoint_type = "INTERNET_FQDN_PORT"
  default_port          = "443"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_global_network_endpoint" "fullstory_relay" {
  for_each                      = local.endpoints
  global_network_endpoint_group = google_compute_global_network_endpoint_group.fullstory_relay[each.key].id
  fqdn                          = each.value
  port                          = 443
}
