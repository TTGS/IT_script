
PostgreSQL中流复制中的unlogged表。  
------------------------------------------
作者:TT
日期:2017-10-9
标签：postgresql  功能  报错信息  数据库管理  案例 
------------------------------------------
当表设置为unlogged表后，会省去日志记录的时间，但是这个表却不能复制到流复制的备库中去，因为流复制使用的是传送日志方式同步的数据，如果数据都不记录日志了，那么就不会有数据发送到备库上去了。看实验。

主库：
mydb=# create unlogged table test_log (
mydb(# id int , uid uuid default uuid_generate_v4()
mydb(# );
CREATE TABLE
mydb=# insert into test_log(id) values(generate_series(1,100));
INSERT 0 100
mydb=# select count(*) from test_log;
 count
-------
   100
(1 row)

mydb=#


备库：
mydb=# \d test_log
               Unlogged table "public.test_log"
 Column |  Type   | Collation | Nullable |      Default      
--------+---------+-----------+----------+--------------------
 id     | integer |           |          |
 uid    | uuid    |           |          | uuid_generate_v4()

mydb=# \dt test_log
          List of relations
 Schema |   Name   | Type  |  Owner  
--------+----------+-------+----------
 public | test_log | table | postgres
(1 row)

mydb=# \dt+ test_log
                      List of relations
 Schema |   Name   | Type  |  Owner   |  Size   | Description
----------+------------+-------+-------------+-----------+-------------
 public | test_log | table | postgres | 0 bytes |
(1 row)

mydb=# select count(*)  from test_log;
ERROR:  cannot access temporary or unlogged relations during recovery
mydb=#

看到报错了吗？其实只有表结构发送到备库了，主库的数据都没有过来。
本质上说，其实unlogged表只有数据没有记录日志，创建表，删除表都会相应的记录一下日志。

备库没有数据，这将是一个在生产上严重的问题，因为备库就是为了时刻接手主库而准备的数据库，但是数据却没有过来，这将是很严重的问题，导入数据多快也是白搭。那有什么办法可以解决这样的问题？

我们可以在插入数据的时候将表设置为unlogged模式，然后在插入数据之后再将unlogged表设置为logged模式。
主库
mydb=# alter table test_log set logged;
ALTER TABLE
mydb=#

备库
mydb=# select count(*)  from test_log;
ERROR:  cannot access temporary or unlogged relations during recovery
mydb=# select count(*)  from test_log;
 count
-------
   100
(1 row)

mydb=#

有人会问，那么如果我将有数据的表设置为unlogged模式，备库会如何呢？再看实验。
主库
mydb=# alter table test_log set logged;
ALTER TABLE
mydb=# insert into test_log(id) values(generate_series(1,100));
INSERT 0 100
mydb=# insert into test_log(id) values(generate_series(1,100));
INSERT 0 100
mydb=# insert into test_log(id) values(generate_series(1,100));
INSERT 0 100
mydb=# select count(*) from test_log;
 count
-------
   400
(1 row)

mydb=# alter table test_log set unlogged;
ALTER TABLE
mydb=#

备库
mydb=# select count(*)  from test_log;
 count
-------
   400
(1 row)

mydb=# select count(*)  from test_log;
ERROR:  cannot access temporary or unlogged relations during recovery
mydb=#

所以，在将表修改成unlogged时候一定要注意，备库会没有数据的。
