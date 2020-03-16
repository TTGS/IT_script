pl/pgsql的数据类型和sql建立表的时候使用的数据类型一样。
以下列举了部分常用类型，
这里值得注意的是char如果不写长度默认长度是1，而varchar不写长度默认是最长长度，
依然可以使用pg_typeof 函数查询该变量的数据类型。

DO $$
DECLARE  i int:=1;
c char(3):='123';
v varchar:='123456';
t text:='12345';
b boolean :=true ; 
BEGIN
 
raise  info 'i:%',i;
raise  info 'c:%',c;
raise  info 'v:%',v;
raise  info 't:%',t;
raise  info 'b:%',b; 
raise  info 'pg_typeof :%',pg_typeof(b); 
 
end
$$;
 
