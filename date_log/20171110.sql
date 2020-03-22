
PostgreSQL动态信息表  

2017-11-10 20:50:13
标签：postgresql  数据库管理  功能  系统表   

很多同学都知道，PostgreSQL中有一类表（或视图）叫做“收集统计信息视图（Collected Statistics Views）”。
为每张表，每个SQL动作都进行相关的收集。对于找到热点表，没有用索引等工作起到了很大的帮助作用。可以关于他们的了解还仅仅是很局限的。

其实你知道吗，这些信息的收集不是为了你我方便管理或者监控数据库使用，更多的是为了vacuum和自动统计信息而存在。
而数据库是否收集这些信息都是和track_counts参数有关，这个参数默认是开启状态，
如果你觉得这些很费劲你的计算机资源，可以关闭他。这样数据库就不会再收集相关信息了。

--关闭了该参数先检查以下
postgres=# select * from pg_stat_user_tables where relname ='a';
-[ RECORD 1 ]-------+------------------------------
relid               | 28662
schemaname          | public
relname             | a
seq_scan            | 1
seq_tup_read        | 1
idx_scan            |
idx_tup_fetch       |
n_tup_ins           | 1
n_tup_upd           | 0
n_tup_del           | 1
n_tup_hot_upd       | 0
n_live_tup          | 0
n_dead_tup          | 0
n_mod_since_analyze | 0
last_vacuum         | 2017-11-10 18:30:59.643731-05
last_autovacuum     |
last_analyze        | 2017-11-10 18:30:59.644096-05
last_autoanalyze    |
vacuum_count        | 2
autovacuum_count    | 0
analyze_count       | 1
autoanalyze_count   | 0

Time: 11.373 ms

--随便做点什么操作吧。
postgres=# insert into a values (1);
INSERT 0 1
Time: 0.660 ms
postgres=# delete from a;
DELETE 1
Time: 0.722 ms

--再次查看这里的内容。
postgres=# select * from pg_stat_user_tables where relname ='a';
-[ RECORD 1 ]-------+------------------------------
relid               | 28662
schemaname          | public
relname             | a
seq_scan            | 1
seq_tup_read        | 1
idx_scan            |
idx_tup_fetch       |
n_tup_ins           | 1
n_tup_upd           | 0
n_tup_del           | 1
n_tup_hot_upd       | 0
n_live_tup          | 0
n_dead_tup          | 0
n_mod_since_analyze | 0
last_vacuum         | 2017-11-10 18:30:59.643731-05
last_autovacuum     |
last_analyze        | 2017-11-10 18:30:59.644096-05
last_autoanalyze    |
vacuum_count        | 2
autovacuum_count    | 0
analyze_count       | 1
autoanalyze_count   | 0

Time: 11.411 ms

你会看到这里的信息根本就没有变化，完全就是静止了一样。

很多人想既然都没有改变了，那如何清空这个表呢？
清理有两种方式，一种是清理掉一行，
使用的是pg_stat_reset_single_table_counters(oid)函数
postgres=# select * from pg_stat_user_tables where relname ='a';
-[ RECORD 1 ]-------+------------------------------
relid               | 28662
schemaname          | public
relname             | a
seq_scan            | 1
seq_tup_read        | 1
idx_scan            |
idx_tup_fetch       |
n_tup_ins           | 1
n_tup_upd           | 0
n_tup_del           | 1
n_tup_hot_upd       | 0
n_live_tup          | 0
n_dead_tup          | 0
n_mod_since_analyze | 0
last_vacuum         | 2017-11-10 18:30:59.643731-05
last_autovacuum     |
last_analyze        | 2017-11-10 18:30:59.644096-05
last_autoanalyze    |
vacuum_count        | 2
autovacuum_count    | 0
analyze_count       | 1
autoanalyze_count   | 0

Time: 11.509 ms
postgres=# select pg_stat_reset_single_table_counters(28662);
-[ RECORD 1 ]-----------------------+-
pg_stat_reset_single_table_counters |

Time: 0.317 ms
postgres=# select * from pg_stat_user_tables where relname ='a';
-[ RECORD 1 ]-------+-------
relid               | 28662
schemaname          | public
relname             | a
seq_scan            | 0
seq_tup_read        | 0
idx_scan            |
idx_tup_fetch       |
n_tup_ins           | 0
n_tup_upd           | 0
n_tup_del           | 0
n_tup_hot_upd       | 0
n_live_tup          | 0
n_dead_tup          | 0
n_mod_since_analyze | 0
last_vacuum         |
last_autovacuum     |
last_analyze        |
last_autoanalyze    |
vacuum_count        | 0
autovacuum_count    | 0
analyze_count       | 0
autoanalyze_count   | 0

