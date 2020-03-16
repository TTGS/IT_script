有时候我们发现我们将一些内容封装到函数中会比封装到哪里都好使。

例如我们可以将一个sql直接封装到函数里，例如
CREATE OR REPLACE FUNCTION gen_ser()
RETURNS SETOF int  
AS
$$
    SELECT generate_series(1,3) id ;  
$$
LANGUAGE 'sql' STABLE;

select gen_ser();

gen_ser 
--------
1       
2       
3    

我们也可以将变化的内容写进去。
CREATE OR REPLACE FUNCTION pg_oid(o  oid )
RETURNS SETOF pg_class
AS
$$
    SELECT oid,* FROM pg_class where oid = $1;
$$
LANGUAGE 'sql' STABLE;
