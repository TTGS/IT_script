
格式： DO [ LANGUAGE lang_name ] code

默认是使用 plpgsql语言，可以不写，如果有对应的扩展编译也可以使用。
DO  LANGUAGE plpgsql
$$
begin 
	 raise  notice  '%',current_date;
end $$ 


--可以使用raise ， 但是不能直接使用return 
do $$
declare i int :=1 ;
begin 
	for j in 1 .. 3
	loop  
	raise  notice  '%',j ;
    end loop; 
   return  i||'abc'
end $$;

-- 在存储过程中可以使用的也可以在这里使用的。
DO $$ 
declare b int ;
BEGIN
execute 'select $1+$2' 
into b
using 1,2;
raise info '%',b;
END$$;


-- 如果想声明多个变量可以在do后面的code中写delare 的变量。
例如： 
r 后面跟着j变量，中间只要 “；” 就行， 后面k变量可以直接赋值进去
当然你再写一个declare 然后声明h变量也是没有问题的。
DO $$
DECLARE r int ; j int ;k int:=1;
declare h int ;
BEGIN
    FOR r IN SELECT generate_series(1,3)
    loop
       j:=r;
       r:=r+j;
    END LOOP;
    raise info '%,%,%,%',r,j,k,h  ;
END$$;
