CREATE OR REPLACE VIEW public.pg_dba_column
AS 
SELECT 							current_database() AS table_database,
									   nc.nspname  AS table_schema,
										c.relname  AS table_name,
										a.attname  AS column_name,
										a.attnum   AS column_position,
 pg_catalog.format_type(a.atttypid, a.atttypmod)   AS column_datatype ,
 pg_get_expr(ad.adbin, ad.adrelid)::character_data AS column_default,
        CASE
            WHEN a.attnotnull OR t.typtype = 'd'::"char" AND t.typnotnull THEN 'NO'::text
            ELSE 'YES'::text
        END  AS can_null,
    case when (SELECT c.collname  FROM pg_catalog.pg_collation c join  pg_catalog.pg_type t 
     on  c.oid = a.attcollation AND t.oid = a.atttypid AND a.attcollation <> t.typcollation)  is not null 
     then (SELECT c.collname  FROM pg_catalog.pg_collation c join  pg_catalog.pg_type t 
     on  c.oid = a.attcollation AND t.oid = a.atttypid AND a.attcollation <> t.typcollation) 
     else db.datcollate 
     end 
     AS column_charset ,
     se.last_value column_sequence_last_value,
           CASE
            WHEN c.relkind = 'r'::"char" THEN 'ordinary table   '::text
            WHEN c.relkind = 'i'::"char" THEN 'index            '::text
            WHEN c.relkind = 'S'::"char" THEN 'sequence         '::text
            WHEN c.relkind = 't'::"char" THEN 'TOAST table      '::text
            WHEN c.relkind = 'v'::"char" THEN 'view             '::text
            WHEN c.relkind = 'm'::"char" THEN 'materialized view'::text
            WHEN c.relkind = 'c'::"char" THEN 'composite type   '::text
            WHEN c.relkind = 'f'::"char" THEN 'foreign table    '::text
            WHEN c.relkind = 'p'::"char" THEN 'partitioned table'::text
            WHEN c.relkind = 'I'::"char" THEN 'partitioned index'::text
            ELSE NULL::text
        END AS object_type
          FROM pg_catalog.pg_attribute a
     LEFT JOIN pg_catalog.pg_attrdef ad ON a.attrelid = ad.adrelid AND a.attnum = ad.adnum
     left JOIN pg_catalog.pg_class c  on a.attrelid = c.oid
	 left JOIN pg_catalog.pg_namespace nc ON c.relnamespace = nc.oid  
     left JOIN pg_catalog.pg_type t  ON a.atttypid = t.oid
     left join pg_catalog.pg_sequences  se  on 'nextval('''||se.sequencename||'''::regclass)'=ad.adsrc
     left join pg_catalog.pg_database db on  datname=current_database()  
  WHERE a.attnum > 0 ;
