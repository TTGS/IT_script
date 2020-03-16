
create view pg_dba_comment
as 
select  relname  comment_name
,CASE
            WHEN a.relkind = 'r'::"char" THEN 'ordinary table   '::text
            WHEN a.relkind = 'i'::"char" THEN 'index            '::text
            WHEN a.relkind = 'S'::"char" THEN 'sequence         '::text
            WHEN a.relkind = 't'::"char" THEN 'TOAST table      '::text
            WHEN a.relkind = 'v'::"char" THEN 'view             '::text
            WHEN a.relkind = 'm'::"char" THEN 'materialized view'::text
            WHEN a.relkind = 'c'::"char" THEN 'composite type   '::text
            WHEN a.relkind = 'f'::"char" THEN 'foreign table    '::text
            WHEN a.relkind = 'p'::"char" THEN 'partitioned table'::text
            WHEN a.relkind = 'I'::"char" THEN 'partitioned index'::text
            ELSE NULL::text
        END AS comment_type ,obj_description( oid, 'pg_class')  as comment_text from pg_class a 
union all 
select  datname, 'database', pg_catalog.shobj_description(oid, 'pg_database')    from pg_database 
union all 
select spcname,'tablespace', shobj_description(oid, 'pg_tablespace')  from pg_tablespace 
union all 
SELECT e.extname ,'extent',  c.description 
FROM pg_catalog.pg_extension e 
LEFT JOIN pg_catalog.pg_description c ON c.objoid = e.oid AND c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass
union all
SELECT r.rolname,'user/role'
, pg_catalog.shobj_description(r.oid, 'pg_authid') AS description
FROM pg_catalog.pg_roles r 
union all 
SELECT proname  ,
  'function/produrce' ,
  pg_catalog.obj_description( oid, 'pg_proc')
FROM pg_catalog.pg_proc

order by comment_type 
