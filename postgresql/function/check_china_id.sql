CREATE OR REPLACE FUNCTION public.random_china_id(
	v_city character   varying DEFAULT null , 
	v_street character varying DEFAULT 'F'::bpchar, 
	v_date character   varying DEFAULT 'A'::bpchar, 
	v_three character  varying DEFAULT 'R'::bpchar, 
	v_check character  varying DEFAULT 'T'::bpchar)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
   -- 我自己的参数
   p_city text:=upper(v_city);
   p_temp_city text:='';
   p_street text:=upper(v_street);
   p_temp_street text:='';
   p_date text:=upper(v_date);
   p_temp_date text:='';
   p_thr text:=upper(v_three);
   p_temp_thr text:='';
   p_check text:=upper(v_check);
   p_temp_check text:='';
   expect_result text:='';
   rsult_text text:='';
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
if  'HELP' in (p_city , p_street,p_date,p_thr,p_check)  or 
 'H' in (p_city , p_street,p_date,p_thr,p_check)  
then 
raise info 'Help text:';
raise info '	the public.random_china_id can make up Chinese identification NO.  (Chinese ID)';
raise info '	public.random_china_id(v_city varchar DEFAULT  F , v_street varchar DEFAULT  F , v_date varchar DEFAULT  F , v_three varchar DEFAULT  F , v_check varchar DEFAULT  F )';
raise info '	v_city 		is F(FALSE,NO,N,0) ,  T(TRUE,YES ,Y ,1)  or 3-digits number';
raise info '	v_street 	is F(FALSE,NO,N,0) ,  T(TRUE,YES ,Y ,1)  or 3-digits number';
raise info '	v_date 		is A,B,F,O,R,N or less 8-digit number ';
raise info '	v_three 	is null , R or 3-digit number';
raise info '	v_check 	is F(FALSE,NO,N) ,  T(TRUE,YES ,Y,'''',Null) or  1-digit numeric';
raise info '	ex. select * from public.random_china_id()';
rsult_text:='public.random_china_id(v_city varchar DEFAULT  F , v_street varchar DEFAULT  F , v_date varchar DEFAULT  F , v_three varchar DEFAULT  F , v_check varchar DEFAULT  F )';
return rsult_text;
elsif  'EXCEPTION' in (p_city , p_street,p_date,p_thr,p_check)    then 
       expect_result:='The function produce a exception that it is ordered .' ; 
       RAISE exception '' ;
end if ; 

-- p_city 
-- 如果是false ， 那么内容将是随机数字
expect_result:='p_city model';
case 
	-- 使用的假身份证号都是999开始，这个是默认值
	when p_city ='' or p_city is null then 
	    expect_result:='the p_city is NULL ';
		p_temp_city:='999'; 
	when  p_city in ('F','FALSE' ,'NO','N' ,'0'  ) or p_city is null   then
		expect_result:='the p_city is F ';
		p_temp_city:=substr(abs(hashfloat8(random()))::text,1,3) ;  
	when   p_city in ('T','TRUE','YES' ,'Y' ,'1') then 
		expect_result:='the p_city is T ';
		select id into p_temp_city 
		from (     
			values('110'),('120'),('130'),('140'),('150'),('210'),('220'),('230'),('310')
			     ,('320'),('330'),('340'),('350'),('360'),('370'),('886'),('710'),('410')
			     ,('420'),('430'),('440'),('450'),('460'),('852'),('810'),('853'),('820')
			     ,('510'),('520'),('530'),('540'),('500'),('610'),('620'),('630'),('640'),('650') 
		     )     as t(id) 
	    order by random() 
	    limit 1 ;
	else 
        -- 这里不用判断对传进来的参数进行数字检查，
        -- 而且利用赋值加类型转换进行，
        -- 如果类型转化失败，那么就直接扔出异常结束。
         expect_result:='v_city  have to  F(FALSE,NO,N,0) or  T(TRUE,YES ,Y ,1) ,but ('||p_city||') is not anyone .' ;
	     p_temp_city:=p_city::int;	
end case  ;
rsult_text:=rsult_text||p_temp_city;

--p_street 
-- 如果是false ， 那么内容将是随机数字
expect_result:='p_street model';
case 
	when  p_street in ('F','FALSE' ,'NO','N' ,'0' ,''  ) or p_street is null  then
		expect_result:='p_street is F';
		p_temp_street:=substr(abs(hashfloat8(random()))::text,1,3) ;  
	when   p_street  in ('T','TRUE','YES' ,'Y' ,'1' ) then 
		expect_result:='p_street is T';
		select stt  into p_temp_street  
		from (
			values('100'),('101'),('102'),('105'),('106'),('107'),('108'),('109')
			     ,('111'),('112'),('113'),('114'),('115'),('116'),('117'),('200'),('228')
			     ,('229'),('000'),('103'),('104'),('110'),('221'),('223'),('225'),('121')
		     ) as tp(stt)  
        order by random() limit 1;
	else 
	    -- 这里不用判断对传进来的参数进行数字检查，
        -- 而且利用赋值加类型转换进行，
        -- 如果类型转化失败，那么就直接扔出异常结束。
        expect_result:='v_street is  F(FALSE,NO,N,0) or  T(TRUE,YES ,Y ,1) ,but ('||p_street||') is not anyone .' ;
		p_temp_street:=p_street::int;
end case  ;
rsult_text:=rsult_text||p_temp_street;

--  p_date  
--  如果是A，当前日期向前推20年到70年之间的一个日期。 ctaxi里增加这个校验，司机至少20岁，所以加上这个。并且这个是默认参数
--  如果是B， 那么内容将是可以在未来，可以在过去。
--  如果是F，那么日期将在未来。
--  如果是O，那么日期间在过去。
--  如果是R，那么日期内容将是一个随机内容。
--  如果是N，那么日期内容将是今天。
--  如果是数字，那么日期间是你给予数字开头的，后面的数位是一个随机日期拼接，
--              例如，你给予了198，那么后面的数位将是198x年开始的任意日期（符合格里历）。
--  注意：B,F,O，那么会有上限下限，上下限是：当前日期-999999999秒  到 当前日期+999999999秒
 expect_result:='p_date model';
case 
-- 如果是B， 当前日期随机加减秒数。
	when  p_date in ('B' ,'BOTH','','TRUE','T') or p_date is null  then
		expect_result:='p_date is B';
		p_temp_date:=to_char( current_date +(abs(hashfloat8(random()))-abs(hashtext(random()::text))||' sec' )::interval 
                             ,'yyyymmdd') ;  
-- 如果是F，当前日期增加随机秒数。
    when  p_date  in ('F','FUTURE') then 
    	expect_result:='p_date is F';
	    p_temp_date:=to_char( current_date+(abs(hashfloat8(random()))|| ' sec' )::interval  ,'yyyymmdd') ;
-- 如果是O，当前日期减去随机秒数。
	when  p_date in ('O','OLD')  then
		expect_result:='p_date is O';
		p_temp_date:=to_char( current_date-(abs(hashfloat8(random()))|| ' sec' )::interval  ,'yyyymmdd') ; 
-- 如果是R，随机数hash之后截取前8位，第一位不可能是0，因为第一位如果是0，那么会被数据库的数学理论忽略掉。
	when   p_date  in ('R','RANDOM','FALSE','F') then 
	 	expect_result:='p_date is R';
        p_temp_date:=substr(abs(hashfloat8(random()))::text,1,8 );
-- 如果是N，当前日期
    when   p_date  in ('N','NOW') then  
    	expect_result:='p_date is N';
		p_temp_date:=to_char(current_date,'yyyymmdd') ;
	
-- 如果是A，当前日期向前推20年到70年之间的一个日期，因为ctaxi校验这个东西，所以才加上这个，并且设置这个为默认参数。
    when    p_date  in ('A','AGE') then  
    	expect_result:='p_date is A';
		 select to_char(i,'yyyymmdd') into p_temp_date 
		 from (
		 select generate_series( 
		 date_trunc('year',current_date)-interval '70' year 
		,date_trunc('year',current_date)+interval '1' year -interval '20' year 
		,'1 days ')
			   ) t(i) 
		order by random() 
		limit 1  ;
-- 如果是一个数字，且不是0开头的，进入补全处理流程。
    when p_date ~* '\d'    then 
    
    --用一个sql手法将p_date变量里的内容分解成每一个，然后判断每一个字符是真还是假，
    --再利用一个filter 窗口函数对false筛选，
    --如果有假，会提供拆解字符的位置。
    --如果都为真，那么array_agg 函数将返回null 。 
	select -- rn,i,bol ,
		 array_agg(rn) filter (where bol=false) 
	into p_temp_date 
	from ( 
		select generate_series(1,length(i)) rn  
		     , i 
		     , substring(i,generate_series(1,length(i)),1) ~* '\d{1}'  bol 
		from (values(p_date)) t(i)  
	)t1 ;
-- 如果有假，那么就抛出异常，并且给出是非数字的位置集合。
-- 如果都是真，那么就对内容进行补全。
     if p_temp_date is null  then 
        expect_result:='p_date is numeric';
-- 这里没限定了只能是8位的日期，防止说我随便截断你的内容。
        p_temp_date:=p_date||substring(to_char((current_date +(abs(hashfloat8(random()+random()))||' sec' )::interval),'yyyymmdd'),length(p_date)+1);
    else 
       expect_result:='there is none key word in p_date ('||p_date||') ,its postion at '||p_temp_date||'.' ; 
       RAISE exception '' ;
     end if ;
-- 如果不是以上关键词，那么会对你提供的内容，
-- 如果你提供的内容不是数字，那么会被bigint转换的时候碰到异常。
	else 
	    -- 这里不用判断对传进来的参数进行数字检查，
        -- 而且利用赋值加类型转换进行，
        -- 如果类型转化失败，那么就直接扔出异常结束。
        expect_result:='v_date have to  B,F,O,R,N or any number ,but ('||p_date||') is not anyone .' ;
	    p_temp_date:=p_date::bigint ; 
end case  ;
rsult_text:=rsult_text||p_temp_date;

-- p_thr
-- 如果是null或者R，那么会随机内容
-- 如果是非null，我会直接使用，超过3个字，那么会超出数据类型最大长度，出问题靠后期的异常救场。
expect_result:='p_thr model';
case 
	when  p_thr  in ('R' ,'','TRUE','T','FALSE','F')   or p_thr is null   then 
	    -- 内容结果是随机内容
		expect_result:='p_thr is null';
        p_temp_thr:=substr(abs(hashfloat8(random()))::text,1,3 );
    when   p_thr ~* '\d{3}'  and length(p_thr)=3  then
        -- 对 p_thr 进行3个数字检查 。一但检查失败，那么就会扔出异常。
        expect_result:='p_thr is 3-digit';
        p_temp_thr:= p_thr::int ;
    else 
       expect_result:='v_three have to null , R or 3-digit number ,but ('||p_thr||') is not anyone .' ; 
       RAISE exception '' ;
end case  ;
rsult_text:=rsult_text||p_temp_thr;


-- p_check
--  如果是F，那么出来的只是一个随机内容。
--  如果是T，那么他会真的去计算这个内容 。
--  如果是数字，那么他会用这个数字去填充你的证件号最后一位。
expect_result:='p_check model';
case 
	when  p_check in ('F','FALSE' ,'NO','N') then
		expect_result:='p_check is F';
		select 
		case ahr when  '10' then 'X' 	else ahr  	end 	
		into p_temp_check 
	    from (select (abs(hashfloat8(random()))%11)::text  ) as tmp(ahr); 
	when   p_check  in ('T','TRUE','YES' ,'Y' ,'') or  p_check is null  then 
		-- 身份证只有17位的计算方法，
		-- 所以即使你提供的内容超过了17位，
		-- 这里也只是计算17位长的内容，超过的内容其实是不计算的，但也会在最后显示出来。
		expect_result:='p_check is T';
		select 
		case ( sum(substring(o.id,i,1)::numeric * v) % 11 ) ::text
		when '0'  then '1' 
		when '1'  then '0' 
		when '2'  then 'X' 
		when '3'  then '9' 
		when '4'  then '8' 
		when '5'  then '7' 
		when '6'  then '6' 
		when '7'  then '5' 
		when '8'  then '4' 
		when '9'  then '3' 
		when '10'  then '2' 
		else 'E' end 
	    into p_temp_check
		from ( values( rsult_text ) ) as o(id) 
		cross join (values
		 (1,7)  ,(2,9) ,(3,10),(4,5) ,(5,8) ,(6,4)
		,(7,2)  ,(8,1) ,(9,6) ,(10,3),(11,7),(12,9)
		,(13,10),(14,5),(15,8),(16,4),(17,2) ) as r(i,v) ; 
   when  length(p_check)=1 and p_check ~* '\d{1}' then 
   		-- 检查长度为1，成功就赋值 
   		expect_result:='v_check  is set  True ,and the  program''s result is not 17-digit. 
			        We only have 17-digit calculation methods .' ;
		p_temp_check:=p_check;
   else  
        -- 如果以上内容检查都失败了，那么这就是我不知道的内容了，会抛出异常。
        -- 这里判断对传进来的参数进行数字检查， 
        -- 如果检查成功，那么就直接扔出异常结束。
       expect_result:='v_check have to F(FALSE,NO,N) ,  T(TRUE,YES ,Y,'''',Null) or  1-digit numeric ,but ('||p_check||') is not anyone.'  ;
       RAISE exception '';
