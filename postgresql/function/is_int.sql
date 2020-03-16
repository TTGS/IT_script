--select is_int(0.95)
--drop function is_int(decimal ) 
CREATE or replace FUNCTION is_int(decimal ) RETURNS boolean  AS $$
declare
--orgin
   v_org decimal :=$1;
--number
   v_number bigint  ;
--percent
   v_decimal decimal  ;
begin
	
--Split int and decimal 
select   trunc(v_org) ,(v_org)-trunc(v_org)  
     into v_number    , v_decimal ;
 
if v_decimal =0 then 
   RETURN 't' ; 
end if ;

return 'f';
    EXCEPTION
        WHEN others THEN
            RAISE NOTICE 'caught EXCEPTION ';
            RETURN null;

END;
$$ LANGUAGE plpgsql;
