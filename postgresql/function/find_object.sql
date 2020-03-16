-- drop   FUNCTION find_object(text)
/*
 * select   find_object('pOStgres');
 * select    * from find_object('pOStgres') ;
*/
CREATE or replace FUNCTION find_object(v_objectname text)    
RETURNS TABLE(object_id oid , object_name name ,object_type text)    
AS $$
DECLARE
   -- 我自己的参数
objname  name := lower(v_objectname)  ;
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
RETURN QUERY 
select oid objcet_id,extname object_name ,'extension' object_type 
from pg_catalog.pg_extension  where lower(extname )=objname
union all 
select oid,proname,'procdurce' 
from pg_catalog.pg_proc where  lower(proname)=objname
union all
select oid,tgname ,'trigger' from pg_catalog.pg_trigger
where lower(tgname)=objname
union all 
select null ,attname , 'column('||attrelid::regclass||')' object_type
from pg_catalog.pg_attribute  where lower(attname)=objname
union all 
select oid,  relname , 
(case relkind 
when  'r' then  'ordinary table'
when  'i' then  'index'
when  'S' then  'sequence'
when  'v' then  'view'
when  'm' then  'materialized view'
when  'c' then  'composite type'
when  't' then  'TOAST table'
when  'f' then  'foreign table'
else null
end) object_type 
from pg_catalog.pg_class where lower(relname )=objname 
union all 
select  oid , nspname,'name space(schema)'    
from pg_catalog.pg_namespace  where lower(nspname)=objname
union all 
select  oid, rolname , 'user/role'   
from pg_catalog.pg_roles where lower(rolname)=objname
union all 
select oid, datname ,'database'   
from pg_catalog.pg_database where lower(datname)=objname
union all 
select oid, spcname,'tablespace'   
from pg_catalog.pg_tablespace where lower(spcname)=objname ;

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
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
END;
$$ LANGUAGE plpgsql ;
