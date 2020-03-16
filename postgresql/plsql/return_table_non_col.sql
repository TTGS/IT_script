
--原始，需要在执行后面写列和类型的方式。
DROP FUNCTION found_oid(oid);
 CREATE OR REPLACE FUNCTION  found_oid(oid) 
 RETURNS SETOF RECORD as
$$
BEGIN
   return query select relname::text , relkind::text from pg_class where oid=$1;
END;
$$
LANGUAGE PLPGSQL;
select * from  found_oid(16698) as t(rel text , rk text) ;
 

--可以在函数上直接声明一个临时表内容，这样执行的时候就不用写列名和列类型了。
DROP FUNCTION found_oid(oid);
CREATE OR REPLACE FUNCTION found_oid (oid) 
 RETURNS TABLE (
     re1 text ,
     object_type text
) 
AS $$
BEGIN
 RETURN QUERY 
 select  relname::text ,relkind::text from pg_class where oid=$1;
END; $$ 
LANGUAGE 'plpgsql';
select * from  found_oid(16698);


---在返回的returns里的table列名和返回的select里的列名不能重复，虽然编译可以通过，但是在使用的时候会报错，说该列不是唯一的。
CREATE OR REPLACE FUNCTION found_oid_err (oid) 
 RETURNS TABLE (
     relname text ,
     relkind  text
) 
AS $$
BEGIN
 RETURN QUERY 
 select  relname::text relname,relkind::text  relkind from pg_class where oid=$1;
END; $$ 
LANGUAGE 'plpgsql';
select * from found_oid_err(16698);


SQL 错误 [42702]: ERROR: column reference "relname" is ambiguous
  Detail: It could refer to either a PL/pgSQL variable or a table column.
  Where: PL/pgSQL function found_oid_err(oid) line 3 at RETURN QUERY
  
  解决方案就是改名，如果名字不一样就可以了。
