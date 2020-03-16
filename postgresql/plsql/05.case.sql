选择语句主要是两种，
1，if ,可以做连续判断
2，case ，可以做整体判断。

-- if 
if  条件1 then 结果1
elsif 条件2 then  结果2 
else   结果3
end if 

DO $$
DECLARE   
n boolean ;
t boolean :=true ; 
f boolean :=false ; 
BEGIN

if  n is null then  raise  info 'n:%',n;
elsif t then     raise  info 't:%',t;
else  raise  info 'f:%',f;
end if ; 
end
$$;

--case 
case 
when 条件1 then 结果1
when 条件2 then 结果2 
else 结果3
end case 

DO $$
DECLARE   
n boolean ;
t boolean :=true ; 
f boolean :=false ; 
BEGIN

case 
when n is null then  raise  info 'n:%',n;
when  t        then  raise  info 't:%',t;
else                 raise  info 'f:%',f;
end case ; 
 
end
$$;
 
