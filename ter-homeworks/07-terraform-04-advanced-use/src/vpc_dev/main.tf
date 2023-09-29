terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "yandex_vpc_network" "develop" {
  name = var.env_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.env_name
  zone           = var.subnets[0].zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = [var.subnets[0].cidr]
}
