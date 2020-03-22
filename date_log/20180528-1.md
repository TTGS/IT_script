
ERROR: role "nww" cannot be dropped because some objects depend on it  

2018-05-28 11:31:48|  分类： PostgreSQL |  标签：postgresql  案例  修复   


如果用户名下有对象，删除用户的时候，pg就会发生类似下面的错误
ERROR:  role "nww" cannot be dropped because some objects depend on it
DETAIL:  owner of table public.bb
owner of table public.aa

这个错误说，nww用户有一个表叫public.bb

这可能就会有一个问题，如果我的东西很多，那么怎么办呢？

这个是pg对用户对象的一种保护，你说删除用户，那么你名下的对象内容怎么处理呢？一起删除还是给别人呢？

一个命令尤其是危险命令，那么将这些写道一起是危险的，pg向用户提供了2个特殊命令
reassign owned by  和 drop owned by ；

reassign owned by 将某人名下的对象改到另一个用户名下。
drop owned by 将某人名下对象都删除。

模拟一下过程。

创建库和nww和oll用户。
postgres=# create database TTGS owner postgres ;    
CREATE DATABASE
postgres=# create user nww password 'nww' login;
CREATE ROLE
postgres=# create user oll password 'oll' login;
CREATE ROLE

登录nww，并且创建对象。
postgres=# \c ttgs nww
You are now connected to database "ttgs" as user "nww".
ttgs=> \conninfo
You are connected to database "ttgs" as user "nww" via socket in "/tmp" at port "5432".
ttgs=> create table public.aa as select * from pg_roles;
SELECT 9
ttgs=> create table public.bb as select * from pg_class ;
SELECT 344
ttgs=> \dt+ public.*
                  List of relations
 Schema | Name | Type  | Owner | Size  | Description
--------+------+-------+-------+-------+-------------
 public | aa   | table | nww   | 16 kB |
 public | bb   | table | nww   | 80 kB |
(2 rows)


我的nww名下有两个表。
然后我们删除该用户。
我们就看到开头提到的错误了。
ttgs=> \c ttgs postgres
You are now connected to database "ttgs" as user "postgres".
ttgs=# drop user nww;
ERROR:  role "nww" cannot be dropped because some objects depend on it
DETAIL:  owner of table public.bb
owner of table public.aa

好了我们直接使用 reassign owned by 进行对象转移。
ttgs=# reassign owned by nww to oll;
REASSIGN OWNED
ttgs=# \dt+ public.*
                  List of relations
 Schema | Name | Type  | Owner | Size  | Description
--------+------+-------+-------+-------+-------------
 public | aa   | table | oll   | 16 kB |
 public | bb   | table | oll   | 80 kB |
(2 rows)

对象都被转移走了，那么再次删除nww用户。
ttgs=# drop user nww;
DROP ROLE

如果使用 drop owned by 呢？
ttgs=# \dt+ public.*
                  List of relations
 Schema | Name | Type  | Owner | Size  | Description
--------+------+-------+-------+-------+-------------
 public | aa   | table | oll   | 16 kB |
 public | bb   | table | oll   | 80 kB |
(2 rows)

ttgs=# drop owned by oll ;
DROP OWNED
ttgs=# \dt+ public.*
Did not find any relation named "public.*".

你会发现，oll名下的对象都被删除了。


当然drop database 是不会问你的，他主要是在删除用户的时候进行提示。

ttgs=> create table public.dd as select * from pg_class;
SELECT 341
ttgs=> \dt+ public.*
                  List of relations
 Schema | Name | Type  | Owner  | Size  | Description
--------+------+-------+--------+-------+-------------
 public | dd   | table | dduser | 80 kB |
(1 row)

ttgs=> \c postgres postgres
You are now connected to database "postgres" as user "postgres".
postgres=# \conninfo
You are connected to database "postgres" as user "postgres" via socket in "/tmp" at port "5432".
postgres=# drop database ttgs;
DROP DATABASE
postgres=#


所以这点需要注意。
