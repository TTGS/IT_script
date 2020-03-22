名称：sum(列名)

说明：这个sum是将列的值直接做加“+”的运算，无论你的值是正还是负，他会自动忽略null内容。

--sum直接忽略空值
with a as (
select 1 id union all 
select 2 id union all 
select null 
)
select sum(id)  from a 
sum   
------
     3

--只是单纯的求和，不管你的内容是正还是负。
with a as (
select -1 id union all 
select 2 id 
)
select sum(id)  from a 
sum   
------
     1
	 
	 
--sum中可以直接使用case when，符合的如何如何。这种方式一般用作切片或者数据选择多。
with a as (
select 1 id union all 
select 2 id union all 
select null 
)
select sum(case when id is not null then 1 else 0 end )  from a 
sum   
------
     2

--当然你也可以先去重然后再求和
with a as (
select 1 id union all 
select 1 id  
)
select sum(distinct id)  from a 
 sum   
------
     1
     
-- 当然也可以按照某列进行分组后再求和。 
with a as (
select 'a' v, 1 id union all 
select 'a' v, 2 id union all 
select 'b' v, 3 id union all 
select 'b' v, 4 id  
)
select v, sum(id)  from a  
group by v 
v     |sum   
------|------
b     |     7
a     |     3

--如果你的分组后内容就一个null，那么你的结果只是null内容。
with a as (
select 'a' v, 1 id union all 
select 'a' v, 2 id union all 
select 'b' v, null id  
)
select v, sum(id)  from a  
group by v 
v     |sum   
------|------
b     |[NULL]
a     |     3
