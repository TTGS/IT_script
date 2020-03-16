create view pg_dba_summary
as 
select 'PostgreSQL启动的时间:' as key_text ,pg_postmaster_start_time()::text as value_text 
union all 
select 'PostgreSQL持续工作:'   ,(CURRENT_TIMESTAMP-pg_postmaster_start_time())::text 
union all 
select 'PostgreSQL最后载入配置文件时间:',pg_conf_load_time()::text
union all 
select 'PostgreSQL版本信息:' ,version()::text
union all 
select '连接的本地地址:',inet_server_addr() ::text
union all 
select '连接的本地端口' , inet_server_port() ::text	 	
union all 
select '当前实例中库有:',array_agg (datname)::text    from pg_catalog.pg_database 
union all 
select '其中用户库有:',array_agg (datname)::text  
from pg_catalog.pg_database where datname not in ('postgres','template1','template0')
union all 
select '当前实例中角色有:',array_agg (rolname)::text  from pg_catalog.pg_roles 
union all 
select '其中非系统角色有:',array_agg (usename)::text  from pg_catalog.pg_user  
union all 
select '数据库内命名空间共计:',array_agg(nspname)::text   
from pg_namespace  
where nspname not  like 'pg_toast%' 
 and  nspname not  like 'pg_temp%' and nspname  not in ('pg_catalog','information_schema')
union all 
select '当前实例表空间有:',array_agg (spcname)::text from pg_catalog.pg_tablespace  
union all 
select '当前实例用户表空间有:',array_agg (spcname)::text 
from pg_catalog.pg_tablespace   where spcname not in ('pg_default','pg_global')  
union all 
select '默认表空间是:',current_setting('wal_level')::text  
union all 
select '默认临时表空间:',current_setting('default_tablespace')::text  
union all 
select 'wal日志级别',current_setting('wal_level')::text  
union all 
select '是否全页写入:',full_page_writes::text  from pg_control_checkpoint()
union all 
select  '最后一次checkpoint时间:', checkpoint_time::text  from pg_control_checkpoint()
union all 
select '写入wal文件名:',redo_wal_file::text  from  pg_control_checkpoint()
union all 
select '数据块大小(k)',(database_block_size/1024)::text   from  pg_control_init() 
union all 
select '数据文件段大小(G)',(blocks_per_segment*database_block_size/1024/1024/1024)::text    from  pg_control_init() 
union all 
select 'wal块大小(k)',(wal_block_size/1024)::text   from  pg_control_init() 
union all 
select 'wal日志段大小(M)',(bytes_per_wal_segment/1024/1024)::text  from  pg_control_init()  
union all 
select '当前对外提供服务IP范围:',  current_setting('listen_addresses')::text 
union all 
select '数据库实例最大连接数:',current_setting('max_connections')::text  
union all 
select   '数据库对象'||case   
            WHEN a.relkind = 'r'::"char" THEN 'ordinary table'::text
            WHEN a.relkind = 'i'::"char" THEN 'index'::text
            WHEN a.relkind = 'S'::"char" THEN 'sequence'::text
            WHEN a.relkind = 't'::"char" THEN 'TOAST table'::text
            WHEN a.relkind = 'v'::"char" THEN 'view'::text
            WHEN a.relkind = 'm'::"char" THEN 'materialized view'::text
            WHEN a.relkind = 'c'::"char" THEN 'composite type'::text
            WHEN a.relkind = 'f'::"char" THEN 'foreign table'::text
            WHEN a.relkind = 'p'::"char" THEN 'partitioned table'::text
            WHEN a.relkind = 'I'::"char" THEN 'partitioned index'::text 
            else A.RELKIND ::TEXT 
          end ||'共计:', count(*)::TEXT  
from pg_catalog.pg_class a 
group by relkind 
union all 
select '数据库扩展共计有:',count(extname )::text from pg_catalog.pg_extension 
union all 
select '最大表有：',pg_size_pretty(max(pg_relation_size(oid)))    from pg_catalog.pg_class where relkind='r'  
union all 
select '最大物化视图有：',pg_size_pretty(max(pg_relation_size(oid)))    from pg_catalog.pg_class where relkind='m'  
union all 
select '最大索引有：',pg_size_pretty(max(pg_relation_size(oid)))    from pg_catalog.pg_class where relkind='i'  
union all 
select '自动回收vacuum是否打开:',  current_setting('autovacuum')::text 
union all 
select '最后一次vacuum时间是:',max(last_vacuum )::text from pg_catalog.pg_stat_all_tables
union all 
select '最后一次analyze时间是:',max(last_analyze )::text  from pg_catalog.pg_stat_all_tables
union all 
select '库中死行(dead tuple)最多有：', (max(n_dead_tup::numeric /(n_dead_tup+n_live_tup)::numeric )*100)::float||'%'    
from pg_stat_all_tables where n_dead_tup>0 or n_live_tup>0

