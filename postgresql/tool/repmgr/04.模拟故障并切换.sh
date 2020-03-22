#主库关闭数据库，模拟故障
[postgres@gpb ~]$ pg_ctl stop -m f -D pg11.6/data/
waiting for server to shut down....
 done
server stopped

#备库看到内容
[postgres@gpa ~]$ repmgr -f repmgr.conf cluster show 
 ID | Name      | Role    | Status        | Upstream   | Location | Priority | Timeline | Connection string                                                   
----+-----------+---------+---------------+------------+----------+----------+----------+----------------------------------------------------------------------
 1  | node1_52  | primary | ? unreachable |            | default  | 100      | ?        | host=192.168.122.52 user=postgres dbname=postgres connect_timeout=2 
 2  | node2_129 | standby |   running     | ? node1_52 | default  | 100      | 1        | host=192.168.122.129 user=postgres dbname=postgres connect_timeout=2

WARNING: following issues were detected
  - unable to connect to node "node1_52" (ID: 1)
  - node "node1_52" (ID: 1) is registered as an active primary but is unreachable
  - unable to connect to node "node2_129" (ID: 2)'s upstream node "node1_52" (ID: 1)
  - unable to determine if node "node2_129" (ID: 2) is attached to its upstream node "node1_52" (ID: 1)
  
 #提升备库身份为主库。--》这里注意，我在这之前试过好多次，都是失败了。这里用了同样的命令，但是就成功了。原因不知道。
[postgres@gpa ~]$ repmgr -f repmgr.conf standby promote --verbose
NOTICE: using provided configuration file "repmgr.conf"
INFO: connected to standby, checking its state
INFO: searching for primary node
INFO: checking if node 1 is primary
ERROR: connection to database failed
DETAIL: 
could not connect to server: Connection refused
	Is the server running on host "192.168.122.52" and accepting
	TCP/IP connections on port 5432?

DETAIL: attempted to connect using:
  user=postgres connect_timeout=2 dbname=postgres host=192.168.122.52 fallback_application_name=repmgr
INFO: checking if node 2 is primary
NOTICE: promoting standby to primary
DETAIL: promoting server "node2_129" (ID: 2) using "pg_ctl  -w -D '/home/postgres/pg11.6/data' promote"
waiting for server to promote.... done
server promoted
NOTICE: waiting up to 60 seconds (parameter "promote_check_timeout") for promotion to complete
INFO: standby promoted to primary after 0 second(s)
NOTICE: STANDBY PROMOTE successful
DETAIL: server "node2_129" (ID: 2) was successfully promoted to primary

#备库成功，并且看到备库已经成功。
[postgres@gpa ~]$ repmgr -f repmgr.conf cluster show 
 ID | Name      | Role    | Status    | Upstream | Location | Priority | Timeline | Connection string                                                   
----+-----------+---------+-----------+----------+----------+----------+----------+----------------------------------------------------------------------
 1  | node1_52  | primary | - failed  |          | default  | 100      | ?        | host=192.168.122.52 user=postgres dbname=postgres connect_timeout=2 
 2  | node2_129 | primary | * running |          | default  | 100      | 2        | host=192.168.122.129 user=postgres dbname=postgres connect_timeout=2

WARNING: following issues were detected
  - unable to connect to node "node1_52" (ID: 1)
 



#开启主库，可以看到不一样的内容。
[postgres@gpb ~]$ pg_ctl start -D pg11.6/data/
waiting for server to start....2020-02-07 20:27:28.052 EST [1553] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2020-02-07 20:27:28.052 EST [1553] LOG:  listening on IPv6 address "::", port 5432
2020-02-07 20:27:28.061 EST [1553] LOG:  listening on Unix socket "/tmp/.s.PGSQL.5432"
2020-02-07 20:27:28.080 EST [1553] LOG:  redirecting log output to logging collector process
2020-02-07 20:27:28.080 EST [1553] HINT:  Future log output will appear in directory "log".
 done
server started
[postgres@gpb ~]$ 
[postgres@gpb ~]$ 
[postgres@gpb ~]$ repmgr -f pg11.6/data/repmgr.conf cluster show 
 ID | Name      | Role    | Status               | Upstream | Location | Priority | Timeline | Connection string                                                   
