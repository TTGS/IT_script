范围分区：
create table t (id int, n char(10), tt timestamp) partition by range (tt);  
create table tp1  partition of t  (id  primary key,  n  , tt   ) for values from ('2020-01-01') to ('2020-02-01');   
create table tp2  partition of t  (id  primary key,  n  , tt   ) for values from ('2020-02-01') to ('2020-03-01');   
create table tp3  partition of t  (id  primary key,  n  , tt   ) for values from ('2020-03-01') to ('2020-04-01');   

列表分区：
create table tl     (id int   , f  varchar(10) , t date) partition by list (f );  
create table tl0 partition of tl  (id  primary key, f , t ) for values in (0);  
create table tl1 partition of tl  (id  primary key, f , t ) for values in (1);  
create table tl2 partition of tl  (id  primary key, f , t ) for values in (2);  
create table tl3 partition of tl  (id  primary key, f , t ) for values in (3);  
