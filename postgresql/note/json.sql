json是一个非常有用的数据类型，细微点比较多，所以这里记录。

--1  自己写json和使用 json_object 函数   ， 自己写的values可以不带双引号， 而 json_object 函数会自动给你加上双引号。
hp=# create table js (s json ) ;
CREATE TABLE
hp=# insert into js values('{"a":100}');
INSERT 0 1
hp=# insert into js values(json_object('{a}','{100}'));
INSERT 0 1
hp=# select * from js;
       s       
---------------
 {"a":100}
 {"a" : "100"}
(2 rows)


--2  如何得到表里的 key 或者values 内容   ， key 用 json_object_keys(s)  ，  values  用 s->json_object_keys(s)  

hp=# select * , json_object_keys(s) ,s->json_object_keys(s) from js ; 
       s       | json_object_keys | ?column? 
---------------+------------------+----------
 {"a":100}     | a                | 100
 {"a" : "100"} | a                | "100"
(2 rows)
