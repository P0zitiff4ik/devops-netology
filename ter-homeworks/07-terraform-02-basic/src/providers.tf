terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"
}

## вместо ключа ssh использую ключ доступа в файле

provider "yandex" {
  service_account_key_file = "~/secret/yc-admin-key.json"
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
}
