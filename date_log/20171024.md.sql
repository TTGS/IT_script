
ERROR: there is no unique or exclusion constraint matching the ON CONFLICT specification  

2017-10-24 22:08:38
标签：postgresql  报错信息  案例  
       

  下载LOFTER
我的照片书  |
今天突然有人报错，错误提示如下
ERROR:  there is no unique or exclusion constraint matching the ON CONFLICT specification

这是怎么回事？其实错误说的很明显，说 没有匹配ON CONFLICT规范的唯一或排除约束

就是使用on conflict然后有没有符合人家的需要。
看下下面的操作复现错误。

postgres=# create  table  a (d int ) ;
CREATE TABLE
postgres=# insert into a values (1) on conflict (d) do nothing;
ERROR:  there is no unique or exclusion constraint matching the ON CONFLICT specification
postgres=# drop table a ;
DROP TABLE

看到错误了吗？这是怎么回事呢？其实在insert中的on conflict 中，是要求有主键的。使用主键就可以了。

看下面的操作。

postgres=# create  table  a (d int primary key  ) ;
CREATE TABLE
postgres=# insert into a values (1) on conflict (d) do nothing;
INSERT 0 1
postgres=# insert into a values (1) on conflict (d) do nothing;
INSERT 0 0
postgres=# select * from a ;
 d
---
 1
(1 row)

重复的内容并没有被插入到表中。也没有报错。

有人肯定要问，如果我在 on conflict中没有使用主键列，会如何呢？
再看下面的操作。

postgres=# drop table a ;
DROP TABLE
postgres=# create table a (d int primary key , c int );
CREATE TABLE
postgres=# insert into a values (1,1) on conflict (c) do nothing;
ERROR:  there is no unique or exclusion constraint matching the ON CONFLICT specification
postgres=#

on conflict后面的列必须为主键列。才行哟
