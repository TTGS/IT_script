

CREATE or replace FUNCTION postgres_check_report()    
returns void   AS $$
DECLARE
-- 我自己的参数
v_setp varchar :=null ;
v_begin_timestamp timestamp:=clock_timestamp();
v_c_user varchar:=current_user;
v_c_database varchar:=current_database();
v_c_saddr varchar:=inet_server_addr();
v_c_sport varchar:=inet_server_port(); 
v_tmp_1 varchar:=null;
v_tmp_2 varchar:=null;
v_tmp_3 varchar:=null;
v_tmp_4 varchar:=null;
v_tmp_5 varchar:=null;
v_tmp_6 varchar:=null;
 i RECORD;
-- 系统异常捕获
sys_RETURNED_SQLSTATE		text:=null;
sys_COLUMN_NAME				text:=null;
sys_CONSTRAINT_NAME			text:=null;
sys_PG_DATATYPE_NAME		text:=null;
sys_MESSAGE_TEXT			text:=null;
sys_TABLE_NAME				text:=null;
sys_SCHEMA_NAME				text:=null;
sys_PG_EXCEPTION_DETAIL		text:=null;
sys_PG_EXCEPTION_HINT		text:=null;
sys_PG_EXCEPTION_CONTEXT	text:=null;
begin
-- begin report 
select current_timestamp into v_begin_timestamp;
raise info '========= 程序开始：当前时间为：% =========',v_begin_timestamp;


--当前ip和端口检查。
raise info '连接 PostgreSQL 服务器 IP 地址为：% , 端口号为：%',v_c_saddr,v_c_sport;

--版本
raise info 'PostgreSQL版本为： %',version();

--当前用户和 当前数据库检查
select 
    case when rolsuper='false' then '不是超级用户' when rolsuper='true' then '是超级用户' else null  end 
into  v_tmp_1 
from pg_catalog.pg_roles where rolname=current_user;

raise info '启动程序的用户为：% ，该用户%',current_user,v_tmp_1;
raise info '检查数据库为：%',v_c_database;

--启动时间 和 总启动时间长度。
raise info 'PostgreSQL服务器端数据库从：%，总共经历了：%',pg_postmaster_start_time(),clock_timestamp()-pg_postmaster_start_time();
select 
case when pg_postmaster_start_time()-pg_conf_load_time()<'00:00:01'::interval 
     then '启动数据库时间与读取配置时间一致，配置文件没有被修改过。'
     when pg_postmaster_start_time()-pg_conf_load_time()>='00:00:01'::interval 
     then '启动数据库时间与读取配置时间相差  '||(pg_postmaster_start_time()-pg_conf_load_time())::varchar||' ，值得注意!!!'
else null 
end  into v_tmp_1;
raise info 'PostgreSQL服务器端数据库配置文件最后读取时间为：% ',pg_conf_load_time() ;
raise info '% ',v_tmp_1;

raise info '';
raise info '>>>数据库基本情况概述<<<' ;
-- 数据库基本情况介绍
select 
datname 
,pg_get_userbyid(datdba)  datdba
,pg_encoding_to_char(encoding) 
,(select  spcname from pg_catalog.pg_tablespace  where oid=dattablespace) dattablespace
,pg_tablespace_location(dattablespace)
,pg_size_pretty(pg_database_size(oid))
into v_tmp_1,v_tmp_2,v_tmp_3,v_tmp_4,v_tmp_5,v_tmp_6
from pg_catalog.pg_database
where datname=current_database();

raise info '数据库名： ...................... %',v_tmp_1;
raise info '创建用户： ...................... %',v_tmp_2;
raise info '默认字符集：..................... %',v_tmp_3;
raise info '默认表空间：..................... %',v_tmp_4;
raise info '默认表空间路径：.................. %',v_tmp_5;
raise info '数据库容量：..................... %',v_tmp_6;


FOR i IN select stats_reset ,xact_commit,xact_rollback,blks_read,blks_hit 
,temp_files	 ,temp_bytes,deadlocks,tup_returned ,tup_fetched ,tup_inserted 
,tup_updated ,tup_deleted
         from pg_stat_database  where datname=current_database() 
