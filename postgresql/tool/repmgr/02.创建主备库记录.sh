完整创建步骤：  
#  主库创建安装
1 在postgresql.conf里修改这些参数，具体原因可以在 https://repmgr.org/docs/4.0/quickstart-postgresql-configuration.html 这里找到
（注意：我在 https://github.com/TTGS/note/blob/master/postgresql/tool/repmgr/01.%E5%AE%89%E8%A3%85_full.sh  这里也备了一个内容。）
 max_wal_senders = 10
 wal_level = 'hot_standby'  
 hot_standby = on  
 archive_mode = on  
 archive_command = '/bin/true'  
 wal_keep_segments = 5000  #够多就行。  
 
 2 创建管理库和管理用户 --（如果你想用原来的postgres，这里不用执行就可以，后续的repmgr也都要改成你的postgres用户）
    createuser -s repmgr
    createdb repmgr -O repmgr
    ALTER USER repmgr SET search_path TO repmgr, "$user", public;
    
 3 允许链接
    local   replication   repmgr                              trust
    host    replication   repmgr      127.0.0.1/32            trust
    host    replication   repmgr      你的ip/24               trust
    local   repmgr        repmgr                              trust
    host    repmgr        repmgr      127.0.0.1/32            trust
    host    repmgr        repmgr      你的ip/24               trust
    
 
 4  测试一下能不能用
    psql 'host=node1 user=repmgr dbname=repmgr connect_timeout=2'
 
 5 配置repmgr文件,
 找地方创建一个名为repmgr.conf 的文件，配置文件内容如下：
    node_id=1
    node_name=ip地址
    conninfo='host=ip地址 user=用户名 dbname=库名 connect_timeout=2'
    data_directory='$PGDATA'
    
    例如：
    node_id=1
    node_name=node1
    conninfo='host=node1 user=repmgr dbname=repmgr connect_timeout=2'
    data_directory='/var/lib/postgresql/data'
  
6 直接启动数据库，然后注册  --这里你可以看到在输出日志里写了，创建内容成功的字眼。
repmgr -f /etc/repmgr.conf primary register

7 检查注册是否成功  -- 第4.6步时候，他在数据库里创建了一个repmgr的schema，把内容都放在这个schema里了。
[postgres@gpb pg11.6]$ repmgr -f data/repmgr.conf  cluster show 
 ID | Name     | Role    | Status    | Upstream | Location | Priority | Timeline | Connection string                                                  
----+----------+---------+-----------+----------+----------+----------+----------+---------------------------------------------------------------------
 1  | node1_52 | primary | * running |          | default  | 100      | 1        | host=192.168.122.52 user=postgres dbname=postgres connect_timeout=2

或者

postgres=# select * from  repmgr.nodes;
-[ RECORD 1 ]----+--------------------------------------------------------------------
node_id          | 1
upstream_node_id | 
active           | t
node_name        | node1_52
type             | primary
location         | default
priority         | 100
conninfo         | host=192.168.122.52 user=postgres dbname=postgres connect_timeout=2
repluser         | postgres
slot_name        | 
config_file      | /home/postgres/pg11.6/data/repmgr.conf





# 安装备库：  
1，需要对过打开数据库
2，可以用 repmgr -h 主ip  -U 主用户 -d 主库  -f repmgr.conf standby clone --dry-run 对环境测试。
[postgres@gpa ~]$ repmgr -h 192.168.122.52 -U postgres -d postgres -f repmgr.conf standby clone --dry-run
NOTICE: destination directory "/home/postgres/pg11.6/data" provided
INFO: connecting to source node
DETAIL: connection string is: host=192.168.122.52 user=postgres dbname=postgres
DETAIL: current installation size is 22 MB
WARNING: target data directory appears to be a PostgreSQL data directory
DETAIL: target data directory is "/home/postgres/pg11.6/data"
HINT: use -F/--force to overwrite the existing data directory
INFO: parameter "max_wal_senders" set to 10
NOTICE: checking for available walsenders on the source node (2 required)
INFO: sufficient walsenders available on the source node
DETAIL: 2 required, 10 available
NOTICE: checking replication connections can be made to the source server (2 required)
INFO: required number of replication connections could be made to the source server
DETAIL: 2 replication connections required
NOTICE: standby will attach to upstream node 1
HINT: consider using the -c/--fast-checkpoint option
INFO: all prerequisites for "standby clone" are met

