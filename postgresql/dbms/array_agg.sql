名称：array_agg()

格式：聚合函数，将提供的列值内容放入同一个格子里。按照读取的顺序放入格子里，可以去重，可以排序，但是不能使用over协助。整体排序是需要分组，如果需要请直接进行分组。


-- 将内容放入一个格子里。
with a as (
select 3 id union all 
select 1  union all 
select 2 ) 
select array_agg(id ) from a 
array_agg
---------
'{3,1,2}'

-- 对内容进行排序
with a as (
select 3 id union all 
select 1  union all 
select 2 ) 
select array_agg(id  order by id  ) from a 
 array_agg
---------
'{1,2,3}'
 
-- 可以去重
with a as (
select 1 id union all 
select 1  union all 
select 2 ) 
select array_agg(distinct id ) from a 
array_agg
---------
'{1,2}'  


-- 分组会影响格子里的内容。
with a as (
select 1 k,3 id union all 
select 1 k,1  union all 
select 2 k,2 ) 
select k,array_agg(id ) from a group  by k 
k     |array_agg
------|---------
     1|'{3,1}'  
     2|'{2}'    
     
--整体排序会报错。
with a as (
select 3 id union all 
select 1  union all 
select 2 ) 
select array_agg(id ) from a order by id 


SQL 错误 [42803]: ERROR: column "a.id" must appear in the GROUP BY clause or be used in an aggregate function
  Position: 127
  ERROR: column "a.id" must appear in the GROUP BY clause or be used in an aggregate function
  Position: 127
  ERROR: column "a.id" must appear in the GROUP BY clause or be used in an aggregate function
  Position: 127

  
