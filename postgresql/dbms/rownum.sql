pg中的 rownum 是利用窗口函数完成的。   
例如：  


hp=# select row_number() over() ,datname from pg_database ;
 row_number |  datname  
------------+-----------
          1 | postgres
          2 | template1
          3 | template0
          4 | hp
(4 rows)
