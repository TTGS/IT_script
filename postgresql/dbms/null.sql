null是特殊的一个类型数据，它属于未知数据，结构如下

   / 已知数据（int， varchar ,time ,date ...
数据
   \ 未知数据（null）

所以你会发现，null有很多特点，
1，null与任何四则运算结果都是null
2，经典聚合函数会自动忽略nul，有些会特指后忽略
3，null可以与任何数据类型搭配
4，null不一定等于null,等式中相等，join运算中不相等
5，寻找null的时候是需要用is关键词，PostgreSQL中可以用一个参数transform_null_equals去修改is改成“=”，只是数据库后台帮你改成了is而已。

--任何四则运算都将返回null，只是对横向的这样。
select null+1,null-1 , null*1 , null/1
?column?|?column?|?column?|?column?
--------|--------|--------|--------
  [NULL]|  [NULL]|  [NULL]|  [NULL]
  
  
select 1+null ,1-null  , 1*null  , 1/null 
?column?|?column?|?column?|?column?
--------|--------|--------|--------
  [NULL]|  [NULL]|  [NULL]|  [NULL]
  
  
select null/0 , 0/null 
?column?|?column?
--------|--------
  [NULL]|  [NULL]
  
  
select null||null , null||'a' ,'b'||null 
?column?|?column?|?column?
--------|--------|--------
[NULL]  |[NULL]  |[NULL]  

--经典聚合函数会忽略null，但是count需要自己指定内容。
with a as (
select 1 id  union all 
select 3     union all 
select null 
)
select sum(id),max(id) ,min(id) , avg(id) , count(*) , count(id)  from a 
sum   |max   |min   |avg               |count |count 
------|------|------|------------------|------|------
     4|     3|     1|2.0000000000000000|     3|     2
     
     

-- null可以和任何的类型搭配，而不会引起类型报错。
select 1 union all select null 
select 'a' union all select null 
select now() union all select null 
select ARRAY[3,4] union all select null 
SELECT int8range(1, 14, '(]') union all select null 
SELECT '1000'::bytea union all select null 
bytea                   
------------------------
decode('31303030','hex')
[NULL]                  

--null在运算中等于null，join中就不会相等。
select null is null , null ='' , ''=null  ,null=null  
?column?|?column?|?column?|?column?
--------|--------|--------|--------
true    |[NULL]  |[NULL]  |[NULL]  

select * from (select null i ) a full   join (select null d ) b on a.i=b.d
i     |d     
------|------
[NULL]|[NULL]
[NULL]|[NULL]
