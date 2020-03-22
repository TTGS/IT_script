
postgresql中的search_path参数  

2018-04-28 14:43:52|  分类： PostgreSQL |  标签：postgresql  参数  


search_path是当你寻找某个对象的时候，数据库查找schema的顺序及范围。
看一个实验。

在postgresql中，postgresql.conf中最后一个参数生效。
[postgres@lion ~]$ cat db/pgdata/postgresql.conf |grep search_path
#search_path = '"$user", public'        # schema names
search_path = '"$user", public'
[postgres@lion ~]$ pg_ctl start -D db/pgdata/
[postgres@lion ~]$ psql
psql (10.3)
Type "help" for help.

postgres=# create database mydb;
CREATE DATABASE
postgres=# create schema myschema ;
CREATE SCHEMA
postgres=# \c mydb
You are now connected to database "mydb" as user "postgres".
mydb=# create table myschema.test as select 1 id ;
ERROR:  schema "myschema" does not exist
这里有个小知识点，就是schema是数据库和数据库对象之间的一个逻辑层，
也就是说，在不同的数据库下，可以创建同名的schema 。

我们在mydb里创建一个schema ， mydb里的schema 。
mydb=# create schema myschema ;
CREATE SCHEMA
mydb=# create table myschema.test as select 1 id ;
SELECT 1
mydb=# show search_path;
   search_path   
-----------------
 "$user", public
(1 row)

mydb=# select * from test;
ERROR:  relation "test" does not exist
LINE 1: select * from test;
                      ^
mydb=# select * from myschema.test;
 id
----
  1
(1 row)
 
这里会看到这样一个问题直接写没有，但是写schema，就能查出来。
没写schema，他去哪里去查找的呢？
我们直接不写schema，看看他创建在哪里。
 
mydb=# create table test as select 2 id ;
SELECT 1
mydb=# select * from test ;
 id
----
  2
(1 row)

mydb=# select relname,relnamespace from pg_class where relname='test';
 relname | relnamespace
---------+--------------
 test    |         2200
 test    |        16404
(2 rows)


mydb=# select oid , * from pg_namespace where oid in (2200,16404);
  oid  |      nspname       | nspowner |               nspacl                
-------+--------------------+----------+-------------------------------------
  2200 | public             |       10 | {postgres=UC/postgres,=UC/postgres}
 16404 | myschema           |       10 |
(2 rows)

mydb=#

看到了么，没有写就直接创建在public里了。这也就是在开头写的-“search_path是当你寻找某个对象的时候，数据库查找schema的顺序及范围。”
mydb=# select * from myschema.test;      
 id
----
  1
(1 row)

mydb=# select * from public.test;  
 id
----
  2
(1 row)

那么为什么myschema里的test找不到呢？因为在查找的时候，search_path中里没有myschema，所以查找的时候没有找myschema
我们把这个myschema加入到search_path中。
[postgres@lion ~]$ cat db/pgdata/postgresql.conf |grep search_path
#search_path = '"$user", public'        # schema names
search_path = '"$user", public,myschema'
[postgres@lion ~]$ pg_ctl restart -m f -D db/pgdata/
[postgres@lion ~]$ psql -d mydb
psql (10.3)
Type "help" for help.

mydb=# select * from test ;
 id
----
  2
(1 row)

看到了么，如果我们把参数的内容修改了，结果是否会变化吗？

[postgres@lion ~]$ cat db/pgdata/postgresql.conf |grep search_path
#search_path = '"$user", public'        # schema names
search_path = '"$user",myschema,public'          

我们看下会不会有不同。
[postgres@lion ~]$ pg_ctl restart -m f -D db/pgdata/
[postgres@lion ~]$ psql -d mydb                     
psql (10.3)
Type "help" for help.

mydb=# select * from test ;
 id
----
  1
(1 row)

mydb=# \q

可能会有不少童鞋会问，为什么pg不会像oracle那样，直接从数据字典表里去找数据库对象，而使用了一个参数去控制呢？oracle的做法是用户和schema是“一个”，也就是说，一个用户名下，对象名称是相对唯一的，而pg允许多个用户和多个schema，那么这时候我们还是使用数据字典表，可能会找到多个对象。数据库没法知道你到底要的那个表。所以，就是用了一个search_path参数去控制到底是那个schema。
