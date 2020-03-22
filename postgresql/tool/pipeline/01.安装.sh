pipelinedb插件安装

[root@ttgs ~]# chown postgres.postgres pipelinedb-1.0.0-11.zip 
[root@ttgs ~]# cp pipelinedb-1.0.0-11.zip /home/postgres
[root@ttgs ~]# ls
anaconda-ks.cfg       Music                                                 Public
Desktop               Pictures                                              rpmbuild
Documents             pipelinedb-1.0.0-11.zip                               Templates
Downloads             pipelinedb-postgresql-10-1.0.0-11.centos7.x86_64.rpm  Videos
initial-setup-ks.cfg  postgresql-10.6.tar.gz
[root@ttgs ~]# su - postgres 
Last login: Sun Jan 20 20:55:29 EST 2019 on pts/0
[postgres@ttgs ~]$ ll
total 28204
-rw-r--r--. 1 postgres postgres   234469 Jan 18 09:23 imgsmlr-master.zip
drwxrwxr-x. 7 postgres postgres       70 Jan 18 09:33 pg106
-rw-r--r--. 1 root     root       578150 Jan 20 20:56 pipelinedb-1.0.0-11.zip
-rw-r--r--. 1 root     root      1148608 Jan 20 20:57 pipelinedb-postgresql-10-1.0.0-11.centos7.x86_64.rpm
drwxrwxr-x. 6 postgres postgres     4096 Jan 18 09:29 postgresql-10.6
-rw-r--r--. 1 postgres postgres 26902911 Jan 18 09:23 postgresql-10.6.tar.gz
[postgres@ttgs ~]$ unzip pipelinedb-1.0.0-11.zip 
Archive:  pipelinedb-1.0.0-11.zip
dc1cc7cbe2b1090e3c205fffaa850a4b87dae1d0
   creating: pipelinedb-1.0.0-11/
  inflating: pipelinedb-1.0.0-11/.gitattributes  
  inflating: pipelinedb-1.0.0-11/.gitignore  
  inflating: pipelinedb-1.0.0-11/LICENSE  
... ...
  inflating: pipelinedb-1.0.0-11/src/update.c  
  inflating: pipelinedb-1.0.0-11/src/worker.c  
[postgres@ttgs ~]$ cd pipelinedb-1.0.0-11/
[postgres@ttgs pipelinedb-1.0.0-11]$ ll
total 120
drwxrwxr-x. 2 postgres postgres    38 Jan 14 16:47 bin
drwxrwxr-x. 2 postgres postgres  4096 Jan 14 16:47 include
-rw-rw-r--. 1 postgres postgres 11358 Jan 14 16:47 LICENSE
-rw-rw-r--. 1 postgres postgres  1710 Jan 14 16:47 Makefile
-rw-rw-r--. 1 postgres postgres   758 Jan 14 16:47 NOTICE
-rw-rw-r--. 1 postgres postgres 78525 Jan 14 16:47 pipelinedb--1.0.0.sql
-rw-rw-r--. 1 postgres postgres   130 Jan 14 16:47 pipelinedb.control
-rw-rw-r--. 1 postgres postgres  4967 Jan 14 16:47 README.md
drwxrwxr-x. 3 postgres postgres  4096 Jan 14 16:47 src
[postgres@ttgs pipelinedb-1.0.0-11]$ make USE_PGXS=1
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -I./include -I/home/postgres/pg106/include -I. -I./ -I/home/postgres/pg106/include/server -I/home/postgres/pg106/include/internal  -D_GNU_SOURCE   -c -o src/aggfuncs.o src/aggfuncs.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -I./include -I/home/postgres/pg106/include -I. -I./ -I/home/postgres/pg106/include/server -I/home/postgres/pg106/include/internal  -D_GNU_SOURCE   -c -o src/analyzer.o src/analyzer.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -I./include -I/home/postgres/pg106/include -I. -I./ -I/home/postgres/pg106/include/server -I/home/postgres/pg106/include/internal  -D_GNU_SOURCE   -c -o src/bloom.o src/bloom.c
... ...
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -I./include -I/home/postgres/pg106/include -I. -I./ -I/home/postgres/pg106/include/server -I/home/postgres/pg106/include/internal  -D_GNU_SOURCE   -c -o src/pipelinefuncs.o src/pipelinefuncs.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -I./include -I/home/postgres/pg106/include -I. -I./ -I/home/postgres/pg106/include/server -I/home/postgres/pg106/include/internal  -D_GNU_SOURCE   -c -o src/planner.o src/planner.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -I./include -I/home/postgres/pg106/include -I. -I./ -I/home/postgres/pg106/include/server -I/home/postgres/pg106/include/internal  -D_GNU_SOURCE   -c -o src/pzmq.o src/pzmq.c
src/pzmq.c:12:17: fatal error: zmq.h: No such file or directory
 #include <zmq.h>
                 ^
