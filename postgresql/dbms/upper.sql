名称：upper(列|字符)

说明：将字符内容变成大写，但是只有字母才有大写，所以这个函数对数字，标点，空格，null无效。

--将字符变为大写
select upper('a') ;
upper 
------
A     

--字符的内容如果已经是大写，那么就不变了。只有小写才会生效。
select upper('AaAa');
upper 
------
AAAA  

--对数字无效，注意，这里的数字是按照字符输入的。
select upper('1');
upper 
------
1     

--对空格无效，结果还是空格。
select upper(' ')
upper 
------
      
	  
--对符号无效，结果还是符号。
select upper('!') 
upper 
------
!     

--对null无效，结果还是null
select upper(null) 
upper 
------
[NULL]

--对列也是可以的，他会判断内容是否为大小写，完全符合上述规则。
with a as (
select 'a' id union all 
select 'b'    union all 
select 'D'    union all 
select 'R'    union all 
select ''     union all 
select ' '    union all 
select null   union all 
select '%'      
)
select id ,upper(id)  from a ;
id    |upper 
------|------
a     |A     
b     |B     
D     |D     
R     |R     
      |      
      |      
[NULL]|[NULL]
%     |%     
