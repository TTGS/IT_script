CREATE or replace FUNCTION feild_count(str text, der text) RETURNS int AS $$
DECLARE
   --char count
   p_count int:=0;
   --error message 
   p_messtext text ;
   p_messtext_detail text ;
   p_messtext_hint text ;
BEGIN
select (length(str)-length(replace(str,der,'')) )into p_count;
RETURN  p_count  ;
    EXCEPTION
    WHEN others THEN
    RAISE NOTICE 'caught EXCEPTION ';
    RETURN null;
END;
$$ LANGUAGE plpgsql;
