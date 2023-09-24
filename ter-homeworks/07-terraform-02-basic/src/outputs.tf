output "web_external_ip_address" {
  value       = yandex_compute_instance.web.network_interface[0].nat_ip_address
  description = "web external ip"
}

output "db_external_ip_address" {
  value       = yandex_compute_instance.db.network_interface[0].nat_ip_address
  description = "db external ip"
}
