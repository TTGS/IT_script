
FATAL: could not write init file  

2018-05-02 17:04:37|  分类： PostgreSQL |  标签：postgresql  案例  报错信息  修复    
 
突然前线报错，数据库连接不上，听得我有点蒙，那运维没说数据库掉了，难道是网络？于是我准备登录到数据库上看看发生了什么，登录到服务器上，用psql登录看了一下，然后我也蒙了。
[dev@kv3000 ~]$ psql -d taxidb -U dev
psql: FATAL:  could not write init file

什么情况？？？盘满了？写一个文件进去。
[dev@kv3000 ~]$ echo 1 > 1.sh
[dev@kv3000 ~]$ cd /tmp
[dev@kv3000 tmp]$ echo 1 > 1.sh

这里我犯傻了，用这种方式看盘是否能写入，是否满了。
[dev@kv3000 tmp]$ psql -d taxidb -U dev
psql: FATAL:  could not write init file
[dev@kv3000 ~]$ cd /u01
[dev@kv3000 u01]$ cd pgdb/
[dev@kv3000 pgdb]$ cd pgdata/
[dev@kv3000 pgdata]$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2        20G  6.3G   12G  35% /
tmpfs            63G     0   63G   0% /dev/shm
/dev/sda1       190M   38M  142M  22% /boot
/dev/sda5       515G  489G   17M 100% /u01
/dev/sdb1       1.7T  1.4T  332G  81% /u02
[dev@kv3000 pgdata]$

psql进入的时候，会在pg的安装目录下进行写盘工作，连接数据库也会增加一些写盘内容。
所以如果看到不能写入初始化文件，那么只有一个问题了，pg安装目录的那个卷满了。
