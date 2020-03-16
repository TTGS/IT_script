CREATE or replace FUNCTION replace_symbol(syn_text text)    
RETURNS text    AS $$
DECLARE
-- 我自己的参数
   s_text    text:=syn_text;
   s_len     numeric:=null;
   s_step    varchar(100):=null;
   r_text    text:='' ;
   s_every_char text:='';
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
-- 得到传入内容的长度。
select length(s_text) into s_len ;
--拆分，每个字节进行判断
s_step:='the for will start(F1)';
FOR i IN 1..s_len  LOOP
-- 切分字符
s_step:='I enter the loop ,it is '||i||' times(F2)' ;
 select  substring(s_text,i,1)  into s_every_char;
s_step:='I split the char num '||i||' ,it is '||s_every_char||' (F3)' ;
--判断，并且重组。
 if (s_every_char ~* '\w' ) then 
s_step:='I think the '||s_every_char||' is character or numerical(CN1)' ;
  r_text:=r_text||s_every_char  ; 
s_step:='the text '||r_text||' was change  (CN2)';
 elsif (s_every_char !~* '\w' ) then 
s_step:='I do not think the '||s_every_char||' is character or numerical(RT1)';
  r_text:=r_text  ;
s_step:='the text '||r_text||' was change  (RT2)';
 else 
 s_step:='I found a non-normal char(NNC)';
 --防止乱码出现。特设自定义异常报告。
      RAISE EXCEPTION '->%<- not is character , numerical or symbol' , s_every_char 
      USING ERRCODE = others ; 
 end if ;
END LOOP;
s_step:='the function will done (Done)';
return r_text ;
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
		RAISE NOTICE 's_step:%',s_step;
		RAISE NOTICE 's_text:%',s_text;
		RAISE NOTICE 's_len:%',s_len;    
		RAISE NOTICE 'r_text:%',r_text;
		RAISE NOTICE 's_every_char:%',s_every_char;
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
