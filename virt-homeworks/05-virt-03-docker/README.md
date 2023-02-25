[Задание](https://github.com/netology-code/virt-homeworks/blob/virt-11/05-virt-03-docker/README.md)

------

### 1. Запуск веб-сервера в фоне с индекс-страницей

https://hub.docker.com/r/pozitiff4ik/nginx_fork

---

### 2. Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?

> #### Сценарий:
> - Высоконагруженное монолитное java веб-приложение;
> - Nodejs веб-приложение;
> - Мобильное приложение c версиями для Android и iOS;
> - Шина данных на базе Apache Kafka;
> - Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
> - Мониторинг-стек на базе Prometheus и Grafana;
> - MongoDB, как основное хранилище данных для java-приложения;
> - Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

Не работал пока с большинством из этого, но, кажется, что для java лучше физическую машину, чтобы использовать максимум для высокой нагрузки. Для всего остального, кроме базы данных и Gitlab с Docker - контейнеры, т.к. удобно управлять и кластеризировать. Для Базы данных и Gitlab/Docker - виртуальную машину для удобства бэкапирования. Несмотря на то, что у Монги есть оф. образ на докерхабе, я слышал, что БД нежелательно запускать в контейнерах.

---

### 3. Листинг и содержание файлов в /data контейнера

```bash
$ mkdir ~/data
$ docker run -td -v ~/data:/data centos:7
$ docker run -td -v ~/data:/data debian:stable-slim
```

```bash
centos# ls
anaconda-post.log  bin  data  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
centos# cd data
centos# ls
centos# echo "Hello World" > Hello.txt
centos# ls
Hello.txt
centos# cat Hello.txt
Hello World
```

```bash
$ echo "Hello, Netology!" > ~/data/Netology.txt
```

```bash
debian# ls
bin  boot  data  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
debian# cd data
debian# ls
Hello.txt  Netology.txt
debian# cat *.txt       
Hello World
Hello, Netology!
```

---

### 4. Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам

Получаю ошибку при сборке image, как при использовании Dockerfile [отсюда](https://github.com/netology-code/virt-video-code/blob/main/docker/Dockerfile), так и [отсюда](https://github.com/netology-code/virt-homeworks/blob/virt-11/05-virt-03-docker/src/build/ansible/Dockerfile)


```bash
ERROR: Cannot uninstall 'packaging'. It is a distutils installed project and thus we cannot accurately determine which files belong to it which would lead to only a partial uninstall.
------
executor failed running [/bin/sh -c CARGO_NET_GIT_FETCH_WITH_CLI=1 &&     apk --no-cache add         sudo         python3        py3-pip         openssl         ca-certificates         sshpass         openssh-client         rsync         git &&     apk --no-cache add --virtual build-dependencies         python3-dev         libffi-dev         musl-dev         gcc         cargo         openssl-dev         libressl-dev         build-base &&     pip install --upgrade pip wheel &&     pip install --upgrade cryptography cffi &&     pip uninstall ansible-base &&     pip install ansible-core &&     pip install ansible==2.10.0 &&     pip install mitogen ansible-lint jmespath &&     pip install --upgrade pywinrm &&     apk del build-dependencies &&     rm -rf /var/cache/apk/* &&     rm -rf /root/.cache/pip &&     rm -rf /root/.cargo]: exit code: 1
```
