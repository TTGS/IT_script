命令： between ... and ...

说明：between ... and ... 是什么介于什么之间，是一个闭区间（带前带后），内容可以是字符，数字，时间。如果是时间戳类型，那么需要注意时间是否包括在内。

--数字类型，闭区间。
with a as (
select 1 id union all 
select 2 union all 
select 3 union all 
select 4 )
select * from a where id between 1 and 3 ;
id    
------
     1
     2
     3

--时间类型，在闭区间内需要注意时间是否被包含。
with a as (
select '2018-11-1 10:00:00'::timestamp id union all 
select '2018-11-2 10:00:00'::timestamp union all 
select '2018-11-3 00:00:01'::timestamp union all 
select '2018-11-4 00:00:00'::timestamp )
select * from a where id between '2018-11-1' and '2018-11-3' ;
id                       
-------------------------
'2018-11-01 10:00:00.000'
'2018-11-02 10:00:00.000'

--时间类型，如果只是些日期，那么时间只是认为是0点0分0秒
with a as (
select '2018-11-1 10:00:00'::timestamp id union all 
select '2018-11-2 10:00:00'::timestamp union all 
select '2018-11-3 00:00:01'::timestamp union all 
select '2018-11-4 00:00:00'::timestamp )
select * from a where id between '2018-11-1' and '2018-11-4' ;
id                       
-------------------------
'2018-11-01 10:00:00.000'
'2018-11-02 10:00:00.000'
'2018-11-03 00:00:01.000'
'2018-11-04 00:00:00.000'

--区间范围也可以是字符，从开始字符 到 开始字符+任意内容 到 结束字符
with a as (
select 'a' id union all 
select 'aa' union all 
select 'c' union all 
select 'b'union all 
select 'c1')
select * from a where id between 'a' and 'c'
id    
------
a     
aa    
c     
b     

--如果你写反了，那么他不会报错，但是会什么都找不到。
with a as (
select 1 id union all 
select 2 union all 
select 3 union all 
select 4 )
select * from a where id between 4 and 1 ;
id    
------
