create view pg_dba_object
as 
select relname  object_name
,case 
when relkind='r' then  'ordinary table   '
when relkind='i' then  'index            '
when relkind='S' then  'sequence         '
when relkind='t' then  'TOAST table      '
when relkind='v' then  'view             '
when relkind='m' then  'materialized view'
when relkind='c' then  'composite type   '
when relkind='f' then  'foreign table    '
when relkind='p' then  'partitioned table'
when relkind='I' then  'partitioned index'
end  object_type
,case 
	when b.spcname is null  then (select spcname from pg_catalog.pg_tablespace  a join pg_catalog.pg_database  b on b.dattablespace=a.oid where b.datname =current_database () )
	else  b.spcname 
end  object_segment
, c.nspname  object_schema
,d.rolname  object_owner
,a.reltuples  object_tuple
,a.relpages object_page
,a.relnatts object_column
,pg_size_pretty(pg_relation_size(a.oid)) object_size 
from pg_catalog.pg_class a left join pg_catalog.pg_tablespace  b on a.reltablespace=b.oid
left join pg_catalog.pg_namespace  c on a.relnamespace=c.oid 
left join pg_catalog.pg_roles d on a.relowner=d."oid" 
