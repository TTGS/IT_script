CREATE or replace FUNCTION xml_split(str xml, begin_xml_node text
, end_xml_node text default null
) RETURNS text AS $$
DECLARE
   --char count
   p_xml text:=str::text;
   p_call text:=null;
   xn_begin text:=begin_xml_node;
   xn_end  text:=end_xml_node ; 
   xnb_po int:=0;
   xne_po int:=0;
   xn_len int:=0;
   xnb_len int:= length(xn_begin);
   --error message 
   p_messtext text ;
   p_messtext_detail text ;
   p_messtext_hint text ;
begin
-- 防止结束内容为空；
	if xn_end is null then 
     xn_end :=replace(xn_begin,'<','</');
	end if ;
-- 计算关键点位置和长度
-- 开始截取点
 select  position(xn_begin in  p_xml  ) into  xnb_po+xnb_len   ;
-- 计算结束点
 select  position(xn_end in  p_xml  ) into  xne_po  ;
-- 计算开始和结束点的长度
-- 这里是0或者负的都是问题。
 select  xne_po-xnb_po into  xn_len ;

-- 截取，为了保证截取顺利，我没有使用正则表达式
 select substring(p_xml from xnb_po for xn_len) into p_call;
RETURN  p_call  ;
    EXCEPTION
    WHEN others THEN
    RAISE NOTICE '==========caught EXCEPTION start(%)==========',now() ;
    RAISE NOTICE 'xml text(p_xml):%',p_xml ;
    RAISE NOTICE 'text return(p_call):%',p_call ;
    RAISE NOTICE 'xml start node(xn_begin):%',xn_begin ;
    RAISE NOTICE 'xml end node(xn_end):%',xn_end ;
    RAISE NOTICE 'xml node start postion(xnb_po):%',xnb_po ;
    RAISE NOTICE 'xml node end postion(xne_po):%',xne_po ;
    RAISE NOTICE 'xml node start to end  length(xn_len):%',xn_len ;
    RAISE NOTICE 'xml node end of start postion length(xnb_len):%',xnb_len;
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
    RETURN '!!!EXCEPTION!!!';
END;
$$ LANGUAGE plpgsql;
