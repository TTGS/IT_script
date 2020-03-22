今天被问到一个很有趣的一个问题。在pg中，有视图，这些在修改底层基础表的列类型的时候，汇报错。

ERROR:  cannot alter type of a column used by a view or rule
DETAIL:  rule _RETURN on view test_v depends on column "id"
SQL state: 0A000

对于开发人员来说，这是不可接受的问题。

报错演示如下：

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
 

其实这个在官方的邮件列表中也是没有太多说法的。只是找到这样的一个邮件内容。
https://www.postgresql.org/message-id/20050216133409.33718.qmail%40web42108.mail.yahoo.com


还有一个sql。
select pg_class.* from pg_depend,pg_attribute,pg_rewrite,pg_class where
refclassid=1259 and
refobjid='你的表'::regclass and
pg_attribute.attrelid='你的表'::regclass and
refobjsubid = attnum and
attname='你的列' and
classid='pg_rewrite'::regclass and
pg_rewrite.oid=objid and
pg_rewrite.rulename='_RETURN' and
pg_class.oid=pg_rewrite.ev_class;


其实开发们就像知道这东西有啥好办，或者有什么替代品。

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

