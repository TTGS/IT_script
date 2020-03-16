create view pg_dba_view
as 
select 
pg_get_userbyid(a.relowner) AS view_owner
,n.nspname AS view_schema
,a.relname as view_name 
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
end  as view_type 
,pg_size_pretty(pg_relation_size(a.oid))  view_size
,case 
		when relkind='v' then  v.definition 
		when relkind='m'  then vv.definition  
		else 'error~~~'
end  as view_definition 
,CASE
     WHEN vv."tablespace" IS NULL THEN ( SELECT a_1.spcname
           FROM pg_tablespace a_1
           JOIN pg_database b_1 ON b_1.dattablespace = a_1.oid
     WHERE b_1.datname = current_database())
     ELSE vv."tablespace"
end as view_tablespace 
from pg_class a 
LEFT JOIN pg_namespace n ON n.oid = a.relnamespace 
left join pg_views v on a.relname=v.viewname  and n.nspname=v.schemaname 
left join pg_matviews vv on a.relname=vv.matviewname   and n.nspname=vv.schemaname 
where a.relkind  in ('m','v' )
