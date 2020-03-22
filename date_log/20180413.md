
创造一个数据库中一个伪全局视图  

2018-04-13 14:24:45|  分类： PostgreSQL |  标签：postgresql  功能   


今天看到有人问，说他想实现一个像pg_database一样的系统表的全局系统表。
新创建的库也能看到，新用户登录到任何库也能看到，但是源头就一个。
任何修改源头都可以看到。
他非常想通过源代码级去做这个事情，我不推荐从源代码层修改，
创建几个简单的命令和基础知识就能做到，何必要冒风险去做代码修改呢？
我也希望借此能普及一下关于postgresql的知识点。

说明，这里我的超级用户是dev，密码是postgres

先登录到postgres上进行创建，这里是pg的系统中枢，
理论上任何人都不应来这里，更不用说在这里创建东西了。
我们在这里创建内容。
postgres=# \connect  postgres
You are now connected to database "postgres" as user "dev".

创建你要的源头表。
postgres=# create table my_abc as select 123::int id ;
SELECT 1

授权给public， 这样今后创建的用户也能用了。
postgres=# grant select on my_abc to public ;
GRANT

到template1 里，这个库又名模板数据库，所有新创建的数据默认都是有template1创建而来， template0 和template1的区别在于0能改字符集，1不能改字符集。推荐一个服务器的字符集都统一，防止乱码。
postgres=# \connect template1
You are now connected to database "template1" as user "dev".

由于所有来源都要来自于这里。所以牵扯到一个跨库问题，我们需要用postgres_fdw，作为跨库准备。
template1=# CREATE SERVER foreign_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '5432', dbname 'postgres');
CREATE SERVER

创建映射用户，给public，这样大家都能看了。
template1=# CREATE USER MAPPING FOR public SERVER foreign_server OPTIONS (user 'dev', password 'postgres');
CREATE USER MAPPING

创建全局视图。这里也可以使用函数再次进行封装，内嵌检查之类的。
template1=# CREATE FOREIGN TABLE v_abc (id numeric) SERVER foreign_server  OPTIONS (schema_name 'public', table_name 'my_abc');
CREATE FOREIGN TABLE

授权这个视图给public
template1=# grant select on v_abc to public;
GRANT

好了，试试吧，新创建一个库，看看能不能看到我们的全局表？
template1=# create database mydb;
CREATE DATABASE
template1=# \connect mydb
You are now connected to database "mydb" as user "dev".
mydb=# select * from v_abc;
 id  
-----
 123
(1 row)

插入一条数据，再看看。
mydb=# \connect postgres
You are now connected to database "postgres" as user "dev".
postgres=# insert into my_abc values (2);
INSERT 0 1
postgres=# select * from my_abc;
 id  
-----
 123
   2
(2 rows)

postgres=# \connect mydb
You are now connected to database "mydb" as user "dev".
mydb=# select * from v_abc;
 id  
-----
 123
   2
(2 rows)

建立一个用户看看吧。
mydb=# create user testuser password '123';
CREATE ROLE
mydb=# \connect mydb testuser
Password for user testuser:
You are now connected to database "mydb" as user "testuser".
mydb=> select * from v_abc;
 id  
-----
 123
   2
(2 rows)

但是这有几个事情，
1，我假设你是一个不会把postgres库当成普通库那么用的地方，如果你到postgres里，是看不到v_abc的。
2，我假设你的新数据库是同一字符集的，也就是来源都用的template1的，如果你用template0作为创建数据库的模板，那么他将失去效果。
3，我的postgres_fdw绑定到了超级用户，是因为这个用户你不可能删除，但是这可能会造成你的权限过大的问题。
4，如果你一定要找pg_database相关的创建内容，他在安装目录下的include/server/catalog/pg_database.h 里 。
