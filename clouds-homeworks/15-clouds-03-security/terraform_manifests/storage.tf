resource "yandex_storage_bucket" "test" {
  folder_id             = var.folder_id
  bucket                = "nbulgakov311224"
  default_storage_class = "STANDARD"
  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-a.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "yandex_storage_object" "object" {
  bucket = yandex_storage_bucket.test.id
  key    = "image.jpg"
  source = "HNY.jpg"
}
