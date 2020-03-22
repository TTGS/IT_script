
在PGDATA下的pg_tblspc恢复  

2016-07-11 21:37:33
标签：postgresql  pgdata  pg_tblspc 

/***********************************************************
pg_tblspc下存放的是表空间目录，
这个目录是pg_tablespace的oid和文件目录的软连接，
而地址是你创建表空间的那个路径。如果你忘记了，说白了就是
“PG_版本_版本日期”的上层。
我们将这个串路径（根到一个叶）进行分解。
 
/pg/tablespace/defdata/PG_9.5_201510051/16386/2619
|----------------------+--------------------| 
|/pg/tablespace/defdata| 表空间路径         | 
|PG_9.5_201510051      | 表空间文件         |
|16386                 | 默认该表空间的库oid|
|2619                  | 该库下的表oid      |
|----------------------+--------------------|
*************************************************************/
[postgres@TT pg_tblspc]$ psql -d mydb
psql (9.5.3)
Type "help" for help.

mydb=# \d
        List of relations
 Schema | Name | Type  |  Owner   
--------+------+-------+----------
 public | boc  | table | postgres
(1 row)

mydb=# \q
[postgres@TT pg_tblspc]$ ll
total 4
lrwxrwxrwx. 1 postgres postgres  22 May 31 11:29 16384 -> /pg/tablespace/defdata
lrwxrwxrwx. 1 postgres postgres  22 May 31 11:29 16385 -> /pg/tablespace/tmpdata
[postgres@TT pg_tblspc]$ rm *
[postgres@TT pg_tblspc]$ psql
psql (9.5.3)
Type "help" for help.

postgres=# \db
ERROR:  could not read symbolic link "pg_tblspc/16384": No such file or directory
postgres=# select oid , spcname from pg_tablespace;
  oid  |  spcname   
-------+------------
  1663 | pg_default
  1664 | pg_global
 16384 | defdata
 16385 | tmpdata
(4 rows)

postgres=# select  *from pg_tablespace;
  spcname   | spcowner | spcacl | spcoptions 
------------+----------+--------+------------
 pg_default |       10 |        | 
 pg_global  |       10 |        | 
 defdata    |       10 |        | 
 tmpdata    |       10 |        | 
(4 rows)

postgres=# \q
[postgres@TT pg_tblspc]$ ll
total 0
[postgres@TT pg_tblspc]$ pwd
/pg/953/data/pg_tblspc
[postgres@TT pg_tblspc]$ cd /pg
[postgres@TT pg]$ ll
total 12
drwxrwxr-x. 8 postgres postgres 4096 May 31 11:08 953
drwxrwxr-x. 4 postgres postgres 4096 May 31 10:02 soft
drwxrwxr-x. 4 postgres postgres 4096 May 31 11:27 tablespace
[postgres@TT pg]$ cd tablespace/
[postgres@TT tablespace]$ ll
total 8
drwx------. 3 postgres postgres 4096 May 31 11:29 defdata
drwx------. 3 postgres postgres 4096 May 31 11:29 tmpdata
[postgres@TT tablespace]$ pwd
/pg/tablespace
[postgres@TT tablespace]$ cd /pg/953/data/pg_tblspc/
[postgres@TT pg_tblspc]$ ln -s /pg/tablespace/tmpdata 16385
[postgres@TT pg_tblspc]$ ln -s /pg/tablespace/defdata 16384
[postgres@TT pg_tblspc]$ ll
total 0
lrwxrwxrwx. 1 postgres postgres 22 May 31 14:01 16384 -> /pg/tablespace/defdata
lrwxrwxrwx. 1 postgres postgres 22 May 31 14:01 16385 -> /pg/tablespace/tmpdata
[postgres@TT pg_tblspc]$ psql
psql (9.5.3)
Type "help" for help.

postgres=# \c mydb
You are now connected to database "mydb" as user "postgres".
mydb=# \d
        List of relations
 Schema | Name | Type  |  Owner   
--------+------+-------+----------
 public | boc  | table | postgres
(1 row)

mydb=# \q
[postgres@TT pg_tblspc]$ 
