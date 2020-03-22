
pg中使用sql变量  

2018-05-02 16:36:51|  分类： PostgreSQL |  标签：postgresql  功能  

经常有开发和我吐槽，说postgresql没有sql变量，非要封装到匿名块里或者函数里才能完成变量赋值。其实开发向我吐槽我无所谓，因为他们可能并不熟悉pg数据库，让我不能忍受的是，很多pg的dba都不知道pg的sql变量赋值怎么弄。

先明确一个事情，什么是sql变量？
其实很简单，就是有些sql是固定的，但是每次进来查询的条件内容不太一样，比如说可能我们每次查询都是不同的值，但是用的sql一样的。

在oracle中是使用“&”和“&&”，sql server 中使用的是"@" ，mysql中也是用“@”。

很多pg的管理员都不清楚这个pg的变量应该如何使用。

好的，这次我也聊聊pg的sql变量应该如何声明和使用。

在pg中是用set [session|local] 变量名 [to|=] 值
postgres=# set my.abc=100;
SET

这里注意，为了区分你的和系统的变量，防止你影响系统。所以用户的这种变量名称必须有一个点"."，也就是匿名看到的my.abc的点。

我们可以这样声明变量。那么应该如何使用变量呢？直接写上去，pg就乱报错，不是列不存在就是表不对....
pg使用sql变量也是有要求的，第一你想用变量必须使用系统的一个函数current_setting，第二，你在这个函数后面需要明确数据类型。第三，current_setting中的名称需要用单引号引起来。第四，变量名默认是小写保存，你在用的时候必须大小写一样。
例如
postgres=# set my.abc=3;
SET
postgres=# select generate_series(1,current_setting('my.abc')::int);
 generate_series
-----------------
               1
               2
               3
(3 rows)

postgres=# show my.abc;
 my.abc
--------
 3
(1 row)

如果你声明了一个不带点的变量，那么他就会吼吼
postgres=# set a=1;
ERROR:  unrecognized configuration parameter "a"

在声明变量set后面是一个session和local的选择，默认是session，就是说这次连接有效，例如
postgres=# set my.abc=3;
SET
postgres=# \q
[postgres@lion ~]$ psql
psql (10.3)
Type "help" for help.

postgres=# show my.abc;
ERROR:  unrecognized configuration parameter "my.abc"
postgres=#

你断开连接那么就失效了。变量就被清理了。

那local是不是在本地永久声明了？不是！
postgres=# set local my.abc=100;
WARNING:  SET LOCAL can only be used in transaction blocks
SET
postgres=#
看到了吗？pg的提示，事务中哟～～

postgres=# \h set
Command:     SET
Description: change a run-time parameter
Syntax:
SET [ SESSION | LOCAL ] configuration_parameter { TO | = } { value | 'value' | DEFAULT }
SET [ SESSION | LOCAL ] TIME ZONE { timezone | LOCAL | DEFAULT }


好，我们再来说点开头的变量。这种声明是危险的，set的时候，点前面必须写session，否则报错，因pg会自动的在你的点前面加上session作为前缀，也就是说你在调用的时候也必须增加session。
postgres=# set .a =2;
ERROR:  syntax error at or near "."
LINE 1: set .a =2;
直接报错，如果不加local或者session

postgres=# set session .a =2;
SET
postgres=# select generate_series(1,current_setting('.a')::int);
ERROR:  unrecognized configuration parameter ".a"
你看报错了吧！我们再来。
postgres=# set session     .a=2;
SET
postgres=# show session   .a ;
 session.a
-----------
 2
(1 row)

postgres=# select current_setting('session.a');
 current_setting
-----------------
 2
(1 row)

postgres=#

当然local也是一样的
postgres=# begin;
BEGIN
postgres=# set local    .b=100;
SET
postgres=# show local.b;
 local.b
---------
 100
(1 row)

postgres=# select current_setting('local.b');
 current_setting
-----------------
 100
(1 row)

postgres=#

当然有人会问，我用set_config函数声明变量可以吗？当然可以，不过他的第三个参数false是session，true是local，当你不在一个事务中，他并不报错。
postgres=# select set_config('my.qw','3',false);
 set_config
------------
 3
(1 row)

postgres=# select current_setting('my.qw');
 current_setting
-----------------
 3
(1 row)

postgres=# select set_config('my.tr','11',true);
 set_config
------------
 11
(1 row)

postgres=# select current_setting('my.tr');     
 current_setting
-----------------
 
(1 row)

postgres=# begin;
BEGIN
postgres=# select set_config('my.tr','22',true);
 set_config
------------
 22
(1 row)

postgres=# select current_setting('my.tr');
 current_setting
-----------------
 22
(1 row)

postgres=# end ;
COMMIT
postgres=#
