格式：
CREATE DOMAIN name [ AS ] data_type
    [ COLLATE collation ]
    [ DEFAULT expression ]
    [ CONSTRAINT constraint_name 
	   { NOT NULL | NULL | CHECK (expression) }
	]


说明：
创建一个带数据类型和约束的新数据类型。
1，约束不能是主外约束
2，check里值用value（单数形式) 
3，数据类型必须，约束等非必须
4，null是默认可以放入的，除非你加上not null

-- drop table test ;
-- drop domain ss ; 

--创建 域-s80 ， 限定日期为1980到1989年之间。 
create domain  s80  
as 
date 
check(value >='1980-01-01' and value < '1990-01-01' );

--创建表的时候就可以使用了
create table test ( sd s80);

--有效数据。
insert into test(sd) values('1981-03-01');
insert into test(sd) values('1989-03-01');
insert into test(sd) values(null); 

select * from test 
sd          
------------
'1981-03-01'
'1989-03-01'
      [NULL]

	  
--无效数据。
insert into test(sd) values('2001-03-01');

SQL 错误 [23514]: ERROR: value for domain s80 violates check constraint "s80_check"
  ERROR: value for domain s80 violates check constraint "s80_check"
  ERROR: value for domain s80 violates check constraint "s80_check"

  
  
-- not null 和 check 可以同时存在。
create domain  tt as int check (value between 1 and 100 ) not null;
