resource "yandex_compute_instance_group" "ig-lamp" {
  name               = "lamp-instance-group"
  service_account_id = var.account_id
  folder_id          = var.folder_id
  instance_template {
    platform_id = var.platform
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
        image_id = "fd827b91d99psvq5fjit"
        type     = "network-ssd"
        size     = 10
      }
    }
    network_interface {
      network_id = yandex_vpc_network.default.id
      subnet_ids = [yandex_vpc_subnet.private.id]
    }

    metadata = {
      user-data = templatefile("${path.module}/cloud-init/minimal.tpl")
      serial-port-enable = 1
    }
  }
  scale_policy {
    fixed_scale {
      size = 3
    }
  }
  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }
  allocation_policy {
    zones = ["ru-central1-d"]
  }
  load_balancer {
    target_group_name        = "target-group"
    target_group_description = "Целевая группа Network Load Balancer"
  }

  health_check {
    http_options {
      path = "/"
      port = 80
    }
  }
}
