
postgresql 的非log表-unlogged  
--------------------------
作者:TT
日期：2017-10-07 19:13:45
标签：postgresql  数据库管理  功能  
--------------------------------       

pg有一种非记录日志的表，几乎是不记录wal的，这样就相当于提高了表的写入速度，但是如果出现任何的意外都将不能做到恢复表。做个小测试。
[postgres@xiaoli pgdata]$ cat ~/1.sql
\timing
truncate table test_log;
truncate table test;
insert into test_log values(generate_series(1,1000000),uuid_generate_v4());
insert into test values(generate_series(1,1000000),uuid_generate_v4());
update test_log set uid=uuid_generate_v4();
update test set uid=uuid_generate_v4();

在执行过程中，开启另一个终端杀掉主进程。不过让我很意外的是10在杀掉终端后依然在写入数据。直到数据都写入完成才停止。
[postgres@xiaoli pgdata]$ psql -d mydb -f ~/1.sql
Timing is on.
TRUNCATE TABLE
Time: 23.965 ms
TRUNCATE TABLE
Time: 13.774 ms
INSERT 0 1000000
Time: 4403.230 ms (00:04.403)
INSERT 0 1000000
Time: 4677.025 ms (00:04.677)
UPDATE 1000000
Time: 4664.203 ms (00:04.664)
UPDATE 1000000
Time: 13408.965 ms (00:13.409)
[postgres@xiaoli pgdata]$

看到数据库其实已经关闭了。
[postgres@xiaoli pgdata]$ psql -d mydb -f ~/1.sql
psql: could not connect to server: Connection refused
    Is the server running locally and accepting
    connections on Unix domain socket "/tmp/.s.PGSQL.5432"?
[postgres@xiaoli pgdata]$

开启数据库，数据库在做恢复。
[postgres@xiaoli pgdata]$ pg_ctl restart -mf  -D /pg/db/10.0/pgdata/
pg_ctl: old server process (PID: 4980) seems to be gone
starting server anyway
waiting for server to start....2017-10-07 18:41:21.337 EDT [5053] LOG:  listening on IPv6 address "::1", port 5432
2017-10-07 18:41:21.337 EDT [5053] LOG:  listening on IPv4 address "127.0.0.1", port 5432
2017-10-07 18:41:21.339 EDT [5053] LOG:  listening on Unix socket "/tmp/.s.PGSQL.5432"
2017-10-07 18:41:21.543 EDT [5053] LOG:  redirecting log output to logging collector process
2017-10-07 18:41:21.543 EDT [5053] HINT:  Future log output will appear in directory "log".

.
........ done
server started
[postgres@xiaoli pgdata]$
[postgres@xiaoli pgdata]$

进入数据库查看表的大小。各位就能看到，test_log里面是空的，对没错，test_log是unlogged模式的。如果中间出现任何问题，数据是不管给你找回的。也就丢失。
[postgres@xiaoli pgdata]$ psql -d mydb
psql (10.0)
Type "help" for help.

mydb=# \dt+
                      List of relations
 Schema |   Name   | Type  |  Owner   |  Size   | Description
--------+----------+-------+----------+---------+-------------
 public | test     | table | postgres | 100 MB  |
 public | test_log | table | postgres | 0 bytes |
(2 rows)

mydb=#


谨慎使用unlogged表确实可以提高dml的操作速度，但是随之而来的风险也要清楚。
