有些时候我们需要拼接sql语句，那么这时候我们应该怎么办呢，可以用excute配合using和into进行


格式如下
execute 'select $1+$2'
into 放入的变量名
using 变量1,变量2;


例题
DO $$--DECLARE i record;
declare b int ;
BEGIN
execute 'select $1+$2' 
into b
using 1,2;
raise info '%',b;
END$$;
 
 using是带入的变量，在execute里第一个变量位置使用$1,第二个变量是$2,...依此类推。
 
 如果有需要，那么可以使用into，将结果放入到into后面的变量里。当然我们也可以不写。
 
 
 如果我的表都是这样的呢？
 

create table public.t_2018_05
as select 5 id ;
create table public.t_2018_04
as select 4 id ;

是的，我们需要拼接一个表名字，但是在直接使用变量是不可以的。

但是我们可以在一个字符串中拼接，然后直接执行这个字符串

CREATE OR REPLACE FUNCTION public.test()
 RETURNS  TABLE (id int ) 
 LANGUAGE plpgsql
AS $function$
begin
p_sql:='select id from public.t_'||p_year||'_'||p_month  ; 
RETURN QUERY EXECUTE p_sql; -- 使用这个语句去执行sql内容。
END;
$function$