Time: 10.973 ms


当然另一种就是全部都清理了。可以使用pg_stat_reset()清理，不过这个清理是当前数据库里的记录。
postgres=# select * from pg_stat_database where datname='postgres';
-[ RECORD 1 ]--+------------------------------
datid          | 13158
datname        | postgres
numbackends    | 1
xact_commit    | 2320
xact_rollback  | 24
blks_read      | 7354429
blks_hit       | 203307539
tup_returned   | 317219011
tup_fetched    | 111999
tup_inserted   | 134218533
tup_updated    | 104203847
tup_deleted    | 12829
conflicts      | 0
temp_files     | 0
temp_bytes     | 0
deadlocks      | 0
blk_read_time  | 0
blk_write_time | 0
stats_reset    | 2017-11-10 19:31:05.052166-05

Time: 10.648 ms
postgres=# select pg_stat_reset();
-[ RECORD 1 ]-+-
pg_stat_reset |

Time: 0.216 ms
postgres=# select * from pg_stat_database where datname='postgres';
-[ RECORD 1 ]--+------------------------------
datid          | 13158
datname        | postgres
numbackends    | 1
xact_commit    | 1
xact_rollback  | 0
blks_read      | 0
blks_hit       | 0
tup_returned   | 0
tup_fetched    | 0
tup_inserted   | 0
tup_updated    | 0
tup_deleted    | 0
conflicts      | 0
temp_files     | 0
temp_bytes     | 0
deadlocks      | 0
blk_read_time  | 0
blk_write_time | 0
stats_reset    | 2017-11-10 20:36:51.301962-05

Time: 10.580 ms
postgres=#
不过这个函数是不能清理掉bgwrite等信息的。例如
postgres=# select * from pg_stat_bgwriter ;
-[ RECORD 1 ]---------+------------------------------
checkpoints_timed     | 52
checkpoints_req       | 91
checkpoint_write_time | 1471968
checkpoint_sync_time  | 8378
buffers_checkpoint    | 498440
buffers_clean         | 493880
maxwritten_clean      | 4517
buffers_backend       | 5923791
buffers_backend_fsync | 0
buffers_alloc         | 2244108
stats_reset           | 2017-11-09 20:56:16.865873-05

Time: 10.560 ms
postgres=# select pg_stat_reset();
-[ RECORD 1 ]-+-
pg_stat_reset |

Time: 0.153 ms
postgres=# select * from pg_stat_bgwriter ;
-[ RECORD 1 ]---------+------------------------------
checkpoints_timed     | 52
checkpoints_req       | 91
checkpoint_write_time | 1471968
checkpoint_sync_time  | 8378
buffers_checkpoint    | 498440
buffers_clean         | 493880
maxwritten_clean      | 4517
buffers_backend       | 5923791
buffers_backend_fsync | 0
buffers_alloc         | 2244109
stats_reset           | 2017-11-09 20:56:16.865873-05

这也就需要使用特定的函数-pg_stat_reset_shared。
postgres=# select * from pg_stat_bgwriter ;
-[ RECORD 1 ]---------+------------------------------
checkpoints_timed     | 53
checkpoints_req       | 91
checkpoint_write_time | 1471968
checkpoint_sync_time  | 8378
buffers_checkpoint    | 498440
buffers_clean         | 493880
maxwritten_clean      | 4517
buffers_backend       | 5923791
buffers_backend_fsync | 0
buffers_alloc         | 2244109
stats_reset           | 2017-11-09 20:56:16.865873-05

Time: 10.504 ms
postgres=# select pg_stat_reset_shared('bgwriter');
-[ RECORD 1 ]--------+-
pg_stat_reset_shared |

Time: 0.193 ms
postgres=# select * from pg_stat_bgwriter ;
-[ RECORD 1 ]---------+------------------------------
checkpoints_timed     | 0
checkpoints_req       | 0
checkpoint_write_time | 0
checkpoint_sync_time  | 0
buffers_checkpoint    | 0
buffers_clean         | 0
maxwritten_clean      | 0
buffers_backend       | 0
buffers_backend_fsync | 0
buffers_alloc         | 0
stats_reset           | 2017-11-10 20:46:25.973971-05

Time: 10.405 ms
追其原因，这些信息是共享信息，不是某个数据库的独有信息。
