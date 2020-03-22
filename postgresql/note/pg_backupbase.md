1，使用pg_backupbase 命令中的 “--create-slot”命令和直接使用  pg_create_physical_replication_slot 是一样的。  只不过（1）是备库写的，（2）是主库写的。  
另外 “--create-slot”后需要增加“--slot”，帮助里没有写，错误提示里写了。  
两个命令如下：  
（1） pg_basebackup -h 192.168.122.129 -p 5432 -U postgres  -R -D ./data/ -c fast  --create-slot --slot gpa   
（2） postgres=# select * from pg_create_physical_replication_slot('gpa');    

是否创建成功可以用以下命令查询：  
postgres=# select  *from pg_replication_slots;  
