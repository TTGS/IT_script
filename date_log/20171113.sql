
postgresql 的explain和explain analyze不同。  

2017-11-13 13:12:31
标签：postgresql  数据库管理  功能 

在pg中可以使用explain参数查询执行计划，也可以使用explain analyze命令让执行计划实际去执行并且抓取一下实际效果和预测效果。

但是你知道吗？explain analyze和explain效果也是不太一样的。
怎么不一样呢？因为他真的会帮你执行一下sql而且是不会回滚的。

先创建一个带有数据的表。
mydb=# create table test1 as select 1 id ;
SELECT 1
Time: 7.697 ms

我们直接使用explain analyze命令去查看一个更新操作的执行计划。
mydb=# explain analyze update test1 set id=2;
                                                QUERY PLAN                                                
----------------------------------------------------------------------------------------------------------
 Update on test1  (cost=0.00..35.50 rows=2550 width=10) (actual time=0.026..0.026 rows=0 loops=1)
   ->  Seq Scan on test1  (cost=0.00..35.50 rows=2550 width=10) (actual time=0.004..0.005 rows=1 loops=1)
 Planning time: 0.058 ms
 Execution time: 0.294 ms
(4 rows)

Time: 0.924 ms

然后再次查看表中数据。
mydb=# select * from test1;
 id
----
  2
(1 row)

Time: 0.179 ms

看到表中数据被修改了吗？
确实会被执行，不要忘记pg是隐式提交方式，也就是说执行计划完成之后你没有办法撤销回去了。

好，我们再次查看更新语句执行计划。
mydb=# explain update test1 set id=3;
                           QUERY PLAN                           
----------------------------------------------------------------
 Update on test1  (cost=0.00..35.50 rows=2550 width=10)
   ->  Seq Scan on test1  (cost=0.00..35.50 rows=2550 width=10)
(2 rows)

Time: 0.191 ms

再次看到表内信息。
mydb=# select * from test1;
 id
----
  2
(1 row)

Time: 0.171 ms
mydb=#

是的，数据没有变化。

那我们要如何才能不改数据的前提下进行呢？
最简单的方法，我们可以把这个执行计划放在begin中执行，后面紧跟一个rollback

mydb=# begin ;
BEGIN
Time: 0.066 ms
mydb=# explain analyze update test1 set id=4;
                                                QUERY PLAN                                                
----------------------------------------------------------------------------------------------------------
 Update on test1  (cost=0.00..35.50 rows=2550 width=10) (actual time=0.024..0.024 rows=0 loops=1)
   ->  Seq Scan on test1  (cost=0.00..35.50 rows=2550 width=10) (actual time=0.006..0.006 rows=1 loops=1)
 Planning time: 0.024 ms
 Execution time: 0.036 ms
(4 rows)

Time: 0.193 ms
mydb=# rollback;
ROLLBACK
Time: 0.131 ms
mydb=# select * from test1;
 id
----
  2
(1 row)

Time: 0.180 ms
mydb=#
这样数据就不会出事了。
