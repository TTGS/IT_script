
PostgreSQL中的json类型-1  

2017-10-23 22:29:11
标签：postgresql  数据库管理  功能  
       

PostgreSQL很早就引入了json和jsonb类型，这就增强了postgresql数据库对存储文本类型有了很大的支持。

这就进一步增强了postgresql数据库对NoSQL的支持。

mongodb数据库是一个json方式保存的NoSQL数据库，虽然个方面都有不俗的表现，但毕竟SQL语言的普及读还是很高的，

而PostgreSQL就这这样的一种数据库，可以用sql去控制json这样的内容。

postgresql中有两种json类型（json和jsonb），我们先看下他们的区别。


json是对输入的完整拷贝，使用时再去解析，然而他并不支持索引。

jsonb是对输入后解析保存的二进制，使用时不用再次解析，他支持索引。

两种类型都是保存了key 和 value ， 差别在于json先保存，使用解析，jsonb先解析，在使用。后者会略微快些。


我们先简单的创建一张表，然后插入一些数据，注意，无论哪种json键值都要使用双引号。
create table j_tab
(
id serial ,
j  json,
jb jsonb
);

insert into j_tab
values
(1,'{"id":"1","name":"postgresql"}','{"id":"1","name":"postgresql"}'),
(2,'{"id":"2","name":"mysql"}','{"id":"2","name":"mysql"}'),
(3,'{"id":"3","name":"sql server"}','{"id":"3","name":"sql server"}'),
(4,'{"id":"4","name":"oracle"}','{"id":"4","name":"oracle"}'),
(5,'{"id":"5","name":"mongodb"}','{"id":"5","name":"mongodb"}');


下列有几种json的运算符号
select '[{"i":1},{"d":2}]'::json->0;
--'{"i":1}'
获取JSON数组元素（索引从0开始）

select '{"i":3,"d":7}'::json->'d';
--7
通过键获取值

select '[{"i":1},{"d":2}]'::json->>1;
--'{"d":2}'
获取JSON数组元素为（索引从0开始）


select '{"i":3,"d":7}'::json->>'d';
--'7'
通过键获取值为text

select '{"i":{"w":1}}'::json #> '{i}' ;
--'{"w":1}'
在指定的路径获取JSON对象text (多层嵌套的样式)
    
select '{"i":[1,2,3],"d":[4,5,6]}'::json#>>'{d,1}';   
--'5'
在指定的路径获取JSON对象为 text（value是数组形式的，找到索引的对应values值，0开始）
    
个人感觉第一种和第三种，第二种和第四种好像。难道说是一样的 :P

当然jsonb还有独特的运算符号 "@>" ，这个符号可以判断出来左边的是否包含右边的内容，有就返回t，没有返回f。
select  id , j->'id',j->'name' ,jb->'id',jb->'name' from j_tab
where jb @> '{"id":"5"}'::jsonb
