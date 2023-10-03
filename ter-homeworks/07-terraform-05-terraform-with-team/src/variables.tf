###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

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
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "validate-test" {
  type        = list(string)
  description = "ip-адрес"
  validation {
    condition = can(cidrhost([var.validate-test], 0))

    error_message = "The IP address range is invalid. Must be of format '0.0.0.0/0'."
  }
  default = ["192.168.0.1/32", "1.1.1.1/32", "127.0.0.1/32"]
}
