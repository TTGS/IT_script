格式：drop table [if exists] 表名 [cascade]

说明：删除表，在表结构上的内容也将被删除，例如数据，自增列，列等。
	if exists 如表存在那么删除表，如表不存在那么不会报错，只会在提示一个消息说"该表不存在，跳过"(00000: table "表名" does not exist, skipping)
	cascade 级联删除表，例如如果有视图，视图是强关联表，也就是表不能能乱改结构。级联删除会把对应的视图也删除。
	
--删除普通表。
create table a(a int  ) ;
 
drop table a   ; 

--删除带有视图的表。
create table a(a int  ) ;

create view view_a as select * from a; 

drop table a cascade ;

-- if exists  的方式删除表。
create table a(a int  ) ;
drop table if exists a ; 
drop table if exists a ; 
