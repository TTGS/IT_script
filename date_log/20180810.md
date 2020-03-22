
pg：Jsonb数据类型的索引与查询  

2018-08-10 18:14:30|  分类： PostgreSQL |  标签：postgresql  功能   

今天群里有人问jsonb的查询问题，感觉很有意思，于是想写点自己的东西出来。

群里问的问题很简单，就是我有个jsonb的列，加了一个btree索引，查询的时候还是走了表扫描。

那肯定的，因为btree是传统的数据类型常用的，而对于这jsonb就“无效”了。

那么如果我有这样的需求怎么办呢？我的数据真的很多，没有索引我会很郁闷的～～

那么我们真的对查询jsonb类型一点办法都没有，当然不是。

对于PG来说，很多时候不是它不好使，而是你不知道怎么使用。

这里我提供我知道也是我长使用的几种方式快速查询jsonb类型数据，我们分别去找key ，values，和jsonb。

ttgs=# select version();

                                                 version                                            

   

---------------------------------------------------------------------------------------------------------

 PostgreSQL 10.4 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-16), 64-bit

(1 row)

 

让我们先创建测试表和一点测试数据，这个数据不宜太少，如果是1G，2G数据太惨了，基本上就是被pg秒杀的过程。所以多塞点数据。

 

CREATE TABLE testtable (id  int, qty jsonb);

INSERT INTO testtable (id,qty)

VALUES ( 1, '{"2018-08-01": 10, "2018-08-11": 20, "2018-10-23": 30}' ),

 ( 2, '{"2018-08-17": 100, "2018-11-01": 200}' ),

 ( 3, '{"2018-09-03": 1, "2018-09-01": 2, "2018-10-01": 3}' );

然后我不断的插入数据进去

ttgs=# insert into testtable select * from testtable ;

塞到大于这样为止

ttgs=# \dt+ testtable

                       List of relations

 Schema |   Name    | Type  |  Owner   |  Size   | Description

--------+-----------+-------+----------+---------+-------------

 public | testtable | table | postgres | 6828 MB |

(1 row)

 

我想这么大的数据量应该可以反映问题了：D

 

 

1， gin

pg自带一种索引类型，叫gin，属于全文检索 。

ttgs=# create index idx_gin on testtable using gin(qty);

CREATE INDEX

Time: 101447.944 ms (01:41.448)

ttgs=# \di+ idx_gin

                           List of relations

 Schema |  Name   | Type  |  Owner   |   Table   |  Size  | Description

--------+---------+-------+----------+-----------+--------+-------------

 public | idx_gin | index | postgres | testtable | 359 MB |

(1 row)

 

ttgs=#

 

我们再来看看他们的速度如何

ttgs=# explain analyze select * from testtable where qty @> '{"2018-08-01":1}'::jsonb;

                                                         QUERY PLAN                                 

                       

-----------------------------------------------------------------------------------------------------------------------------

 Bitmap Heap Scan on testtable  (cost=959.59..196632.76 rows=62915 width=79) (actual time=1117.389..1117.389 rows=0 loops=1)

   Recheck Cond: (qty @> '{"2018-08-01": 1}'::jsonb)

   ->  Bitmap Index Scan on idx_gin  (cost=0.00..943.86 rows=62915 width=0) (actual time=1117.385..1117.385 rows=0 loops=1)

         Index Cond: (qty @> '{"2018-08-01": 1}'::jsonb)

 Planning time: 3.917 ms

 Execution time: 1117.431 ms

(6 rows)

 

Time: 1122.656 ms (00:01.123)

ttgs=# explain analyze select * from testtable where qty ? '2018-08-01';

                                                             QUERY PLAN                             

                               

-------------------------------------------------------------------------------------------------------------------------------------

 Bitmap Heap Scan on testtable  (cost=723.59..196396.76 rows=62915 width=79) (actual time=917.785..132717.798 rows=11534336 loops=1)

   Recheck Cond: (qty ? '2018-08-01'::text)

   Rows Removed by Index Recheck: 48366107

   Heap Blocks: exact=51260 lossy=822554

   ->  Bitmap Index Scan on idx_gin  (cost=0.00..707.86 rows=62915 width=0) (actual time=906.422..906.422 rows=11534336 loops=1)

         Index Cond: (qty ? '2018-08-01'::text)

 Planning time: 0.085 ms

 Execution time: 133336.408 ms

(8 rows)

 

Time: 133336.871 ms (02:13.337)

ttgs=# explain analyze select * from testtable where qty ? '1';

                                                      QUERY PLAN                                    

                 