compilation terminated.
make: *** [src/pzmq.o] Error 1

报这个错误说明需要一个叫做 libzmq 的软件，这个是一个分布式消息系统，官网网站 http://zeromq.org/  和 github  https://github.com/zeromq/libzmq/releases 
下面安装 libzmq 



[root@ttgs ~]# tar -zxvf libzmq-4.3.1.tar.gz 
libzmq-4.3.1/
libzmq-4.3.1/.clang-format
libzmq-4.3.1/.clang-tidy
libzmq-4.3.1/.github/
libzmq-4.3.1/.github/PULL_REQUEST_TEMPLATE.md
... ...
libzmq-4.3.1/unittests/unittest_poller.cpp
libzmq-4.3.1/unittests/unittest_radix_tree.cpp
libzmq-4.3.1/unittests/unittest_resolver_common.hpp
libzmq-4.3.1/unittests/unittest_udp_address.cpp
libzmq-4.3.1/unittests/unittest_ypipe.cpp
libzmq-4.3.1/version.sh
[root@ttgs ~]# cd libzmq-4.3.1/
[root@ttgs libzmq-4.3.1]# ls
acinclude.m4  builds          COPYING         external       m4           README.cygwin.md   tests
appveyor.yml  ci_build.sh     COPYING.LESSER  include        Makefile.am  README.doxygen.md  tools
AUTHORS       ci_deploy.sh    doc             INSTALL        NEWS         README.md          unittests
autogen.sh    CMakeLists.txt  Dockerfile      installer.ico  packaging    RELICENSE          version.sh
branding.bmp  configure.ac    Doxygen.cfg     Jenkinsfile    perf         src
[root@ttgs libzmq-4.3.1]# ./autogen.sh 
autogen.sh: error: could not find libtool.  libtool is required to run autogen.sh.           <---------------需要一个libtool
[root@ttgs libzmq-4.3.1]# ./autogen.sh
autoreconf: Entering directory `.'
autoreconf: configure.ac: not using Gettext
autoreconf: running: aclocal -I config --force -I config
...  ...
configure.ac:14: installing 'config/missing'
Makefile.am: installing 'config/depcomp'
parallel-tests: installing 'config/test-driver'
autoreconf: Leaving directory `.'
[root@ttgs libzmq-4.3.1]# echo $?
0
[root@ttgs libzmq-4.3.1]# ./configure
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for a thread-safe mkdir -p... /usr/bin/mkdir -p
...  ...
config.status: creating builds/deprecated-msvc/Makefile
config.status: creating src/platform.hpp
config.status: executing depfiles commands
config.status: executing libtool commands
[root@ttgs libzmq-4.3.1]# make 
Making all in doc
make[1]: Entering directory `/root/libzmq-4.3.1/doc'
make[1]: Nothing to be done for `all'.
make[1]: Leaving directory `/root/libzmq-4.3.1/doc'
...  ...
 /usr/bin/mkdir -p '/usr/local/lib/pkgconfig'
 /usr/bin/install -c -m 644 src/libzmq.pc '/usr/local/lib/pkgconfig'
make[2]: Leaving directory `/root/libzmq-4.3.1'
make[1]: Leaving directory `/root/libzmq-4.3.1'

##这里后期做的时候，make完成做make install 报错，切到root用户，该目录下，make install 正常解决。
##下面这步忘记没事，在pipeline里 make UES_PGXS=1 的时候也会报错。
[root@ttgs lib]# ln -s   /usr/local/lib/libzmq.so.5.2.1  /usr/lib/libzmq.a
[root@ttgs lib]# ldconfig 
[root@ttgs lib]# su - postgres 
Last login: Sun Jan 20 21:19:15 EST 2019 on pts/1
[postgres@ttgs pipelinedb-1.0.0-11]$ make USE_PGXS=1
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -I./include -I/home/postgres/pg106/include -I. -I./ -I/home/postgres/pg106/include/server -I/home/postgres/pg106/include/internal  -D_GNU_SOURCE   -c -o src/aggfuncs.o src/aggfuncs.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -I./include -I/home/postgres/pg106/include -I. -I./ -I/home/postgres/pg106/include/server -I/home/postgres/pg106/include/internal  -D_GNU_SOURCE   -c -o src/analyzer.o src/analyzer.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -I./include -I/home/postgres/pg106/include -I. -I./ -I/home/postgres/pg106/include/server -I/home/postgres/pg106/include/internal  -D_GNU_SOURCE   -c -o src/bloom.o src/bloom.c
...  ...
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -I./include -I/home/postgres/pg106/include -I. -I./ -I/home/postgres/pg106/include/server -I/home/postgres/pg106/include/internal  -D_GNU_SOURCE   -c -o src/update.o src/update.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -I./include -I/home/postgres/pg106/include -I. -I./ -I/home/postgres/pg106/include/server -I/home/postgres/pg106/include/internal  -D_GNU_SOURCE   -c -o src/worker.o src/worker.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -shared -o pipelinedb.so src/aggfuncs.o src/analyzer.o src/bloom.o src/bloomfuncs.o src/catalog.o src/cmsketch.o src/combiner.o src/combiner_receiver.o src/commands.o src/compat.o src/config.o src/copy.o src/distfuncs.o src/executor.o src/firstvalues.o src/freqfuncs.o src/fss.o src/hashfuncs.o src/hll.o src/hllfuncs.o src/json.o src/jsonb.o src/kv.o src/matrel.o src/microbatch.o src/miscutils.o src/mutator.o src/physical_group_lookup.o src/pipeline_combine.o src/pipeline_query.o src/pipeline_stream.o src/pipelinefuncs.o src/planner.o src/pzmq.o src/queue.o src/reader.o src/reaper.o src/ruleutils.o src/scheduler.o src/stats.o src/stream_fdw.o src/tdigest.o src/topkfuncs.o src/transform_receiver.o src/tuplestore_scan.o src/update.o src/worker.o -L/home/postgres/pg106/lib    -Wl,--as-needed -Wl,-rpath,'/home/postgres/pg106/lib',--enable-new-dtags  /usr/lib/libzmq.a -lstdc++ 
[postgres@ttgs pipelinedb-1.0.0-11]$ make install
/bin/mkdir -p '/home/postgres/pg106/lib'
/bin/mkdir -p '/home/postgres/pg106/share/extension'
/bin/mkdir -p '/home/postgres/pg106/share/extension'
/bin/install -c -m 755  pipelinedb.so '/home/postgres/pg106/lib/pipelinedb.so'
/bin/mkdir -p /home/postgres/pg106/include/server/../pipelinedb
/bin/install -c -m 644 /home/postgres/pipelinedb-1.0.0-11/include/*.h '/home/postgres/pg106/include/server/../pipelinedb'
/bin/install -c -m 644 ./pipelinedb.control '/home/postgres/pg106/share/extension/'
/bin/install -c -m 644 ./pipelinedb--1.0.0.sql  '/home/postgres/pg106/share/extension/'
[postgres@ttgs pipelinedb-1.0.0-11]$ cd 
安装完成后，需要在pg的配置文件中写入两个东西，一个是 shared_preload_libraries 调用该组件， 另一个是max_worker_processes 需要开的足够大。
[postgres@ttgs ~]$ vim pg106/pgdata/postgresql.conf 
shared_preload_libraries = 'pipelinedb' 
max_worker_processes = 128
"pg106/pgdata/postgresql.conf" 660L, 22853C written                                    
[postgres@ttgs ~]$ 
启动吧，这里有个报错，是因为我的ld配置有问题。 
[postgres@ttgs ~]$ pg_ctl restart -D pg106/pgdata/ -mf 
waiting for server to shut down....2019-01-20 21:53:53.381 EST [84507] LOG:  received fast shutdown request
2019-01-20 21:53:53.385 EST [84507] LOG:  aborting any active transactions
2019-01-20 21:53:53.385 EST [84507] LOG:  worker process: logical replication launcher (PID 84514) exited with exit code 1
2019-01-20 21:53:53.386 EST [84509] LOG:  shutting down
2019-01-20 21:53:53.397 EST [84507] LOG:  database system is shut down
 done
server stopped
waiting for server to start....2019-01-20 21:53:53.498 EST [84806] FATAL:  could not load library "/home/postgres/pg106/lib/pipelinedb.so": libzmq.so.5: cannot open shared object file: No such file or directory
2019-01-20 21:53:53.498 EST [84806] LOG:  database system is shut down
 stopped waiting
pg_ctl: could not start server
Examine the log output.
[postgres@ttgs ~]$ psql 
psql: could not connect to server: No such file or directory
        Is the server running locally and accepting
        connections on Unix domain socket "/tmp/.s.PGSQL.5432"?
[postgres@ttgs ~]$ cd pg106/lib/
先找到这个说少的文件， 然后写入到conf文件里。刷新即可。
[root@ttgs ~]# find / -name libzmq.so.5
/root/libzmq-4.3.1/src/.libs/libzmq.so.5
/usr/local/lib/libzmq.so.5
[root@ttgs ~]# cd /etc/ld.so.conf.d/
[root@ttgs ld.so.conf.d]# ls
dyninst-x86_64.conf                libiscsi-x86_64.conf     mariadb-x86_64.conf
kernel-3.10.0-693.el7.x86_64.conf  libvirt-cim.x86_64.conf  qt-x86_64.conf
[root@ttgs ld.so.conf.d]# cat libzmq.conf
/usr/local/lib/
然后启动就可以看到一个不同的内容。
[root@ttgs ld.so.conf.d]# su - postgres 
Last login: Sun Jan 20 22:34:17 EST 2019 on tty1
[postgres@ttgs ~]$ pg_ctl start -D pg106/pgdata/
waiting for server to start....    
    ____  _            ___            ____  ____
   / __ \(_)___  ___  / (_)___  ___  / __ \/ __ )
  / /_/ / / __ \/ _ \/ / / __ \/ _ \/ / / / __  |
 / ____/ / /_/ /  __/ / / / / /  __/ /_/ / /_/ /
/_/   /_/ .___/\___/_/_/_/ /_/\___/_____/_____/
       /_/
2019-01-20 22:40:33.658 EST [88066] LOG:  listening on IPv6 address "::1", port 5432
2019-01-20 22:40:33.658 EST [88066] LOG:  listening on IPv4 address "127.0.0.1", port 5432
2019-01-20 22:40:33.660 EST [88066] LOG:  listening on Unix socket "/tmp/.s.PGSQL.5432"
2019-01-20 22:40:33.751 EST [88067] LOG:  database system was shut down at 2019-01-20 21:53:53 EST
2019-01-20 22:40:33.754 EST [88066] LOG:  database system is ready to accept connections
2019-01-20 22:40:33.773 EST [88073] LOG:  pipelinedb scheduler started
 done
server started
[postgres@ttgs ~]$ psql 
psql (10.6)
Type "help" for help.
postgres=# \c ttgs 
You are now connected to database "ttgs" as user "postgres".
ttgs=# create extension pipelinedb ;
CREATE EXTENSION
ttgs=# 
