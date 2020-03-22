
ERROR: invalid input syntax for type point: ""  

2018-07-03 14:50:30|  分类： PostgreSQL |  标签：postgresql  案例  修复    

今天接了一个大活，把开发存在mysql数据库里的坐标都导入到postgresql里，为后面的postgis做准备。开发存放坐标也是比较直接，直接一个字符类型就保存了坐标。

前面传过来的数据也是很规矩，经纬度，逗号分隔，不会给你偷摸多个空格什么的。

那我我这里就直接保存成point类型就好了。因为后面反正也是给postgis用，point类型后续的计算等事情就方便很多。
但是我在校验的时候报错了。

postgres=# select p::point from tpoint ;
2018-07-03 22:05:40.310 CST [4237] ERROR:  invalid input syntax for type point: ""
2018-07-03 22:05:40.310 CST [4237] STATEMENT:  select p::point from tpoint ;
ERROR:  invalid input syntax for type point: ""
Time: 0.664 ms

这事是什么？莫名其妙的内容。什么都没有输出。

其实这个就和varchar中的null和''有关 ， 如果只是NULL，那么这个可以直接转换成point内容，但是如果插入的是''，那么恭喜你，这个是一个不可隐式转换方式。
我们可以使用case进行换话一下。

postgres=# select case when p='' then null else p end ::point from tpoint ;  
                 p                  
------------------------------------
 (116.590185016394,39.803132322094)
 
(2 rows)

Time: 8.204 ms

''是varchar中一种比较特殊的NULL，看上去和NULL没什么区别，但是这个''经常是不能与其他类型兼容的内容。

例如：
postgres=# select ''::int ;
2018-07-03 22:47:47.525 CST [4237] ERROR:  invalid input syntax for integer: "" at character 8
2018-07-03 22:47:47.525 CST [4237] STATEMENT:  select ''::int ;
ERROR:  invalid input syntax for integer: ""
LINE 1: select ''::int ;
               ^
Time: 0.288 ms

但是NULL就不会有这样的问题。
postgres=# select null::int , null::point ;
 int4 | point
------+-------
      |
(1 row)

Time: 0.279 ms
postgres=#