-----------------------------------------------------------------------------------------------------------------------

 Bitmap Heap Scan on testtable  (cost=723.59..196396.76 rows=62915 width=79) (actual time=3.561..3.561 rows=0 loops=1)

   Recheck Cond: (qty ? '1'::text)

   ->  Bitmap Index Scan on idx_gin  (cost=0.00..707.86 rows=62915 width=0) (actual time=3.556..3.556 rows=0 loops=1)

         Index Cond: (qty ? '1'::text)

 Planning time: 0.104 ms

 Execution time: 3.589 ms

(6 rows)

 

Time: 4.085 ms

 

正如各位所见，找value和jsonb都是很快的，但是找key就不好了，太慢了。

 

 

2， btree_gin

这个是pg的一个扩展，官方文档里有介绍，按照也是很简单。

ttgs=# drop index idx_gin ;

DROP INDEX

Time: 22.830 ms

ttgs=# create extension btree_gin ;

CREATE EXTENSION

Time: 61.268 ms

ttgs=# create index idx_btree_gin on testtable using gin(qty);

CREATE INDEX

Time: 103814.957 ms (01:43.815)

ttgs=# \di+ idx_btree_gin

                              List of relations

 Schema |     Name      | Type  |  Owner   |   Table   |  Size  | Description

--------+---------------+-------+----------+-----------+--------+-------------

 public | idx_btree_gin | index | postgres | testtable | 359 MB |

(1 row)

 

ttgs=#

 

在看看他们的速度

ttgs=# explain analyze select * from testtable where qty @> '{"2018-08-01":1}'::jsonb;

                                                            QUERY PLAN                              

                            

----------------------------------------------------------------------------------------------------------------------------------

 Bitmap Heap Scan on testtable  (cost=959.59..196632.76 rows=62915 width=79) (actual time=1148.308..1148.308 rows=0 loops=1)

   Recheck Cond: (qty @> '{"2018-08-01": 1}'::jsonb)

   ->  Bitmap Index Scan on idx_btree_gin  (cost=0.00..943.86 rows=62915 width=0) (actual time=1148.305..1148.305 rows=0 loops=1)

         Index Cond: (qty @> '{"2018-08-01": 1}'::jsonb)

 Planning time: 4.529 ms

 Execution time: 1148.399 ms

(6 rows)

 

Time: 1153.502 ms (00:01.154)

ttgs=# explain analyze select * from testtable where qty ? '2018-08-01';

                                                              QUERY PLAN                            

                                 

---------------------------------------------------------------------------------------------------------------------------------------

 Bitmap Heap Scan on testtable  (cost=723.59..196396.76 rows=62915 width=79) (actual time=938.375..133649.397 rows=11534336 loops=1)

   Recheck Cond: (qty ? '2018-08-01'::text)

   Rows Removed by Index Recheck: 48366107

   Heap Blocks: exact=51260 lossy=822554

   ->  Bitmap Index Scan on idx_btree_gin  (cost=0.00..707.86 rows=62915 width=0) (actual time=923.504..923.504 rows=11534336 loops=1)

         Index Cond: (qty ? '2018-08-01'::text)

 Planning time: 0.094 ms

 Execution time: 134264.864 ms

(8 rows)

 

Time: 134265.346 ms (02:14.265)

ttgs=# explain analyze select * from testtable where qty ? '1';

                                                         QUERY PLAN                                 

                      

----------------------------------------------------------------------------------------------------------------------------

 Bitmap Heap Scan on testtable  (cost=723.59..196396.76 rows=62915 width=79) (actual time=3.696..3.696 rows=0 loops=1)

   Recheck Cond: (qty ? '1'::text)

   ->  Bitmap Index Scan on idx_btree_gin  (cost=0.00..707.86 rows=62915 width=0) (actual time=3.691..3.691 rows=0 loops=1)

         Index Cond: (qty ? '1'::text)

 Planning time: 0.109 ms

 Execution time: 3.724 ms

(6 rows)

 

Time: 4.204 ms

 

 

是的，values和jsonb速度是非常不错，但是在key查询就不行了。

 

你先等一下，这个btree_gin和gin好像速度差不多，那我为什么还要弄个扩展上去？

 

实际上是在dml的时候的维护代价，我复制testtable表到testtable1和testtable2，插入testtable表数据

ttgs=# select count(*) from testtable;

  count  

----------

 63914560

(1 row)

 

 

在testtable2上创建btree_gin ，

ttgs=# create index idx_btree_gin on testtable2 using gin(qty);

CREATE INDEX

Time: 105579.942 ms (01:45.580)

ttgs=# insert into testtable2 select * from testtable ;

INSERT 0 63914560

Time: 411679.726 ms (06:51.680)

 

在testtable1上创建gin ，（当然删除掉扩展之后创建）

