[Задание](https://github.com/netology-code/bd-dev-homeworks/blob/main/06-db-02-sql/README.md)

------

### 1. Используя Docker, поднимите инстанс PostgreSQL (версию 12) c 2 volume, в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose-манифест.

```yaml
version: "3.8"
services:
  db:
    image: postgres:12
    container_name: psql12
    restart: always
    volumes:
      - db-data:/var/lib/postgresql/data
      - backup:/media/postgresql/backup
    environment:
      POSTGRES_USER: netology
      POSTGRES_PASSWORD: example
      POSTGRES_DB: netology_db
    ports:
      - 5432:5432

  
volumes:
  db-data:
  backup:
```

---

### 2. В БД из задачи 1:

- создайте пользователя test-admin-user и БД test_db;
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже);
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db;
- создайте пользователя test-simple-user;
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE этих таблиц БД test_db.

Таблица orders:
- id (serial primary key);
- наименование (string);
- цена (integer).

Таблица clients:
- id (serial primary key);
- фамилия (string);
- страна проживания (string, index);
- заказ (foreign key orders).

Приведите:
- итоговый список БД после выполнения пунктов выше;
```sql
                                                                       List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |       Access privileges        |  Size   | Tablespace |                Description       
-----------+----------+----------+------------+------------+--------------------------------+---------+------------+--------------------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |                                | 8033 kB | pg_default | default administrative connection database
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +| 7833 kB | pg_default | unmodifiable empty database
           |          |          |            |            | postgres=CTc/postgres          |         |            |
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +| 7833 kB | pg_default | default template for new databases
           |          |          |            |            | postgres=CTc/postgres          |         |            |
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                  +| 8113 kB | pg_default |
           |          |          |            |            | postgres=CTc/postgres         +|         |            |
           |          |          |            |            | "test-admin-user"=CTc/postgres |         |            |
(4 rows)
```
- описание таблиц (describe);
```sql
                                                             Table "public.clients"
      Column       |         Type          | Collation | Nullable |               Default               | Storage  | Stats target | Description
-------------------+-----------------------+-----------+----------+-------------------------------------+----------+--------------+-------------
 id                | integer               |           | not null | nextval('clients_id_seq'::regclass) | plain    |              |
 фамилия           | character varying(50) |           | not null |                                     | extended |              |
 страна проживания | character varying(50) |           | not null |                                     | extended |              |
 заказ             | integer               |           |          |                                     | plain    |              |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "idx_country" UNIQUE, btree ("страна проживания")
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
Access method: heap
```
```sql
                                                           Table "public.orders"
    Column    |          Type          | Collation | Nullable |              Default               | Storage  | Stats target | Description
--------------+------------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id           | integer                |           | not null | nextval('orders_id_seq'::regclass) | plain    |              |
 наименование | character varying(150) |           | not null |                                    | extended |              |
 цена         | integer                |           |          |                                    | plain    |              |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
Access method: heap
```
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db;
```sql
=# SELECT
    grantee, table_catalog, table_name, privilege_type
FROM
    information_schema.table_privileges
WHERE
    table_name in ('clients','orders')
order by
    1,2,3;
```
- список пользователей с правами над таблицами test_db.
```sql
     grantee      | table_catalog | table_name | privilege_type
------------------+---------------+------------+----------------
 postgres         | test_db       | clients    | TRIGGER
 postgres         | test_db       | clients    | REFERENCES
 postgres         | test_db       | clients    | TRUNCATE
 postgres         | test_db       | clients    | DELETE
 postgres         | test_db       | clients    | UPDATE
 postgres         | test_db       | clients    | SELECT
 postgres         | test_db       | clients    | INSERT
 postgres         | test_db       | orders     | INSERT
 postgres         | test_db       | orders     | SELECT
 postgres         | test_db       | orders     | UPDATE
 postgres         | test_db       | orders     | DELETE
 postgres         | test_db       | orders     | TRUNCATE
 postgres         | test_db       | orders     | REFERENCES
 postgres         | test_db       | orders     | TRIGGER
 test-admin-user  | test_db       | clients    | DELETE
 test-admin-user  | test_db       | clients    | TRIGGER
 test-admin-user  | test_db       | clients    | REFERENCES
 test-admin-user  | test_db       | clients    | TRUNCATE
 test-admin-user  | test_db       | clients    | INSERT
 test-admin-user  | test_db       | clients    | SELECT
 test-admin-user  | test_db       | clients    | UPDATE
 test-admin-user  | test_db       | orders     | DELETE
 test-admin-user  | test_db       | orders     | UPDATE
 test-admin-user  | test_db       | orders     | SELECT
 test-admin-user  | test_db       | orders     | INSERT
 test-admin-user  | test_db       | orders     | TRIGGER
 test-admin-user  | test_db       | orders     | REFERENCES
 test-admin-user  | test_db       | orders     | TRUNCATE
 test-simple-user | test_db       | clients    | DELETE
 test-simple-user | test_db       | clients    | INSERT
 test-simple-user | test_db       | clients    | SELECT
 test-simple-user | test_db       | clients    | UPDATE
 test-simple-user | test_db       | orders     | INSERT
 test-simple-user | test_db       | orders     | DELETE
 test-simple-user | test_db       | orders     | UPDATE
 test-simple-user | test_db       | orders     | SELECT
(36 rows)
```

---

