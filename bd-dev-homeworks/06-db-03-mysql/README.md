[Задание](https://github.com/netology-code/virt-homeworks/blob/virt-11/06-db-03-mysql/README.md)

------

### 1. Используя Docker, поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

docker-compose.yml
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

### 3. Исследуйте, какой `engine` используется в таблице БД `test_db` и приведите в ответе.

```sql
> SELECT TABLE_NAME, ENGINE, TABLE_ROWS FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'test_db';
+------------+--------+------------+
| TABLE_NAME | ENGINE | TABLE_ROWS |
+------------+--------+------------+
| orders     | InnoDB |          5 |
+------------+--------+------------+
1 row in set (0.00 sec)
```

Измените `engine` и приведите время выполнения и запрос на изменения из профайлера в ответе:

```sql
> ALTER TABLE orders ENGINE MyISAM;
Query OK, 5 rows affected (0.03 sec)
Records: 5  Duplicates: 0  Warnings: 0

> ALTER TABLE orders ENGINE InnoDB;
Query OK, 5 rows affected (0.04 sec)
Records: 5  Duplicates: 0  Warnings: 0

> SHOW PROFILES;
+----------+------------+----------------------------------+
| Query_ID | Duration   | Query                            |
+----------+------------+----------------------------------+
|        1 | 0.03450525 | ALTER TABLE orders ENGINE MyISAM |
|        2 | 0.03443875 | ALTER TABLE orders ENGINE InnoDB |
+----------+------------+----------------------------------+
2 rows in set, 1 warning (0.00 sec)
```

---

### 4. Изучите файл my.cnf в директории /etc/mysql.

Приведите в ответе изменённый файл my.cnf.

```editorconfig
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/8.0/en/server-configuration-defaults.html

[mysqld]
# netology
# скорость IO важнее сохранности данных;
innodb_flush_log_at_trx_commit=2

# нужна компрессия таблиц для экономии места на диске;
innodb_compress_debug=zlib

# размер буффера с незакомиченными транзакциями 1 Мб;
innodb_log_buffer_size=1M

# буффер кеширования 30% от ОЗУ (всего докер забирает 7.73GB);
innodb_buffer_pool_size = 2374M

# размер файла логов операций 100 Мб.
innodb_log_file_size=100M

#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M

# Remove leading # to revert to previous value for default_authentication_plugin,
# this will increase compatibility with older clients. For background, see:
# https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_authentication_plugin
# default-authentication-plugin=mysql_native_password
skip-host-cache
skip-name-resolve
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
user=mysql

pid-file=/var/run/mysqld/mysqld.pid
[client]
socket=/var/run/mysqld/mysqld.sock

!includedir /etc/mysql/conf.d/
```

---