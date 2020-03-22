--json 指定key去排序 
with a as (
select 1 id , '{"grade":10,"gradeCode":"A","gradeName":"An"}'::json k union all 
select 2 id , '{"grade":50,"gradeCode":"B","gradeName":"BN"}'::json j
)
select * from a 
order by k->>'grade' desc   

id    |k                                            
------|---------------------------------------------
     2|{"grade":50,"gradeCode":"B","gradeName":"BN"}
     1|{"grade":10,"gradeCode":"A","gradeName":"An"}
