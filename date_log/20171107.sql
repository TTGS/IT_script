
PostgreSQL获得SQL影响的行数  

2017-11-07 12:19:06
标签：postgresql  pgpl/sql  

很多人在知道oracle里可以使用sql%rowcount获取刚刚执行过的sql影响的行数，
而pg中就知道的人就不多了。虽然很多时候pg可以兼容oracle的迁移，但是如何获取影响行数呢？
PostgreSQL里面有一个内置的变量DIAGNOSTICS与ROW_COUNT可以做到这一点。

创建一个用于测试的表。
create table test (id int );

然后使用动态的过程化语句。
do
$$
declare
v_rcount int;
begin
insert into test values(1),(2);
get diagnostics v_rcount=row_count;
raise notice '%',v_rcount;
end;
$$;


--执行
mydb=# do
mydb-# $$
mydb$# declare
mydb$# v_rcount int;
mydb$# begin
mydb$# insert into test values(1),(2);
mydb$# get diagnostics v_rcount=row_count;
mydb$# raise notice '%',v_rcount;
mydb$# end;
mydb$# $$;
NOTICE:  2
DO




你看返回了影响的结果了吧。
不过吧，这个row_count参数不能在事务中使用。
mydb=# begin;
BEGIN
mydb=# insert into test values(3);
INSERT 0 1
mydb=# raise notice row_number;
ERROR:  syntax error at or near "raise"
LINE 1: raise notice row_number;
        ^
mydb=# end;
ROLLBACK
