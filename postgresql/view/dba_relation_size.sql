create view pg_dba_relation_size
as 
select 
 d.rolname  user_name
,c.nspname  schema_name
,pg_size_pretty(sum(pg_relation_size(a.oid))) relation_total 
from pg_catalog.pg_class a  
join pg_catalog.pg_namespace  c on a.relnamespace=c.oid 
join pg_catalog.pg_roles d on a.relowner=d."oid" 
group by  d.rolname  ,c.nspname   
order by user_name,schema_name ;
