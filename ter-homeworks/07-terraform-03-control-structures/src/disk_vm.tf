resource "yandex_compute_disk" "default" {
  count      = 3
  name       = "disk-${count.index}"
  type       = var.vm_min_resource.disk_type
  zone       = var.default_zone
  image_id   = data.yandex_compute_image.ubuntu-2004-lts.image_id
  size       = 5
  block_size = 4096
  labels = {
    environment = "test"
  }
}

resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = var.vm_min_resource.platform

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

  dynamic "secondary_disk" {
    for_each = { for n in yandex_compute_disk.default[*] : n.name => n }
    content {
      disk_id = secondary_disk.value.id
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
