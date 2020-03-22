恢复PGDATA下的pg_clog  

#没事干吧pgdata下的pg_clog里的0000删除了，然后就被迫进行了强制恢复内容。
#以下内容是全部的操作过程，没有任何删减。
[postgres@TT data]$ cd pg_clog/
[postgres@TT pg_clog]$ ll
total 32
-rw-------. 1 postgres postgres 32768 May 25 23:24 0000
[postgres@TT pg_clog]$ tail -100f 0000 
@UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUjYUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU^[[?1;2cVT102:Q
^C
[postgres@TT pg_clog]$ ll
total 32
-rw-------. 1 postgres postgres 32768 May 25 23:24 0000
[postgres@TT pg_clog]$ rm 0000 
[postgres@TT pg_clog]$ cd ..
[postgres@TT data]$ ll
total 120
drwx------. 5 postgres postgres  4096 May 19 03:47 base
drwx------. 2 postgres postgres  4096 May 25 23:19 global
drwx------. 2 postgres postgres  4096 May 26 02:20 pg_clog
drwx------. 2 postgres postgres  4096 May 19 03:47 pg_commit_ts
drwx------. 2 postgres postgres  4096 May 19 03:47 pg_dynshmem
-rw-------. 1 postgres postgres  4535 May 19 04:31 pg_hba.conf
-rw-------. 1 postgres postgres  1636 May 19 03:47 pg_ident.conf
drwx------. 4 postgres postgres  4096 May 19 03:47 pg_logical
drwx------. 4 postgres postgres  4096 May 19 03:47 pg_multixact
drwx------. 2 postgres postgres  4096 May 25 23:19 pg_notify
drwx------. 2 postgres postgres  4096 May 19 03:47 pg_replslot
drwx------. 2 postgres postgres  4096 May 19 03:47 pg_serial
drwx------. 2 postgres postgres  4096 May 19 03:47 pg_snapshots
drwx------. 2 postgres postgres  4096 May 25 23:19 pg_stat
drwx------. 2 postgres postgres  4096 May 25 23:19 pg_stat_tmp
drwx------. 2 postgres postgres  4096 May 19 03:47 pg_subtrans
drwx------. 2 postgres postgres  4096 May 19 03:50 pg_tblspc
drwx------. 2 postgres postgres  4096 May 19 03:47 pg_twophase
-rw-------. 1 postgres postgres     4 May 19 03:47 PG_VERSION
drwx------. 3 postgres postgres  4096 May 26 01:54 pg_xlog
-rw-------. 1 postgres postgres    88 May 19 03:47 postgresql.auto.conf
-rw-------. 1 postgres postgres 22299 May 25 23:05 postgresql.conf
-rw-------. 1 postgres postgres    30 May 25 23:19 postmaster.opts
-rw-------. 1 postgres postgres    67 May 25 23:19 postmaster.pid                       
[postgres@TT data]$ pg_ctl restart -D .  -m fast 
waiting for server to shut down....LOG:  received fast shutdown request
LOG:  aborting any active transactions
FATAL:  terminating connection due to administrator command
LOG:  shutting down.........LOG:  database system is shut down
 done
server stopped
server starting
[postgres@TT data]$ 
[postgres@TT data]$ 
[postgres@TT data]$ 
[postgres@TT data]$ 
[postgres@TT data]$ LOG:  database system was shut down at 2016-05-26 02:21:43 EDT
FATAL:  the database system is starting up
FATAL:  the database system is starting up
FATAL:  could not access status of transaction 2258
DETAIL:  Could not open file "pg_clog/0000": No such file or directory.
LOG:  startup process (PID 16906) exited with exit code 1
LOG:  aborting startup due to startup process failure

[postgres@TT data]$ 
[postgres@TT data]$ 
[postgres@TT data]$ psql
psql: could not connect to server: No such file or directory
        Is the server running locally and accepting
        connections on Unix domain socket "/tmp/.s.PGSQL.5432"?
[postgres@TT data]$ pg_ctl start -D . 
server starting
[postgres@TT data]$ LOG:  database system was interrupted; last known up at 2016-05-26 02:22:09 EDT
LOG:  database system was not properly shut down; automatic recovery in progress
LOG:  invalid record length at 8/70000098
LOG:  redo is not required
FATAL:  could not access status of transaction 2258
DETAIL:  Could not open file "pg_clog/0000": No such file or directory.
LOG:  startup process (PID 16913) exited with exit code 1
LOG:  aborting startup due to startup process failure

[postgres@TT data]$ 
[postgres@TT data]$ psql
psql: could not connect to server: No such file or directory
        Is the server running locally and accepting
        connections on Unix domain socket "/tmp/.s.PGSQL.5432"?
[postgres@TT data]$ cd pg_clog/
#然后我就企图伪造一个0000的文件，这当然是不成功的。你也知道，这里面是空的。人家里面可是有东西的，启动的时候要读取的这个好不。
[postgres@TT pg_clog]$ touch 0000
[postgres@TT pg_clog]$ cd -
/pg/953/data
[postgres@TT data]$ pg_ctl start -D . 
server starting
[postgres@TT data]$ LOG:  database system was interrupted; last known up at 2016-05-26 02:22:26 EDT
LOG:  database system was not properly shut down; automatic recovery in progress
LOG:  invalid record length at 8/70000108
LOG:  redo is not required
FATAL:  could not access status of transaction 2258
DETAIL:  Could not read from file "pg_clog/0000" at offset 0: Success.
LOG:  startup process (PID 16921) exited with exit code 1
LOG:  aborting startup due to startup process failure

[postgres@TT data]$ 
[postgres@TT data]$ 
#好了你看到了，这玩意儿不能通过，然后我就又截断了一下事物日志（xlog）。
#我想通过截断这个没有提交的内容来完成启动。
#不过你也明白这东西不是想想那种可以的事情。
[postgres@TT data]$ pg_resetxlog -f .
Transaction log reset
[postgres@TT data]$ pg_ctl start -D . 
server starting
[postgres@TT data]$ LOG:  database system was shut down at 2016-05-26 02:23:23 EDT
FATAL:  could not access status of transaction 2258
DETAIL:  Could not read from file "pg_clog/0000" at offset 0: Success.
LOG:  startup process (PID 16926) exited with exit code 1
LOG:  aborting startup due to startup process failure

[postgres@TT data]$ 
[postgres@TT data]$ pg_resetxlog --help
pg_resetxlog resets the PostgreSQL transaction log.

Usage:
  pg_resetxlog [OPTION]... DATADIR

Options:
  -c XID,XID       set oldest and newest transactions bearing commit timestamp
                   (zero in either value means no change)
 [-D] DATADIR      data directory
  -e XIDEPOCH      set next transaction ID epoch
  -f               force update to be done
  -l XLOGFILE      force minimum WAL starting location for new transaction log
  -m MXID,MXID     set next and oldest multitransaction ID
  -n               no update, just show what would be done (for testing)
  -o OID           set next OID
  -O OFFSET        set next multitransaction offset
  -V, --version    output version information, then exit
  -x XID           set next transaction ID
  -?, --help       show this help, then exit

Report bugs to <pgsql-bugs@postgresql.org>.
[postgres@TT data]$ pg_resetxlog -x 2258
pg_resetxlog: no data directory specified
Try "pg_resetxlog --help" for more information.
[postgres@TT data]$ pg_resetxlog -c 2258
pg_resetxlog: invalid argument for option -c
Try "pg_resetxlog --help" for more information.
[postgres@TT data]$ pg_resetxlog -c 2258 -D .
pg_resetxlog: invalid argument for option -c
Try "pg_resetxlog --help" for more information.
[postgres@TT data]$ pg_resetxlog -x 2259 -D .
The database server was not shut down cleanly.
Resetting the transaction log might cause data to be lost.
If you want to proceed anyway, use -f to force reset.
[postgres@TT data]$ pg_resetxlog -f -x 2259 -D .
Transaction log reset
[postgres@TT data]$ pg_ctl start -D .
server starting
[postgres@TT data]$ LOG:  database system was shut down at 2016-05-26 02:24:47 EDT
FATAL:  could not access status of transaction 2259
DETAIL:  Could not read from file "pg_clog/0000" at offset 0: Success.
LOG:  startup process (PID 16940) exited with exit code 1
LOG:  aborting startup due to startup process failure

[postgres@TT data]$ 
[postgres@TT data]$ 
[postgres@TT data]$ touch pg_clog/0000
[postgres@TT data]$ pg_resetxlog -f -x 2260 -D .
Transaction log reset
[postgres@TT data]$ 
[postgres@TT data]$ 
[postgres@TT data]$ 
[postgres@TT data]$ pg_ctl start -D .
server starting
[postgres@TT data]$ LOG:  database system was shut down at 2016-05-26 02:25:15 EDT
FATAL:  could not access status of transaction 2260
DETAIL:  Could not read from file "pg_clog/0000" at offset 0: Success.
LOG:  startup process (PID 17318) exited with exit code 1
LOG:  aborting startup due to startup process failure

[postgres@TT data]$ 
[postgres@TT data]$ 
[postgres@TT data]$ cd ..
[postgres@TT 953]$ ll
total 28
drwxrwxr-x.  2 postgres postgres 4096 May 19 02:33 bin
drwx------. 19 postgres postgres 4096 May 26 02:25 data
drwxrwxr-x.  4 postgres postgres 4096 May 19 02:33 include
drwxrwxr-x.  4 postgres postgres 4096 May 19 02:33 lib
drwxrwxr-x.  2 postgres postgres 4096 May 26 02:21 pg_archive
drwxrwxr-x.  3 postgres postgres 4096 May 19 02:33 share
drwxrwxr-x.  5 postgres postgres 4096 May 19 03:48 tablespace
#工作是徒劳的，0000不是带有内容的文件，或者说这个是启动必须带的，你截断多少都要这里的内容。
#所以我刚才新初始化一个，拿来用好了，放在也是一样的，因为都提交了内容。
[postgres@TT 953]$ mkdir data1
[postgres@TT 953]$ initdb -D data1
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.UTF-8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory data1 ... ok
creating subdirectories ... ok
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting dynamic shared memory implementation ... posix
creating configuration files ... ok
creating template1 database in data1/base/1 ... ok
initializing pg_authid ... ok
initializing dependencies ... ok
creating system views ... ok
loading system objects' descriptions ... ok
creating collations ... ok
creating conversions ... ok
creating dictionaries ... ok
setting privileges on built-in objects ... ok
creating information schema ... ok
loading PL/pgSQL server-side language ... ok
vacuuming database template1 ... ok
copying template1 to template0 ... ok
copying template1 to postgres ... ok
syncing data to disk ... ok

WARNING: enabling "trust" authentication for local connections
You can change this by editing pg_hba.conf or using the option -A, or
--auth-local and --auth-host, the next time you run initdb.

Success. You can now start the database server using:

    pg_ctl -D data1 -l logfile start

[postgres@TT 953]$ cd data1
[postgres@TT data1]$ ll
total 112
drwx------. 5 postgres postgres  4096 May 26 02:29 base
drwx------. 2 postgres postgres  4096 May 26 02:29 global
drwx------. 2 postgres postgres  4096 May 26 02:29 pg_clog
drwx------. 2 postgres postgres  4096 May 26 02:29 pg_commit_ts
drwx------. 2 postgres postgres  4096 May 26 02:29 pg_dynshmem
-rw-------. 1 postgres postgres  4468 May 26 02:29 pg_hba.conf
-rw-------. 1 postgres postgres  1636 May 26 02:29 pg_ident.conf
drwx------. 4 postgres postgres  4096 May 26 02:29 pg_logical
drwx------. 4 postgres postgres  4096 May 26 02:29 pg_multixact
drwx------. 2 postgres postgres  4096 May 26 02:29 pg_notify
drwx------. 2 postgres postgres  4096 May 26 02:29 pg_replslot
drwx------. 2 postgres postgres  4096 May 26 02:29 pg_serial
drwx------. 2 postgres postgres  4096 May 26 02:29 pg_snapshots
drwx------. 2 postgres postgres  4096 May 26 02:29 pg_stat
drwx------. 2 postgres postgres  4096 May 26 02:29 pg_stat_tmp
drwx------. 2 postgres postgres  4096 May 26 02:29 pg_subtrans
drwx------. 2 postgres postgres  4096 May 26 02:29 pg_tblspc
drwx------. 2 postgres postgres  4096 May 26 02:29 pg_twophase
-rw-------. 1 postgres postgres     4 May 26 02:29 PG_VERSION
drwx------. 3 postgres postgres  4096 May 26 02:29 pg_xlog
-rw-------. 1 postgres postgres    88 May 26 02:29 postgresql.auto.conf
-rw-------. 1 postgres postgres 21727 May 26 02:29 postgresql.conf
[postgres@TT data1]$ cd pg_clog/
[postgres@TT pg_clog]$ ll
total 32
-rw-------. 1 postgres postgres 32768 May 26 02:29 0000
[postgres@TT pg_clog]$ cp 0000 ../
base/                 pg_multixact/         pg_tblspc/
global/               pg_notify/            pg_twophase/
pg_clog/              pg_replslot/          PG_VERSION
pg_commit_ts/         pg_serial/            pg_xlog/
pg_dynshmem/          pg_snapshots/         postgresql.auto.conf
pg_hba.conf           pg_stat/              postgresql.conf
pg_ident.conf         pg_stat_tmp/          
pg_logical/           pg_subtrans/          
[postgres@TT pg_clog]$ cp 0000 ../../
bin/        data1/      lib/        share/      
data/       include/    pg_archive/ tablespace/ 
[postgres@TT pg_clog]$ cp 0000 ../../data/
base/                 pg_multixact/         pg_tblspc/
global/               pg_notify/            pg_twophase/
pg_clog/              pg_replslot/          PG_VERSION
pg_commit_ts/         pg_serial/            pg_xlog/
pg_dynshmem/          pg_snapshots/         postgresql.auto.conf
pg_hba.conf           pg_stat/              postgresql.conf
pg_ident.conf         pg_stat_tmp/          postmaster.opts
pg_logical/           pg_subtrans/          
[postgres@TT pg_clog]$ cp 0000 ../../data/pg_c
pg_clog/      pg_commit_ts/ 
[postgres@TT pg_clog]$ cp 0000 ../../data/pg_clog/
[postgres@TT pg_clog]$ pg_ctl start -D .
pg_ctl: directory "." is not a database cluster directory
[postgres@TT pg_clog]$ 
[postgres@TT pg_clog]$ pg_ctl start -D /pg/953/data
server starting
[postgres@TT pg_clog]$ psql
LOG:  database system was interrupted; last known up at 2016-05-26 02:25:22 EDT
FATAL:  the database system is starting up
FATAL:  the database system is starting up
psql: FATAL:  the database system is starting up
[postgres@TT pg_clog]$ LOG:  database system was not properly shut down; automatic recovery in progress
LOG:  invalid record length at 8/7C000098
LOG:  redo is not required
LOG:  MultiXact member wraparound protections are now enabled
LOG:  database system is ready to accept connections
LOG:  autovacuum launcher started

[postgres@TT pg_clog]$ 
[postgres@TT pg_clog]$ psql
psql (9.5.3)
Type "help" for help.

postgres=# \q
[postgres@TT pg_clog]$ 
#我可以这样做是因为我clog里没有没提交的内容或者待提交的内容，所以我可以使用这个方法重建。
#如果你的clog的0000里有待提交的或者没提交的内容，那就可能会造成丢失内容。
#pg_clog是事务状态日志，而我又将整个wal截断掉，相当于我没有没有提交的事务内容，
#所以数据库启动就不会读取更多的内容信息。启动完成。
