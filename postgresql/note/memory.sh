据说可以将pg的部分内容放在内存中，这样可以提高读写速度，步骤如下：

mkdir /tmp/ram
mount -t ramfs ramfs /tmp/ram -o size=10M
chown -R postgres.postgres /tmp/ram

CREATE TABLESPACE ramtablespace LOCATION '/tmp/ram';
CREATE TABLE ramtable(id serial primary key USING INDEX TABLESPACE ramtablespace) TABLESPACE ramtablespace;


另外，ramfs和tmpfs是两种，不同也一起贴来（https://www.cnblogs.com/dosrun/p/4057112.html）
ramfs和tmpfs是在内存上建立的文件系统（Filesystem）。
其优点是读写速度很快，但存在掉电丢失的风险。如果一个进程的性能瓶颈是硬盘的读写，那么可以考虑在ramfs或tmpfs上进行大文件的读写操作。

ramfs和tmpfs之间的区别：
ramfs和tmpfs的区别 
特性                 	 tmpfs                      	ramfs
达到空间上限时继续写入 	提示错误信息并终止 	 可以继续写尚未分配的空间
是否固定大小 	                  是 	                           否
是否使用swap 	           是 	                           否
具有易失性                      是 	                           是
 
 

测试如下，t是普通磁盘（SSD），r是内存。注意（以上创建方式和方法和下面测试无关)
[postgres@hp ~]$ pgbench -c 10 -r -t 1000   t
starting vacuum...end.
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 10
number of threads: 1
number of transactions per client: 1000
number of transactions actually processed: 10000/10000
latency average = 24.153 ms
tps = 414.024456 (including connections establishing)
tps = 414.057874 (excluding connections establishing)
statement latencies in milliseconds:
         0.002  \set aid random(1, 100000 * :scale)
         0.000  \set bid random(1, 1 * :scale)
         0.000  \set tid random(1, 10 * :scale)
         0.000  \set delta random(-5000, 5000)
         0.125  BEGIN;
         0.213  UPDATE pgbench_accounts SET abalance = abalance + :delta WHERE aid = :aid;
         0.142  SELECT abalance FROM pgbench_accounts WHERE aid = :aid;
         8.864  UPDATE pgbench_tellers SET tbalance = tbalance + :delta WHERE tid = :tid;
        12.291  UPDATE pgbench_branches SET bbalance = bbalance + :delta WHERE bid = :bid;
         0.126  INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES (:tid, :bid, :aid, :delta, CURRENT_TIMESTAMP);
         2.259  END;

[postgres@hp ~]$ pgbench -c 10 -r -t 1000   r
starting vacuum...end.
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 10
number of threads: 1
number of transactions per client: 1000
number of transactions actually processed: 10000/10000
latency average = 22.407 ms
tps = 446.290741 (including connections establishing)
tps = 446.329076 (excluding connections establishing)
statement latencies in milliseconds:
         0.001  \set aid random(1, 100000 * :scale)
         0.000  \set bid random(1, 1 * :scale)
         0.000  \set tid random(1, 10 * :scale)
         0.000  \set delta random(-5000, 5000)
         0.110  BEGIN;
         0.197  UPDATE pgbench_accounts SET abalance = abalance + :delta WHERE aid = :aid;
         0.130  SELECT abalance FROM pgbench_accounts WHERE aid = :aid;
         8.221  UPDATE pgbench_tellers SET tbalance = tbalance + :delta WHERE tid = :tid;
        11.335  UPDATE pgbench_branches SET bbalance = bbalance + :delta WHERE bid = :bid;
         0.110  INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES (:tid, :bid, :aid, :delta, CURRENT_TIMESTAMP);
         2.108  END;
