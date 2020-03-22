
使用int类型与numeric类型的区别  

2018-03-19 17:14:41|  分类： PostgreSQL |  标签：postgresql  报错信息  案例   



今天业务数据部门匆匆跑来，一进来就非常亢奋的说，他们发现了一个postgresql的重大bug，在多个版本里都存在，而且很坚信的说。灰常激动的告诉我，他们能用几个简单的sql复现这个bug，
我们来看一下这个复现。
postgres=# create table test(i int , c int) ;
CREATE TABLE
postgres=# insert into test values(1,2);
INSERT 0 1
postgres=# insert into test values(2,3);
INSERT 0 1
postgres=# select i/c ,i ,c from test;
 ?column? | i | c
----------+---+---
        0 | 1 | 2
        0 | 2 | 3
(2 rows)

postgres=# \d test
                Table "public.test"
 Column |  Type   | Collation | Nullable | Default
--------+---------+-----------+----------+---------
 i      | integer |           |          |
 c      | integer |           |          |
 
怎么个bug呢，你看，俩个数字，1和2相除应该得到0.5才对，结果呢，得到了0.2和3相除，应该得到0.3，但数据库里缺得到了0，说明该bug表现是不遵守四舍五入，貌似只是取整。

我的一口老血吐出来了。这XX的是什么鬼。我一个int类型和numeric一样，我要int类型搞毛子啊！！！这里一定有本质上的区别啊！！！！

https://www.postgresql.org/docs/10/static/datatype-numeric.html


8.1.1. Integer Types

The types smallint, integer, and bigint store whole numbers, that is, numbers without fractional components, of various ranges. Attempts to store values outside of the allowed range will result in an error.

The type integer is the common choice, as it offers the best balance between range, storage size, and performance. The smallint type is generally only used if disk space is at a premium. The bigint type is designed to be used when the range of the integer type is insufficient.

SQL only specifies the integer types integer (or int), smallint, and bigint. The type names int2, int4, and int8 are extensions, which are also used by some other SQL database systems.


人家官方文档里说啦，这是整数，整数，整数。也就是说你i列是整数类型，你c列是整数类型，你的“i/c”列出来的也是整数类型，我一个整数怎么能带小数？我要是出0.5那才是出bug了。

有人可能会问，那postgresql如何才能让数据正常显示结果？我应该使用什么类型呢？
根据你的需要去设置类型。postgresql是一种严格数据类型的数据库，他几乎不会修改你的类型。
例如我们可以是用经典的numeric类型，例如

postgres=# create table test (i numeric , c numeric)
postgres-# ;
CREATE TABLE
postgres=# insert into test values(1,2);
INSERT 0 1
postgres=# insert into test values(2,3);
INSERT 0 1
postgres=# select i,c,i/c from test;
 i | c |        ?column?        
---+---+------------------------
 1 | 2 | 0.50000000000000000000
 2 | 3 | 0.66666666666666666667
(2 rows)

postgres=#
这个numeric的优点就是，你的数学运算绝对正确，但是不一定是你想看到的。例如1/2的结果。
要求人家走整数路线，就不要在让别人附加小数。

肯定有人说，我就想看点正常的，我就觉得你这个现实我无法接受，postgresql中也提供了相关可用类型。

postgres=# create table tt (i1 int ,c1 int , i2 numeric ,c2 numeric , i3 double precision ,c3 double precision);
CREATE TABLE
postgres=# insert into tt values (1,2,1,2,1,2);
INSERT 0 1
postgres=#
postgres=#
postgres=# select i1/c1,i2/c2,i3/c3 from tt;
 ?column? |        ?column?        | ?column?
----------+------------------------+----------
        0 | 0.50000000000000000000 |      0.5
(1 row)

postgres=# select i1/c1,i1/c2,i1/c3 from tt;
 ?column? |        ?column?        | ?column?
----------+------------------------+----------
        0 | 0.50000000000000000000 |      0.5
(1 row)

postgres=#
