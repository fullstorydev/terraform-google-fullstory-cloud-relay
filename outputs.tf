output "relay_ip_address" {
  description = "The IP address of the relay load balancer."
  value       = google_compute_global_address.fullstory_relay.address
}
