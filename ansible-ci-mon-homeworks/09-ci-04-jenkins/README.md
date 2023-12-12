[Задание](https://github.com/netology-code/mnt-homeworks/blob/4fb67230c6762d687576b31f10b3833f6a140be6/09-ci-04-jenkins/README.md)

---

# Домашнее задание к занятию 10 «Jenkins»

<details><summary>

## Подготовка к выполнению

</summary>

1. Создать два VM: для jenkins-master и jenkins-agent.
2. Установить Jenkins при помощи playbook.
3. Запустить и проверить работоспособность.
4. Сделать первоначальную настройку.

</details>

<details><summary>

## Основная часть

</summary>

1. Сделать Freestyle Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.
4. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.
5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline).
6. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True). По умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.
7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`.
8. Отправить ссылку на репозиторий с ролью и Declarative Pipeline и Scripted Pipeline.
9. Сопроводите процесс настройки скриншотами для каждого пункта задания!!

</details>

<details><summary>

## Необязательная часть

</summary>

1. Создать скрипт на groovy, который будет собирать все Job, завершившиеся хотя бы раз неуспешно. Добавить скрипт в репозиторий с решением и названием `AllJobFailure.groovy`.
2. Создать Scripted Pipeline так, чтобы он мог сначала запустить через Yandex Cloud CLI необходимое количество инстансов, прописать их в инвентори плейбука и после этого запускать плейбук. Мы должны при нажатии кнопки получить готовую к использованию систему.

</details>

---

# Решение

<details><summary>1. Freestyle Job</summary>

![Freestyle Job status](<screenshots/Freestyle_Job.png>)

</details>

<details><summary>2. Declarative Pipeline Job</summary>

![Declarative Pipeline status](screenshots/Declarative_Pipeline_status.png)

Скрипт

![Declarative pipeline](screenshots/Declarative_Pipeline.png)

</details>

<details><summary>3. Declarative Pipeline в репозитории</summary>

[Jenkinsfile](https://github.com/P0zitiff4ik/vector-role/blob/main/Jenkinsfile)

![Jenkiknsfile in repo](screenshots/Jenkinsfile.png)

</details>

<details><summary>4. Multibranch Pipeline</summary>

![Multibranch Pipeline status](screenshots/Multibranch_Pipeline.png)

</details>

<details><summary>6. Изменённый Scripted Pipeline</summary>

[ScriptedJenkinsfile](ScriptedJenkinsfile)

![Scripted status](screenshots/Scripted_Pipeline_status.png)

</details>