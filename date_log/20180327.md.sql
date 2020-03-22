
ERROR: first column of remote table must be unique for INSERT/UPDATE/DELETE operation  

2018-03-27 12:56:25|  分类： PostgreSQL |  标签：postgresql  数据库管理  报错信息  案例  


咳咳，今天有人发来一个错误，说是pg的。
ERROR:  first column of remote table must be unique for INSERT/UPDATE/DELETE operation

问了一下做什么操作出现的这个错误提示。

postgres=# insert into abc values(2);
ERROR:  first column of remote table must be unique for INSERT/UPDATE/DELETE operation
Time: 1.453 ms



他们觉得很不可思议，都什么年代了，还要表加唯一约束。

当然先看下这个表是什么样子。

postgres=#           
 
select * From abc;
 id
----
  1
(1 row)

Time: 2.547 ms

再看一下表结构。
postgres=# \d abc
                   Foreign table "public.abc"
 Column |  Type   | Collation | Nullable | Default | FDW options
--------+---------+-----------+----------+---------+-------------
 id     | integer |           |          |         |
Server: mysql_s1
FDW options: (dbname 'taxi', table_name 'abc')

很明显这个表不是pg内的一般表，他是一个通过mysql_s1服务连接到另一个服务器或者其他数据库的。

具体是什么呢？我们继续查看。
postgres=# \des
          List of foreign servers
   Name   |  Owner   | Foreign-data wrapper
----------+----------+----------------------
 mysql_s1 | postgres | mysql_fdw
(1 row)

postgres=# \des+
                                                        List of foreign servers
   Name   |  Owner   | Foreign-data wrapper | Access privileges | Type | Version
 |              FDW options              | Description
----------+----------+----------------------+-------------------+------+--------
-+---------------------------------------+-------------
 mysql_s1 | postgres | mysql_fdw            |                   |      |        
 | (host '192.168.239.132', port '3306') |
(1 row)

postgres=#

不用多说了，这个是一个通过mysql_fdw插件去连接到 192.168.239.132 机器上的扩展。

这个mysql_fdw扩展确实可以查询和推dml操作，当然这也不是没有代价的。需要在mysql数据库的服务器端创建一个约束即可。
