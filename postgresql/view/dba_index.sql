/*
这个是从pg_indexes修改过来的内容，不能说这是我的原创，只能说是二次开发或者二次编写。
*/
CREATE OR REPLACE VIEW  pg_dba_index
AS 
SELECT 
    n.nspname AS index_schema_name,
    c.relname AS index_table_name,
    i.relname AS index_index_name,
    t.spcname AS index_tablespace,
    pg_get_indexdef(i.oid) AS index_scripte,
    pg_size_pretty(pg_relation_size(i.oid)) index_size  
   FROM pg_index x
     JOIN pg_class c ON c.oid = x.indrelid
     JOIN pg_class i ON i.oid = x.indexrelid
     LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
     LEFT JOIN pg_tablespace t ON t.oid = i.reltablespace
  WHERE (c.relkind = ANY (ARRAY['r'::"char", 'm'::"char"])) AND i.relkind = 'i'::"char";
