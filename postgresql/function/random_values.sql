--drop function random_values(str text, der text) 
--select random_values('a,d,e,d,e,gew,ds,a,',',')
CREATE or replace FUNCTION random_values(str text, der text) RETURNS text AS $$
DECLARE
--array
  p_arr text[]:=null;
--return
p_ret text:=null;
--error message 
   p_messtext text ;
   p_messtext_detail text ;
   p_messtext_hint text ;
BEGIN 
--text convert array
select string_to_array(str,der) into p_arr ;

--random 
select  d into p_ret 
from  unnest(p_arr ) as d 
order by random()
limit 1 ;
--return result
RETURN  p_ret  ;
    EXCEPTION
    WHEN others THEN
    RAISE NOTICE 'caught EXCEPTION ';
    RETURN null;
END;
$$ LANGUAGE plpgsql;

