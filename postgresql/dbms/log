with a as (
select 1 i , 2 b , 3 c union all 
select 4 i , 5 b , 6 c  )
select * from a 
where  i=4 or  i=1  and b=2
i     |b     |c     
------|------|------
     1|     2|     3
     4|     5|     6
 
with a as (
select 1 i , 2 b , 3 c union all 
select 4 i , 5 b , 6 c  )
select * from a 
where  i=4 or   ( i=1  and b=2 ) 
i     |b     |c     
------|------|------
     1|     2|     3
     4|     5|     6
     
with a as (
select 1 i , 2 b , 3 c union all 
select 4 i , 5 b , 6 c  )
select * from a 
where ( i=4 or  i=1 )  and b=2
i     |b     |c     
------|------|------
     1|     2|     3
