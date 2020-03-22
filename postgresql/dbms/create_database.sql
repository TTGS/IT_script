Command:     CREATE DATABASE
Description: create a new database
Syntax:
CREATE DATABASE name
    [ [ WITH ] [ OWNER [=] user_name ]
           [ TEMPLATE [=] template ]
           [ ENCODING [=] encoding ]
           [ LC_COLLATE [=] lc_collate ]
           [ LC_CTYPE [=] lc_ctype ]
           [ TABLESPACE [=] tablespace_name ]
           [ ALLOW_CONNECTIONS [=] allowconn ]
           [ CONNECTION LIMIT [=] connlimit ]
           [ IS_TEMPLATE [=] istemplate ] ]
		   
该命令不能放在任何一个事务中进行。
owner 超级用户可以指定数据库的属主是谁。默认是当前创建人。
TEMPLATE 指定创建的模板，默认template1，template1和template0的区别在于，0可以直接修改字符集，1不行。也可以是其他库。
ENCODING 指定新库的字符集。
LC_COLLATE 影响排序
LC_CTYPE    影响字符分类
TABLESPACE  指定数据库保存的表空间
ALLOW_CONNECTIONS  是否接受对外连接
CONNECTION LIMIT   有多少并发可以连接到该库，默认是-1没有限制。
IS_TEMPLATE  这个库是属于克隆数据库。但也没啥用，在删除的时候，会报错需要先解除限制才能删除。


--指定属主是谁
postgres=# create user viewer ;
CREATE ROLE
postgres=# create database mydb owner=viewer ; 
CREATE DATABASE
postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 mydb      | viewer   | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(4 rows)

postgres=# \c
You are now connected to database "postgres" as user "postgres".
postgres=# 

-- template可以指任何数据库，该数据库里的东西也被复制过来了。
postgres=# create database  nondb2 template nondb  ;
CREATE DATABASE
postgres=# \c nondb2 
You are now connected to database "nondb2" as user "postgres".
nondb2=# \d 
        List of relations
 Schema | Name | Type  |  Owner   
--------+------+-------+----------
 public | a    | table | postgres
 public | b    | table | postgres
(2 rows)

nondb2=# select * from a ; 
 i 
---
(0 rows)

nondb2=# select * from b;
  oid  
-------
 16413
  2619
  1247
  2830
  2831


-- is_template 如果在创建的时候是true，那么删除的时候会报错，需要先解除再删除。
postgres=# drop database  clonedb ;
2018-12-04 11:00:05.675 EST [29175] ERROR:  cannot drop a template database
2018-12-04 11:00:05.675 EST [29175] STATEMENT:  drop database  clonedb ;
ERROR:  cannot drop a template database
postgres=# alter database  clonedb  is_template false ;
ALTER DATABASE
postgres=# 
postgres=# drop database  clonedb ;
DROP DATABASE
postgres=# 
