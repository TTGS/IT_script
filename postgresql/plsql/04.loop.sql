循环一共有3种，
1,loop ,可以一直循环，直到触发内部循环退出条件
2,while，发现符合就执行循环，不管多少次
3,for ，指定次数或者结果集，循环一遍后，结束。


--loop
DO $$
DECLARE  k int:=1;
BEGIN
loop 
raise  info '%',k;
k:=k+1;
exit when k>3;
end loop;
end
$$;



-- while 
DO $$
DECLARE  k int:=1;
BEGIN
    while k<=3
    loop
    raise  info '%',k;
    k:=k+1;
    end loop ;  
END$$;


--for 
DO $$
DECLARE  k int:=1;
BEGIN
    FOR k IN SELECT generate_series(1,3)
    loop
     raise info '%',k  ;
    END LOOP;
END$$;

 
