
CREATE or replace FUNCTION  math_limit(
double precision,
double precision
)
RETURNS double precision     AS $$
DECLARE
-- 我自己的参数
p_head double precision:=$1;
p_tail double precision:=$2;
p_result double precision:='NaN';
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
select 
case    -- >0
		when  p_head>0           and p_tail=0                    then 'Infinity' 
		when  p_head>0           and p_tail='Infinity'           then 0 
		when  p_head>0           and p_tail='-Infinity'          then 0 	
		-- <0
		when  p_head<0           and p_tail=0                    then '-Infinity' 
		when  p_head<0           and p_tail='Infinity'           then 0 
		when  p_head<0           and p_tail='-Infinity'          then 0 
		-- =0
		when  p_head=0           and p_tail=0                    then 1
		when  p_head=0           and p_tail='Infinity'           then 0 
		when  p_head=0           and p_tail='-Infinity'          then 0 
		-- =Infinity
		when  p_head='Infinity'           and p_tail=0                    then 'Infinity'
		when  p_head='Infinity'           and p_tail='Infinity'           then 1 
		when  p_head='Infinity'           and p_tail='-Infinity'          then -1 
		-- =  -Infinity
		when  p_head='-Infinity'           and p_tail=0                    then '-Infinity'
		when  p_head='-Infinity'           and p_tail='Infinity'           then -1 
		when  p_head='-Infinity'           and p_tail='-Infinity'          then 1 
		-- =NaN
		when  p_head='NaN'       or  p_tail='NaN'       then  'NaN'
		else  p_head/p_tail       
end 
into  p_result;
	
	
return  p_result;
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
       RAISE NOTICE 'p_head:%',p_head;
       RAISE NOTICE 'p_tail:%',p_tail;
       RAISE NOTICE 'p_result:%',p_result;
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
    RETURN '!!!exception!!!';
END;
$$ LANGUAGE plpgsql;
