
PostgreSQL中如何找到并导出函数内容  

2016-12-12 20:39:01|  分类： PostgreSQL |  标签：postgresql  操作题目 

今天被突然问到，如何将PostgreSQL的函数内容导出成一个文件。

感觉还是需要普及一下PostgreSQL的一些操作。

我们先建立一个用于测试的函数。
CREATE OR REPLACE FUNCTION  test()
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
 STABLE PARALLEL RESTRICTED STRICT
AS 
$$
begin
select now();
end
$$;

一，怎么看函数内容
在psql里\sf可以看到函数的具体信息
postgres=# \sf test
CREATE OR REPLACE FUNCTION public.test()
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
 STABLE PARALLEL RESTRICTED STRICT
AS $function$
begin
select now();
end
$function$
postgres=# 


或者干脆看系统表保存的内容。
postgres=# select proname,prosrc from pg_proc where proname like '%test%';
 proname |    prosrc     
---------+---------------
 test    |              +
         | begin        +
         | select now();+
         | end          +
         | 
(1 row)


会看到这里之间的差异，\sf出来的是一个创建语句，而pg_proc里保留的是内容。


可以看到函数语句了。不多可以选择自己复制粘贴啦 :p 

二，如何导出内容。
我们还可以使用\o来导出内容。
 \o [FILE]              send all query results to file or |pipe

很多同学一定会这样执行
postgres=# \sf test \o ~/1.sql
ERROR:  invalid name syntax at character 8
STATEMENT:  SELECT E'test \\o ~/1.sql'::pg_catalog.regproc::pg_catalog.oid
ERROR:  invalid name syntax
postgres=# 

妥妥的报错了，\o不行吗？
当然不是，这依然是可以用的。
postgres=# \o ~/1.sql \sf test

查一下内容。
postgres=# \! cat ~/1.sql
CREATE OR REPLACE FUNCTION public.test()
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
 STABLE PARALLEL RESTRICTED STRICT
AS $function$
begin
select now();
end
$function$
~~/1.sql

postgres=# 


可能会很多，有同学希望写一个shell来完成这事。可以不用那么麻烦，直接用psql的-c传命令进去就好了。

[postgres@hp ~]$ psql -c"\sf test" -o ~/2.sql
[postgres@hp ~]$ cat ~/2.sql
CREATE OR REPLACE FUNCTION public.test()
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
 STABLE PARALLEL RESTRICTED STRICT
AS $function$
begin
select now();
end
$function$
[postgres@hp ~]$ 

使用pg_proc表输出内容也可以。
[postgres@hp ~]$ psql -c" select prosrc from pg_proc where proname='test';" -o ~/3.sql -t
[postgres@hp ~]$ cat ~/3.sql
              +
 begin        +
 select now();+
 end          +
 

[postgres@hp ~]$ 


9.6的版本，如果在刚刚执行过，可以用以下方法
postgres=# CREATE OR REPLACE FUNCTION public.test()
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
 STABLE PARALLEL RESTRICTED STRICT
AS $function$
begin
select now();
end
$function$
postgres=# \p
CREATE OR REPLACE FUNCTION public.test()
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
 STABLE PARALLEL RESTRICTED STRICT
AS $function$
begin
select now();
end
$function$

postgres=# \w ~/5.sql
postgres=# 
