机器名    |   ip            |     方向    |    pg里名称  
----------+-----------------+-------------+----------  
pga       | 192.168.122.129 |   发送方    |    发布  
----------+-----------------+-------------+----------  
pgb       | 192.168.122.52  |   接受方    |    订阅 


发送方（？我的在接受方报错，我在两边都改了。）的日志级别要 wal_level >= logical 否则要报错。  
ERROR:  could not create replication slot "pgb_sub": ERROR:  logical decoding requires wal_level >= logical  

发送方执行命令  
postgres=# create publication pga_pub for table a , b ;  
CREATE PUBLICATION  

接受方执行命令  
postgres=# create subscription pgb_sub   
connection 'host=192.168.122.129 port=5432 user=postgres dbname=postgres'   
publication pga_pub ;  
NOTICE:  created replication slot "pgb_sub" on publisher  
CREATE SUBSCRIPTION  


解释：  

发送方执行命令  
postgres=# create publication 发布名称 for table 表1 , 表2 ;    

接受方执行命令  
postgres=# create subscription 订阅名称   
connection 'host=ip地址 port=端口号 user=用户名 dbname=数据库名'   
publication 发布名称 ; 

/***************************************************************    
1,官方说truncate不能同步，不过我在11.6上测试发现truncate能过去  

2，指定表用for table ，库下全部表用for all table 

3，订阅要有权限的。  

4，物理流复制后的备库是不能创建发布他会报错
postgres=# create publication pgb_pub for all tables;  
ERROR:  cannot execute CREATE PUBLICATION in a read-only transaction  

5,创建伊始，就会同步数据过去。

6,发布和订阅的双方schema必须一致，复制报错“ERROR:  schema "hp" does not exist”

7，订阅方需要先有相同结构的表才能创建成功，否则会因为没有表而失败。

8，库不用一样，同步的库下可以有不同schema，同步的schema一样即可，但是前提是不能用for all tables 的方式。

9,如果你在发布方的发布表做更新删除，可能看到这样的错误
ERROR:  cannot delete from table "hp_a" because it does not have a replica identity and publishes deletes
HINT:  To enable deleting from the table, set REPLICA IDENTITY using ALTER TABLE.
需要使用  alter table base.hp_a REPLICA IDENTITY full ;  去解决问题

10,两台机器确实可以互相建立同一张表cust ， ##但是##  当你做dml操作的时候，他们会互相无限传日志，造成一个dml语句无限执行。  
****************************************************************/