ttgs=# create index idx_gin on testtable1 using gin(qty);

CREATE INDEX

Time: 104731.355 ms (01:44.731)

ttgs=# insert into testtable1 select * from testtable ;

INSERT 0 63914560

Time: 416635.930 ms (06:56.636)

 

维护索引的代价相差了将近5秒时间。

 

有同学会说gist比gin要好，是这样，gist不能支持jsonb，如果你创建gist在jsonb上会出现错误。

ttgs=# create index idx_gist on testtable using gist(qty);

ERROR:  data type jsonb has no default operator class for access method "gist"

HINT:  You must specify an operator class for the index or define a default operator class for the data type.

Time: 2.067 ms

 

 

 
3，并行

如果您使用的是10以上版本，那么这个将是一个很好的方式，在使用9.6的朋友我并不推荐使用这个方式。因为我觉得9.6并行真的没有10好使，嘿嘿....

 

并行与max_parallel_workers_per_gather 和 max_parallel_workers 有关，默认开启。

ttgs=# show max_parallel_workers;

 max_parallel_workers

----------------------

 8

(1 row)

 

Time: 0.284 ms

ttgs=# show max_parallel_workers_per_gather ;

 max_parallel_workers_per_gather

---------------------------------

 2

(1 row)

 

Time: 0.217 ms

 

因为pg10自己就带2个并行，所以在查询的时候自动开启了并行。

 

ttgs=# explain analyze select * from testtable where qty @> '{"2018-08-01":1}'::jsonb;

                                                             QUERY PLAN                             

                               

-------------------------------------------------------------------------------------------------------------------------------------

 Gather  (cost=1000.00..1208785.75 rows=62915 width=79) (actual time=25033.395..25033.395 rows=0 loops=1)

   Workers Planned: 2

   Workers Launched: 2

   ->  Parallel Seq Scan on testtable  (cost=0.00..1201494.25 rows=26215 width=79) (actual time=25022.059..25022.059 rows=0 loops=3)

         Filter: (qty @> '{"2018-08-01": 1}'::jsonb)

         Rows Removed by Filter: 20971520

 Planning time: 0.463 ms

 Execution time: 25033.521 ms

(8 rows)

 

Time: 25035.143 ms (00:25.035)

ttgs=# explain analyze select * from testtable where qty ? '2018-08-01';

                                                              QUERY PLAN                            

                                 

---------------------------------------------------------------------------------------------------------------------------------------

 Gather  (cost=1000.00..1208785.75 rows=62915 width=79) (actual time=4.073..24553.427 rows=11534336 loops=1)

   Workers Planned: 2

   Workers Launched: 2

   ->  Parallel Seq Scan on testtable  (cost=0.00..1201494.25 rows=26215 width=79) (actual time=1.929..22615.100 rows=3844779 loops=3)

         Filter: (qty ? '2018-08-01'::text)

         Rows Removed by Filter: 17126741

 Planning time: 0.039 ms

 Execution time: 25031.620 ms

(8 rows)

 

Time: 25032.066 ms (00:25.032)

ttgs=# explain analyze select * from testtable where qty ? '1';

                                                             QUERY PLAN                             

                               

-------------------------------------------------------------------------------------------------------------------------------------

 Gather  (cost=1000.00..1208785.75 rows=62915 width=79) (actual time=24933.162..24933.162 rows=0 loop

s=1)

   Workers Planned: 2

   Workers Launched: 2

   ->  Parallel Seq Scan on testtable  (cost=0.00..1201494.25 rows=26215 width=79) (actual time=24930.047..24930.047 rows=0 loops=3)

         Filter: (qty ? '1'::text)

         Rows Removed by Filter: 20971520

 Planning time: 0.097 ms

 Execution time: 24933.230 ms

(8 rows)

 

Time: 24933.707 ms (00:24.934)

ttgs=#

 

其实执行速度还是可以，20多秒，如果我们开大并行是否会加速吗？

ttgs=# set max_parallel_workers=48;

SET

Time: 0.233 ms

ttgs=# set max_parallel_workers_per_gather=8;

SET

Time: 0.237 ms

ttgs=#

ttgs=# show max_parallel_workers;

 max_parallel_workers

----------------------

 48

(1 row)

 

Time: 0.226 ms

ttgs=# show max_parallel_workers_per_gather;

 max_parallel_workers_per_gather

---------------------------------

 8

(1 row)

 

Time: 0.223 ms

ttgs=#

 

ttgs=# explain analyze select * from testtable where qty @> '{"2018-08-01":1}'::jsonb;

                                                            QUERY PLAN                              

                             

