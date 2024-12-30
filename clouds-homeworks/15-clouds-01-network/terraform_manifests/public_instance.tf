resource "yandex_compute_instance" "public_instance" {
  name        = "public-instance"
  platform_id = var.platform
  zone        = yandex_vpc_subnet.public.zone
  scheduling_policy {
    preemptible = true
  }

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
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    user-data          = templatefile("${path.module}/cloud-init/minimal.tpl", {
      ssh_public_key = local.ssh_public_key
      })
    serial-port-enable = 1
  }

  allow_stopping_for_update = true
}
