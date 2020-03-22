名称：lag(列 [,int[,null]]) over(patition by 列 order by 列) 

说明：读取lag函数中列的上一行内容，如果当前行是第一行（默认），那么返回null，该分析函数是多行函数并非能聚合其他行。
      over中的order by 可以影响非函数列的排序。lag中的int是可以跳跃过几个，即读取向前第几个值，默认是1（上一个），
	       null是如果没有找到向上找的值没有找到，那么就使用什么值进行填充，默认用null填充。可以使用其他字符代替，不过需要类型兼容。
	       注意：如果想使用lag函数中的第三个值（null），那么第二个值不能省略。
               order by 后面可以用nulls last|first ，不过没用，也不报错。

	       
--读取本行上一个值内容。
with a as (
select 1 id union all 
select 2    union all 
select 3    union all 
select 4    
)
select id , lag(id) over(order by id )  from a 
id    |lag   
------|------
     1|[NULL]
     2|     1
     3|     2
     4|     3

--over中的order by 是可以直接影响其他行的顺序。	 
with a as (
select 1 id union all 
select 2    union all 
select 3    union all 
select 4    
)
select id , lag(id) over(order by id desc )  from a  
id    |lag   
------|------
     4|[NULL]
     3|     4
     2|     3
     1|     2

--加上partition by 分组后，将返回分组后的上一行。
with a as (
select 'a' v , 1 id union all 
select 'a' v ,  2    union all 
select 'a' v ,  3    union all 
select 'b' v ,  4    
)
select id , lag(id) over(partition by v order by id )  from a 
id    |lag   
------|------
     1|[NULL]
     2|     1
     3|     2
     4|[NULL]

	 
--lag是多行函数，所以如果非要和聚合函数在一起使用，会出现一个很怪异的结果。
with a as (
select 'a' v , 1 id union all 
select 'a' v ,  2    union all 
select 'a' v ,  3    union all 
select 'b' v ,  4    
)
select v,sum(id)  , lag(id) over(partition by v order by id )  from a group by v ,   id 
v     |sum   |lag   
------|------|------
a     |     1|[NULL]
a     |     2|     1
a     |     3|     2
b     |     4|[NULL]



--修改默认读取上一行的成读取上第3行内容。
with a as (
select 'a' v , 1 id union all 
select 'a' v ,  2    union all 
select 'a' v ,  3    union all 
select 'a' v ,  4    
)
select id , lag(id   ,3   ) over(order by id)   from a  
id    |lag   
------|------
     1|[NULL]
     2|[NULL]
     3|[NULL]
     4|     1
	 

-- 修改默认值从null成100 . 
with a as (
select 'a' v , 1 id union all 
select 'a' v ,  2    union all 
select 'a' v ,  3    union all 
select 'a' v ,  4    
)
select id , lag(id   , 1 ,100  ) over(order by id)   from a  
id    |lag   
------|------
     1|   100
     2|     1
     3|     2
     4|     3
	 
	 
-- 默认类型可以使用别的，但是你需要将两个类型兼容。
with a as (
select 'a' v , 1 id union all 
select 'a' v ,  2    union all 
select 'a' v ,  3    union all 
select 'a' v ,  4    
)
select id , lag(id::varchar  , 1 ,'a'   ) over(order by id)   from a  
id    |lag   
------|------
     1|a     
     2|1     
     3|2     
     4|3     