end case  ;
rsult_text:=rsult_text||p_temp_check;

-- 对长度进行检查。
if length(rsult_text)<>18 then  
       expect_result:=rsult_text||'('||length(rsult_text)||'-digit) is not equal 17-digit .' ;
       RAISE exception '';
end if ;

-- 程序整个完成
expect_result:='the program is done';
return rsult_text;
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
          RAISE NOTICE 'v_city(p_city):%',p_city;
          RAISE NOTICE 'p_temp_city:%',p_temp_city;
          RAISE NOTICE 'v_street(p_street):%',p_street;
          RAISE NOTICE 'p_temp_street:%',p_temp_street;
          RAISE NOTICE 'v_date(p_date):%',p_date;
          RAISE NOTICE 'p_temp_date:%',p_temp_date;
          RAISE NOTICE 'v_thr(p_thr):%',p_thr;
          RAISE NOTICE 'p_temp_thr:%',p_temp_thr;
          RAISE NOTICE 'v_check(p_check):%',p_check;
          RAISE NOTICE 'p_temp_check:%',p_temp_check;
          RAISE NOTICE 'rsult_text:%',rsult_text;
          RAISE NOTICE 'expect_result:%',expect_result;
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
   select case when expect_result is null then 'this is unknow exception!!!' 
               else expect_result 
           end into expect_result;
    RETURN expect_result;
END;
$function$
;
