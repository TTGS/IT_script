create view pg_dba_function
as 
select  rl.rolname as "proc_owner"
, np.nspname   as "proc_schema"
, proname as "proc_name"
, lge.lanname   as "proc_lanuage"
, pc.probin as "proc_binary"
,pg_get_functiondef(pc.oid)  as "proc_scritpe"
from pg_catalog.pg_proc pc  
left join pg_catalog.pg_namespace  np  on  pc.pronamespace =np.oid
left join pg_catalog.pg_roles  rl on pc.proowner =rl.oid 
left join pg_catalog.pg_language  lge on pc.prolang=lge.oid  
