[Задание](https://github.com/netology-code/bd-dev-homeworks/blob/main/06-db-04-postgresql/README.md)

------

### Задача 1
<details> <summary> Описание </summary>
Используя Docker, поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
Подключитесь к БД PostgreSQL, используя psql.

Воспользуйтесь командой \? для вывода подсказки по имеющимся в psql управляющим командам.

Найдите и приведите управляющие команды для:

вывода списка БД,
подключения к БД,
вывода списка таблиц,
вывода описания содержимого таблиц,
выхода из psql.
</details>

###### Решение:

Используем docker-compose из [06-db-02-sql](bd-dev-homeworks/06-db-02-sql/README.md)

- `\l[+]   [PATTERN]`  -   list databases
- `\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}`  -  connect to new database (currently "netology_db")
- `\dt[S+] [PATTERN]`  -  list tables
- `\d[S+]  NAME`  -  describe table, view, sequence, or index
- `\q`  -  quit psql

---

### Задача 2
<details> <summary> Описание </summary>
Используя psql, создайте БД test_database.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/virt-11/06-db-04-postgresql/test_data).

Восстановите бэкап БД в test_database.

Перейдите в управляющую консоль psql внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы orders с наибольшим средним значением размера элементов в байтах.

Приведите в ответе команду, которую вы использовали для вычисления, и полученный результат.
</details>

###### Решение:

Cоздайте БД test_database
```sql
=# CREATE DATABASE test_database;
```

Восстановите бэкап БД в test_database
```shell
$ psql -h localhost -U netology test_database < test_dump.sql
```

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице
```shell
$ psql -h localhost -U netology test_database
```
```sql
=# ANALYZE
```

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы orders с наибольшим средним значением размера элементов в байтах.
Приведите в ответе команду, которую вы использовали для вычисления, и полученный результат.
```sql
=# SELECT tablename,attname,avg_width FROM pg_stats WHERE tablename='orders' ORDER BY avg_width DESC limit 1;
 tablename | attname | avg_width
-----------+---------+-----------
 orders    | title   |        16
(1 row)
```

---

### Задача 3

<details> <summary> Описание </summary>
Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и поиск по ней занимает долгое время. Вам как успешному выпускнику курсов DevOps в Нетологии предложили провести разбиение таблицы на 2: шардировать на orders_1 - price>499 и orders_2 - price<=499.

Предложите SQL-транзакцию для проведения этой операции.

Можно ли было изначально исключить ручное разбиение при проектировании таблицы orders?
</details>

###### Решение:

Я слишком заморочился, но, так как я всё же выпускник курсов DevOps в Нетологии решил, что надо сделать правильно, а не просто разбить их вручную. 

Сначала создаём новую головную партицированную таблицу идентичной структуры под новым именем:
```sql
CREATE TABLE orders_part
(LIKE orders INCLUDING DEFAULTS INCLUDING CONSTRAINTS)
PARTITION BY RANGE (price);
```

И партиции orders_1 и orders_2  на будущее:
```sql
CREATE TABLE orders_1
PARTITION OF orders_part
FOR VALUES FROM ('500') TO (MAXVALUE);

CREATE TABLE orders_2
PARTITION OF orders_part
FOR VALUES FROM (MINVALUE) TO ('500');
```

На [Stackoverflow](https://ru.stackoverflow.com/questions/1168712/Секционирование-существующей-таблицы-postgresql) рекомендуют ещё подготовить таблицу, чтобы не было длительного даунтайма, но в нашем варианте можно это и опустить.

Собственно транзакция, переименовываем старую таблицу в архив, новую - в orders и заполняем её данными из старой таблицы:
```sql
BEGIN;
SET statement_timeout TO '1s';
ALTER TABLE orders RENAME TO orders_archive;
ALTER TABLE orders_part RENAME TO orders;
INSERT INTO orders SELECT * FROM orders_archive;
COMMIT;
```

Проверяем, что в таблице orders есть заказы, в таблице orders_1 те же заказы, но с ценой >499, а в таблице orders_2 - с ценой <=499:
```sql
test_database=# SELECT * FROM orders;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
(8 rows)

test_database=# SELECT * FROM orders_1;
 id |       title        | price
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
(3 rows)

test_database=# SELECT * FROM orders_2;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(5 rows)
```
Пробуем вставить новые заказы и проверить корректность шардирования:
```sql
INSERT INTO orders (id, title, price) VALUES
(9, 'some funny name', 99),
(10, 'another funny name', 1001);

test_database=# SELECT * FROM orders ORDER BY id;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  2 | My little database   |   500
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  6 | WAL never lies       |   900
  7 | Me and my bash-pet   |   499
  8 | Dbiezdmin            |   501
  9 | some funny name      |    99
 10 | another funny name   |  1001
(10 rows)

test_database=# SELECT * FROM orders_1;
 id |       title        | price 
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
 10 | another funny name |  1001
(4 rows)

test_database=# SELECT * FROM orders_2;
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  9 | some funny name      |    99
(6 rows)

```

Разумеется, можно было изначально исключить ручное разбиение при проектировании таблицы orders. Для этого надо было изначально создать её с партиционированием

---

### Задача 4

<details> <summary> Описание </summary>
Используя утилиту pg_dump, создайте бекап БД test_database.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца title для таблиц test_database?
</details>

###### Решение:

```shell
pg_dump -h localhost -U netology test_database > test_database_new.sql
```

Уникальность столбца title можно выполнить, добавив столбцу индексацию:
```sql
CREATE unique INDEX title_un ON public.orders(title);
```
---