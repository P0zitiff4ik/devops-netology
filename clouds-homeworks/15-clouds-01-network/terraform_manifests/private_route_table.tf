resource "yandex_vpc_route_table" "private" {
  network_id = yandex_vpc_network.default.id
  name = "private-route-table"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat_instance.network_interface.0.ip_address
  }
}