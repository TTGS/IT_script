格式：count(*|列)

说明：count是计算行数，可以按照是否为空的行数，count最低是0，不会出现null或者负数。

with a as (
select '1' id union all 
select '1'  union all 
select 'b'  union all 
select 'b'  union all 
select null 
)
select count(*) , count(1) , count('@') , count(id) ,count(distinct id) 
from a 

count |count |count |count |count 
------|------|------|------|------
     5|     5|     5|     4|     2
	 
--计数列中的行数，包括空和非空内容。
count(*) 

--计算列中全部内容，和count(*)一样，只不过数字可以不带引号，符号中只有"*"不用带引号。
count(1) 
count('@')

--计算列中非空的行数，null则不计算
count(id)

--计算列中非空的行数，null则不计算，并且将非空内容去重后计算行数。
count(distinct id)


--假如我们就是想要计算空呢，count内依然可以使用case when 
with a as (
select '1' id union all 
select '1'  union all 
select 'b'  union all 
select 'b'  union all 
select null 
)
select count(case when id is null then 'a' else null end )  
from a  

count 
------
     1
	 
--count中也可以有distinct和case when进行配合
with a as (
select '1' id union all 
select '1'  union all 
select 'b'  union all 
select 'b'  union all 
select null 
)
select count(distinct case when id='b' then 'a' else null end )  
from a  

count 
------
     1
