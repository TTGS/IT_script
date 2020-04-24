1,参数文件在安装包的etc里有，pgbouncer1.12 叫 pgbouncer.ini  

2,启动命令  ./bin/pgbouncer -d  参数文件

3,进入pgbouncer的命令是 psql -p 6432 -U   用户   pgbouncer

4，3当中的用户在认证文件里写的用户名，对应的配置文件中的参数为
auth_type = trust             --认证方式
auth_file = /home/postgres/pgbcer112/userlist.txt    --认证用户文件记录，里面就是用户和“密码”

5，进到pgbouncer里后可以用show databases;  看到的数据库是在配置文件里参数是在
[database]   --标题下内容,例如
hpdb = host=127.0.0.1 port=5432 user=postgres dbname=hp  connect_query='SELECT now();'
