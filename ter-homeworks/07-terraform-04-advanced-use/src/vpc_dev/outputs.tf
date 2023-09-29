output "vpc_network_id" {
  value = yandex_vpc_network.develop.id
}

output "vpc_subnet_id" {
  value = yandex_vpc_subnet.develop.id
}

output "vpc_zone" {
  value = yandex_vpc_subnet.develop.zone
}

output "vpc_network_name" {
  value = yandex_vpc_network.develop.name
}

output "vpc_subnet_name" {
  value = yandex_vpc_subnet.develop.name
}

output "vpc_subnet_cidr" {
  value = yandex_vpc_subnet.develop.v4_cidr_blocks
}
