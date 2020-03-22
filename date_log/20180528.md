
pg授权其他schema下的对象查询权限。  

2018-05-28 11:52:40|  分类： PostgreSQL |  标签：postgresql  功能  概述    
其他schema下的对象，如果授权用户给其他用户查询？

我们先创建一下环境内容，用超级用户 一个 schema，一个对象 和 一个用户 。

ttgs=# create schema myschema;
CREATE SCHEMA
ttgs=# create table myschema.mm as select 'myschema' id ;    
SELECT 1
ttgs=# create user ttuser password 'ttuser' login;
CREATE ROLE

切换到超级用户，授权查询权限给ttuser 。
ttgs=> \c ttgs postgres
You are now connected to database "ttgs" as user "postgres".
ttgs=# grant select on TABLE myschema.mm to ttuser;
GRANT

切换到ttuser，你会发现依然不能查询
ttgs=# \c ttgs ttuser                              
You are now connected to database "ttgs" as user "ttuser".
ttgs=> select * from myschema.mm;                  
ERROR:  permission denied for schema myschema
LINE 1: select * from myschema.mm;
                      ^

这依然是权限不足造成的，因为这个schema的使用也需要一个授权。                      
ttgs=> \c ttgs postgres                            
You are now connected to database "ttgs" as user "postgres".

允许ttuser使用myschema内容。
ttgs=# grant USAGE on SCHEMA myschema to ttuser ;
GRANT
ttgs=# \c ttgs ttuser                            
You are now connected to database "ttgs" as user "ttuser".
ttgs=> select * from myschema.mm;                
    id    
----------
 myschema
(1 row)

这就查询成功了。

肯定有人会问，我就给一个schema的usage权限是不是也能看到这个schema对象？

我们再来模拟一下这种情况。

创建在myschema下新创建一个对象。
ttgs=> \c ttgs postgres                          
You are now connected to database "ttgs" as user "postgres".
ttgs=# create table myschema.xx as select 1 id ;
SELECT 1

根本不授权select on table 的权限。直接查询。
ttgs=# \c ttgs ttuser                           
You are now connected to database "ttgs" as user "ttuser".
ttgs=> select * from myschema.xx;
ERROR:  permission denied for relation xx
ttgs=>


依然是失败的。
