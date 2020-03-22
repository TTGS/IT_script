在PG10中推出了新一代的分区技术。不再使用之前的继承技术了。
新一代的分区表特点也有很多，本文尝试和大家一起讨论pg的新一代的分区表的特点等。

目前有list方式分区和range分区两种方式。
在range分区中有两个关键词叫做maxvalue和minvalue（注意，他俩是单数形式），分别代表着最大和最小或者说是负无穷和正无穷。

新一代的分区和之前老分区方法很类似，也是需要一个主表，然后手工去创建各个分区。
在range分区中可以使用minvalue定一个最小的下限值，而maxvalue定一个最大的上限值。
mydb=# create table test (id int , uid uuid ) partition by range(id)  ;
CREATE TABLE
Time: 11.535 ms
mydb=# create table test_min partition  of test(id) for values from (minvalue) to (0);
CREATE TABLE
Time: 4.329 ms


这里有个小问题，就是这个范围是包括下限，但是不包括上限值。
你看直接就报错了吧。说0没有被定义到一个分区中。
mydb=# insert into test select generate_series(-10,0);
ERROR:  no partition of relation "test" found for row
DETAIL:  Partition key of the failing row contains (id) = (0).
Time: 0.452 ms

这不由的让我想问一个事情，如果上限与下限都是同一个值，那么有没有可能是这一个分区里只有这一个值呢？
其实这是不行的，因为pg也会去检查上下限。
mydb=# create table teat_0 partition of test(id) for values from (0) to (0);
ERROR:  empty range bound specified for partition "teat_0"
DETAIL:  Specified lower bound (0) is greater than or equal to upper bound (0).
Time: 1.065 ms

如果我就想呢？保存一个值在某一个分区内呢？
我们可以写这个值和他的最近的一个值。
mydb=# create table teat_0 partition of test(id) for values from (0) to (1);
CREATE TABLE
Time: 0.837 ms

最后为了保证所有数据都进入分区中，创建一个包含全部内容的分区。
这里不得不说一下，目前pg不支持拆分区。所以，拆分另外想办法。
mydb=# create table test_max partition of test(id) for values from (1) to (maxvalue);
CREATE TABLE
Time: 4.066 ms


有没有发现我之前的teat_0的分区名字起错了，
这时候就会有一个问题了，就是分区改名，直接和改表名一样就可以了。
mydb=# alter table teat_0 rename to test_0;
ALTER TABLE
Time: 0.488 ms

这时候我在想，如果有null，那么他会在哪个分区中呢？
尝试插入一个null。
mydb=# insert  into  test values (null);
ERROR:  no partition of relation "test" found for row
DETAIL:  Partition key of the failing row contains (id) = (null).
Time: 0.316 ms

好吧，那么既然没有null的范围，那么我们就创建一个分区，专门放null。
结果报错了，他说这个不符合样式。
mydb=# create table test_max partition of test  for values from (null);
ERROR:  syntax error at or near ";"
LINE 1: ...te table test_max partition of test  for values from (null);
                                                                      ^
Time: 0.172 ms


我们单独创建一个分区了，专门测试一下null
mydb=# create table test_null (id int) partition by range(id) ;
CREATE TABLE
Time: 3.911 ms

建立一个分区，包含全部内容。
mydb=# create table test_min_max partition of test_null for values from (minvalue) to (maxvalue);
CREATE TABLE
Time: 4.061 ms

我们再次尝试插入null进入。看看是否能插入到分区表中。
再次报错了。
mydb=# insert into test_null values(null);
ERROR:  no partition of relation "test_null" found for row
DETAIL:  Partition key of the failing row contains (id) = (null).
Time: 0.317 ms

删除掉原表，一会重新创建。
mydb=# drop table test_null ;
DROP TABLE
Time: 0.895 ms

再次创建一个主表。
mydb=# create table test_null (id int) partition by range(id) ;
CREATE TABLE
Time: 1.059 ms

尝试着将负无穷到null放在一起。
数据库依然一个错误出来。这个错误就明确写出来了。
mydb=# create table test_min_1 partition of test_null for values from (minvalue) to (null);
ERROR:  cannot specify NULL in range bound
Time: 1.557 ms
