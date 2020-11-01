--drop FUNCTION drop_table_2_recyclebin ; 
CREATE or replace   FUNCTION drop_table_2_recyclebin
( in table_name varchar(64) 
, in commend varchar(64) default null ) 
RETURNS table(old_table_name text ,new_table_name text 
,  execute_status text 
, fun_message text )
AS $$
DECLARE
   -- 我自己的参数
   p_tabname   text:=table_name;  
   p_comm      text:=commend; 
   t_text      text:=null;
   t_status    text:='Error';
   t_old_name  text:=table_name;
   t_new_name  text:=null;
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
--commend参数有更高的优先权限,非空就会进入特殊模式.
	if p_comm is not null or p_comm<>'' then 
		case lower(p_comm)			
		    when 'exception' then 
				t_text:='the commend is '||p_comm||' ,to launch exception.';
				t_status:='Exception';
				raise exception ' fun-01555:user require this exception .'
				using hint = ' user require this exception .';
			when 'init' then 
				execute   'create table recyclebin ( 
				drop_time timestamp not null  default now() 
			   ,old_table_name varchar(100)
			   ,new_table_name varchar(1000)  )';
			   t_text:='the commend is '||p_comm||' ,to init is done';
			when 'help' then 
				t_text:='the commend is '||p_comm||' ,help in case';
			else
				t_text:='it is x message';
		end case ;

	else 
		select cast(oid as text ) , relname 
		into   t_new_name          , t_old_name 
        from pg_class where relkind='r' and relname=p_tabname ;
		t_new_name='RECYC_'||t_new_name;
		execute   'alter table  '||t_old_name||'   rename to '||t_new_name ; 
		t_text:='it has dropped '||t_old_name||' .';
		insert into recyclebin 	values(default , t_new_name, t_old_name );
	end if ; 
	t_status:='Done';
	--返回结果
    RETURN query  select  
	 old_table_name old_table_name
	,new_table_name new_table_name
	,t_status execute_status 
	,t_text  fun_message ;

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
		   if lower(p_comm) <>'exception' then 
		   t_text:='the exception is not user require.';
		   end if ;
		RAISE NOTICE 'p_tabname :%',p_tabname ;    
		RAISE NOTICE 'p_comm    :%',p_comm    ;  
		RAISE NOTICE 't_text    :%',t_text    ;  
		RAISE NOTICE 't_status  :%',t_status  ;  
		RAISE NOTICE 't_old_name:%',t_old_name;  
		RAISE NOTICE 't_new_name:%',t_new_name;  
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
	rollback;
    RETURN query  select  
	 old_table_name old_table_name
	,new_table_name new_table_name
	,t_status execute_status 
	,t_text  fun_message ;
END;
$$ LANGUAGE plpgsql;


select  * from drop_table_2_recyclebin('test' )


create table test(id int )


select * from recyclebin 


select * from pg_class  where relname ilike '%recyc%'


drop table  recyc_16410; 
