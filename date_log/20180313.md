
FATAL: terminating connection due to administrator command  

2018-03-13 12:20:16|  分类： PostgreSQL |  标签：postgresql  案例  报错信息    

今天碰到一个很无语的问题，
程序员说他们的程序连接数据库的时候，被扔了一个错误“FATAL:  terminating connection due to administrator command”

他们感觉很莫名其妙，管理员让终止的，我的连接应该只有我呀！管理员（他们理解报错中的administrator是数据库的超级用户postgres）怎么能使用我的连接呢？他怎么进来的？一定是数据库的锅，这是重大bug，我们要xxx（此处省略好多字...）。

这个真的不需要登录数据库就能做到。我们来用一个实验完成这个报错。

--服务器端
[root@ha ~]# su - postgres
[postgres@ha ~]$ cd db/9.6/pgdata/pg_log
[postgres@ha pg_log]$ ls
[postgres@ha pg_log]$ pg_ctl start -D ../
server starting
[postgres@ha pg_log]$ LOG:  redirecting log output to logging collector process
HINT:  Future log output will appear in directory "pg_log".

[postgres@ha pg_log]$ ls
postgresql-2018-03-12_213854.log
[postgres@ha pg_log]$ tail -100f postgresql-2018-03-12_213854.log
LOG:  database system was shut down at 2018-03-12 21:33:01 CST
LOG:  MultiXact member wraparound protections are now enabled
LOG:  database system is ready to accept connections
LOG:  autovacuum launcher started
^C               
[postgres@ha pg_log]$ echo '---------------' >>postgresql-2018-03-12_213854.log
[postgres@ha pg_log]$

-----------客户端
[root@sp ~]# su - postgres
[postgres@sp ~]$ psql -h 192.168.74.131
psql (9.6.7)
Type "help" for help.

postgres=# select version();
                                                 version                                    
              
--------------------------------------------------------------------------------------------
--------------
 PostgreSQL 9.6.7 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.4.7 20120313 (Red Hat 4.4.
7-17), 64-bit
(1 row)

postgres=# \watch 1
                                Mon 12 Mar 2018 09:50:29 PM CST (every 1s)

                                                 version                                                  
----------------------------------------------------------------------------------------------------------
 PostgreSQL 9.6.7 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.4.7 20120313 (Red Hat 4.4.7-17), 64-bit
(1 row)

注意，这里不要停止psql的查询。
回到服务器端，找到这个psql连接
[postgres@ha pg_log]$ ps -ef |grep post
root      5414  5386  0 21:07 pts/0    00:00:00 su - postgres
postgres  5415  5414  0 21:07 pts/0    00:00:00 -bash
root      6915  6157  0 21:38 pts/2    00:00:00 su - postgres
postgres  6916  6915  0 21:38 pts/2    00:00:00 -bash
postgres  6960     1  0 21:38 pts/2    00:00:00 /home/postgres/db/9.6/bin/postgres -D ..
postgres  6961  6960  0 21:38 ?        00:00:00 postgres: logger process                
postgres  6963  6960  0 21:38 ?        00:00:00 postgres: checkpointer process          
postgres  6964  6960  0 21:38 ?        00:00:00 postgres: writer process                
postgres  6965  6960  0 21:38 ?        00:00:00 postgres: wal writer process            
postgres  6966  6960  0 21:38 ?        00:00:00 postgres: autovacuum launcher process   
postgres  6967  6960  0 21:38 ?        00:00:00 postgres: archiver process              
postgres  6968  6960  0 21:38 ?        00:00:00 postgres: stats collector process       
postgres 12329  6960  0 21:50 ?        00:00:00 postgres: postgres postgres 192.168.74.128(56666) idle
postgres 12332  6916  0 21:51 pts/2    00:00:00 ps -ef
postgres 12333  6916  0 21:51 pts/2    00:00:00 grep post
[postgres@ha pg_log]$ kill -15 12329
[postgres@ha pg_log]$ cat postgresql-2018-03-12_213854.log
LOG:  database system was shut down at 2018-03-12 21:33:01 CST
LOG:  MultiXact member wraparound protections are now enabled
LOG:  database system is ready to accept connections
LOG:  autovacuum launcher started
---------------
FATAL:  terminating connection due to administrator command

看到了吗？报错出现了。

实际上你的连接我在主机层面直接发送一个终止信号过去，数据库的对应进程就会停止了，也就看到错误了。

很多人只是知道kill -9 是杀进程。kill命令的-9是什么意思就不知道了。
实际上kill有很多终止信号，我们可以用kill -l查看。
[postgres@ha pg_log]$ kill -l
 1) SIGHUP       2) SIGINT       3) SIGQUIT      4) SIGILL       5) SIGTRAP
 6) SIGABRT      7) SIGBUS       8) SIGFPE       9) SIGKILL     10) SIGUSR1
