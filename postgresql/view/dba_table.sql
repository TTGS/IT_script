create view  pg_dba_table
as 
select 
pg_get_userbyid(a.relowner) AS table_owner
,n.nspname AS table_schema
,a.relname as table_name 
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
end  as table_type
,a.relrowsecurity AS table_row_security
 ,case 
	when t.spcname is null  then (select spcname from pg_catalog.pg_tablespace  a join pg_catalog.pg_database  b on b.dattablespace=a.oid where b.datname =current_database () )
	else  t.spcname 
end  as   table_tablespace
,pg_size_pretty(pg_relation_size(a.oid)) as table_size 
,(select count(*) from pg_catalog.pg_index  where indrelid=a.oid) as table_index_count
,b.n_live_tup as table_live_row
,b.n_dead_tup as table_dead_row
,case when last_vacuum>=last_autovacuum then last_vacuum else last_autovacuum end as table_last_vacuum_timestamp
,case when last_analyze>=last_autoanalyze then last_analyze else last_autoanalyze end as table_last_analyze_timestamp
, vacuum_count+ autovacuum_count as table_vacuum_count
, analyze_count+ autoanalyze_count as table_analyze_count
,b.n_tup_ins as table_insert_count
,b.n_tup_del as table_delete_count
,b.n_tup_upd as table_update_count
,b.seq_scan as table_seq_scan 
,b.seq_tup_read as table_seq_live_scan
,b.idx_scan as table_index_scan
,b.idx_tup_fetch as  table_index_live_fetch
,c.heap_blks_read  as table_read_disk_block
,c.heap_blks_hit  as table_read_cache_block
,c.idx_blks_read  as table_index_read_disk_block
,c.idx_blks_hit  as table_index_read_cache_block
from pg_class a 
LEFT JOIN pg_namespace n ON n.oid = a.relnamespace
LEFT JOIN pg_tablespace t ON t.oid = a.reltablespace
left join pg_stat_all_tables b on b.relid=a.oid 
left join pg_statio_all_tables c on c.relid =a.oid 
where a.relkind  in ('r','f','p','t')