3，使用 repmgr -h 192.168.122.52 -U postgres -d postgres -f repmgr.conf standby clone 开始克隆，#看意思是有覆盖pgdata目录内容
[postgres@gpa ~]$ repmgr -h 192.168.122.52 -U postgres -d postgres -f repmgr.conf standby clone -F
NOTICE: destination directory "/home/postgres/pg11.6/data" provided
INFO: connecting to source node
DETAIL: connection string is: host=192.168.122.52 user=postgres dbname=postgres
DETAIL: current installation size is 22 MB
NOTICE: checking for available walsenders on the source node (2 required)
NOTICE: checking replication connections can be made to the source server (2 required)
WARNING: directory "/home/postgres/pg11.6/data" exists but is not empty
NOTICE: -F/--force provided - deleting existing data directory "/home/postgres/pg11.6/data"
NOTICE: starting backup (using pg_basebackup)...
HINT: this may take some time; consider using the -c/--fast-checkpoint option
INFO: executing:
  pg_basebackup -l "repmgr base backup"  -D /home/postgres/pg11.6/data -h 192.168.122.52 -p 5432 -U postgres -X stream 
NOTICE: standby clone (using pg_basebackup) complete
NOTICE: you can now start your PostgreSQL server
HINT: for example: pg_ctl -D /home/postgres/pg11.6/data start
HINT: after starting the server, you need to register this standby with "repmgr standby register"

4，需要手动打开数据库，#注意，提示有说你打开数据库，但是词语并不明显。
[postgres@gpa ~]$ pg_ctl start -D pg11.6/data/
waiting for server to start....2020-02-07 19:45:27.787 EST [1707] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2020-02-07 19:45:27.787 EST [1707] LOG:  listening on IPv6 address "::", port 5432
2020-02-07 19:45:27.796 EST [1707] LOG:  listening on Unix socket "/tmp/.s.PGSQL.5432"
2020-02-07 19:45:27.810 EST [1707] LOG:  redirecting log output to logging collector process
2020-02-07 19:45:27.810 EST [1707] HINT:  Future log output will appear in directory "log".
 done
server started

5，可以看到和主库一样的信息说明克隆成功。
[postgres@gpa ~]$ repmgr -f repmgr.conf cluster show 
 ID | Name     | Role    | Status    | Upstream | Location | Priority | Timeline | Connection string                                                  
----+----------+---------+-----------+----------+----------+----------+----------+---------------------------------------------------------------------
 1  | node1_52 | primary | * running |          | default  | 100      | 1        | host=192.168.122.52 user=postgres dbname=postgres connect_timeout=2

6，备库依然需要手动去注册。
[postgres@gpa ~]$ repmgr -f repmgr.conf standby register
INFO: connecting to local node "node2_129" (ID: 2)
INFO: connecting to primary database
WARNING: --upstream-node-id not supplied, assuming upstream node is primary (node ID 1)
INFO: standby registration complete
NOTICE: standby node "node2_129" (ID: 2) successfully registered

7，成功后可以看到注册信息。
[postgres@gpa ~]$ repmgr -f repmgr.conf cluster show 
 ID | Name      | Role    | Status    | Upstream | Location | Priority | Timeline | Connection string                                                   
----+-----------+---------+-----------+----------+----------+----------+----------+----------------------------------------------------------------------
 1  | node1_52  | primary | * running |          | default  | 100      | 1        | host=192.168.122.52 user=postgres dbname=postgres connect_timeout=2 
 2  | node2_129 | standby |   running | node1_52 | default  | 100      | 1        | host=192.168.122.129 user=postgres dbname=postgres connect_timeout=2
 
