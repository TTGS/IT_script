CREATE or replace FUNCTION xml_split_mul(
str xml
,begin_xml_node text default null 
,end_xml_node text default null 
)    RETURNS text[]   AS $$
DECLARE
   --char count
   p_xml text:=str::text;
   xn_begin text:=begin_xml_node;
   xn_end  text:=end_xml_node ; 
   arr_save text[]:=null;
begin
-- 检查部分
-- 帮助
if 
position('<' in xn_begin)=0 or 
position('>' in xn_begin)=0  or 
position('</' in xn_end)=0 or 
position('>' in xn_end)=0 
then 
select string_to_array('select xml_split_mul(''<T>1</T><d>2</d><T>3</T>'',''<T>'' );'
,'' ) into arr_save ;
RAISE INFO 'EX. select xml_split_mul(''<T>1</T><d>2</d><T>3</T>'',''<T>'' );' ;
RETURN  arr_save  ;
end if ;

-- 防止结束内容为空；
	if  xn_begin is not  null  and  xn_end is null  then
     xn_end :=replace(xn_begin,'<','</');
	elsif  xn_begin is null  and  xn_end is not  null  then
     xn_begin :=replace(xn_end,'</','<');
	end if ;

-- 先使用string_to_array将内容转成array，然后用unnest变成表，
-- where筛选得到要得行。在显示的id列上，去定位xml的开始节点名
-- 然后截取出来开始节点名+内容，用replace替换掉xml开始节点名
-- 使用array_agg对内容进行合并，出来的是数组
select array_agg( 
replace(
substring( id from
              position( xn_begin in id )  
          ) 
    ,xn_begin,'')    
                ) 
into arr_save
from unnest(string_to_array(p_xml,xn_end)  )  as tmp_tab(id)
where id like '%'||xn_begin||'%';

-- 字符输出内容。
RAISE NOTICE 'arr_save:%',arr_save;

-- 输出arr_save
RETURN  arr_save  ;
exception
    WHEN others THEN
    RAISE NOTICE '==========caught EXCEPTION start(%)==========',now() ;
    RAISE NOTICE 'enter xml text(str):%',str ;
    RAISE NOTICE 'enter xml start node name(begin_xml_node):%',begin_xml_node ;
    RAISE NOTICE 'enter xml end node name(end_xml_node):%',end_xml_node ;
    RAISE NOTICE 'xml text(p_xml):%',p_xml ;
    RAISE NOTICE 'xml start node(xn_begin):%',xn_begin ;
    RAISE NOTICE 'xml end node(xn_end):%',xn_end ;
    RAISE NOTICE 'xml node save arry text(arr_save):%',arr_save ;
    RAISE NOTICE 'ex. select xml_split_mul(''<T>1</T><d>2</d><T>3</T>'',''<T>'' );';
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
    RETURN '!!!EXCEPTION!!!';
END;
$$ LANGUAGE plpgsql;
