
安装mysql_fdw扩展  

2018-03-26 16:03:16|  分类： PostgreSQL |  标签：postgresql  功能  安装  


因为业务需要，需要从mysql的数据库同步到postgresql数据库。
mysql的dba提出，他们可以帮助同步数据，并且愿意帮我们搭建各种从库(1主多从，多主多从，1从多主)，
感谢mysql的dba提供各种帮助，但是对于PostgreSQL数据库来说，这些真的不需要。
PostgreSQL的数据库有各种扩展，有些扩展可以做很多事情，mysql_fdw就是这样的一个扩展。
他的作用和名字一样，他的作用就是让PG具有连接mysql数据库的能力，
或者说pg可以直接去mysql数据库里直接读取数据。

这里记录一下按照过程。
mysql_fdw可以从 https://github.com/EnterpriseDB/mysql_fdw  下载源代码即可。
这个mysql_fdw，本身也需要部分mysql的lib及client内容的支持。
mysql的功能包可以从  https://dev.mysql.com/downloads/mysql/ 这里我下的是 mysql-5.7.21-1.el7.x86_64.rpm-bundle.tar内容，因为这里个包可以批量下载我需要的内容。

我们需要先删除本身的mariadb和mysql内容。用旧的也不是绝对不行，不过有点变扭。

不删除就可能发生下面的问题
[root@tiger pkg]# rpm -ivh mysql-community-client-5.7.21-1.el7.x86_64.rpm mysql-
community-libs-compat-5.7.21-1.el7.x86_64.rpm
warning: mysql-community-client-5.7.21-1.el7.x86_64.rpm: Header V3 DSA/SHA1 Signature, key ID 5072e1f5: NOKEY
error: Failed dependencies:
    mysql-community-libs(x86-64) >= 5.7.9 is needed by mysql-community-client-5.7.21-1.el7.x86_64
    mariadb is obsoleted by mysql-community-client-5.7.21-1.el7.x86_64
    mysql-community-libs(x86-64) >= 5.7.9 is needed by mysql-community-libs-compat-5.7.21-1.el7.x86_64
    mariadb-libs is obsoleted by mysql-community-libs-compat-5.7.21-1.el7.x86_64
    
好了，我们开始删除。
[root@tiger pkg]# yum -y remove mariadb*
Loaded plugins: fastestmirror, langpacks
Resolving Dependencies
--> Running transaction check
...  省略部分内容  ...
Dependency Removed:
  akonadi-mysql.x86_64 0:1.9.2-4.el7     perl-DBD-MySQL.x86_64 0:4.023-5.el7    
  postfix.x86_64 2:2.10.1-6.el7          qt-mysql.x86_64 1:4.8.5-13.el7         

Complete!

解压缩包选择我们需要的几个内容。

最低按照需要，client端即可。不过libs和common是依赖包，一起安装吧。
注意，我这里也是少了不少内容，只是为了展示这个插件的几个错误。
mysql-community-client-5.7.21-1.el7.x86_64.rpm  
mysql-community-libs-5.7.21-1.el7.x86_64.rpm   
mysql-community-common-5.7.21-1.el7.x86_64.rpm

[root@tiger pkg]# rpm -ivh mysql-community-client-5.7.21-1.el7.x86_64.rpm  mysql-
-community-libs-5.7.21-1.el7.x86_64.rpm   mysql-community-common-5.7.21-1.el7.x86
6_64.rpm
warning: mysql-community-client-5.7.21-1.el7.x86_64.rpm: Header V3 DSA/SHA1 Signature, key ID 5072e1f5: NOKEY
Preparing...
...  省略部分内容  ...
 99%)################################# [100%]

如何知道安装是否可以被mysql_fdw可以使用了呢？
需要检查一个命令，编译的用户（可以是postgres用户编译）的时候能找到mysql_config就行。
[root@tiger pkg]# which mysql_config
/usr/bin/which: no mysql_config in (/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin)

看到了么，虽然有client端了，但是缺少了mysql_config，编译的时候需要读取了部分mysql的设定。这个特别要注意。
那么这个命令在哪里呢？在mysql-community-devel-5.7.21-1.el7.x86_64.rpm 里。
这个包直接安装就行了。