----+-----------+---------+----------------------+----------+----------+----------+----------+----------------------------------------------------------------------
 1  | node1_52  | primary | * running            |          | default  | 100      | 1        | host=192.168.122.52 user=postgres dbname=postgres connect_timeout=2 
 2  | node2_129 | standby | ! running as primary |          | default  | 100      | 2        | host=192.168.122.129 user=postgres dbname=postgres connect_timeout=2

WARNING: following issues were detected
  - node "node2_129" (ID: 2) is registered as standby but running as primary


#想重新开始还给重新克隆过去。注意点，这时候是需要 旧主库 关闭状态，并且他会提示pgdata内有东西，可以加 -F 强制
##pgdata有东西，报错
[postgres@gpb ~]$ repmgr -D pg11.6/data/ -d postgres -U postgres -f repmgr.conf -h 192.168.122.129 standby clone 
NOTICE: destination directory "/home/postgres/pg11.6/data" provided
INFO: connecting to source node
DETAIL: connection string is: user=postgres host=192.168.122.129 dbname=postgres
DETAIL: current installation size is 22 MB
ERROR: target data directory appears to be a PostgreSQL data directory
DETAIL: target data directory is "/home/postgres/pg11.6/data"
HINT: use -F/--force to overwrite the existing data directory
## 强制覆盖。
[postgres@gpb ~]$ repmgr -D pg11.6/data/ -d postgres -U postgres -f repmgr.conf -h 192.168.122.129 standby clone -F
NOTICE: destination directory "/home/postgres/pg11.6/data" provided
INFO: connecting to source node
DETAIL: connection string is: user=postgres host=192.168.122.129 dbname=postgres
DETAIL: current installation size is 22 MB
NOTICE: checking for available walsenders on the source node (2 required)
NOTICE: checking replication connections can be made to the source server (2 required)
WARNING: directory "/home/postgres/pg11.6/data" exists but is not empty
NOTICE: -F/--force provided - deleting existing data directory "/home/postgres/pg11.6/data"
NOTICE: starting backup (using pg_basebackup)...
HINT: this may take some time; consider using the -c/--fast-checkpoint option
INFO: executing:
  pg_basebackup -l "repmgr base backup"  -D /home/postgres/pg11.6/data -h 192.168.122.129 -p 5432 -U postgres -X stream 
NOTICE: standby clone (using pg_basebackup) complete
NOTICE: you can now start your PostgreSQL server
HINT: for example: pg_ctl -D /home/postgres/pg11.6/data start
HINT: after starting the server, you need to re-register this standby with "repmgr standby register --force" to update the existing node record

#依然要求你手工开启数据库。
[postgres@gpb ~]$ pg_ctl start -D pg11.6/data/
waiting for server to start....2020-02-07 20:33:04.805 EST [1607] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2020-02-07 20:33:04.805 EST [1607] LOG:  listening on IPv6 address "::", port 5432
2020-02-07 20:33:04.812 EST [1607] LOG:  listening on Unix socket "/tmp/.s.PGSQL.5432"
2020-02-07 20:33:04.826 EST [1607] LOG:  redirecting log output to logging collector process
2020-02-07 20:33:04.826 EST [1607] HINT:  Future log output will appear in directory "log".
 done
server started

#你依然需要注册
##因为原来有内容，需要强制覆盖。
[postgres@gpb ~]$ repmgr -f repmgr.conf standby register 
INFO: connecting to local node "node1_52" (ID: 1)
INFO: connecting to primary database
ERROR: node 1 is already registered
HINT: use option -F/--force to overwrite an existing node record

##强制覆盖内容。
[postgres@gpb ~]$ repmgr -f repmgr.conf standby register -F
INFO: connecting to local node "node1_52" (ID: 1)
INFO: connecting to primary database
INFO: standby registration complete
NOTICE: standby node "node1_52" (ID: 1) successfully registered
[postgres@gpb ~]$ 

#主库备库可以看到内容
[postgres@gpa ~]$ repmgr -f repmgr.conf cluster show 
 ID | Name      | Role    | Status    | Upstream  | Location | Priority | Timeline | Connection string                                                   
----+-----------+---------+-----------+-----------+----------+----------+----------+----------------------------------------------------------------------
 1  | node1_52  | standby |   running | node2_129 | default  | 100      | 2        | host=192.168.122.52 user=postgres dbname=postgres connect_timeout=2 
 2  | node2_129 | primary | * running |           | default  | 100      | 2        | host=192.168.122.129 user=postgres dbname=postgres connect_timeout=2
