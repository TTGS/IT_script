#有人没事干，把pgdata下的pg_clog里的0000删除了，然后就被迫进行了恢复。
#不得不说一句，在pg中有个3个带log的文件夹，
#除了pg_log文件夹可以清理内容，其他几个不要乱动。
#为此pg10还特地修改了文件夹名称。
#以下是我重现灾难和修复过程。并非还是真实环境。
[postgres@TT data]$ cd pg_clog/
[postgres@TT pg_clog]$ ll
total 32
-rw-------. 1 postgres postgres 32768 May 25 23:24 0000
[postgres@TT pg_clog]$ rm 0000 
[postgres@TT pg_clog]$ cd ..

#在这里我尝试重启数据库，因为数据库不正常啦  \(^w^)/                     
[postgres@TT data]$ pg_ctl restart -D .  -m fast 
waiting for server to shut down....LOG:  received fast shutdown request
LOG:  aborting any active transactions
FATAL:  terminating connection due to administrator command
LOG:  shutting down.........LOG:  database system is shut down
 done
server stopped
server starting
[postgres@TT data]$ 

#启动的时候已经发生报错信息了。
[postgres@TT data]$ LOG:  database system was shut down at 2016-05-26 02:21:43 EDT
FATAL:  the database system is starting up
FATAL:  the database system is starting up
FATAL:  could not access status of transaction 2258
DETAIL:  Could not open file "pg_clog/0000": No such file or directory.
LOG:  startup process (PID 16906) exited with exit code 1
LOG:  aborting startup due to startup process failure


#虽然说是在启动中，但是用psql尝试登录，是根本上不去的。
[postgres@TT data]$ psql
psql: could not connect to server: No such file or directory
        Is the server running locally and accepting
        connections on Unix domain socket "/tmp/.s.PGSQL.5432"?

#再次尝试启动，依然如此，仔细看错，是由于一个无效的8/70000098引起的。
#而事务2258没有记录。细节是"pg_clog/0000": No such file or directory.
#其实这个错误就很明显了，pg_clog/0000没有文件了。
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

#然后我就企图伪造一个0000的文件，这当然是不成功的。
#0000里是放的提交状态，我touch出来的这里面是空的。数据库启动的时候要读取的这个文件的。
#错误依旧。
[postgres@TT data]$ cd pg_clog/
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



#好了看到了，这玩意儿不能通过。
#然而截断一下事物日志（xlog）是否能解决这问题吗？
#我想通过截断这个没有提交的内容来完成启动。
#不过你也明白这东西不是想想那种可以的事情。
#启动还是失败了，他还是要去找这个0000的文件。
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


#再次创建一个空的。然后尝试启动。
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

#依旧不行，工作是徒劳的，0000不是空的，
#他是带有内容的文件，或者说这个是启动必须带的，你截断多少都要这里的内容。
#所以我新初始化一个库，把0000拿来用好了，反正事务也截断了，之前的你也不看了。
[postgres@TT 953]$ mkdir data1
[postgres@TT 953]$ initdb -D data1
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.
...(略)...
Success. You can now start the database server using:

    pg_ctl -D data1 -l logfile start

[postgres@TT 953]$ cd data1
[postgres@TT data1]$ cd pg_clog/
[postgres@TT pg_clog]$ ll
total 32
-rw-------. 1 postgres postgres 32768 May 26 02:29 0000
[postgres@TT pg_clog]$ cp 0000 ../../data/pg_clog/

#让我尝试一下启动吧。
[postgres@TT pg_clog]$ pg_ctl start -D /pg/953/data
server starting
[postgres@TT pg_clog]$ 
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
#之所以启动的时候需要找那段记录，是因为有脏数据没有写入到硬盘中，
#而数据库启动的时候是需要日志去解决没有写入的问题的。
#我可以使用这个方法重建，是因为我接受丢数据，并且截断了事务。
#启动的时候他读取的时候日志是重置的，clog也是“正常的”。