[root@tiger pkg]# rpm -ivh mysql-community-devel-5.7.21-1.el7.x86_64.rpm
warning: mysql-community-devel-5.7.21-1.el7.x86_64.rpm: Header V3 DSA/SHA1 Signature, key ID 5072e1f5: NOKEY
Preparing...   
...  省略部分内容 ...
 99%)################################# [100%]
[root@tiger pkg]#
[root@tiger pkg]# which my_config
/usr/bin/mysql_config

下一步我把对应的mysql_fdw源代码给到postgres用户，一会用用postgres编译。
[root@tiger pkg]# cd ..
[root@tiger soft]# ls
mysql-5.7.21-linux-glibc2.12-x86_64.tar.gz     mysql_fdw-master.zip
mysql_fdw_10-2.4.0-1.rhel7.x86_64.rpm         pkg
mysql_fdw_10-debuginfo-2.4.0-1.rhel7.x86_64.rpm  postgresql-10.3.tar.gz
[root@tiger soft]# cp mysql_fdw-master.zip /home/postgres/
[root@tiger soft]# chown postgres:postgres /home/postgres/mysql_fdw-master.zip
[root@tiger soft]# su - postgres
Last login: Tue Mar 20 01:10:55 CST 2018 on pts/0

给大家展示一下，我是否打开postgresql和mysql两种数据没有。
[postgres@tiger ~]$ ps auxww|grep post
root   2181  0.1  0.1 220576  3384 pts/0    S    19:33   0:00
gres   2182  0.2  0.1 116572  3244 pts/0    S    19:33   0:00 -bash
gres   2236  0.0  0.0 151064  1808 pts/0    R+   19:33   0:00 ps auxww
gres   2237  0.0  0.0 112660   968 pts/0    S+   19:33   0:00 grep --color=auto  
[postgres@tiger ~]$ ps auxww|grep mysql
postgres   2248  0.0  0.0 112660   968 pts/0    S+   19:34   0:00 grep --color=auto

好了，我们解压缩，然后我们编译下。
[postgres@tiger ~]$ ls
db  mysql_fdw-master.zip  postgresql-10.3  postgresql-10.3.tar.gz
[postgres@tiger ~]$unzip mysql_fdw-master.zip
Archive:  mysql_fdw-master.zip
6d436e01266a0e04d7b4c9a4a5558b7da1284684
   creating: mysql_fdw-master/
 extracting: mysql_fdw-master/.gitignore  
 extracting: mysql_fdw-master/CONTRIBUTING.md  
  inflating: mysql_fdw-master/LICENSE  
  inflating: mysql_fdw-master/META.json  
  inflating: mysql_fdw-master/Makefile  
  inflating: mysql_fdw-master/README.md  
  inflating: mysql_fdw-master/connection.c  
  inflating: mysql_fdw-master/deparse.c  
   creating: mysql_fdw-master/expected/
  inflating: mysql_fdw-master/expected/mysql_fdw.out  
  inflating: mysql_fdw-master/mysql_fdw--1.0--1.1.sql  
  inflating: mysql_fdw-master/mysql_fdw--1.0.sql  
  inflating: mysql_fdw-master/mysql_fdw--1.1.sql  
  inflating: mysql_fdw-master/mysql_fdw.c  
  inflating: mysql_fdw-master/mysql_fdw.control  
  inflating: mysql_fdw-master/mysql_fdw.h  
  inflating: mysql_fdw-master/mysql_init.sh  
  inflating: mysql_fdw-master/mysql_query.c  
  inflating: mysql_fdw-master/mysql_query.h  
  inflating: mysql_fdw-master/option.c  
   creating: mysql_fdw-master/sql/
  inflating: mysql_fdw-master/sql/mysql_fdw.sql  
