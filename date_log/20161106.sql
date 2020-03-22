从一个报错信息说起链接与设计问题
psql: FATAL: remaining connection slots are reserved for non-replication superuser connections  

2016-11-26 10:28:09
 标签：postgresql  报错信息 


今天生产数据库上碰到一个错误，本身错误不在程序本身，而是设计上的一些问题，记录下来。

[postgres@vd ~]$ psql -d mydb -U appuser
psql: FATAL:  remaining connection slots are reserved for non-replication superuser connections
#使用普通用户登录到数据库的时候数据库报错。并且拒绝链接访问。

[postgres@vd ~]$ psql -U postgres -d mydb
psql (9.5.4)
Type "help" for help.

mydb=# \q
#而我使用超级用户登录到该数据库却并没有提示错误。

[postgres@vd ~]$ psql -U appuser  -d mydb
psql: FATAL:  remaining connection slots are reserved for non-replication superuser connections
[postgres@vd ~]$ psql -U postgres -d mydb
psql (9.5.4)
Type "help" for help.

mydb=> select datname,datconnlimit from pg_database ;
  datname  | datconnlimit 
-----------+--------------
 template1 |           -1
 template0 |           -1
 postgres  |           -1
 mydb      |           -1
(4 rows)
#数据库链接数并没有进行限制。也就是说链接上线不是数据库自身设置抛出。

mydb=# select count(*) from pg_stat_activity ;
 count 
-------
     402
(1 row)

mydb=# select current_setting('max_connections');
 current_setting 
-----------------
 410
(1 row)

mydb=# select current_setting('superuser_reserved_connections');
 current_setting 
-----------------
 10
(1 row)
#用超级用户登录上去检查一下链接数是否正常。
#max_connections是总链接数，
#superuser_reserved_connections是为超级用户预留的用户数，
#也就是说 ：普通用户最多可以登录数量=max_connections-superuser_reserved_connections

mydb=# select pg_terminate_backend(pid) from pg_stat_activity where pid<>pg_backend_pid() and status='idle';
 pg_terminate_backend 
----------------------
 t
...(省略)...
 t
(352 row)

#经过协调，相关人员同意将空闲用户都清除出去。使用pg_terminate_backend函数可以从数据库服务器端直接断开这些空闲链接。
#当然我自己的链接不能被断开。pg_backend_pid()是自己的pid号。

mydb=# \q
[postgres@vd ~]$ psql -U appuser  -d mydb
psql (9.5.4)
Type "help" for help.

mydb=> \q
#再次使用普通用户链接就没有这个问题了。


追其发生原因，是业务方面不断增加任务需求，而开发人员为了增加任务同时工作数量，
在中间件上不断增加链接数，而数据库端却没有增加，
不增加数据库上的总链接数是因为怕数据库端内存不够而不敢无休止的增加，
希望中间件能协调好复用链接，但没想到中间件最后解决的方法是直接占满数据库链接，
起始中间件的日志中也有不少该报错，只是没有发现。

这里不得不吐嘈一下，目前postgresql数据库还没有共享链接方式，只能是来一个链接起一个进程（非windows），
一般是使用中间件来控制链接过多的问题，
但是无论是使用什么中间件也不能无休止的增加数据库链接来解决业务需求过多的问题。
