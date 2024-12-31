resource "yandex_storage_bucket" "test" {
  bucket                = "nbulgakov311224"
  default_storage_class = "STANDARD"
  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }
}

resource "yandex_storage_object" "object" {
  bucket = yandex_storage_bucket.test.id
  key    = "image.jpg"
  source = "HNY.jpg"
}

