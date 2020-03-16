-- drop FUNCTION FUNCTION fake_uuid()
/*
 * select   fake_uuid();
 * select   fake_uuid() ,* from pg_class ;
*/
CREATE or replace FUNCTION fake_uuid()    
RETURNS text  AS $$
DECLARE
   -- 我自己的参数
   re_uuid      text:='';
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
-- 8-4-4-4-12的32个字符
-- 构建内容
with d(id) as (
   values('0'),('1'),('2'),('3')
		,('4'),('5'),('6'),('7')
		,('8'),('9'),('a'),('b')
		,('c'),('d'),('e'),('f')
		      )
-- 随机自由内容
select 
-- 8 位
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )|| 
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||'-'|| 
-- 4 位
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||'-'||  
-- 4 位
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||'-'||  
-- 4 位
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||'-'||  
-- 12 位
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )|| 
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )|| 
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )||
(select id from d order by random() limit 1 )
into re_uuid;

--返回结果
return re_uuid;
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
        RAISE NOTICE 're_uuid:%',re_uuid ;    
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
