select what_type('{10000, 10000, 10000, 10000}'  ,'int4[]')
select what_type('{10000, 10000, 10000, 10000}'  ,'text[]')
select what_type('{10000, 10000, 10000, 10000}'  ,'varchar')
select what_type('{10000, 10000, 10000, 10000}'  ,'date')
select what_type('{10000, 10000, 10000, 10000}'  ,'timestamp')

drop FUNCTION public.what_type;
-- 不要用于大规模数据检查，速度上不去！！！！！！！！！
-- Do not use it to check too much data   ！！！！！！

CREATE OR REPLACE FUNCTION public.what_type(v_text varchar  ,v_type varchar)
RETURNS boolean    AS $$
DECLARE
-- 我自己的参数
p_data text:=v_data;
p_datatype varchar:=v_datatype;
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
	-- 使用cast 标准转换函数对内容和提供的类型去转换，如果是失败，那么他就不是这种类型，当然也可能是这个类型不存在。
execute  'select cast('''||p_data||''' as '||p_datatype||')';
    -- 成功转换就发挥真。
return true;
exception
    when sqlstate '22P02' then 
    RAISE notice 'to convert is false';
       RETURN false ;
    when SQLSTATE  '42704' then 
    RAISE notice 'the data type is not exists';
       RETURN null ;
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
       RAISE NOTICE 'this is unkonw error';
       RAISE NOTICE 'p_data:%',p_data;
       RAISE NOTICE 'p_datatype:%',p_datatype;
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
    RETURN null ;
END;
$$ LANGUAGE plpgsql;
