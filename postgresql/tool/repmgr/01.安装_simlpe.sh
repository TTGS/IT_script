1,安装用  ./configure && make install 即可，  
网上说需要对pg的变量进行声明我在.bash_profile里声明了2个变量  PGDATA和PGHOME  ，但是，我在后来的测试中发现，这东西不用声明也行。  
文件内容如下：  
export PGHOME=/home/postgres/pg11.6  
export PGDATA=/home/postgres/pg11.6/data  

PATH=/home/postgres/pg11.6/bin::$PATH:$HOME/.local/bin:$HOME/bin  

2，验证是否安装成功，可以直接用  
[postgres@gpa ~]$ repmgr --version   
repmgr 4.4  
[postgres@gpa ~]$ repmgrd --version  
repmgrd 4.4  

3，系统安装编译用的是postgres 数据库安装用户即：  

[postgres@gpa ~]$ pg_ctl --version  
pg_ctl (PostgreSQL) 11.6  
[postgres@gpa ~]$ repmgr --version   
repmgr 4.4  
