名称: create table as 

格式：
CREATE [ [ GLOBAL | LOCAL ] { TEMPORARY | TEMP } | UNLOGGED ] TABLE [ IF NOT EXISTS ] table_name
    [ (column_name [, ...] ) ]
    [ WITH ( storage_parameter [= value] [, ... ] ) | WITH OIDS | WITHOUT OIDS ]
    [ ON COMMIT { PRESERVE ROWS | DELETE ROWS | DROP } ]
    [ TABLESPACE tablespace_name ]
    AS query
    [ WITH [ NO ] DATA ]

说明：create table as 是一个快速复制表的内容。
global 或者 local 是兼容词，也是保留词 现在（ pg10 ） 写上执行没有任何区别，global会提示错误，但是会成功创建，local不会提示错误。。需要和temp一起使用
temporary 和 temp 一样
unlogged 是永久表的选项，表将不记录日志，如果出现需要恢复数据的时候，这个表直接做清空处理。但速度飞快。
IF NOT exists  如果表不存在，那么创建，如果存在，提示内并停止创建，不会抛出错误内容。
ON COMMIT { PRESERVE ROWS | DELETE ROWS | DROP } 如果是temp表，那么你可以使用这个，在一个事务结束如果处理临时表的内容。
	PRESERVE ROWS  默认，事务结束不做任何操作
	DELETE ROWS    事务结束清空数据
	drop           事务结束删除临时表
TABLESPACE tablespace_name   指定表创建在那个表空间，临时表在temp_tablespace ， 永久表在 default_tablespace 
query 是查询逻辑SQL 
with no data 查询逻辑SQL 只是复制表结构（没有数据）
with   data 查询逻辑SQL 复制表结构和数据 

 
--带有提示的临时表
taxidb=# create global  temp table tmp 
as select '1' id ;
WARNING:  GLOBAL is deprecated in temporary table creation
LINE 1: create global  temp table tmp 
               ^
SELECT 1
Time: 1.764 ms
taxidb=# select * from tmp;
 id 
----
 1
(1 row)

Time: 0.435 ms
taxidb=# 

--不提示内容
taxidb=# create local  temp table tmp 
taxidb-# as select '1' id ;
SELECT 1
Time: 15.303 ms
taxidb=# select * from tmp
taxidb-# ;
 id 
----
 1
(1 row)

Time: 0.737 ms

-- temporary 和 temp 一样
taxidb=# create  temp table tmp1 as select '1' id ;
SELECT 1
Time: 1.724 ms
taxidb=# create  temporary  table tmp2 as select '1' id ;
SELECT 1
Time: 2.026 ms
taxidb=# \d tmp1
             Table "pg_temp_7.tmp1"
 Column | Type | Collation | Nullable | Default 
--------+------+-----------+----------+---------
 id     | text |           |          | 
Tablespace: "rawdisk"

taxidb=# \d tmp2
             Table "pg_temp_7.tmp2"
 Column | Type | Collation | Nullable | Default 
--------+------+-----------+----------+---------
 id     | text |           |          | 
Tablespace: "rawdisk"

taxidb=# 

-- if not exists 非覆盖，非错误，提示内容。
taxidb=#  create table abc  as  select 2 ;
SELECT 1
Time: 1.316 ms
taxidb=# create table if not exists  abc   as  select 1 ;
NOTICE:  relation "abc" already exists, skipping
CREATE TABLE AS
Time: 0.276 ms
taxidb=# select * from abc;
 ?column? 
----------
        2
(1 row)

Time: 0.404 ms
taxidb=# 

-- on commit 在一个事务里。
taxidb=# create temp table tmp  on commit preserve rows as select 1 id ; 
SELECT 1
Time: 1.083 ms
taxidb=# select * from tmp;
 id 
----
  1
(1 row)

Time: 3.240 ms


taxidb=# create temp table tmp2  on commit delete rows as select 1 id ; 
SELECT 1
Time: 3.869 ms
taxidb=# select * from tmp2;
 id 
----
(0 rows)

Time: 3.225 ms

taxidb=# create temp table tmp3  on commit drop  as select 1 id ; 
SELECT 1
Time: 6.133 ms
taxidb=# select * from tmp3;
ERROR:  relation "tmp3" does not exist
LINE 1: select * from tmp3;
                      ^
Time: 0.297 ms
taxidb=# 

-- with no data 不带数据，空表
taxidb=# create table abc as select 1 id with no data ;
CREATE TABLE AS
Time: 1.307 ms
taxidb=# select * from abc;
 id 
----
(0 rows)

Time: 0.404 ms
taxidb=# 
