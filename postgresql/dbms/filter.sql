聚合函数筛选  filter 

格式：aggregate() [filter(where values [...])]

该命令在聚合函数之后使用，如果不写，那么不会生效，写了会按照要求去筛选去计算聚合函数内容。但不符合的内容依然会出现。where不能省略。



--只有符合id=2的时候sum才会计算，但不符合要求的内容依然会被显示。
with a as (
select 1 id    union all 
select 1 id    union all 
select 1 id    union all 
select 2 id    union all 
select 2 id    union all 
select 2 id    union all 
select 3 id  
)
 select id,  sum(id)  filter(where id=2)     from a group by id ;
id    |sum   
------|------
     1|[NULL]
     3|[NULL]
     2|     6

--分组依然可以。
with a as (
select 1 id  ,17 k union all 
select 1 id  ,27 k union all 
select 1 id  ,27 k union all 
select 1 id  ,17 k union all 
select 2 id  ,27 k union all 
select 2 id ,27 k  union all 
select 2 id ,17 k
)
select k,id,  sum(id)  filter(where k=27)     from a group by k,id ;
k     |id    |sum   
------|------|------
    27|     1|     2
    17|     2|[NULL]
    17|     1|[NULL]
    27|     2|     4


-- 关于一个filter 的错误。
SQL 错误 [0A000]: ERROR: FILTER is not implemented for non-aggregate window functions
  Position: 240
  ERROR: FILTER is not implemented for non-aggregate window functions
  Position: 240
  ERROR: FILTER is not implemented for non-aggregate window functions
  Position: 240
