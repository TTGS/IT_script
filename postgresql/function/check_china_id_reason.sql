CREATE OR REPLACE FUNCTION public.check_china_id_reason(id text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
   -- 我自己的参数
   p_id    text:=id;
   ck_bool  boolean:=null;
   ck_step text:=null;
   ck_len  int:=null;
   ck_text boolean:=null;
   ck_date date:=null;
   p_steen text:=null;
   p_eteen text:=null;
   p_sum   numeric :=null;
   s_eteen text:=null;
-- 系统异常捕获
sys_RETURNED_SQLSTATE		text:=null;
sys_COLUMN_NAME				text:=null;
sys_CONSTRAINT_NAME			text:=null;
sys_PG_DATATYPE_NAME		text:=null;
sys_MESSAGE_TEXT			text:=null;
sys_TABLE_NAME				text:=null;
sys_SCHEMA_NAME				text:=null;
sys_PG_EXCEPTION_DETAIL		text:=null;
sys_PG_EXCEPTION_HINT		text:=null;
sys_PG_EXCEPTION_CONTEXT	text:=null;
begin

-- 长度检查
ck_step:='to check length(L1)';
select length(p_id) into ck_len;
ck_step:='I have ck_len(L2)';
if ck_len>18 then 
ck_step:='I will false(L3)';
return 'too long';
elsif ck_len<18 then 
ck_step:='I will false(L3)';
return 'too small';
end if ;
ck_step:='the check pass(L4)';

/*
 * \d=[0-9]
 * \d{17}=[0-9]写了17次
 * (\d|x)=最后一位是0到9的数字或者x
 *  ~* 正则表达式，大小写不敏感
 * */
-- 检查内容是否为数字，最后一位为x或者数字。注意这里x大小写不敏感。
ck_step:='to check text (N1)';
SELECT  p_id ~* '\d{17}(\d|x)' 
into ck_text;
ck_step:='I have ck_text(N2)';
if ck_text=false then 
	ck_step:='I will false(N3)';
	return 'not numeric or x';
end if ;
ck_step:='I will false(N3)';

-- 地区检查
-----------------------------------------
-- 没有数据，只是检查1前6位是否为数字。           --
-- 不过感觉这个有点多此一举，                            --
-- 因为如果有非数字进来，前面的检查就拦截了。 --
-- 不会轮到这里再检查。                                      --
-----------------------------------------
ck_step:='I have entered the block (B2)'; 
select case when substring(p_id,1,6) ~* '\d{6}' then true  else false end  into ck_bool ; 

if  ck_bool is false then 
    return 'the area is not number';
end if ; 

-- 生日检查 
ck_step:='to check 8 postion (B1)';
BEGIN 
ck_step:='I have entered the block (B2)'; 
select substring(p_id,7,8)::date into ck_date; 
ck_step:='the pass for date check(B3)'; 
exception
WHEN SQLSTATE '22008' then
ck_step:='I will false(B4)'; 
    return 'birthday error';
END;
ck_step:='the pass date check(B5)'; 


-- 最后一位校验位检查

-- 17 位求和
ck_step:='to find 17 postion (P1)'; 
p_steen:=substring(p_id,1,17);
ck_step:='I have  17 postion (P2)'; 

-- 前17位乘以系数
ck_step:='17 postion × system number (P3)'; 
select sum(substring(o.id,i,1)::int *v) 
into p_sum 
from ( values( p_id ) ) as o(id) 
cross join (values
 (1,7)  ,(2,9) ,(3,10),(4,5) ,(5,8) ,(6,4)
,(7,2)  ,(8,1) ,(9,6) ,(10,3),(11,7),(12,9)
,(13,10),(14,5),(15,8),(16,4),(17,2) ) as r(i,v) ;
ck_step:='I have summed (P4)'; 

-- 18 位 
ck_step:='to find num 18 (F1)';
p_eteen:=substring(p_id,18,1);
ck_step:='found num 18 (F2)';


-- 找到正确余数
ck_step:='to found real our NUM 18  (F3)';
select cz_checknum
into s_eteen
from 
(values(1,0,'1'),(2,1,'0'),(3,2,'x'),(4,3,'9'),(5,4,'8'),(6,5,'7')
,(7,6,'6'),(8,7,'5'),(9,8,'4'),(10,9,'3'),(11,10,'2')) 
cz(cz_id,cz_mod,cz_checknum)
-- 求出余数
where cz_mod=mod(p_sum,11);
ck_step:='NUM 18 was found (F4)';


ck_step:='to check 18 and 18 (E1)';
-- 检查最后一位是不是对的。
if  upper(s_eteen)<> upper(p_eteen)  then 
return 'check num error';
end if ;
ck_step:='18 and 18 is pass  (E2)';

ck_step:='the end of the wolrd (done)';
return 'true';
exception
    WHEN others then
    GET STACKED DIAGNOSTICS 
		sys_RETURNED_SQLSTATE	=RETURNED_SQLSTATE	,
		sys_COLUMN_NAME			=COLUMN_NAME	,
		sys_CONSTRAINT_NAME		=CONSTRAINT_NAME,
		sys_PG_DATATYPE_NAME	=PG_DATATYPE_NAME,
		sys_MESSAGE_TEXT		=MESSAGE_TEXT	,
		sys_TABLE_NAME			=TABLE_NAME		,
		sys_SCHEMA_NAME			=SCHEMA_NAME		,
		sys_PG_EXCEPTION_DETAIL	=PG_EXCEPTION_DETAIL,
		sys_PG_EXCEPTION_HINT   =PG_EXCEPTION_HINT,
		sys_PG_EXCEPTION_CONTEXT=PG_EXCEPTION_CONTEXT;
    RAISE NOTICE '==========caught EXCEPTION start(%)==========',now() ;
    RAISE NOTICE '========== SYS exception ==========';
		RAISE NOTICE 'sys_RETURNED_SQLSTATE:%',  sys_RETURNED_SQLSTATE;	
		RAISE NOTICE 'sys_COLUMN_NAME:%',  sys_COLUMN_NAME		;	
		RAISE NOTICE 'sys_CONSTRAINT_NAME:%',  sys_CONSTRAINT_NAME	;	
		RAISE NOTICE 'sys_PG_DATATYPE_NAME:%',  sys_PG_DATATYPE_NAME	;
		RAISE NOTICE 'sys_MESSAGE_TEXT:%',  sys_MESSAGE_TEXT	;	
		RAISE NOTICE 'sys_TABLE_NAME:%',  sys_TABLE_NAME	;		
		RAISE NOTICE 'sys_SCHEMA_NAME:%',  sys_SCHEMA_NAME	;		
		RAISE NOTICE 'sys_PG_EXCEPTION_DETAIL:%',  sys_PG_EXCEPTION_DETAIL	;
		RAISE NOTICE 'sys_PG_EXCEPTION_HINT:%',  sys_PG_EXCEPTION_HINT	;
		RAISE NOTICE 'sys_PG_EXCEPTION_CONTEXT:%',  sys_PG_EXCEPTION_CONTEXT;
   RAISE NOTICE '========== my exception ==========';
       RAISE NOTICE 'p_id:%',p_id;
       RAISE NOTICE 'ck_step:%',ck_step;
       RAISE NOTICE 'ck_len:%',ck_len;
       RAISE NOTICE 'ck_text:%',ck_text;
       RAISE NOTICE 'ck_date:%',ck_date;
       RAISE NOTICE 'p_steen:%',p_steen;
       RAISE NOTICE 'p_eteen:%',p_eteen;
       RAISE NOTICE 'p_sum:%',p_sum;
       RAISE NOTICE 's_eteen:%',s_eteen;
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
    RETURN NULL;
END;
$function$
;