11) SIGSEGV     12) SIGUSR2     13) SIGPIPE     14) SIGALRM     15) SIGTERM
16) SIGSTKFLT   17) SIGCHLD     18) SIGCONT     19) SIGSTOP     20) SIGTSTP
21) SIGTTIN     22) SIGTTOU     23) SIGURG      24) SIGXCPU     25) SIGXFSZ
26) SIGVTALRM   27) SIGPROF     28) SIGWINCH    29) SIGIO       30) SIGPWR
31) SIGSYS      34) SIGRTMIN    35) SIGRTMIN+1  36) SIGRTMIN+2  37) SIGRTMIN+3
38) SIGRTMIN+4  39) SIGRTMIN+5  40) SIGRTMIN+6  41) SIGRTMIN+7  42) SIGRTMIN+8
43) SIGRTMIN+9  44) SIGRTMIN+10 45) SIGRTMIN+11 46) SIGRTMIN+12 47) SIGRTMIN+13
48) SIGRTMIN+14 49) SIGRTMIN+15 50) SIGRTMAX-14 51) SIGRTMAX-13 52) SIGRTMAX-12
53) SIGRTMAX-11 54) SIGRTMAX-10 55) SIGRTMAX-9  56) SIGRTMAX-8  57) SIGRTMAX-7
58) SIGRTMAX-6  59) SIGRTMAX-5  60) SIGRTMAX-4  61) SIGRTMAX-3  62) SIGRTMAX-2
63) SIGRTMAX-1  64) SIGRTMAX
[postgres@ha pg_log]$

行了下面的问题，就是如何找到这个发送kill命令的人了。
另外，发送不同的kill信号，数据库的log是不同的。

发送了一个-3的信号过去。
[postgres@ha pg_log]$ ps -ef |grep post
root      5414  5386  0 21:07 pts/0    00:00:00 su - postgres
postgres  5415  5414  0 21:07 pts/0    00:00:00 -bash
root      6915  6157  0 21:38 pts/2    00:00:00 su - postgres
postgres  6916  6915  0 21:38 pts/2    00:00:00 -bash
postgres  6960     1  0 21:38 pts/2    00:00:00 /home/postgres/db/9.6/bin/postgres -D ..
postgres  6961  6960  0 21:38 ?        00:00:00 postgres: logger process                
postgres  6963  6960  0 21:38 ?        00:00:00 postgres: checkpointer process          
postgres  6964  6960  0 21:38 ?        00:00:00 postgres: writer process                
postgres  6965  6960  0 21:38 ?        00:00:00 postgres: wal writer process            
postgres  6966  6960  0 21:38 ?        00:00:00 postgres: autovacuum launcher process   
postgres  6967  6960  0 21:38 ?        00:00:00 postgres: archiver process              
postgres  6968  6960  0 21:38 ?        00:00:00 postgres: stats collector process       
postgres 12756  6960  0 21:57 ?        00:00:00 postgres: postgres postgres 192.168.74.128(56668) idle
postgres 12758  6916  3 21:58 pts/2    00:00:00 ps -ef
postgres 12759  6916  0 21:58 pts/2    00:00:00 grep post
[postgres@ha pg_log]$ kill -3 12756
[postgres@ha pg_log]$ cat postgresql-2018-03-12_213854.log

WARNING:  terminating connection because of crash of another server process
DETAIL:  The postmaster has commanded this server process to roll back the current transaction and exit, because another server process exited abnormally and possibly corrupted shared memory.
HINT:  In a moment you should be able to reconnect to the database and repeat your command.
LOG:  server process (PID 12756) exited with exit code 2
DETAIL:  Failed process was running: select version();
LOG:  terminating any other active server processes
WARNING:  terminating connection because of crash of another server process
DETAIL:  The postmaster has commanded this server process to roll back the current transaction and exit, because another server process exited abnormally and possibly corrupted shared memory.
HINT:  In a moment you should be able to reconnect to the database and repeat your command.
LOG:  archiver process (PID 6967) exited with exit code 1
LOG:  all server processes terminated; reinitializing
LOG:  database system was interrupted; last known up at 2018-03-12 21:53:54 CST
LOG:  database system was not properly shut down; automatic recovery in progress
LOG:  redo starts at 0/17000290
LOG:  invalid record length at 0/17000370: wanted 24, got 0
LOG:  redo done at 0/17000338
LOG:  MultiXact member wraparound protections are now enabled
LOG:  database system is ready to accept connections
LOG:  autovacuum launcher started
[postgres@ha pg_log]$

kill命令不要乱用！！！！！！
