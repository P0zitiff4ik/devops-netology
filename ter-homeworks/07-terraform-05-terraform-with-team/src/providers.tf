terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"
  
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket   = "tfstate-netology-1"
    region   = "ru-central1"
    key      = "terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true

    dynamodb_endpoint = "https://docapi.serverless.yandexcloud.net/ru-central1/b1g905jcf2o5pj39cg09/etn5b2ql3nfsdilf6hba"
    dynamodb_table    = "tfstate-1"
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}