LOOP
     raise info '...............在 % 开始计录',i.stats_reset ;
     raise info '...............提交 % 次',i.xact_commit ;
     raise info '...............回滚 % 次',i.xact_rollback ;
     raise info '...............从磁盘读取块共计  % 个块',i.blks_read ;
     raise info '...............从 PG 的缓冲区里命中 % 次',i.blks_hit ;
     raise info '...............曾经为了该库创建了 % 个临时文件',i.temp_files ;
     raise info '...............曾经创建的临时文件共计 % G ( % bytes)',i.temp_bytes/1024/1024/1204 ,i.temp_bytes;
     raise info '...............查询返回 % 行数据',i.tup_returned;
     raise info '...............循环读取 % 次',i.tup_fetched;
     raise info '...............插入 % 行',i.tup_inserted;
     raise info '...............更新 % 行',i.tup_updated;
     raise info '...............删除 % 行',i.tup_deleted;
     raise info '...............被记录到的锁死共计 % 次',i.deadlocks;
END LOOP;
   
   
raise info '';
raise info '>>>数据库扩展插件概述<<<' ;
raise info '数据库 % 下扩展插件有：',v_c_database;
for i in  select b.nspname , a.extname , a.extversion  
from pg_catalog.pg_extension a join pg_catalog.pg_namespace b 
on a.extnamespace=b.oid 
loop 
raise info '...............在schema % 下的插件%（版本为:%）',i.nspname,i.extname,i.extversion;
end loop;

raise info '';
raise info '>>>数据库对象概述<<<' ;
raise info '数据库 % 下对象有：',v_c_database;
for i in  select table_schema,table_type,count(*) cc 
from information_schema.tables 
where table_catalog=current_database() 
and table_schema not in ('pg_catalog','information_schema')
group by  table_schema,table_type 
order by 1,2
loop 
raise info '...............在schema % 下有 % 共计 % 张',i.table_schema,i.table_type,i.cc ;
end loop;

raise info '';
raise info '>>>数据库储存情况概述<<<' ;
raise info '数据库 % ，使用了如下表空间：',v_c_database;
for i in  select spcname,pd ,tsize from  pg_catalog.pg_database  a
join (select pg_tablespace_databases(oid) toid ,pg_tablespace_location(oid) pd ,spcname 
,pg_size_pretty(pg_tablespace_size(oid)) tsize
from  pg_catalog.pg_tablespace tt where exists 
		(select 1 from pg_catalog.pg_database dd 
		where dd.dattablespace=tt.oid and dd.datname=current_database())
) b on a.oid=toid 
where a.datname=current_database() 
loop 
raise info '...............%表空间路径为： %(%)',i.spcname,i.pd,i.tsize;
end loop;

raise info '';
raise info '数据库 %,容量 top 10',v_c_database;
for i in  SELECT  
    nc.nspname::sql_identifier AS rel_schema,
    c.relname::sql_identifier AS rel_name,
        CASE
            WHEN nc.oid = pg_my_temp_schema() THEN 'LOCAL TEMPORARY'::text
            WHEN c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"]) THEN 'BASE TABLE'::text
            WHEN c.relkind = 'v'::"char" THEN 'VIEW'::text
            WHEN c.relkind = 'f'::"char" THEN 'FOREIGN TABLE'::text
            ELSE NULL::text
        END::character_data AS rel_type
        ,pg_size_pretty(pg_relation_size(c.oid)) rel_size 
   FROM pg_namespace nc
     JOIN pg_class c ON nc.oid = c.relnamespace
     LEFT JOIN (pg_type t
     JOIN pg_namespace nt ON t.typnamespace = nt.oid) ON c.reloftype = t.oid
  WHERE (c.relkind = ANY (ARRAY['r'::"char", 'v'::"char", 'f'::"char", 'p'::"char"])) 
    AND NOT pg_is_other_temp_schema(nc.oid) AND (
        pg_has_role(c.relowner, 'USAGE'::text) 
     OR has_table_privilege(c.oid, 'SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER'::text) 
     OR has_any_column_privilege(c.oid, 'SELECT, INSERT, UPDATE, REFERENCES'::text)
     ) and pg_relation_size(c.oid) >8192
