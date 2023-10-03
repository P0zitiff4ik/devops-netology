variable "vm_resource" {
  type = list(object({ vm_name = string, cpu = number, ram = number, disk = number, core_fraction = number }))
  default = [
    { vm_name = "main", cpu = 4, ram = 2, disk = 15, core_fraction = 20 },
    { vm_name = "replica", cpu = 2, ram = 1, disk = 10, core_fraction = 5 }
  ]
}

resource "yandex_compute_instance" "db" {
  for_each    = { for v in var.vm_resource : index(var.vm_resource, v) => v }
  name        = each.value.vm_name
  platform_id = "standard-v1"

  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type     = "network-hdd"
      size     = each.value.disk
    }
  }

  metadata = local.metadata

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }
  allow_stopping_for_update = true
}
