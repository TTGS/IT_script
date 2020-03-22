 名称:boolean 布尔类型
 
 说明：布尔类型,只允许true或false，在缺少非空约束可以额外插入null进入，使用true和false可以不带引号，但是使用其他是必须带引号的
 true  允许 true ,yes ,1 ,y
 false 允许 false , no ,0 ,n 
 null  允许 null
 
create table abc (i serial , lg boolean  ) 

-- 标准内容插入
insert into abc (lg) values (true) ; 
insert into abc (lg) values (false) ;
-- 额外允许插入内容
insert into abc (lg) values ('true') ; 
insert into abc (lg) values ('false') ;
insert into abc (lg) values ('yes') ; 
insert into abc (lg) values ('no') ;
insert into abc (lg) values ('1') ; 
insert into abc (lg) values ('0') ;
insert into abc (lg) values ('t') ; 
insert into abc (lg) values ('f') ; 
insert into abc (lg) values ('y') ; 
insert into abc (lg) values ('n') ; 

-- 有条件的插入内容。
insert into abc (lg) values (null) ; 

-- 禁止插入内容。
insert into abc (lg) values (yes) ; 
insert into abc (lg) values (no) ;
insert into abc (lg) values (1) ; 
insert into abc (lg) values (0) ;
insert into abc (lg) values (unknown ) ; 
insert into abc (lg) values ('') ;

select * from abc 