-----------------------------------------------------------------------------------------------------------------------------------

 Gather  (cost=1000.00..993453.01 rows=62915 width=79) (actual time=24973.299..24973.299 rows=0 loops=1)

   Workers Planned: 7

   Workers Launched: 7

   ->  Parallel Seq Scan on testtable  (cost=0.00..986161.51 rows=8988 width=79) (actual time=24961.885..24961.885 rows=0 loops=8)

         Filter: (qty @> '{"2018-08-01": 1}'::jsonb)

         Rows Removed by Filter: 7864320

 Planning time: 0.039 ms

 Execution time: 24973.579 ms

(8 rows)

 

Time: 24973.957 ms (00:24.974)

ttgs=# explain analyze select * from testtable where qty ? '2018-08-01';

                                                             QUERY PLAN                              

                               

-------------------------------------------------------------------------------------------------------------------------------------

 Gather  (cost=1000.00..993453.01 rows=62915 width=79) (actual time=4.985..24589.957 rows=11534336 loops=1)

   Workers Planned: 7

   Workers Launched: 7

   ->  Parallel Seq Scan on testtable  (cost=0.00..986161.51 rows=8988 width=79) (actual time=0.645..23384.141 rows=1441792 loops=8)

         Filter: (qty ? '2018-08-01'::text)

         Rows Removed by Filter: 6422528

 Planning time: 0.102 ms

 Execution time: 25061.753 ms

(8 rows)

 

Time: 25062.198 ms (00:25.062)

ttgs=# explain analyze select * from testtable where qty ? '1';

                                                            QUERY PLAN                              

                             

-----------------------------------------------------------------------------------------------------------------------------------

 Gather  (cost=1000.00..993453.01 rows=62915 width=79) (actual time=24940.345..24940.345 rows=0 loops=1)

   Workers Planned: 7

   Workers Launched: 7

   ->  Parallel Seq Scan on testtable  (cost=0.00..986161.51 rows=8988 width=79) (actual time=24931.271..24931.271 rows=0 loops=8)

         Filter: (qty ? '1'::text)

         Rows Removed by Filter: 7864320

 Planning time: 0.038 ms

 Execution time: 24940.931 ms

(8 rows)

 

Time: 24941.299 ms (00:24.941)

ttgs=#

 

是的，并行其实开大有时候并不能加速查询，但是如果你敢关闭，哼哼～～

ttgs=# set max_parallel_workers=0;

SET

Time: 0.207 ms

ttgs=# set max_parallel_workers_per_gather=0;

SET

Time: 0.205 ms

ttgs=#

ttgs=# show max_parallel_workers;

 max_parallel_workers

----------------------

 0

(1 row)

 

Time: 0.215 ms

ttgs=# show max_parallel_workers_per_gather;

 max_parallel_workers_per_gather

---------------------------------

 0

(1 row)

 

Time: 0.214 ms

ttgs=# explain analyze select * from testtable where qty @> '{"2018-08-01":1}'::jsonb;

                                                      QUERY PLAN                                     

                

----------------------------------------------------------------------------------------------------------------------

 Seq Scan on testtable  (cost=0.00..1660246.60 rows=62915 width=79) (actual time=25181.924..25181.924 rows=0 loops=1)

   Filter: (qty @> '{"2018-08-01": 1}'::jsonb)

   Rows Removed by Filter: 62914560

 Planning time: 0.034 ms

 Execution time: 25181.940 ms

(5 rows)

 

Time: 25182.320 ms (00:25.182)

ttgs=# explain analyze select * from testtable where qty ? '2018-08-01';

                                                       QUERY PLAN                                   

                   

-------------------------------------------------------------------------------------------------------------------------

 Seq Scan on testtable  (cost=0.00..1660246.60 rows=62915 width=79) (actual time=3.973..24631.931 rows=11534336 loops=1)

   Filter: (qty ? '2018-08-01'::text)

   Rows Removed by Filter: 51380224

 Planning time: 0.033 ms

 Execution time: 25116.762 ms

(5 rows)

 

Time: 25117.222 ms (00:25.117)

ttgs=# explain analyze select * from testtable where qty ? '1';

                                                      QUERY PLAN                                    

                 

----------------------------------------------------------------------------------------------------------------------

 Seq Scan on testtable  (cost=0.00..1660246.60 rows=62915 width=79) (actual time=25262.239..25262.239 rows=0 loops=1)

   Filter: (qty ? '1'::text)

   Rows Removed by Filter: 62914560

 Planning time: 0.077 ms

 Execution time: 25262.257 ms

(5 rows)

 

Time: 25262.675 ms (00:25.263)

ttgs=#

 

会慢哟～～，所以并行找jsonb类型，如果dml和查询都很多的话，这个是最后的选择。

 
