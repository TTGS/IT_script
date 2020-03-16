CREATE or replace FUNCTION strsubing_c2c(
str text
,begin_char text default null 
,end_char text default null 
)    RETURNS text    AS $$
DECLARE
   --char count
   p_text text:=str;
   s_begin text:=begin_char;
   s_end  text:=end_char ; 
   result_text text:=null;
begin
-- 检查部分
-- 防止结束内容为空；
	if  s_begin is null  and  s_end is null  then
	    RAISE INFO 'do not have start char and end char!!!';
        RAISE INFO 'EX. select strsubing_c2c(''abcdefg'',''c'',''f'');' ;
        select 'do not have start char and end char!!!' into result_text;
        RETURN  result_text  ;  
	elsif  s_begin is not  null  and  s_end is null  then
        select substring(p_text,length(p_text))  into s_end ;
	elsif  s_begin is null  and  s_end is not  null  then
	    RAISE INFO 'do not have start char!!!';
        RAISE INFO 'EX. select strsubing_c2c(''abcdefg'',''c'',''f'');' ;
        select 'do not have start char and end char!!!' into result_text;
        RETURN  result_text  ;
	end if ;
-- 切割
select substring(p_text ,
position(  s_begin  in  p_text ),
position(   s_end in p_text  )
-position(   s_begin in   p_text )+1
) into result_text;

-- 字符输出内容。
RAISE NOTICE 'result_text:%',result_text;

-- 输出arr_save
RETURN  result_text  ;
exception
    WHEN others THEN
    RAISE NOTICE '==========caught EXCEPTION start(%)==========',now() ;
    RAISE NOTICE 'this is a error that I do not know.';
    RAISE NOTICE 'enter full text(str):%',str ;
    RAISE NOTICE 'enter to split text start char(begin_char):%',begin_char ;
    RAISE NOTICE 'enter to split text end char(end_char):%',end_char ;
    RAISE NOTICE 'to split full text(p_text):%',p_text ;
    RAISE NOTICE 'split start char(begin_char):%',begin_char ;
    RAISE NOTICE 'split start char(s_end):%',s_end ;
    RAISE NOTICE 'out result text(result_text):%',result_text ;
    RAISE NOTICE 'EX. select strsubing_c2c(''abcdefg'',''c'',''f'');' ;
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
    RETURN '!!!EXCEPTION!!!';
END;
$$ LANGUAGE plpgsql;
