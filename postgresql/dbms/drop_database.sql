postgres-# \h drop database 
Command:     DROP DATABASE
Description: remove a database
Syntax:
DROP DATABASE [ IF EXISTS ] name


删除数据库，但是当前数据库不能被删除，需要先切换到其他数据库之后再尝试，
IF EXISTS 如果存在删除，如果不存在不报错，只是提示。
postgres 系统数据库，不能删除
template1 模板数据库，不能删除
template0 模板数据库的模板数据库，不能删除。



-- 删除数据库如果不存在，那么只是提示，不会报错。
postgres=# drop  database  if exists abcdef;
NOTICE:  database "abcdef" does not exist, skipping
DROP DATABASE

--如果该库存在那么删除会直接删除。
postgres=# drop  database  if exists mydb ;
DROP DATABASE
postgres=# drop  database  if exists mydb ;
NOTICE:  database "mydb" does not exist, skipping
DROP DATABASE

--如果没有加if exists ，那么删除一个不存在的库，那么会直接报错。
postgres=# drop  database  mydb ;
2018-12-04 11:12:28.805 EST [29175] ERROR:  database "mydb" does not exist
2018-12-04 11:12:28.805 EST [29175] STATEMENT:  drop  database  mydb ;
ERROR:  database "mydb" does not exist
postgres=# 