order by  pg_relation_size(c.oid)   desc  limit 10 
loop 
raise info '...............%.% 类型：% > > %',i.rel_schema,i.rel_name,i.rel_type,i.rel_size;

end loop;




raise info '';
raise info '数据库 % ,非系统schema,容量 top 10',v_c_database;
for i in  SELECT  
    nc.nspname::sql_identifier AS rel_schema,
    c.relname::sql_identifier AS rel_name,
        CASE
            WHEN nc.oid = pg_my_temp_schema() THEN 'LOCAL TEMPORARY'::text
            WHEN c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"]) THEN 'BASE TABLE'::text
            WHEN c.relkind = 'v'::"char" THEN 'VIEW'::text
            WHEN c.relkind = 'f'::"char" THEN 'FOREIGN TABLE'::text
            ELSE NULL::text
        END::character_data AS rel_type
        ,pg_size_pretty(pg_relation_size(c.oid)) rel_size 
   FROM pg_namespace nc
     JOIN pg_class c ON nc.oid = c.relnamespace
     LEFT JOIN (pg_type t
     JOIN pg_namespace nt ON t.typnamespace = nt.oid) ON c.reloftype = t.oid
  WHERE (c.relkind = ANY (ARRAY['r'::"char", 'v'::"char", 'f'::"char", 'p'::"char"])) 
    AND NOT pg_is_other_temp_schema(nc.oid) AND (
        pg_has_role(c.relowner, 'USAGE'::text) 
     OR has_table_privilege(c.oid, 'SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER'::text) 
     OR has_any_column_privilege(c.oid, 'SELECT, INSERT, UPDATE, REFERENCES'::text)
     ) and pg_relation_size(c.oid) >8192 
     and  nc.nspname not in ('information_schema','pg_catalog')
order by  pg_relation_size(c.oid)   desc  limit 10 
loop 
raise info '...............%.% 类型：% > > %',i.rel_schema,i.rel_name,i.rel_type,i.rel_size;

end loop;

raise info '';
raise info '数据库 % 下用户对象中有死行表top10为：',v_c_database;
for i in  select n_dead_tup,schemaname,relname,relid 
from pg_catalog.pg_stat_user_tables 
where n_dead_tup>0
order by n_dead_tup desc limit 10 
loop 
raise info '...............在schema % 下有 %（oid:%） 共计死行(dead tuple) % 行',i.schemaname,i.relname,i.relid,i.n_dead_tup ;
end loop;


raise info '';
raise info '数据库 % 下用户对象中 插入top10：',v_c_database;
for i in  select  schemaname,relname,relid ,n_tup_ins
from pg_catalog.pg_stat_user_tables 
where n_tup_ins>0
order by n_tup_ins desc  limit 10 
loop 
raise info '...............在schema % 下有 %（oid:%） 共计插入语句插入  % 行',i.schemaname,i.relname,i.relid,i.n_tup_ins ;
end loop;





raise info '';
raise info '数据库 % 下用户对象中 删除 top10：',v_c_database;
for i in  select  schemaname,relname,relid ,n_tup_del
from pg_catalog.pg_stat_user_tables 
where n_tup_del>0
order by n_tup_del desc  limit 10  
loop 
raise info '...............在schema % 下有 %（oid:%） 共计插入语句删除  % 行',i.schemaname,i.relname,i.relid,i.n_tup_del ;
end loop;
 


raise info '';
raise info '数据库 % 下I/O top10：',v_c_database;
raise info '>>>表I/O top10：';
    FOR i IN select relid,schemaname,relname,heap_blks_read,heap_blks_hit
               from pg_catalog.pg_statio_user_tables
               where heap_blks_read>0 or heap_blks_read is not null 
               order by heap_blks_read desc limit 10
    LOOP
         raise info '...............在 schema  % 中 %（oid:% ） 磁盘读共计  % 个块，缓存命中 % 个块',i.schemaname,i.relname,i.relid,i.heap_blks_read,i.heap_blks_hit ;
    END LOOP;
