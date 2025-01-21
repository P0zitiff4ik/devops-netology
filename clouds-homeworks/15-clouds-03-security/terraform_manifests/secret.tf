resource "yandex_kms_symmetric_key" "key-a" {
  name              = "key-a"
  description       = "Ключ для ДЗ 15-3"
  default_algorithm = "AES_128"
  rotation_period   = "8760h"
}

resource "yandex_lockbox_secret" "netology-secret" {
  name                = "netology-secret"
  description         = "Секрет для ДЗ 15-3"
  folder_id           = var.folder_id
  kms_key_id          = yandex_kms_symmetric_key.key-a.id
  deletion_protection = false
}

resource "yandex_lockbox_secret_version_hashed" "my_version" {
  secret_id = yandex_lockbox_secret.netology-secret.id

  key_1        = "key_1"
  text_value_1 = file("${path.module}/certs/www.netology.pozitiff4ik.ru.key")
}


resource "yandex_cm_certificate" "netology-lockbox" {
  name = "netology-lockbox"

  self_managed {
    certificate = file("${path.module}/certs/www.netology.pozitiff4ik.ru.crt")
    private_key_lockbox_secret {
      id  = yandex_lockbox_secret.netology-secret.id
      key = yandex_lockbox_secret_version_hashed.my_version.key_1
    }
  }
}
