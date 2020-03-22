
PostgreSQL查询主外键  

2016-07-14 21:08:57

标签：postgresql  主键  外键  系统表

今天有人问我PostgreSQL怎么找到主外键?

感觉还是有必要写一下的.


--删除样例表

drop table if exists orders;

drop table if exists products;

--你说对了,我这俩表的建表语句就是抄的  :P
--创建两个表
--带主键的表
CREATE TABLE products (
product_no integer PRIMARY KEY,
name text,
price numeric
);
--外键表
CREATE TABLE orders (
order_id integer ,
prno integer REFERENCES products (product_no),
quantityy integer
);

--查看关系
SELECT
(select nspname from pg_namespace c where c.oid=b.relnamespace ) "table_schema"
,b.relname as table_name
,(case
when a.contype='p' then 'PRIMARY KEY'
when a.contype='f' then 'FOREIGN KEY'
when a.contype='c' then 'CHECK'
when a.contype='u' then 'UNIQUE KEY'
else cast(a.contype as text)
end) table_constraint
--c = 检查约束， f = 外键约束， p = 主键约束， u = 唯一约束
,conname constraint_name
FROM
pg_constraint a join
pg_class b on a.conrelid=b.oid
where b.relname in ('products','orders');


--结果
"table_schema"|"table_name" |"table_constraint" |"constraint_name"
--------------+--------------+--------------------+----------------------
"public" |"products" |"PRIMARY KEY" |"products_pkey"
"public" |"orders" |"FOREIGN KEY" |"orders_prno_fkey"




--你查底下那个视图也行.不过是在information_schema下的.

select * from information_schema.constraint_table_usage
where table_name in ('products','orders');


--底下的这个视图也行,只不过有点不一样.

select * from information_schema.table_constraints
where table_name in ('products','orders');
