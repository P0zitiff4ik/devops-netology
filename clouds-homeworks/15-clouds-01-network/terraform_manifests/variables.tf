variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-d"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "platform" {
  type        = string
  default     = "standard-v2"
  description = "https://cloud.yandex.ru/docs/compute/concepts/platforms"
}

variable "ssh_public_key_path" {
  default     = "~/.ssh/id_ed25519.pub"
}