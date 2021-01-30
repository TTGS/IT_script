
drop table sh.test ; 

create table sh.test
(
   ID int ,
   rk VARCHAR2(100),
   ct DATE
)
PARTITION BY RANGE (ct) INTERVAL (NUMTODSINTERVAL(1, 'day'))
(partition part_t01 values less than(to_date('2020-01-01', 'yyyy-mm-dd')));

create unique  index  id_pk on sh.test(id) global partition by hash(id) partitions 4;
crEATE index idx_rk on sh.test(rk) local ;

alter table sh.test add constraint pk_id primary key (id) using index id_pk ; 


insert into sh.test values(1,'a',date'2020-01-01') ; 
insert into sh.test values(1,'a',date'2020-01-02') ;
insert into sh.test values(null,'a',date'2020-01-01') ;

update sh.test set id=2 where id=1 ; 
delete sh.test where id=2;
