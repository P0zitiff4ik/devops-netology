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
}

resource "yandex_lb_network_load_balancer" "network-lb" {
  name = "network-lb"
  listener {
    name = "http"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_compute_instance_group.ig-lamp.load_balancer.0.target_group_id
    healthcheck {
      name = "healthcheck"
      http_options {
        path = "/"
        port = 80
      }
    }
  }
}
