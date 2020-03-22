
PostgreSQL10逻辑流的错误信息  

2017-11-09 14:48:11
标签：postgresql  数据库管理  报错信息  案例 

突然接到运维监控人员的一个报告，说pg数据库突然疯狂报错，
问做过什么？当然回答是什么也没做就这样了。

--发布端报错
2017-11-09 14:16:40.832 EST [13317] LOG:  starting logical decoding for slot "sub_test"
2017-11-09 14:16:40.832 EST [13317] DETAIL:  streaming transactions committing after 0/3043908, reading WAL from 0/30438D0
2017-11-09 14:16:40.832 EST [13317] LOG:  logical decoding found consistent point at 0/30438D0
2017-11-09 14:16:40.832 EST [13317] DETAIL:  There are no running transactions.
2017-11-09 14:16:40.832 EST [13317] ERROR:  publication "pub_test" does not exist
2017-11-09 14:16:40.832 EST [13317] CONTEXT:  slot "sub_test", output plugin "pgoutput", in the change callback, associated LSN 0/3043908


--接收端报错
2017-11-09 14:19:04.772 EST [13642] LOG:  logical replication apply worker for subscription "sub_test" has started
2017-11-09 14:19:04.775 EST [13642] ERROR:  could not receive data from WAL stream: ERROR:  publication "pub_test" does not exist
    CONTEXT:  slot "sub_test", output plugin "pgoutput", in the change callback, associated LSN 0/3043908
2017-11-09 14:19:04.775 EST [13629] LOG:  worker process: logical replication worker for subscription 24588 (PID 13642) exited with exit code 1

然后他们就不知道怎么办了。

先说下环境，这个报错环境是PostgreSQL10的环境。

猛地一看确实没有什么头绪，其实这个报错很有意思。
错误里说publication和subscription有问题。
有人会问，这是啥？
这是PostgreSQL10里新特性之一，叫逻辑复制(Logical replication)
主要用作两个master库的表级的主备。

这时候需要去检查逻辑复制是否搭建正常。
（注意，这里的内容错误是我模拟的，因为什么？你懂得～～）
--主库信息
psql (10.0)
Type "help" for help.

postgres=# select * from pg_replication_slots ;
 slot_name |  plugin  | slot_type | datoid | database | temporary | active | active_pid | xmin | catalog_xmin | restart_lsn |
 confirmed_flush_lsn
-----------+----------+-----------+--------+----------+-----------+--------+------------+------+--------------+-------------+
---------------------
 sub_test  | pgoutput | logical   |  13158 | postgres | f         | f      |            |      |          563 | 0/30438D0   |
 0/30438D0
(1 row)

postgres=# select * from pg_publication;
 pubname  | pubowner | puballtables | pubinsert | pubupdate | pubdelete
----------+----------+--------------+-----------+-----------+-----------
 test_pub |       10 | f            | t         | t         | t
(1 row)

postgres=#


--备库信息
psql (10.0)
Type "help" for help.

postgres=# select * from pg_subscription;
 subdbid | subname  | subowner | subenabled |                         subconninfo                         | subslotname | subsyn
ccommit | subpublications
---------+----------+----------+------------+-------------------------------------------------------------+-------------+-------
--------+-----------------
   13158 | sub_test |       10 | t          | host=172.16.179.130 port=5432 dbname=postgres user=postgres | sub_test    | off   
        | {pub_test}
(1 row)

postgres=#


看到了吗？逻辑复制搭建的时候写出问题了。
主库的发布端叫test_pub， 订阅端叫pub_test 明显不对嘛。
当有数据插入的时候，造成了数据库要往其他备库传输数据的时候惊奇的发现，
怎么没有对应的内容呢？和说好的不一样啊～～
然后数据库就会瞬间怀疑库生了。报错也就发生了。

告诉他们，把这个订阅暂时删除了。
当然闯祸的开发当然不服气了，难道说我配置错了还不提示吗？

我们再来看
--主库
postgres=# create publication test_pub for table pub_table ;
CREATE PUBLICATION

--备库
postgres=# create  subscription sub_test
postgres-# connection 'host=172.16.179.130 port=5432 dbname=postgres user=postgres'
postgres-# publication pub_test;
CREATE SUBSCRIPTION

其实这里就没有报错，完全是成功的。
因为数据库也不知道你订阅的是哪个，
难道它还要帮你挨个检查结果吗？:P