[postgres@tiger ~]$ cd mysql_fdw-master/
[postgres@tiger mysql_fdw-master]$ ls
connection.c     Makefile          mysql_fdw.c         mysql_query.h
CONTRIBUTING.md  META.json          mysql_fdw.control  option.c
deparse.c     mysql_fdw--1.0--1.1.sql  mysql_fdw.h         README.md
expected     mysql_fdw--1.0.sql      mysql_init.sh      sql
LICENSE         mysql_fdw--1.1.sql      mysql_query.c

这里介绍一下，在这个包里的 README.md 文件，这里有你需要的所有安装参考内容。

另外在安装前需要在确定一下能找到pg_config命令。
[postgres@tiger mysql_fdw-master]$ which pg_config
~/db/bin/pg_config

做好准备就可以直接找到文档中的make内容了。其实就俩个make内容就行了。
[postgres@tiger mysql_fdw-master]$ cat README.md |grep make
1. To build on POSIX-compliant systems you need to ensure the `pg_config` executable is in your path when you run `make`. This executable is typically in your PostgreSQL installation's `bin` directory. For example:
3. Compile the code using make.
    $ make USE_PGXS=1
    $ make USE_PGXS=1 install
[postgres@tiger mysql_fdw-master]$ make USE_PGXS=1 && make USE_PGXS=1 install
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -g -O2 -fPIC -I/usr/include/mysql -D _MYSQL_LIBNAME=\"libmysqlclient.so\" -I. -I./ -I/home/postgres/db/include/server -I/home/postgres/db/include/internal  -D_GNU_SOURCE   -c -o connection.o connection.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -g -O2 -fPIC -I/usr/include/mysql -D _MYSQL_LIBNAME=\"libmysqlclient.so\" -I. -I./ -I/home/postgres/db/include/server -I/home/postgres/db/include/internal  -D_GNU_SOURCE   -c -o option.o option.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -g -O2 -fPIC -I/usr/include/mysql -D _MYSQL_LIBNAME=\"libmysqlclient.so\" -I. -I./ -I/home/postgres/db/include/server -I/home/postgres/db/include/internal  -D_GNU_SOURCE   -c -o deparse.o deparse.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -g -O2 -fPIC -I/usr/include/mysql -D _MYSQL_LIBNAME=\"libmysqlclient.so\" -I. -I./ -I/home/postgres/db/include/server -I/home/postgres/db/include/internal  -D_GNU_SOURCE   -c -o mysql_query.o mysql_query.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -g -O2 -fPIC -I/usr/include/mysql -D _MYSQL_LIBNAME=\"libmysqlclient.so\" -I. -I./ -I/home/postgres/db/include/server -I/home/postgres/db/include/internal  -D_GNU_SOURCE   -c -o mysql_fdw.o mysql_fdw.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -g -O2 -fPIC -shared -o mysql_fdw.so connection.o option.o deparse.o mysql_query.o mysql_fdw.o -L/home/postgres/db/lib -Wl,--as-needed -Wl,-rpath,'/home/postgres/db/lib',--enable-new-dtags  
/bin/mkdir -p '/home/postgres/db/lib'
/bin/mkdir -p '/home/postgres/db/share/extension'
/bin/mkdir -p '/home/postgres/db/share/extension'
/bin/install -c -m 755  mysql_fdw.so '/home/postgres/db/lib/mysql_fdw.so'
/bin/install -c -m 644 .//mysql_fdw.control '/home/postgres/db/share/extension/'
/bin/install -c -m 644 .//mysql_fdw--1.0.sql .//mysql_fdw--1.1.sql .//mysql_fdw--1.0--1.1.sql  '/home/postgres/db/share/extension/'


好了，这就已经编译好了。启动pg吧。
[postgres@tiger mysql_fdw-master]$ cd
[postgres@tiger ~]$ pg_ctl start -D db/pgdata/
waiting for server to start....2018-03-26 19:41:09.396 CST [2480] LOG:  listening on IPv6 address "::1", port 5432
2018-03-26 19:41:09.396 CST [2480] LOG:  listening on IPv4 address "127.0.0.1", port 5432
2018-03-26 19:41:09.397 CST [2480] LOG:  listening on Unix socket "/tmp/.s.PGSQL.5432"
2018-03-26 19:41:09.411 CST [2480] LOG:  redirecting log output to logging collector process
2018-03-26 19:41:09.411 CST [2480] HINT:  Future log output will appear in directory "log".
 done
