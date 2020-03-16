在pg中的函数有2种输出结果的方法。
一个是直接使用return ,另一个是直接写out参数。

1，使用return输出。
CREATE OR REPLACE FUNCTION get_me_sum(a int,  b int) 
RETURNS NUMERIC AS $$
BEGIN
 RETURN a+b;
END; $$
LANGUAGE plpgsql;

select  get_me_sum(1,2);

get_me_sum 
-----------
3          

另一个种是使用out参数方法输出。如果不写默认是in参数，（in是你给函数，out是函数给你）
CREATE OR REPLACE FUNCTION get_me_sum2(a int,  b int, out c numeric ) 
AS $$
begin
c:=a+b;
END; $$
LANGUAGE plpgsql;

select  get_me_sum2(3,4);

get_me_sum2 
------------
7           

这里请注意，如果你使用了out参数，就不能再写return，写了可能会受到错误。
CREATE OR REPLACE FUNCTION get_me_sum3(a int,  b int, out c numeric ) 
AS $$
begin
c:=a+b;
return c;
END; $$
LANGUAGE plpgsql;

SQL Error [42804]: 错误: 在带有输出参数的函数中RETURN不能有参数
  Position: 105
  错误: 在带有输出参数的函数中RETURN不能有参数
  Position: 105
  错误: 在带有输出参数的函数中RETURN不能有参数
  Position: 105
  
  
  
  很多人肯定有人想问这俩还有什么不一样吗？
 -- 使用select into 进行赋值
CREATE OR REPLACE FUNCTION out_level() 
returns void 
AS $$
declare
a int;
b int;
begin
select get_me_sum(1,2) into a ;
RAISE INFO 'this is get_me_sum(%)',a;
select get_me_sum2(4,5) into b ;
RAISE INFO 'this is get_me_sum2(%)',b;
END; $$
LANGUAGE plpgsql; 


--使用等于变量赋值
CREATE OR REPLACE FUNCTION out_level2() 
returns void 
AS $$
declare
a int;
b int;
begin
a:=get_me_sum(1,2);
RAISE INFO 'this is get_me_sum(%)',a;
b:=get_me_sum2(4,5) ;
RAISE INFO 'this is get_me_sum2(%)',b;
END; $$
LANGUAGE plpgsql; 

结果都是输出

00000: this is get_me_sum(3)
00000: this is get_me_sum2(9)

在函数套函数里没啥区别
