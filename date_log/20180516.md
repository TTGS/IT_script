
PostgreSQL在表格里的日期和数值如何运算  

2018-05-16 15:50:34|  分类： PostgreSQL |  标签：postgresql  功能  sql关键词  


我们来聊聊postgresql中的时间计算。

今天和开发聊起来说他们想到一个很好的设计，他们在X数据库里就是这样做的，玩的还挺爽，但是pg不支持，他们很遗憾，说pg虽然不错，但是要走的路很长。我很好奇，问了一下是怎么样的一种设计。听完了设计，非常感慨，不会就说不会，非说人家不支持。还非常初级的使用了非间隔类型。

设计很简单，也是之前被框架师们广泛使用的，就是记录一个开始时间点，在关键时候记录代码中的时间差到数据库，如果你要任何一个时间点，都可以通过开始时间加时间差得到。也方便业务分析人员去分析每个埋点数据的问题。另一方面也降低了服务器时间不同步造成的问题。

我们先按照开发说的进行初始化内容。

postgres=# create table public.test(t date , i int);
CREATE TABLE
postgres=# insert into public.test values(current_date,30);
INSERT 0 1

类仿按照x数据库的写法去做

postgres=# select t,i,t+ interval i day  from public.test;
ERROR:  syntax error at or near "day"
LINE 1: select t,i,t+ interval i day  from public.test;
                                 ^
postgres=#

你看，不行了吧。

你自己加这俩列试试啊！
postgres=# select t,i,t+i from public.test;
     t      | i  |  ?column?  
------------+----+------------
 2018-05-16 | 30 | 2018-06-15
(1 row)

这里面的内容如果是放的是天数，那没问题，可是如果我们的i列放的是秒呢？

postgres=# select t,i,t+ interval i sec  from public.test;
ERROR:  syntax error at or near "sec"
LINE 1: select t,i,t+ interval i sec  from public.test;
                                 ^
报错就一样了，这时候怎么办呢？x数据库就行是哈。

其实这个事情不是pg不能做，是做的方式有点不同而已。

postgres=# select t,i,t+(i||'sec')::interval  from public.test;
     t      | i  |      ?column?       
------------+----+---------------------
 2018-05-16 | 30 | 2018-05-16 00:00:30
(1 row)

他需要你把数字和单位连接并且作为一个整体括起来，在告诉数据这是interval类型就好了。当然其他的单位也可以。写法类似


postgres=# select t,i,t+(i||'year')::interval+(i||'hour')::interval  from public.test;
     t      | i  |      ?column?       
------------+----+---------------------
 2018-05-16 | 30 | 2048-05-17 06:00:00
(1 row)


实际上你不知道，pg本身有个时间间隔数据类型叫做interval ，需要你写你保存的数字是什么时间单位，
当然插入的时候也要你明确一下是什么时间类型。
postgres=# create table public.test2(t date , i interval SECOND);
CREATE TABLE
postgres=# insert into public.test2 values(current_date,interval '30' second);
INSERT 0 1
postgres=# select t,i,t+i  from public.test2;                     
     t      |    i     |      ?column?       
------------+----------+---------------------
 2018-05-16 | 00:00:30 | 2018-05-16 00:00:30
(1 row)

你看是不是直接就支持了呢？
