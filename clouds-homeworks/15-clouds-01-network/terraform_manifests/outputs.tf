output "public_instance_external_ip" {
  value       = yandex_compute_instance.public_instance.*.network_interface.0.nat_ip_address
  description = "ext_network_interface"
}

output "private_instance_internal_ip" {
  value       = yandex_compute_instance.private_instance.*.network_interface.0.ip_address
  description = "int_network_interface"
}
