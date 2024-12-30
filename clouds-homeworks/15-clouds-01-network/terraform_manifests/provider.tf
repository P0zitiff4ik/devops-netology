terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">=0.99"
    }
    template = {
      version = "~> 2.0"
    }
  }
  required_version = ">=0.13"
}

provider "yandex" {
  service_account_key_file = file("~/secret/yc-admin-key.json")
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
}
