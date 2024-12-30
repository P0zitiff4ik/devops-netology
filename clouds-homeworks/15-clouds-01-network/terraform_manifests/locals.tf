locals {
  ssh_public_key  = file(var.ssh_public_key_path)
  ssh_private_key_base64  = file(var.ssh_private_key_base64_path)
}
