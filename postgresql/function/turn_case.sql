-- drop FUNCTION turn_case(v_char varchar)   ;

--select turn_case('AbCDeFg12345 ^&*()')

CREATE or replace FUNCTION turn_case(v_char varchar)    
RETURNS varchar    AS $$
DECLARE
-- 我自己的参数
	p_char varchar:=v_char;
	p_result varchar:='';
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
 
/*
 *帮助你理解我的sql是怎么回事。
select substring (i,v,1) , ascii(substring (i,v,1))  
,case 
when  ascii(substring (i,v,1))   >=97 then upper(substring (i,v,1)) 
when  ascii(substring (i,v,1))   < 97 then lower(substring (i,v,1)) 
else substring (i,v,1)
end  
from (values('abcdefgH')) t(i)
,    ( select  generate_series(1,length('abcdefgH') )   ) as  c(v)

select 	array_to_string(ARRAY[1, 2, 3 , 5], '' )
 * */

select  array_to_string(--使用array_to_string 对array转换成string类型，也就是去掉了逗号什么的。
	array_agg  ( --使用array_agg聚合函数将内容合并到一起，返回是array类型。
				case --使用笛卡尔积将字符串每个拆出来了，判断ascii，
				     --大于等于97就是小写，变大写；
				     --小于      97就是大写，变小写。
				     --else是为了防止泄漏，也是代码闭区间的防意外。
						when  ascii(substring (i,v,1))   >=97 then upper(substring (i,v,1)) 
						when  ascii(substring (i,v,1))   < 97 then lower(substring (i,v,1)) 
						else substring (i,v,1)
				end  
				) 
,'') into p_result --将结果放入变量
from (values(p_char)) t(i)
--为了产生多长字符串，出来多少行，为了动态切割。
,    ( select  generate_series(1,length(p_char) )   ) as  c(v) ;

return p_result;
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
       RAISE NOTICE 'p_char:%',p_char;
       RAISE NOTICE 'p_result:%',p_result;
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
