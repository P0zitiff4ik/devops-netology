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
write_files:
  - path: /root/.ssh/id_ed25519_base64
    permissions: '0600'
    owner: root:root
    content: |
      ${ssh_private_key_base64}
  - path: /root/.ssh/id_ed25519.pub
    permissions: '0644'
    owner: root:root
    content: |
      ${ssh_public_key}
  - path: /root/.ssh/config
    permissions: '0644'
    owner: root:root
    content: |
      Host *
        IdentityFile /root/.ssh/id_ed25519
runcmd:
  - base64 --decode /root/.ssh/id_ed25519_base64 > /root/.ssh/id_ed25519
  - chmod 600 /root/.ssh/id_ed25519
  - chmod 644 /root/.ssh/id_ed25519.pub
  - chmod 644 /root/.ssh/config