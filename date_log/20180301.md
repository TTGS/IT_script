
ERROR: permission denied to create "pg_catalog.a"  

2018-03-01 16:20:18|  分类： PostgreSQL |  标签：案例  postgresql  参数    


今天开发扔过来一个报错很有意思，报错如下
mydb=# create table a (id int );
ERROR:  permission denied to create "pg_catalog.a"
DETAIL:  System catalog modifications are currently disallowed.

他们说这个错误莫名其妙，为什么呢，他们向我展示了一下相关信息

mydb=# \conninfo
You are connected to database "mydb" as user "postgres" via socket in "/tmp" at port "5432".
mydb=# \c
You are now connected to database "mydb" as user "postgres".
mydb=# \connect
You are now connected to database "mydb" as user "postgres".

按照他们的话说，我一个超级用户，我都不能创建表了，你让别的普通用户怎么活？

其实不得不说，有些朋友说PostgreSQL的报错莫名其妙，根本不说重点。
这样的想法真的不太对，你看让家说的错误是什么。
ERROR:  permission denied to create "pg_catalog.a"
错误：没有权限在pg_catalog名下创建a。
DETAIL:  System catalog modifications are currently disallowed.
细节：系统目录修改当前是不被允许的。

人家说的多明白，你创建这个a在pg_catalog里了，这个是系统的，系统不同意你创建啊亲！

PostgreSQL是按照search_path参数里的顺序进行创建的。
我们show一下
mydb=# show search_path ;
                     search_path                     
-----------------------------------------------------
 "$user",madlib,pg_catalog,information_schema,public
(1 row)

"$user"是指同名的，与你现在使用的用户同名的schema ，既然现在是使用postgres，那么就会找名叫postgres的schema去创建。
如果没有，那么使用下一个，也就是madlib，在没有再下一个。
从错误分析上分析，"$user"和madlib都没有，才用的pg_catalog的哟

所以，\dnS看一下吧
mydb=# \dnS
        List of schemas
        Name        |  Owner   
--------------------+----------
 information_schema | postgres
 pg_catalog         | postgres
 pg_temp_1          | postgres
 pg_toast           | postgres
 pg_toast_temp_1    | postgres
 public             | postgres
(6 rows)

mydb=#

知道原因了，那么就可以去解决了。
要么改search_path参数，要么直接一点，也是我推荐的方式，加schema名去创建对象。
mydb=# create table public.a (id int );
CREATE TABLE

问题解决了。

那dml和dql呢？也是按照顺序去找呀，找到就自动帮你写上，没找到就报错了。

mydb=# insert into a select generate_series(1,1000);
INSERT 0 1000

所以创建带名字还是很重要的。
