# resource "yandex_vpc_network" "develop" {
#   name = var.vpc_name
# }
# resource "yandex_vpc_subnet" "develop" {
#   name           = var.vpc_name
#   zone           = var.default_zone
#   network_id     = yandex_vpc_network.develop.id
#   v4_cidr_blocks = var.default_cidr
# }

module "vpc_dev" {
  source   = "./vpc_dev"
  env_name = "develop"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
  ]
  # zone = "ru-central1-a"
  # cidr = ["10.0.1.0/24"]
}

module "vpc_prod" {
  source   = "./vpc_dev"
  env_name = "production"
  subnets = [[
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", cidr = "10.0.2.0/24" },
    { zone = "ru-central1-c", cidr = "10.0.3.0/24" },
  ]]
}


module "test-vm" {
  source       = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name     = "develop"
  network_id   = module.vpc_dev.vpc_network_id
  subnet_zones = [module.vpc_dev.vpc_zone]
  subnet_ids   = [module.vpc_dev.vpc_subnet_id]
  # network_id     = yandex_vpc_network.develop.id
  # subnet_zones   = ["ru-central1-a"]
  # subnet_ids     = [yandex_vpc_subnet.develop.id]
  instance_name  = "web"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = 1
  }

}

data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")

  vars = {
    ssh_public_key = ("${file("~/.ssh/id_ed25519.pub")}")
  }
}
