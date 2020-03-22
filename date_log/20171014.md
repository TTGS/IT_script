postgresql中表移动表空间后，文件节点和表的oid改变
------------------------------------
日期：2017-10-14
作者：TT
标签：postgresql  数据库管理 
------------------------------------
如果一个表的保存表空间改变了，那么他的文件节点和表的oid是否也会改变？

我们来做一个实验验证一下想法。

先看一下表空间和库的默认表空间。
mydb=# select oid ,spcname from pg_tablespace;
  oid  |  spcname   
-------+------------
  1663 | pg_default
  1664 | pg_global
 16384 | tmp
 16385 | def
 33008 | idx
(5 rows)

mydb=# select datname , dattablespace,spcname  from pg_database , pg_tablespace where dattablespace=pg_tablespace.oid;
  datname  | dattablespace |  spcname   
-----------+---------------+------------
 postgres  |          1663 | pg_default
 template1 |          1663 | pg_default
 template0 |          1663 | pg_default
 mydb      |         16385 | def
(4 rows)


我有个表叫做dy，放在mydb库中的默认表空间里（即def表空间中）
mydb=# select oid , relname ,reltablespace from pg_class where relname='dy';
  oid  | relname | reltablespace 
-------+---------+---------------
 32999 | dy      |             0
(1 row)

文件节点和文件保存路径。
mydb=# select pg_relation_filenode('32999');
 pg_relation_filenode 
----------------------
                33012
(1 row)

mydb=# select pg_relation_filepath('32999');
            pg_relation_filepath             
---------------------------------------------
 pg_tblspc/16385/PG_10_201707211/16386/33012
(1 row)

将dy表移动到idx表空间下。
mydb=# alter table dy set tablespace idx;
ALTER TABLE

再次查看表的oid内容，发现表空间已经改变，但oid文件号还是一样依然是32999 。
mydb=# select oid , relname ,reltablespace from pg_class where relname='dy';
  oid  | relname | reltablespace 
-------+---------+---------------
 32999 | dy      |         33008
(1 row)


再次查看文件节点号和文件路径。返回的内容已经改变了。
mydb=# select pg_relation_filenode('32999');
 pg_relation_filenode 
----------------------
                33015
(1 row)

mydb=# select pg_relation_filepath('32999');
            pg_relation_filepath             
---------------------------------------------
 pg_tblspc/33008/PG_10_201707211/16386/33015
(1 row)



如果用户移动了表的表空间，那么pg是复制过去的，而不是移动过去的。
这样做的原因我想是为了满足数据的完整性而设计的。
如果在移动过程中断电，那么很可能造成两个表空间中的文件无法恢复（没有一个完整可信的内容)
所以采用了稳妥的复制方式，到时候只要消除原表空间的记录即可。

那么原来的文件是在复制完成之后就“干掉”了吗？
我们继续来验证。

检查现有的文件节点路径
mydb=# select pg_relation_filepath('32999');
            pg_relation_filepath             
---------------------------------------------
 pg_tblspc/33008/PG_10_201707211/16386/33015
(1 row)

转移表空间。
mydb=# alter table dy set tablespace def;
ALTER TABLE

得到新的文件节点路径
mydb=# select pg_relation_filepath('32999');
            pg_relation_filepath             
---------------------------------------------
 pg_tblspc/16385/PG_10_201707211/16386/33018
(1 row)

mydb=# \q
离开数据库直接到PGDATA下检查。俩个还是都有哈。
[postgres@xiaoli pgdata]$ ll pg_tblspc/33008/PG_10_201707211/16386/33015
-rw-------. 1 postgres postgres 0 Oct 14 20:39 pg_tblspc/33008/PG_10_201707211/16386/33015
[postgres@xiaoli pgdata]$ ll pg_tblspc/16385/PG_10_201707211/16386/33018
-rw-------. 1 postgres postgres 8192 Oct 14 20:39 pg_tblspc/16385/PG_10_201707211/16386/33018
回收一下看看
[postgres@xiaoli pgdata]$ vacuumdb -a
vacuumdb: vacuuming database "mydb"
vacuumdb: vacuuming database "postgres"
vacuumdb: vacuuming database "template1"
[postgres@xiaoli pgdata]$ ll pg_tblspc/33008/PG_10_201707211/16386/33015
-rw-------. 1 postgres postgres 0 Oct 14 20:39 pg_tblspc/33008/PG_10_201707211/16386/33015
[postgres@xiaoli pgdata]$ ll pg_tblspc/16385/PG_10_201707211/16386/33018
-rw-------. 1 postgres postgres 8192 Oct 14 20:39 pg_tblspc/16385/PG_10_201707211/16386/33018

依然存在，这货不受vacummdb影响？！

想知道原来的表空间中的那个文件是什么吗？走咱们回去看看。
mydb=# select oid , relname ,reltablespace from pg_class where relname='dy';
  oid  | relname | reltablespace 
-------+---------+---------------
 32999 | dy      |             0
(1 row)

mydb=# select oid ,spcname from pg_tablespace;
  oid  |  spcname   
-------+------------
  1663 | pg_default
  1664 | pg_global
 16384 | tmp
 16385 | def
 33008 | idx
(5 rows)

mydb=# select pg_filenode_relation(16385,33018);
 pg_filenode_relation 
----------------------
 dy
(1 row)

mydb=# select pg_filenode_relation(33008,33015);
 pg_filenode_relation 
----------------------
 
(1 row)

这时候会发现原理的表空间加文件节点其实没有内容了。
出去看一下这个文件，发现已经没了。
mydb=# \q
[postgres@xiaoli pgdata]$ ll pg_tblspc/33008/PG_10_201707211/16386/33015
ls: cannot access pg_tblspc/33008/PG_10_201707211/16386/33015: No such file or directory
[postgres@xiaoli pgdata]$ ll pg_tblspc/16385/PG_10_201707211/16386/33018
-rw-------. 1 postgres postgres 8192 Oct 14 20:39 pg_tblspc/16385/PG_10_201707211/16386/33018
[postgres@xiaoli pgdata]$ 


-----------------------------------
不知道是什么时候清理掉的，我前后确实用了几分钟，然后就发现这伙木有了。后来又测试了测试，发现等一会就会没有，和vacuum 没啥关系，即使使用了full模式回收。
