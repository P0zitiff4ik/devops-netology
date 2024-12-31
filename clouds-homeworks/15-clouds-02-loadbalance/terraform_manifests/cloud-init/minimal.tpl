#cloud-config
write_files:
  - path: /var/www/html/index.html
    content: |
      <html>
      <body>
        <img src='https://storage.yandexcloud.net/nbulgakov311224/image.jpg'>
      </body>
      </html>
    owner: root:root
    permissions: "0644"
    defer: true
runcmd:
  - [systemctl, restart, apache2]
