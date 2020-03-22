1,pipeline 是可以支持PostgreSQL的 分支或者插件

2，pipeline是利用zeromq 分布式消息进行的。

3，他的流计算方式是需要提前定义sql才能，而低层定义的表是一个外部表，可以插入数据但是不能直接查询。

4，创建流计算的视图后，会会出现多个进程进行盯。
postgres   2344   2331  0 01:30 ?        00:00:00 postgres: bgworker: reaper0 [ttgs]   
postgres   2345   2331  0 01:30 ?        00:00:00 postgres: bgworker: queue0 [ttgs]   
postgres   2346   2331  0 01:30 ?        00:00:00 postgres: bgworker: combiner0 [ttgs]   
postgres   2347   2331  0 01:30 ?        00:00:00 postgres: bgworker: worker0 [ttgs]   

5，如果有reaper0，queue0 , combiner0,worker0 存在，那么这个库就不能删除，需要先删除原有的流表后才能删除这个库。

6，如果在删除流表前删除流插件，那么他会报错。
ttgs=# drop extension pipelinedb ;
2019-01-21 01:29:30.323 EST [1469] LOG:  terminating pipelinedb processes for database: "ttgs"
2019-01-21 01:29:30.326 EST [1476] LOG:  pipelinedb process "queue0 [ttgs]" shutting down
2019-01-21 01:29:30.327 EST [1478] LOG:  pipelinedb process "worker0 [ttgs]" shutting down
2019-01-21 01:29:30.328 EST [1475] LOG:  pipelinedb process "reaper0 [ttgs]" shutting down
2019-01-21 01:29:30.330 EST [1477] LOG:  pipelinedb process "combiner0 [ttgs]" shutting down
2019-01-21 01:29:30.381 EST [2291] ERROR:  cannot drop extension pipelinedb because other objects depend on it
2019-01-21 01:29:30.381 EST [2291] DETAIL:  foreign table test_stream depends on table pipelinedb.stream
        view test_view depends on table pipelinedb.stream
2019-01-21 01:29:30.381 EST [2291] HINT:  Use DROP ... CASCADE to drop the dependent objects too.
2019-01-21 01:29:30.381 EST [2291] STATEMENT:  drop extension pipelinedb ;
ERROR:  cannot drop extension pipelinedb because other objects depend on it
DETAIL:  foreign table test_stream depends on table pipelinedb.stream
view test_view depends on table pipelinedb.stream
HINT:  Use DROP ... CASCADE to drop the dependent objects too.
2019-01-21 01:29:30.384 EST [2293] LOG:  pipelinedb process "queue0 [ttgs]" running with pid 2293
2019-01-21 01:29:30.384 EST [2292] LOG:  pipelinedb process "reaper0 [ttgs]" running with pid 2292
2019-01-21 01:29:30.387 EST [2294] LOG:  pipelinedb process "combiner0 [ttgs]" running with pid 2294
2019-01-21 01:29:30.388 EST [2295] LOG:  pipelinedb process "worker0 [ttgs]" running with pid 2295


7,pipeline在创建view之后才会计算数据，之前的多少数据都不计算。

8，pip创建的流表不能delete，不能truncate ，会报错的。
