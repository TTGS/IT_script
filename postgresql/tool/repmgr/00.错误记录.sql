
1，在创建官方要求的用户时候，  createuser -s repmgr 发现hold住，很久不返回，停掉进入数据库创建依然hold住，停掉删除表一样。查看内存发现大量进程互等
postgres  2241  2231  0 07:24 ?        00:00:00 postgres: postgres postgres [local] CREATE ROLE waiting for 1/D6000900
postgres  2246  2231  0 07:26 ?        00:00:00 postgres: postgres postgres [local] CREATE ROLE waiting
postgres  2270  1364  0 07:27 pts/0    00:00:00 psql
postgres  2271  2231  0 07:27 ?        00:00:00 postgres: postgres postgres [local] DROP TABLE waiting for 1/D6008328

停掉数据库重启依然没有改善，将postgres.conf里的参数synchronous_standby_names = '*'  注释掉，问题解决。

-----------------------
2,只是注册一个主库后，是没有办法取消掉，删除pgdata重新初始化会出现异样，但是可以通过重新编译覆盖原内容实现注销主库。
