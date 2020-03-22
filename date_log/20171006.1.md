
postgresql 10分区表-list  

2017-10-06 21:14:57
标签：postgresql  数据库管理  功能  报错信息
  
 
10月最新发布的pg10，自带分区，单只是2中分区方式——list和range。不免有点小遗憾，如果是那种非重复的内容，可能自带的就有点不够了。不过没关系，我们可以继续探索一下自带的这两种分区方式。

tt=# create table part_list (id int , va varchar(10)) partition by list (va);
CREATE TABLE
tt=# insert into part_list values(1,'a');
2017-10-06 20:28:36.694 EDT [18709] ERROR:  no partition of relation "part_list" found for row
2017-10-06 20:28:36.694 EDT [18709] DETAIL:  Partition key of the failing row contains (va) = (a).
2017-10-06 20:28:36.694 EDT [18709] STATEMENT:  insert into part_list values(1,'a');
ERROR:  no partition of relation "part_list" found for row
DETAIL:  Partition key of the failing row contains (va) = (a).
tt=#
咦～～～ 上来就报错了。这是怎么回事？分区表创建好了，但是分区表不能自动分区，需要手动进行创建内容。所以我们还需要手动的创建具体的分区表内容。
tt=# create table part_list_abc partition of part_list for values in ('a','b','c');
CREATE TABLE
tt=#
tt=# insert into part_list values(1,'a');INSERT 0 1
tt=# insert into part_list values(1,'a');
INSERT 0 1
tt=# insert into part_list values(1,'a');
INSERT 0 1
tt=# insert into part_list values(2,'b');
INSERT 0 1
tt=# insert into part_list values(3,'c');
INSERT 0 1
看到了，其实创建很简单，插入几个值都是没有问题的，但是，如果你要是插入一点没有定义的值，那么对不起，报错，看下面
tt=# insert into part_list values(4,'d');
2017-10-06 20:41:56.832 EDT [18709] ERROR:  no partition of relation "part_list" found for row
2017-10-06 20:41:56.832 EDT [18709] DETAIL:  Partition key of the failing row contains (va) = (d).
2017-10-06 20:41:56.832 EDT [18709] STATEMENT:  insert into part_list values(4,'d');
ERROR:  no partition of relation "part_list" found for row
DETAIL:  Partition key of the failing row contains (va) = (d).
tt=#

直接就警告错误了。

然后我多塞了一点数据进入，看看数据库是将这些数据存放在哪里
tt=# insert into part_list values(generate_series(1,100),'c');
INSERT 0 100
tt=# insert into part_list values(generate_series(1,100),'c');
INSERT 0 100
tt=# insert into part_list values(generate_series(1,100),'c');
INSERT 0 100
tt=# insert into part_list values(generate_series(1,100),'c');
INSERT 0 100
tt=# insert into part_list values(generate_series(1,100),'c');
INSERT 0 100
tt=# insert into part_list values(generate_series(1,100),'c');
INSERT 0 100
tt=# \dt+
                         List of relations
 Schema |     Name      | Type  |  Owner   |  Size   | Description
--------+---------------+-------+----------+---------+-------------
 public | part_list     | table | postgres | 0 bytes |
 public | part_list_abc | table | postgres | 48 kB   |
(2 rows)

tt=#
实际上主表没有存放任何东西， 只是定义好的分区表进行存放数据了。
那么好了，是否数据库真的能发现分区表吗？
tt=# explain analyze select count(*) from part_list where va='a';
                                                     QUERY PLAN                
                                   
--------------------------------------------------------------------------------
------------------------------------
 Aggregate  (cost=10.57..10.58 rows=1 width=8) (actual time=0.054..0.054 rows=1 loops=1)
   ->  Append  (cost=0.00..10.56 rows=2 width=0) (actual time=0.008..0.052 rows=3 loops=1)
         ->  Seq Scan on part_list_abc  (cost=0.00..10.56 rows=2 width=0) (actual time=0.008..0.052 rows=3 loops=1)
               Filter: ((va)::text = 'a'::text)
               Rows Removed by Filter: 602
 Planning time: 0.133 ms
 Execution time: 0.067 ms
(7 rows)

tt=#
数据库的优化器也是正常发现了分区内容，直接调用了分区表。这样在超大表中，我们就可以减少读取的数据量了。
