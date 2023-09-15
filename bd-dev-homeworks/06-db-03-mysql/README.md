[Задание](https://github.com/netology-code/virt-homeworks/blob/virt-11/06-db-03-mysql/README.md)

------

Используя Docker, поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

```yaml
version: "3.8"
services:
  db:
    image: mysql:8.0
    container_name: mysql1
    restart: always
    command: --default-authentication-plugin=mysql_native_password
    volumes:
      - mysql-db-data:/var/lib/mysql
      - mysql-backup:/tmp/backup
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_DATABASE: test_db
  
volumes:
  mysql-db-data:
  mysql-backup:
```

Запускаем контейнер, копируем в него дамп, восстанавливаем из дампа:

```shell
$ docker-compose up -d
$ docker cp test_dump.sql mysql1:/tmp/backup/
$ docker exec -it mysql1 bash
bash-4.4# mysql test_db -p < /tmp/backup/test_dump.sql
```

Найдите команду для выдачи статуса БД и приведите в ответе из её вывода версию сервера БД.

```sql
> \s
...
Server version:         8.0.34 MySQL Community Server - GPL
...
```
Подключитесь к восстановленной БД и получите список таблиц из этой БД. Приведите в ответе количество записей с price > 300.

```shell
> select count(*) from orders where price < 300;
+----------+
| count(*) |
+----------+
|        2 |
+----------+
1 row in set (0.04 sec)
```

---

### 2. Создайте пользователя test в БД c паролем test-pass, используя указанные в задаче параметры:

```sql
> CREATE USER 'test'@'localhost'
    -> IDENTIFIED WITH mysql_native_password BY 'test-pass'
    -> WITH MAX_QUERIES_PER_HOUR 100
    -> PASSWORD EXPIRE INTERVAL 180 DAY
    -> FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 2
    -> ATTRIBUTE '{"fname": "James", "lname": "Pretty"}';
Query OK, 0 rows affected (0.31 sec)
```

Предоставьте привелегии пользователю test на операции SELECT базы test_db.

```sql
> GRANT SELECT ON test_db.* TO 'test'@'localhost';
```

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES, получите данные по пользователю test и приведите в ответе к задаче.

```sql
> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER='test';
+------+-----------+---------------------------------------+
| USER | HOST      | ATTRIBUTE                             |
+------+-----------+---------------------------------------+
| test | localhost | {"fname": "James", "lname": "Pretty"} |
+------+-----------+---------------------------------------+
1 row in set (0.00 sec)
```

---
