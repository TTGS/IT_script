CREATE OR REPLACE FUNCTION public.any_key_sfunc( numeric ,  anyelement, anyelement )
 RETURNS numeric 
 LANGUAGE sql
 IMMUTABLE
AS $function$
    SELECT  $1+i from (select case when  $2=$3 then 1 else 0 end ) t(i) ;  
$function$ ;

-- 聚集函数，需要上面的运算函数的支持。
CREATE AGGREGATE  any_key( anyelement, anyelement   )(
    SFUNC=any_key_sfunc ,
    STYPE=numeric,
    iNITCOND= 0
);




-- 测试
SELECT 
sum(case when e =true  then 1 else 0 end )::numeric  --等价这个列算法。
,any_key(e  ,true  )  
from (values(true) ,(true ),(false) ,(true) ,(true ),(false)  ) t(e )  ;


