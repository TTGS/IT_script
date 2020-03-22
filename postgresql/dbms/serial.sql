格式：bigserial , serial , smallserial 

说明：serial 是一个默认序列加对应的int类型。
如果你有，那么用你的，
如果没有，那么他会顺序写下去。

--创建一个自增列。
create table tt (i serial ) ;

--插入默认值或者你的值。
insert into tt values(default );
insert into tt values(100) ;

-- 可以看到默认值是一个序列，也可以看到序列名。
select table_name ,column_default  from information_schema.columns  where table_name ='tt'
select * from pg_catalog.pg_sequences  

serial=序列+int类型

如果你使用他，那么他就提供一个值出来，如果你自己赋值也可以，但是这并不浪费他的数值。  


hp=# create table a (i serial ,b int) ;
CREATE TABLE
hp=# insert into a values(1,1);
INSERT 0 1
hp=# insert into a(b) values(2);
INSERT 0 1
hp=# select * from a;
 i | b 
---+---
 1 | 1
 1 | 2
(2 rows)
