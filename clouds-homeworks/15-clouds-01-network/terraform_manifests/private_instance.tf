resource "yandex_compute_instance" "private_instance" {
  name        = "private-instance"
  platform_id = var.platform
  zone        = yandex_vpc_subnet.private.zone

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd83r8l1erja63002a2h"
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
  }

  metadata = {
    user-data          = templatefile("${path.module}/cloud-init/minimal.tpl", {
      ssh_public_key = local.ssh_public_key
      })
    serial-port-enable = 1
  }

  depends_on = [yandex_vpc_route_table.private]
}
