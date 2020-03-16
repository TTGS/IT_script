--select combination(9,3)
--drop function combination(int , int ) 
CREATE or replace FUNCTION combination(int , int ) RETURNS bigint AS $$
DECLARE
--max number
   v_bigint int :=$1;
   --min number
   v_littleint int:=$2;
   --molecular
   p_mu bigint :=1;
   --molecular desc 
   p_cal bigint:=1;
   --Denominator 
   p_md bigint :=1;
   --error message 
   p_messtext text ;
BEGIN
--Determine the input parameters
 if v_bigint <v_littleint then 
    RAISE EXCEPTION  'The second number(%) is greater than the frist number(%)',v_littleint,v_bigint;
 end if ;
  
  --Determine the input parameters , it can not zero 
 if v_bigint =0 or v_littleint=0 then 
    RETURN 1; 
 end if ;
 
 --No negative number
 if v_bigint < 0 or v_littleint < 0  then 
  RAISE EXCEPTION  'No negative number (%,%)  ',v_bigint,v_littleint;
 end if ;
 
    --desc cal    
    p_cal:=v_bigint;
    --Calculate molecules
    for i in 1 .. v_littleint   loop
    p_mu:=p_cal*p_mu;
    p_cal:=p_cal-1;
    RAISE  NOTICE 'p_mu:%',p_mu;
    end loop;
    
    --Calculate Denominator
    for d in 1 .. v_littleint loop
    p_md:=d*p_md;
    RAISE NOTICE 'p_md:%',p_md;
    end loop;
    
    --output result 
    RETURN p_mu/p_md; 

END;
$$ LANGUAGE plpgsql;
