case是SQL里的选择语句，对结果集的内容进行选择处理
注意：
1，先碰到的先显示
2，then后面的类型要统一
3，else 为null 是默认存在的。
4，case ... end 是整体编译的，所以有一点问题都会停止。
5，如果是用case 选择，那么运算方式计算会更灵活，应该可以使用更多运算符
6，when为真就会返回，所以请你把选择条件写闭合。
7，源和显示可以类型不同。

格式: 格式有两种，
1，源和条件只能是等值就返回真。
case 源
	 when 条件1 then 显示 
	[when 条件2 then 显示 ]
	[else 显示 ]
end
2，运算条件只要返回真。
case 
	 when 运算条件1 then 显示 
	[when 运算条件2 then 显示 ]
	[else 显示 ]
end

--两种条件下可以互相转化。
select 
case 1
	when  1  then 1 
end  ,case  
	when  1=1  then 1
end 

-- 当多个符合条件的时候，碰到第一个符合的条件就会显示，后面其他符合条件不会处理
select 
case 
	when  2> 1  then 2  
	when  3< 4  then 4 
	when  7<>8  then 9
	else null   
end  

-- 即使后续不会看，那也需要符合基本条件，因为他会整体编译。
select 
case 
	when  2> 1  then 2  
	when  3< 4  then 4 
	when  7<>8  then 'a'
	else null   
end  

--数字在这里可以隐式转换类型。而不用操心。
select 
case 
	when  2= 1  then '2'  
	when  3< 4  then  4  
	when  7<>8  then '44'
	else null   
end  

--else 为null 是默认存在的，
select 
case 
	when  2= 1  then '2'    
end  

-- 更多运算符使用和源与结果不同类型。
select case when '1' in ('a','1','d') then 1 end 
