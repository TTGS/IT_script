
create view pg_dba_extent_table 
as 
select   cl.relname fdw_object_name ,dw.fdwname   fdw_name
,   CASE
            WHEN cl.relkind = 'r'::"char" THEN 'ordinary table   '::text
            WHEN cl.relkind = 'i'::"char" THEN 'index            '::text
            WHEN cl.relkind = 'S'::"char" THEN 'sequence         '::text
            WHEN cl.relkind = 't'::"char" THEN 'TOAST table      '::text
            WHEN cl.relkind = 'v'::"char" THEN 'view             '::text
            WHEN cl.relkind = 'm'::"char" THEN 'materialized view'::text
            WHEN cl.relkind = 'c'::"char" THEN 'composite type   '::text
            WHEN cl.relkind = 'f'::"char" THEN 'foreign table    '::text
            WHEN cl.relkind = 'p'::"char" THEN 'partitioned table'::text
            WHEN cl.relkind = 'I'::"char" THEN 'partitioned index'::text
            ELSE NULL::text
    end  as  fdw_object_type
,  s.srvname server_name  
,  s.srvoptions  server_info 
,  tb.ftoptions    mapping_table_name
,  cl.relacl     fdw_object_auth 
,  s.srvacl server_auth 
,  dw.fdwacl  fdw_auth
from pg_catalog.pg_foreign_table tb 
left join  pg_catalog.pg_foreign_server  s on tb.ftserver=s.oid
left join pg_catalog.pg_foreign_data_wrapper dw on s.srvfdw = dw.oid 
left join pg_catalog.pg_class  cl on tb.ftrelid =cl.oid 