server started
[postgres@tiger ~]$ psql
psql (10.3)
Type "help" for help.

postgres=# create extension mysql_fdw ;
ERROR:  failed to load the mysql query:
libmysqlclient.so: cannot open shared object file: No such file or directory
HINT:  export LD_LIBRARY_PATH to locate the library
postgres=# \q

这里有个报错，这个报错也是很多新手碰到，然后让很多新手都郁闷的错误。
这里看到的是让你去折腾 LD_LIBRARY_PATH 参数去。
我悄悄的告诉你，这个是因为他找不到mysql的lib内容
去root下，先ldconfig试试，然后回来再试试。

[root@tiger pkg]# ldconfig
[root@tiger pkg]# su - postgres
Last login: Mon Mar 26 19:43:03 CST 2018 on pts/0

[postgres@tiger ~]$ psql
psql (10.3)
Type "help" for help.

postgres=# create extension mysql_fdw ;
CREATE EXTENSION
postgres=#


还是在这个README.md里也有相关创建方式。 贴出看看。
-- load extension first time after install

    CREATE EXTENSION mysql_fdw;

-- create server object

    CREATE SERVER mysql_server
         FOREIGN DATA WRAPPER mysql_fdw
         OPTIONS (host '127.0.0.1', port '3306');

-- create user mapping

    CREATE USER MAPPING FOR postgres
        SERVER mysql_server
        OPTIONS (username 'foo', password 'bar');

-- create foreign table

    CREATE FOREIGN TABLE warehouse(
         warehouse_id int,
         warehouse_name text,
         warehouse_created datetime)
    SERVER mysql_server
         OPTIONS (dbname 'db', table_name 'warehouse');
        
        
解释一下内容
-- create server object

    CREATE SERVER mysql_server
         FOREIGN DATA WRAPPER mysql_fdw
         OPTIONS (host '对方mysql数据库的IP', port '对方mysql数据库的3306');

-- create user mapping

    CREATE USER MAPPING FOR postgres
        SERVER mysql_server
        OPTIONS (username '对方mysql数据库的用户', password '对方mysql数据库的密码');

-- create foreign table

    CREATE FOREIGN TABLE warehouse(id int)
    SERVER mysql_server
         OPTIONS (dbname '对方mysql数据库的名字', table_name '对方mysql数据库的表名');
        
warehouse是pg数据这里保存元数据内容名字。列名也是要对应到对方表的列数据类型。至少要兼容的。
        
编辑一下，直接执行。
[postgres@tiger ~]$ psql -f exa.sql
CREATE SERVER
CREATE USER MAPPING
CREATE FOREIGN TABLE
[postgres@tiger ~]$ psql
psql (10.3)
Type "help" for help.

postgres=#
postgres=# select * from warehouse;
ERROR:  failed to connect to MySQL: Can't connect to MySQL server on '192.168.239.132' (113)
看到这个错误就说明你需要解决几个问题。
1，对方mysql数据库是否给你开相关权限了没有。
2，对方的防火墙是否允许你通过。
3，mysql数据库是否打开了没有。
4，mysql是否你允许连接。

如果你解决了问题，你就可以看到对方的内容了。
postgres=# select * from warehouse;
 id
----
   
   
  1
(3 rows)

这种连接方式有好处也有缺点。
优点：
1，不需要同步内容过来，节省不少硬盘。
2，没有mysql的从库，也防止了从库过忙造成拉垮主库。
3，减轻mysql的压力。
4，什么时候查询什么时候连接，相当一个查询的客户端。
5，完全可以在pg中使用窗口函数进行运算。
缺点：
1，需要知道双方可兼容的数据类型。
2，pg的插件太多，有可能造成启动慢。
3，完全拉数据过来，造成网络压力，（新版mysql_fdw可以下推条件到mysql去了）

注意：部分系统需要额外安装mysql的test包。我这里使用的centos，所以没有安装。
