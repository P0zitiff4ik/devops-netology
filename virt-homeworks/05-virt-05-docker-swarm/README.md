[Задание](https://github.com/netology-code/virt-homeworks/blob/virt-11/05-virt-05-docker-swarm/README.md)

------

### 1. Дайте письменые ответы на вопросы:

> - В чём отличие режимов работы сервисов в Docker Swarm-кластере: replication и global?

В режиме replicated приложение запускается в том количестве экземпляров, какое укажет пользователь. При этом на отдельной ноде может быть как несколько экземпляров приложения, так и не быть совсем.

В режиме global приложение запускается обязательно на каждой ноде и в единственном экземпляре.

> - Какой алгоритм выбора лидера используется в Docker Swarm-кластере?
 
Алгоритм консенсуса Raft

- Алгоритм решает проблему согласованности, чтобы все manager ноды имели одинаковое представление о состоянии кластера
- Для отказоустойчивой работы должно быть не менее трёх manager нод. 
- Среди `manager` нод выбирается лидер, его задача гарантировать согласованность. 
- Лидер отправляет keepalive пакеты с заданной периодичностью в пределах 150-300мс. Если пакеты не пришли, менеджеры начинают выборы нового лидера.
- Количество нод обязательно должно быть нечётным (это рекомендация из документации Docker).
- Если кластер разбит, нечётное количество нод должно гарантировать, что кластер останется консистентным, т.к. факт изменения состояния считается совершенным, если его отразило большинство нод. Если разбить кластер пополам, нечётное число гарантирует что в какой-то части кластера будеть большинство нод.

> - Что такое Overlay Network?

Сеть для связи контейнеров и служб. Если не определена при создании контейнера, по умолчанию используется сеть `ingress`

---

### 2. Создайте ваш первый Docker Swarm-кластер в Яндекс Облаке.

```shell
[root@node01 ~]# docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
ubu8fybi903bo7neqddc6onzs *   node01.netology.yc   Ready     Active         Leader           23.0.1
yyhrmoyuhiejpyxnzh6mow5b6     node02.netology.yc   Ready     Active         Reachable        23.0.1
w4g3dgqgrijc991hrao6b3wz1     node03.netology.yc   Ready     Active         Reachable        23.0.1
xycenhta7vhwu3pyi2g95xmlz     node04.netology.yc   Ready     Active                          23.0.1
1kirzuxal1wkdnpwj83k8ykbz     node05.netology.yc   Ready     Active                          23.0.1
kkcj3hk5u5gp6p6alo0wpikfh     node06.netology.yc   Ready     Active                          23.0.1
```

---

### 3. Создайте ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

```shell
[root@node01 ~]# docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
nukoprq5kzfg   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0
v8wwlkk01pie   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
462cv98w1bn0   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest
ttdojfnmwxa4   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest
remag3yj02bx   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4
zirr2wn2y9gt   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0
e3uoeoplivoe   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0
i3lph7otei8p   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0

```

---

### 4. Что делает и зачем нужна команда `docker swarm update --autolock=true` (см. https://docs.docker.com/engine/swarm/swarm_manager_locking/):

Данная команда блокирует manager ноду таким образом, что после перезапуска докера для подключения обратно к swarm необходимо ввести ключ разблокировки, который выдаётся при исполнении команды. Без него docker не может получить доступ к хранящимся в Raft секретам. Ниже я запустил команду на первой ноде, являвшейся на тот момент лидером, после чего произвёл перезапуск докер сервиса на второй и третьей ноде, на второй запустил `docker swarm unlock`:

```shell
[root@node02 ~]# docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
ubu8fybi903bo7neqddc6onzs     node01.netology.yc   Ready     Active         Leader           23.0.1
yyhrmoyuhiejpyxnzh6mow5b6 *   node02.netology.yc   Ready     Active         Reachable        23.0.1
w4g3dgqgrijc991hrao6b3wz1     node03.netology.yc   Down      Active         Unreachable      23.0.1
xycenhta7vhwu3pyi2g95xmlz     node04.netology.yc   Ready     Active                          23.0.1
1kirzuxal1wkdnpwj83k8ykbz     node05.netology.yc   Ready     Active                          23.0.1
kkcj3hk5u5gp6p6alo0wpikfh     node06.netology.yc   Ready     Active                          23.0.1
```

Предполагаю, что нужна для обеспечения безопасности в плане доступа остальным элементам swarm, если злоумышленник получит доступ к одному из узлов

---