普通行按照json方式输出，可以利用 row_to_json 函数。
----    这里需要注意的是，函数里的星花是需要别名或者表名的。
例如：
hp=# select row_to_json(t.*) from pg_tablespace  t;
                               row_to_json                                
--------------------------------------------------------------------------
 {"spcname":"pg_default","spcowner":"10","spcacl":null,"spcoptions":null}
 {"spcname":"pg_global","spcowner":"10","spcacl":null,"spcoptions":null}
 {"spcname":"def","spcowner":"10","spcacl":null,"spcoptions":null}
 {"spcname":"tmp","spcowner":"10","spcacl":null,"spcoptions":null}
(4 rows)

hp=# select row_to_json(pg_tablespace.*) from pg_tablespace  ;
                               row_to_json                                
--------------------------------------------------------------------------
 {"spcname":"pg_default","spcowner":"10","spcacl":null,"spcoptions":null}
 {"spcname":"pg_global","spcowner":"10","spcacl":null,"spcoptions":null}
 {"spcname":"def","spcowner":"10","spcacl":null,"spcoptions":null}
 {"spcname":"tmp","spcowner":"10","spcacl":null,"spcoptions":null}
(4 rows)


---- 这里需要注意的是，函数里的星花是需要别名或者表名的。
hp=# select row_to_json(*) from pg_tablespace  ;
ERROR:  function row_to_json() does not exist
LINE 1: select row_to_json(*) from pg_tablespace  ;
               ^
HINT:  No function matches the given name and argument types. You might need to add explicit type casts.
hp=# 
