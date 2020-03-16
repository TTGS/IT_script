-- drop FUNCTION   define_round ( v_numeric numeric DEFAULT  null , v_postion int DEFAULT  null , v_define int DEFAULT  null ) ;
-- select  define_round (null,null,null)  ;
-- select  define_round ()  ;
-- select  define_round (1.123456,2,0)  ;
-- select  define_round (1.123456,0,0)  ;
CREATE or replace FUNCTION define_round ( v_numeric numeric DEFAULT  null , v_postion int DEFAULT  null , v_define int DEFAULT  null )    
RETURNS numeric    AS $$
DECLARE
-- 我自己的参数
       p_numeric numeric :=v_numeric;
              p_post int :=v_postion;
            p_define int :=v_define;
       r_numeric numeric :=v_numeric;
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
	--帮助 
	if  (  p_numeric is null and  p_post is null and   p_define is null)  then 
		raise  info '这个函数有3个参数， v_numeric numeric  , v_postion int , v_define int';
		raise  info 'v_numeric是需要解决的数值';
	    raise  info 'v_postion是参数的精度';
	    raise  info 'v_define是精度位需要检查的数字，精度位+1位大于等于这个数值，那么进位，否则舍去';
	    return null;  
	end if ;
	--select round(3.55,2);
	--select round(3.5,2);
	--如果你的位数不足，那么直接返回你给的内容。
	if scale(p_numeric)<=p_post then 
		return r_numeric;
	end if ;

-- 截取你要求长度+1那么多内容。剩下的都可以扔掉了。
select trunc(p_numeric,p_post+1) into p_numeric ; 


-- 截断要求的长度，然后看到位数，加小数精度后的位数.1内容
-- 如果最后一位和要求进位的数不符合，那么就只是截断。
if right(p_numeric::varchar,1)::int >=p_define then 
 r_numeric:= trunc(p_numeric,p_post) +  10/10^scale( p_numeric );  
else 
 r_numeric:= trunc(p_numeric,p_post)  ;
end if ;

return r_numeric;
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
       RAISE NOTICE 'p_numeric:%',p_numeric;  
       RAISE NOTICE 'p_post:%',p_post;
       RAISE NOTICE 'p_define:%',p_define;
       RAISE NOTICE 'r_numeric:%',r_numeric;
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