raise info '>>>索引I/O top10：';
    FOR i IN select relid,schemaname,relname,idx_blks_hit,idx_blks_read
               from pg_catalog.pg_statio_user_tables  
               where idx_blks_hit is not null or idx_blks_hit >0 
               order by idx_blks_hit desc limit 10
    LOOP
         raise info '...............在 schema  % 中 %（oid:% ）上的索引 引发的磁盘读共计  % 个块，缓存命中 % 个块',i.schemaname,i.relname,i.relid,i.idx_blks_read,i.idx_blks_hit ;
    END LOOP;
   
   
 -- perform   pg_sleep(1);
	
raise info '=============== 程序结束：总共经历 % ===============', (clock_timestamp()-v_begin_timestamp) ;
--return ;
exception
    WHEN others then
    GET STACKED DIAGNOSTICS 
		sys_RETURNED_SQLSTATE	=RETURNED_SQLSTATE	,
		sys_COLUMN_NAME			=COLUMN_NAME	,
		sys_CONSTRAINT_NAME		=CONSTRAINT_NAME,
		sys_PG_DATATYPE_NAME	=PG_DATATYPE_NAME,
		sys_MESSAGE_TEXT		=MESSAGE_TEXT	,
		sys_TABLE_NAME			=TABLE_NAME		,
		sys_SCHEMA_NAME			=SCHEMA_NAME		,
		sys_PG_EXCEPTION_DETAIL	=PG_EXCEPTION_DETAIL,
		sys_PG_EXCEPTION_HINT   =PG_EXCEPTION_HINT,
		sys_PG_EXCEPTION_CONTEXT=PG_EXCEPTION_CONTEXT;
    RAISE NOTICE '==========caught EXCEPTION start(%)==========',now() ;
    RAISE NOTICE '========== SYS exception ==========';
		RAISE NOTICE 'sys_RETURNED_SQLSTATE:%',  sys_RETURNED_SQLSTATE;	
		RAISE NOTICE 'sys_COLUMN_NAME:%',  sys_COLUMN_NAME		;	
		RAISE NOTICE 'sys_CONSTRAINT_NAME:%',  sys_CONSTRAINT_NAME	;	
		RAISE NOTICE 'sys_PG_DATATYPE_NAME:%',  sys_PG_DATATYPE_NAME	;
		RAISE NOTICE 'sys_MESSAGE_TEXT:%',  sys_MESSAGE_TEXT	;	
		RAISE NOTICE 'sys_TABLE_NAME:%',  sys_TABLE_NAME	;		
		RAISE NOTICE 'sys_SCHEMA_NAME:%',  sys_SCHEMA_NAME	;		
		RAISE NOTICE 'sys_PG_EXCEPTION_DETAIL:%',  sys_PG_EXCEPTION_DETAIL	;
		RAISE NOTICE 'sys_PG_EXCEPTION_HINT:%',  sys_PG_EXCEPTION_HINT	;
		RAISE NOTICE 'sys_PG_EXCEPTION_CONTEXT:%',  sys_PG_EXCEPTION_CONTEXT;
   RAISE NOTICE '========== my exception ==========';
       RAISE NOTICE 'v_setp:%',v_setp;
       RAISE NOTICE 'v_begin_timestamp:%',v_begin_timestamp;
       RAISE NOTICE 'v_c_user:%',v_c_user;
       RAISE NOTICE 'v_c_database:%',v_c_database;
       RAISE NOTICE 'v_c_saddr:%',v_c_saddr;
       RAISE NOTICE 'v_c_sport:%',v_c_sport; 
       RAISE NOTICE 'v_tmp_1:%',v_tmp_1;
       RAISE NOTICE 'v_tmp_2:%',v_tmp_2;
    RAISE NOTICE '==========caught EXCEPTION end ===============' ;
END;
$$ LANGUAGE plpgsql ;

--select postgres_check_report();