### 3. Используя SQL-синтаксис, наполните таблицы следующими тестовыми данными:
```sql
test_db=# INSERT INTO
test_db-#   orders (наименование,цена)
test_db-# VALUES
test_db-#   ('Шоколад',10),
test_db-#   ('Принтер',3000),
test_db-#   ('Книга',500),
test_db-#   ('Монитор',7000),
test_db-#   ('Гитара',4000);
INSERT 0 5

test_db=# SELECT * FROM orders;
 id | наименование | цена
----+--------------+------
  1 | Шоколад      |   10
  2 | Принтер      | 3000
  3 | Книга        |  500
  4 | Монитор      | 7000
  5 | Гитара       | 4000
(5 rows)
```

```sql
test_db=# INSERT INTO
  clients (ФИО,"страна проживания")
VALUES
  ('Иванов Иван Иванович','USA'),
  ('Петров Петр Петрович','Canada'),
  ('Иоганн Себастьян Бах','Japan'),
  ('Ронни Джеймс Дио','Russia'),
  ('Ritchie Blackmore','Russia');
INSERT 0 5

test_db=# SELECT * FROM clients
;
 id |         ФИО          | страна проживания | заказ
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |
  2 | Петров Петр Петрович | Canada            |
  3 | Иоганн Себастьян Бах | Japan             |
  4 | Ронни Джеймс Дио     | Russia            |
  5 | Ritchie Blackmore    | Russia            |
(5 rows)
```

Используя SQL-синтаксис вычислите количество записей для каждой таблицы.

```sql
test_db=# SELECT count(*) FROM clients;
 count
---------
       5
(1 row)

test_db=# SELECT count(*) FROM orders;
 count
---------
       5
(1 row)
```

---

### 4. Используя foreign keys, свяжите записи из таблиц, согласно таблице. Приведите SQL-запросы для выполнения этих операций.

```sql
=# UPDATE clients SET заказ = (select id from orders where наименование = 'Книга') WHERE ФИО = 'Иванов Иван Иванович';
```
```sql
=# UPDATE clients SET заказ = (select id from orders where наименование = 'Монитор') WHERE ФИО = 'Петров Петр Петрович';
```
```sql
=# UPDATE clients SET заказ = (select id from orders where наименование = 'Гитара') WHERE ФИО = 'Иоганн Себастьян Бах';
```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод этого запроса.

```sql
=# SELECT clients.ФИО, orders.наименование AS Заказ FROM clients INNER JOIN orders ON clients.заказ=orders.id;
         ФИО          |  Заказ
----------------------+---------
 Иванов Иван Иванович | Книга
 Петров Петр Петрович | Монитор
 Иоганн Себастьян Бах | Гитара
(3 rows)
```

---

### 5. Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 (используя директиву EXPLAIN).

Приведите получившийся результат и объясните, что значат полученные значения.

```sql
=# EXPLAIN SELECT clients.ФИО, orders.наименование AS Заказ FROM clients INNER JOIN orders ON clients.заказ=orders.id;
                                    QUERY PLAN
----------------------------------------------------------------------------------
 Nested Loop  (cost=0.14..9.23 rows=1 width=436)
   ->  Seq Scan on clients  (cost=0.00..1.00 rows=1 width=122)
   ->  Index Scan using orders_pkey on orders  (cost=0.14..8.16 rows=1 width=322)
         Index Cond: (id = clients."заказ")
```
Числа, перечисленные в скобках (слева направо), имеют следующий смысл:
- Приблизительная стоимость запуска. Это время, которое проходит, прежде чем начнётся этап вывода данных, например для сортирующего узла это время сортировки.
- Приблизительная общая стоимость. Она вычисляется в предположении, что узел плана выполняется до конца, то есть возвращает все доступные строки. На практике родительский узел может досрочно прекратить чтение строк дочернего (см. приведённый ниже пример с LIMIT).
- Ожидаемое число строк, которое должен вывести этот узел плана. При этом так же предполагается, что узел выполняется до конца.
- Ожидаемый средний размер строк, выводимых этим узлом плана (в байтах).

Важно понимать, что стоимость узла верхнего уровня включает стоимость всех его потомков

Планировщик использует план с узлом соединения с вложенным циклом, на вход которому поступают данные от двух его потомков, узлов сканирования. Первый - план простого последовательного сканирования в таблице clients, второй - план сканирования в индексе таблицы orders.

Postgres делает предположения на основе статистики, которую собирает периодический выполня analyze запросы на выборку данных из служебных таблиц. Но если запустить explain analyze, то запрос будет выполнен и к плану добавятся уже точные данные по времени и объёму данных

---

### 6. Приведите список операций, который вы применяли для бэкапа данных и восстановления.
6.1. Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
```shell
# pg_dump -U postgres test_db > /media/postgresql/backup/test_db.backup
```
6.2. Остановите контейнер с PostgreSQL (но не удаляйте volumes).
```shell
$ docker stop psql12
```
6.3. Поднимите новый пустой контейнер с PostgreSQL.
```shell
$ docker run --rm -d -e POSTGRES_USER=test-admin-user -e POSTGRES_PASSWORD=netology -e POSTGRES_DB=test_db -v psql_backup:/home/pozitiff4ik/backup/ -p 5432:5432 --name psql12_new postgres:12
```
6.4. Восстановите БД test_db в новом контейнере.
```shell
$ export PGPASSWORD=netology && psql -h localhost -U test-admin-user -f $(ls -1trh /home/pozitiff4ik/backup/*.backup) test_db
```
---