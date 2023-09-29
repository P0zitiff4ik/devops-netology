variable "subnets" {
  type    = tuple([object({ zone = string, cidr = string })])
  default = [{ zone = "ru-central1-a", cidr = "10.0.1.0/24" }]

}

# variable "zone" {
#   type        = string
#   default     = "ru-central1-a"
#   description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
# }
# variable "cidr" {
#   type        = list(string)
#   default     = ["10.0.1.0/24"]
#   description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
# }

variable "env_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

# variable "vpc_network_id" {
#   type = string
# }
