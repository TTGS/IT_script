-- drop FUNCTION random_alnum(v_len bigint,v_case text  )
/*
 * select random_alnum(5,'n');
 * select random_alnum(5,'y');
 *
 * select random_alnum(5,null);
 * select random_alnum(null);
*/
CREATE or replace FUNCTION random_alnum(v_len bigint,v_case text default 'N')    
RETURNS text    AS $$
DECLARE
   -- 我自己的参数
   p_len       bigint:=v_len;
   r_text      text:='';
   r_text_temp text:='';
   p_case      text:=v_case;
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

-- 防止第一个参数被输入null内容。
if  p_len is null  then 
	-- 输入其他内容都是帮助输出。
	r_text:='Please enter a correct content,';
	r_text:=r_text||'the varchar is not Case sensitive ,';
	r_text:=r_text||'EX. yes(Y) or no(N)';
	return r_text;
end if ;

-- 判断是否要求区分大小写
if UPPER(p_case) in ('Y','YES','1','T','TRUE')  then 
	p_case:='Y';
elsif  UPPER(p_case) in ('N','NO','0','F','FALSE')   then 
	p_case:='N';
else 
	-- 输入其他内容都是帮助输出。
	r_text:='Please enter a correct content,';
	r_text:=r_text||'the varchar is not Case sensitive ,';
	r_text:=r_text||'EX. yes(Y) or no(N)';
	return r_text;
end if ;

/* 内容 的循环 
*  p_case:='Y' 是内容区分大小写， 
*  是否大小写取决于mod(abs(hashtext(random()::text)::int),2) 的结果
*  p_case:='N' 是内容 不 区分大小写 ，但是默认输出就是小写哟
*/
for i in 1.. p_len loop
		select 
		(case 
		when p_case='Y' and mod(abs(hashtext(random()::text)::int),2)=1 then upper(id)
		when p_case='Y' and mod(abs(hashtext(random()::text)::int),2)=0 then lower(id)
		when p_case='N' then id
		else null end )
		into r_text_temp 
		from (
		values('a'),('b'),('c'),('d'),('e'),('f')
		,('g'),('h'),('i'),('j'),('k'),('l'),('m')
		,('n'),('o'),('p'),('q'),('r'),('s'),('t')
		,('u'),('v'),('w'),('x'),('y'),('z')
		,('0'),('1'),('2'),('3'),('4'),('5')
		,('6'),('7'),('8'),('9')
		) d(id) 
		order by random() 
		limit 1 ;
		--拼接字符
		r_text:=r_text||r_text_temp;
end loop ;

return r_text;
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
       RAISE NOTICE 'p_len:%',p_len   ;    
       RAISE NOTICE 'r_text:%',r_text  ;    
       RAISE NOTICE 'r_text_temp:%',r_text_temp ;
       RAISE NOTICE 'p_case:%',p_case  ;
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
