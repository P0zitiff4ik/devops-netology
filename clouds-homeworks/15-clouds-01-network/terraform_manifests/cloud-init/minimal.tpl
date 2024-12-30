#cloud-config
groups:
  - admingroup: [root, sys]
  - cloud-users
ssh_pwauth: false
ssh_deletekeys: false
users:
  - name: root
    groups: sudo, users
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    ssh_authorized_keys:
      - ${ssh_public_key}
