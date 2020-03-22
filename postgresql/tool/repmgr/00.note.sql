1,repmgr搭建好的备库里，依然不能创建订阅或者发布

[postgres@gpa ~]$ ip a s ens3
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:13:9f:eb brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.129/24 brd 192.168.122.255 scope global noprefixroute dynamic ens3
       valid_lft 3072sec preferred_lft 3072sec
    inet6 fe80::9c96:d92d:f7cb:7cd7/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
[postgres@gpa ~]$ repmgr -f repmgr.conf cluster show 
 ID | Name      | Role    | Status    | Upstream | Location | Priority | Timeline | Connection string                                                   
----+-----------+---------+-----------+----------+----------+----------+----------+----------------------------------------------------------------------
 1  | node1_52  | primary | * running |          | default  | 100      | 1        | host=192.168.122.52 user=postgres dbname=postgres connect_timeout=2 
 2  | node2_129 | standby |   running | node1_52 | default  | 100      | 1        | host=192.168.122.129 user=postgres dbname=postgres connect_timeout=2
[postgres@gpa ~]$ psql
psql (11.6)
Type "help" for help.

postgres=# create publication pga ;
ERROR:  cannot execute CREATE PUBLICATION in a read-only transaction
postgres=# 


2， 备库提升命令只能在备库执行
[postgres@gpb ~]$ repmgr -f pg11.6/data/repmgr.conf standby promote
ERROR: STANDBY PROMOTE can only be executed on a standby node


3，用传统的trigger_file = '' 也可以直接提升数据库为主库角色。 （注意：虽然备库角色是写的备库，但是真的可以在备库读写了。）
备库在recovery.conf 里添加trigger_file = ''命令

#备库
[postgres@gpa ~]$ cat pg11.6/data/recovery.done 
standby_mode = 'on'
primary_conninfo = 'user=postgres connect_timeout=2 host=192.168.122.52 fallback_application_name=repmgr application_name=node2_129'
recovery_target_timeline = 'latest'
trigger_file = '/home/postgres/GBA'
[postgres@gpa ~]$ touch GBA

#主库看到的内容。
[postgres@gpb ~]$ repmgr -f repmgr.conf cluster show 
 ID | Name      | Role    | Status    | Upstream | Location | Priority | Timeline | Connection string                                                   
----+-----------+---------+-----------+----------+----------+----------+----------+----------------------------------------------------------------------
 1  | node1_52  | primary | * running |          | default  | 100      | 3        | host=192.168.122.52 user=postgres dbname=postgres connect_timeout=2 
 2  | node2_129 | standby |   running | node1_52 | default  | 100      | 3        | host=192.168.122.129 user=postgres dbname=postgres connect_timeout=2
[postgres@gpb ~]$ 
[postgres@gpb ~]$ 
[postgres@gpb ~]$ repmgr -f repmgr.conf cluster show 
 ID | Name      | Role    | Status               | Upstream   | Location | Priority | Timeline | Connection string                                                   
----+-----------+---------+----------------------+------------+----------+----------+----------+----------------------------------------------------------------------
 1  | node1_52  | primary | * running            |            | default  | 100      | 3        | host=192.168.122.52 user=postgres dbname=postgres connect_timeout=2 
 2  | node2_129 | standby | ! running as primary | ! node1_52 | default  | 100      | 4        | host=192.168.122.129 user=postgres dbname=postgres connect_timeout=2

WARNING: following issues were detected
  - node "node2_129" (ID: 2) is registered as standby but running as primary
  - node "node2_129" (ID: 2) is not attached to its upstream node "node1_52" (ID: 1)


4,在pgdata下有recovery.conf 的话，创建会抱错。去掉“--recovery-conf-only” 即可解决，不过recovery.conf 文件内容和原理不是一样。
[postgres@gpa ~]$ repmgr -f repmgr.conf  -D pg11.6/data/ -d postgres -U postgres -h 192.168.122.52 standby clone -F --recovery-conf-only
ERROR: unable to retrieve node record for local node 2
HINT: standby must be registered before a new recovery.conf file can be created
