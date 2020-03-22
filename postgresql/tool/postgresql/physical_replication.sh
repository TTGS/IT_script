搭建物理流复制

说明：物理流复制在9.4版本推出，之前版本不是自带的流复制，PostgreSQL的流复制分为异步和同步，
应用区别在于
异步，主库完成就反馈给用户，备库不在，不回馈也不影响主库。
同步，主库发送文件后必须得到备库的完整应用后才会反馈给用户。
搭建区别在于
同步比异步在recovery.conf中多写一个名称。
如果是一主多备库，可能还需要postgresql.conf中多写一个裁决参数（synchronous_standby_names）

nodea 172.25.0.10  主库
nodeb 172.25.0.11  备库
使用postgres作为流用户

nodea 
vim $PGDATA/postgresql.conf

listen_addresses = '0.0.0.0' # 对外开放
max_wal_senders = 10         # 准备多少个进程对外传数据，有几个备库写几个。
wal_level = replica          #  不能是最低级别日志记录，需要replica，最少
hot_standby = on             #  备库需要的参数，主库写不写都行，这里写是方便传到备库不用再添加这个参数。
archive_mode = on            # 流复制必须归档开启，归档默认位置在$PGDATA/pg_wal/archive_status 里
archive_command = '/bin/true' #归档后你可以做什么命令，这个即使不需要也给写一个shell命令，不写日志里会说你没写这个参数。
#synchronous_standby_names='nodeb'  #同步流复制需要写这个参数。在主库里，异步不用写。


vim $PGDATA/pg_hba.conf
host    replication     all             0.0.0.1/0            trust
流复制需要在最后添加这样一句，前面的all all 不行
host 主机
replication 流复制功能
all 任何用户 
0.0.0.1/0 开放ip地址段 ip/cidr
trust 验证方式（我这里是绝对信任）

[postgres@nodea pg106]$ pg_ctl start -D $PGDATA
[postgres@nodea pg106]$ psql 
psql (10.6)
Type "help" for help.

postgres=# \sf pg_create_physical_replication_slot 
CREATE OR REPLACE FUNCTION pg_catalog.pg_create_physical_replication_slot(slot_name name, immediately_reserve boolean DEFAULT false, temporary boolean DEFAULT false, OUT slot_name name, OUT lsn pg_lsn)
 RETURNS record
 LANGUAGE internal
 STRICT
AS $function$pg_create_physical_replication_slot$function$
postgres=# 
postgres=# 
postgres=# select pg_create_physical_replication_slot('nodeb');
 pg_create_physical_replication_slot 
-------------------------------------
 (nodeb,)
(1 row)

postgres=# \q


nodeb
[postgres@nodeb pgdata]$ rm -rf * 
[postgres@nodeb pgdata]$ cd ..
[postgres@nodeb pg106]$ pg_basebackup -h 172.25.0.10 -U postgres -F p -P  -R -D pgdata/
waiting for checkpoint

31605/31605 kB (100%), 1/1 tablespace

[postgres@nodeb pg106]$ vim $PGDATA/recovery.conf 
primary_slot_name = 'nodeb'
[postgres@nodeb pg106]$ pg_ctl start -D pgdata/
waiting for server to start....2018-12-05 13:52:53.638 CST [1127] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2018-12-05 13:52:53.642 CST [1127] LOG:  listening on Unix socket "/tmp/.s.PGSQL.5432"
2018-12-05 13:52:53.760 CST [1127] LOG:  redirecting log output to logging collector process
2018-12-05 13:52:53.760 CST [1127] HINT:  Future log output will appear in directory "log".
 done
server started
[postgres@nodeb pg106]$ pg_controldata pgdata/
pg_control version number:            1002
Catalog version number:               201707211
Database system identifier:           6628079478174753652
Database cluster state:               in archive recovery  #备库标志。
pg_control last modified:             Wed 05 Dec 2018 01:52:54 PM CST
Latest checkpoint location:           0/8000060
Prior checkpoint location:            0/8000060
Latest checkpoint's REDO location:    0/8000028
Latest checkpoint's REDO WAL file:    000000010000000000000008
Latest checkpoint's TimeLineID:       1
Latest checkpoint's PrevTimeLineID:   1
Latest checkpoint's full_page_writes: on
Latest checkpoint's NextXID:          0:572
Latest checkpoint's NextOID:          16624
Latest checkpoint's NextMultiXactId:  1
Latest checkpoint's NextMultiOffset:  0
Latest checkpoint's oldestXID:        548
Latest checkpoint's oldestXID's DB:   1
Latest checkpoint's oldestActiveXID:  572
Latest checkpoint's oldestMultiXid:   1
Latest checkpoint's oldestMulti's DB: 1
Latest checkpoint's oldestCommitTsXid:0
Latest checkpoint's newestCommitTsXid:0
Time of latest checkpoint:            Wed 05 Dec 2018 01:52:10 PM CST
Fake LSN counter for unlogged rels:   0/1
Minimum recovery ending location:     0/80000F8
Min recovery ending loc's timeline:   1
Backup start location:                0/0
Backup end location:                  0/0
End-of-backup record required:        no
wal_level setting:                    replica
wal_log_hints setting:                off
max_connections setting:              100
max_worker_processes setting:         8
max_prepared_xacts setting:           0
max_locks_per_xact setting:           64
track_commit_timestamp setting:       off
Maximum data alignment:               8
Database block size:                  8192
Blocks per segment of large relation: 131072
WAL block size:                       8192
Bytes per WAL segment:                16777216
Maximum length of identifiers:        64
Maximum columns in an index:          32
Maximum size of a TOAST chunk:        1996
Size of a large-object chunk:         2048
Date/time type storage:               64-bit integers
Float4 argument passing:              by value
Float8 argument passing:              by value
Data page checksum version:           0
Mock authentication nonce:            50b5aede114b60340b04c7824d0df0422542bcfe8c30c7e85efdd325aff13e84

# 可以在下面的表里看到同步的情况
select  *from pg_stat_replication 
