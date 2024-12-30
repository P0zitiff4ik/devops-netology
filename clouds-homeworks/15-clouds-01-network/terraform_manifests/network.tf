resource "yandex_vpc_network" "default" {
  name = "my-vpc"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = var.default_zone
  network_id     = yandex_vpc_network.default.id
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = var.default_zone
  network_id     = yandex_vpc_network.default.id
  route_table_id = yandex_vpc_route_table.private.id
}
