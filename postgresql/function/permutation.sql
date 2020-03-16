--select permutation(5)
--drop function permutation(int) 
CREATE or replace FUNCTION permutation(int ) RETURNS bigint AS $$
DECLARE
--max number
   v_number int :=$1;
   --cal
   v_cal bigint :=1;
   --error message 
   p_messtext text ;
BEGIN
--Determine the input parameters
 if v_number =0 then 
   RETURN 1; 
 end if ;

--No negative number
 if v_number < 0 then 
  RAISE EXCEPTION  'Please enter A positive number (%)  ',v_number;
 end if ;
 
   for d in 1 .. v_number  loop
   v_cal:=v_cal*d;
    RAISE NOTICE 'v_cal:%',v_cal;
    end loop;
    
    --output result 
    RETURN v_cal ; 
END;
$$ LANGUAGE plpgsql;
