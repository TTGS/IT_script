窗口函数 row_number 

格式：row_number() over([partition by 列1[,列2...]] [order by 列1[,列2...] [asc|desc] ] [nulls first|last])

row_number后面的括号里没有任何内容，
over是计算方式，
	partition by 是分组，按照列值分组数数，不同的值会重新数数
	order by 是排序方式，按照什么列进行排序，从大到小还是从小到大，空放在最上还是最下。

--按照 v列进行分组，每个不同的值都会从1开始数。
with a as (
select 1 id , 'a' v union all 
select 1 id , 'b' v union all 
select 2 id , 'a' v union all 
select 2 id , 'b' v union all 
select 2 id , 'c' v union all 
select 3 id , 'a' v  
)
 select id, v, row_number() over (partition by v  order by v  )   from a;
id    |v     |row_number
------|------|----------
     1|a     |         1
     2|a     |         2
     3|a     |         3
     1|b     |         1
     2|b     |         2
     2|c     |         1


--如果列值内容一样，那么其实他排序也会向下数。 nulls 会控制null值放在哪里。
with a as (
select 1 id   union all 
select 1 id   union all 
select 1 id   union all 
select 2 id   union all 
select 2 id   union all 
select 3 id   union all 
select null id 
)
 select id,  row_number() over ( partition by id  order by id   nulls last  )   from a;
id    |row_number
------|----------
     1|         1
     1|         2
     1|         3
     2|         1
     2|         2
     3|         1
[NULL]|         1


--order by 列内容排序默认是升序asc，可以用desc进行倒序排列。
with a as (
select 1 id , 'a' v union all 
select 1 id , 'b' v union all 
select 2 id , 'a' v union all 
select 2 id , 'b' v union all 
select 2 id , 'c' v union all 
select 3 id , 'a' v  
)
 select id, v, row_number() over (partition by v  order by id  desc  )   from a;
 
id    |v     |row_number
------|------|----------
     3|a     |         1
     2|a     |         2
     1|a     |         3
     2|b     |         1
     1|b     |         2
     2|c     |         1


-- 如果不分组，那么就会是整个表进行排序内容。
with a as (
select 1 id   union all 
select 1 id   union all 
select 1 id   union all 
select 2 id   union all 
select 2 id   union all 
select 3 id   union all 
select null id 
)
 select id,  row_number() over (   order by id      )   from a;
 id    |row_number
------|----------
     1|         1
     1|         2
     1|         3
     2|         4
     2|         5
     3|         6
[NULL]|         7

-- 在pg里可以省略order by 内容，有些数据库里不行。
with a as (
select 1 id   union all 
select 1 id   union all 
select 1 id   union all 
select 2 id   union all 
select 2 id   union all 
select 3 id   union all 
select null id 
)
 select id,  row_number() over (  partition by  id )   from a;
id    |row_number
------|----------
     1|         1
     1|         2
     1|         3
     2|         1
     2|         2
     3|         1
[NULL]|         1


-- 当然你可以在pg里都不写。一样执行，因为有默认，默认是读出来的顺序进行进行全表排序。
with a as (
select 1 id  ,17 k union all 
select 1 id  ,27 k union all 
select 1 id  ,17 k union all 
select 2 id  ,17 k union all 
select 2 id  ,27 k union all 
select 3 id ,27 k  union all 
select null id ,17 k
)
 select k,id,  row_number() over ()   from a;
k     |id    |row_number
------|------|----------
    17|     1|         1
    27|     1|         2
    17|     1|         3
    17|     2|         4
    27|     2|         5
    27|     3|         6
    17|[NULL]|         7
