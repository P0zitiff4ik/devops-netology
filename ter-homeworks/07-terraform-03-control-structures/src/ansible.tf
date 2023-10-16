resource "local_file" "ansible_inventory" {
  content = templatefile(
    "${abspath(path.module)}/hosts.tftpl",
    {
      webservers = [for i in yandex_compute_instance.web : i]
      databases  = [for k, v in yandex_compute_instance.db : v]
      storage    = tolist([yandex_compute_instance.storage])
    }
  )
  filename = "${abspath(path.module)}/hosts.cfg"
}

resource "null_resource" "web_hosts_provision" {
  #Ждем создания инстанса
  depends_on = [yandex_compute_instance.db, yandex_compute_instance.storage, yandex_compute_instance.web]

  #Добавление ПРИВАТНОГО ssh ключа в ssh-agent
  provisioner "local-exec" {
    command = "cat ~/.ssh/id_rsa | ssh-add -"
  }

  #Запуск ansible-playbook
  provisioner "local-exec" {
    command     = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/hosts.cfg --limit 'webservers' ${abspath(path.module)}/test.yml"
    on_failure  = continue #Продолжить выполнение terraform pipeline в случае ошибок
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
    #срабатывание триггера при изменении переменных
  }
  triggers = {
    always_run        = "${timestamp()}"                         #всегда т.к. дата и время постоянно изменяются
    playbook_src_hash = file("${abspath(path.module)}/test.yml") # при изменении содержимого playbook файла
    ssh_public_key    = local.metadata.ssh-keys                  # при изменении переменной
  }

}
