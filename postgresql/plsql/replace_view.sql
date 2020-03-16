
ERROR:  cannot alter type of a column used by a view or rule
DETAIL:  rule _RETURN on view test_v depends on column "id"
SQL state: 0A000


create table test (id int );

create view test_v 
as 
select * from test ;

alter table test alter id type bigint;
/*
ERROR:  cannot alter type of a column used by a view or rule
DETAIL:  rule _RETURN on view test_v depends on column "id"
SQL state: 0A000
*/
 
 

--这是我提出的解决方案，替代品:D
create table a(id int , b varchar(10));

insert into a values (1,'a');
insert into a values (1,'a');
insert into a values (2,'a');
insert into a values (3,'a');
insert into a values (1,'a');
insert into a values (1,'a');
insert into a values (2,'a');
insert into a values (3,'a');

drop function v_a();

CREATE FUNCTION v_a() RETURNS SETOF a AS $$
   SELECT id , case when b='a' then 'good' else 'bad' end as  b 
   FROM a ;
$$ LANGUAGE SQL;


select * from v_a()
where id=3

alter table a alter id type bigint ;



有时候我们会进行一个join表，那么我们应该怎么样呢？我们应该如何返回内容呢？
create table l as select 1 id ;
create table r as select 1 id union select 2 id ; 

select * from l full  join r on l.id=r.id ;

直接指定语言是sql， 然后在returns里写明返回的列名和类型名，请注意这里的列名和查询出来的列名需要一一对应，否则将会出现错位的问题。
create or replace  function v_join()
returns table (lid int , rid int )
as 
$$
select r.id rid ,l.id  lid  from l full  join r on l.id=r.id ;
$$  LANGUAGE SQL; 

select * from v_join()

lid |rid 
----|----
1   |1   
2   |[NULL]


当然这里也可以使用pgplsql的语言进行不过写法略微不同。上面的环境进行编写
这里要注意pgplsql是需要写begin ... end 语句块的，不能省， 而且要求 RETURN QUERY 作为查询，如果没有那么select 在pgplsql里只能作为赋值方法使用。
create or replace  function v_join_rq()
returns    table (rid int , lid int )
as 
$$
begin 
	RETURN QUERY  select r.id rid ,l.id  lid  from l full  join r on l.id=r.id ;
end
$$  LANGUAGE plpgSQL; 

select * from v_join_rq()
rid |lid 
----|----
1   |1   
2   |[NULL]
