resource "yandex_compute_instance" "web" {
  name        = "web-${count.index + 1}"
  platform_id = var.vm_min_resource.platform
  count       = 2

  resources {
    cores         = var.vm_min_resource.resources.cores
    memory        = var.vm_min_resource.resources.ram
    core_fraction = var.vm_min_resource.resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type     = var.vm_min_resource.disk_type
      size     = var.vm_min_resource.disk_size
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
