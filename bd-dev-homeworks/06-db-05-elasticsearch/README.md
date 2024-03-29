[Задание](https://github.com/netology-code/bd-dev-homeworks/blob/main/06-db-05-elasticsearch/README.md)

------

## Задача 1

<details><summary>Описание</summary>

В этом задании вы потренируетесь в:
- установке Elasticsearch,
- первоначальном конфигурировании Elasticsearch,
- запуске Elasticsearch в Docker.

Используя Docker-образ [centos:7](https://hub.docker.com/_/centos) как базовый и [документацию по установке и запуску Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):
- составьте Dockerfile-манифест для Elasticsearch,
- соберите Docker-образ и сделайте `push` в ваш docker.io-репозиторий,
- запустите контейнер из получившегося образа и выполните запрос пути `/` с хост-машины.
 
Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`,
- имя ноды должно быть `netology_test`.
 
В ответе приведите:
- текст Dockerfile-манифеста,
- ссылку на образ в репозитории dockerhub,
- ответ `Elasticsearch` на запрос пути `/` в json-виде.
 
Подсказки:
- возможно, вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum,
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml,
- при некоторых проблемах вам поможет Docker-директива ulimit,
- Elasticsearch в логах обычно описывает проблему и пути её решения.
 
Далее мы будем работать с этим экземпляром Elasticsearch.
</details>

##### Решение

###### 1.1. Dockerfile

```dockerfile
FROM centos:7

ENV ES_HOME="/elasticsearch-8.9.2"

RUN yum update -y && \
    yum install -y perl-Digest-SHA && \
    yum clean all && \
    curl -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.9.2-linux-x86_64.tar.gz && \
    curl https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.9.2-linux-x86_64.tar.gz.sha512 | shasum -a 512 -c - && \
    rm -f *.tar.* &&\
    useradd -m -u 1000 elasticsearch && \
    mkdir $ES_HOME/snapshots && \
    chown elasticsearch:elasticsearch -R $ES_HOME && \
    mkdir /var/lib/elasticsearch && \
    chown elasticsearch:elasticsearch -R /var/lib/elasticsearch && \
    mkdir /var/log/elasticsearch && \
    chown elasticsearch:elasticsearch -R /var/log/elasticsearch

COPY elasticsearch.yml ${ES_HOME}/config/

USER elasticsearch

EXPOSE 9200 9300

CMD ["sh", "-c", "${ES_HOME}/bin/elasticsearch"]
```

###### 1.2. [Ссылка на образ в репозитории](https://hub.docker.com/r/pozitiff4ik/netology-elastic)

Запуск:
```shell
$ sudo sysctl -w vm.max_map_count=262144
$ docker run --rm  --name elastic -p 9200:9200 -p 9300:9300 --ulimit memlock=-1:-1 --ulimit nofile=65535:65535 -d netology-elastic
```

###### 1.3. Ответ Elasticsearch:

```json
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "z1ELVw80Rsm-ZDAtEvzSMg",
  "version" : {
    "number" : "8.9.2",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "e8179018838f55b8820685f92e245abef3bddc0f",
    "build_date" : "2023-08-31T02:43:14.210479707Z",
    "build_snapshot" : false,
    "lucene_version" : "9.7.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}

```

---

## Задача 2

<details><summary>Описание</summary>

В этом задании вы научитесь:

- создавать и удалять индексы,
- изучать состояние кластера,
- обосновывать причину деградации доступности данных.

Ознакомьтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) и добавьте в `Elasticsearch` 3 индекса в соответствии с таблицей:

| Имя   | Количество реплик | Количество шард |
|-------|-------------------|-----------------|
| ind-1 | 0                 | 1               |
| ind-2 | 1                 | 2               |
| ind-3 | 2                 | 4               |

Получите список индексов и их статусов, используя API, и **приведите в ответе** на задание.

Получите состояние кластера `Elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находятся в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера Elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

</details>

##### Решение

Добавьте в `Elasticsearch` 3 индекса в соответствии с таблицей
```shell
$ curl -u elastic -X PUT "localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}

$ curl -u elastic -X PUT "localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 2,
    "number_of_replicas": 1
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-2"
}

$ curl -u elastic -X PUT "localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 4,
    "number_of_replicas": 2
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-3"
}
```

Получите список индексов и их статусов, используя API, и **приведите в ответе** на задание.
```shell
$ curl -u elastic -X GET "localhost:9200/_cat/indices/ind-*?v=true&s=index&pretty"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 ZGmAWio8SpmXCAi88j30cA   1   0          0            0       247b           247b
yellow open   ind-2 91blHwTGTrOk0nDLnRnarA   2   1          0            0       494b           494b
yellow open   ind-3 rVnTFnqDTtmAQRr_vwaq4g   4   2          0            0       988b           988b
```

Получите состояние кластера Elasticsearch, используя API.
```shell
$ curl -u elastic -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 7,
  "active_shards" : 7,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 41.17647058823529
}
```

Как вы думаете, почему часть индексов и кластер находятся в состоянии yellow?

*Потому что кластер состоит из одной ноды, без реплик, хотя в индексах мы задали другие значения. См. [Документацию по состоянию кластера](https://www.elastic.co/guide/en/elasticsearch/reference/8.9/cluster-health.html#cluster-health-api-response-body)*

Удалите все индексы.
```shell
$ curl -u elastic -X DELETE "localhost:9200/ind-1,ind-2,ind-3&pretty"
{"acknowledged":true}
```

---

## Задача 3

<details><summary>Описание</summary>

В этом задании вы научитесь:

- создавать бэкапы данных,
- восстанавливать индексы из бэкапов.

Создайте директорию `{путь до корневой директории с Elasticsearch в образе}/snapshots`.

Используя API, [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
эту директорию как `snapshot repository` с именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) состояния кластера `Elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние кластера `Elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:

- возможно, вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `Elasticsearch`.

</details>

##### Решение:

Создайте директорию `{путь до корневой директории с Elasticsearch в образе}/snapshots`
```shell
$ docker exec -it elastic mkdir ${ES_HOME}/snapshots
```

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.
```shell
$ curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/elasticsearch-8.9.2/snapshots"
  }
}
'
{
  "acknowledged" : true
}
```

**Приведите в ответе** список индексов
```shell
$ curl -X GET "localhost:9200/_cat/indices/?v=true&s=index&pretty"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  HBYkMVEOQremMYi-hlTczA   1   0          0            0       225b           225b
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) состояния кластера `Elasticsearch`.
```shell
$ curl -X PUT "localhost:9200/_snapshot/netology_backup/my_snapshot?wait_for_completion=true&pretty"
{
  "snapshot" : {
    "snapshot" : "my_snapshot",
    "uuid" : "ZQ6nuuS1RkOfSndxqZkj3g",
    "repository" : "netology_backup",
    "version_id" : 8090299,
    "version" : "8.9.2",
    "indices" : [
      "test"
    ],
    "data_streams" : [ ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2023-09-17T21:54:01.589Z",
    "start_time_in_millis" : 1694987641589,
    "end_time" : "2023-09-17T21:54:01.789Z",
    "end_time_in_millis" : 1694987641789,
    "duration_in_millis" : 200,
    "failures" : [ ],
    "shards" : {
      "total" : 1,
      "failed" : 0,
      "successful" : 1
    },
    "feature_states" : [ ]
  }
}

```

**Приведите в ответе** список файлов в директории со `snapshot`.
```shell
$ docker exec -it elastic ls -lah $ES_HOME/snapshots
total 52K
drwxr-xr-x 1 elasticsearch elasticsearch 4.0K Sep 17 21:54 .
drwxr-xr-x 1 elasticsearch elasticsearch 4.0K Sep 17 21:42 ..
-rw-r--r-- 1 elasticsearch elasticsearch  587 Sep 17 21:54 index-0
-rw-r--r-- 1 elasticsearch elasticsearch    8 Sep 17 21:54 index.latest
drwxr-xr-x 3 elasticsearch elasticsearch 4.0K Sep 17 21:54 indices
-rw-r--r-- 1 elasticsearch elasticsearch  21K Sep 17 21:54 meta-ZQ6nuuS1RkOfSndxqZkj3g.dat
-rw-r--r-- 1 elasticsearch elasticsearch  307 Sep 17 21:54 snap-ZQ6nuuS1RkOfSndxqZkj3g.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.
```shell
$ curl -X GET "localhost:9200/_cat/indices/?v=true&s=index&pretty"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 gz78iBAoStOBvYxr7Y48Mg   1   0          0            0       225b           225b
```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние кластера `Elasticsearch` из `snapshot`, созданного ранее.
```shell
$ curl -X POST "localhost:9200/_snapshot/netology_backup/my_snapshot/_restore?pretty" -H 'Content-Type: application/json' -d'
{
  "include_global_state": false,
  "indices": "*"
}
'
{
  "accepted" : true
}
```

Итоговый список индексов
```shell
$ curl -X GET "localhost:9200/_cat/indices/?v=true&s=index&pretty"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test   YwQYavFyRpatVVCwBOLROA   1   0          0            0       247b           247b
green  open   test-2 gz78iBAoStOBvYxr7Y48Mg   1   0          0            0       247b           247b
```
---