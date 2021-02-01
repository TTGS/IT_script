# postgresql_function
Mathematical , Check or Computing Functions in  postgresql 

only postgresql  function


为PostgreSQL 写的函数， 丰富PostgreSQL里的函数和功能。

	combination.sql 	    	组合运算 	
	feild_count.sql 	    	统计格子里的某个字符的个数 
	is_int.sql                  	判断输入的是否为整数 	
	permutation.sql 	    	求排列或者说是求阶乘 	
	random_range.sql 	    	在给出范围中的整数中随机返回一个值  
	random_values.sql           	随机出一个给定的值内容 
	random_date.sql             	返回一个给定日期范围内的日期
	xml_split.sql               	提取xml内容的节点内容
	xml_split_mul.sql           	可以解决一个xml里多个节点的内容问题。
	strsubing_c2c.sql           	字符到字符的切割
	check_china_id              	检查身份证号码
	replace_symbol              	自动替换非数字字符内容
	check_china_id_reason       	检查身份证并告知错误项
	random_char                 	随机字符串
	random_alnum                  	随机字符数字
	like_uuid                     	仿uuid函数，可以返回一个好像uuid的内容，但是该内容是0～9，a~z的组合，只是32长位内容。
	fake_uuid                     	假uuid函数，返回类似uuid内容，32位，16进制数字内容。
	find_object              	帮助查询提供的对象是什么类型
	substring_p2p			切割字符从开始字符点到结束字符点
	text_to_table			文本内容直接变成一个表输出
	random_china_id         	生成身份证号 
	math_limit			求分母为0或者无穷的问题
	postgres_check_report     	检查pg数据库并声称报告
	yesterday                	返回昨天的日期
	tomorrow                 	返回明天的日期
	what_type                	尝试用你给我的类型转换你给我的内容 ，如果成功就给你true，否则就false
	turn_case                	大小写翻转，大写变小写，小写变大写，数字符号没变化。
	check_datatype           	检查给的类型是否正确，是what_type的类似的东西。
	define_round             	自定义数值长度进位数值。
	string_index			随意找字符串
	drop_table_2_recyclebin         将指定的表改名并记录，仿oracle的闪回表（表的回收站）
	cust_orderby                    自定义排序，给出需要查找的列，排列的顺序和排列顺序的分割符号，返回数字，可以实现自动排序。
