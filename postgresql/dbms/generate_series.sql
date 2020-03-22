名称：generate_series(numeric ,numeric[,step])

说明:generate_series是PostgreSQL自己的函数，主要是帮你数行数。第一个是开始，一定会数到，第二个是上限，可以相等但是不能超过，最后一个步伐，如果是数字是可以不写（默认1），但是如果是日期类型，那么你必须写。上限下限不接受null，从小往大，不能从大往小，步伐不接受0


--上限和下限，默认是1
select generate_series(1,10);
generate_series
---------------
              1
              2
              3
              4
              5
              6
              7
              8
              9
             10


--步伐定为4
select generate_series(1,10,4) ; 
generate_series
---------------
              1
              5
              9


--步伐如果是与上限下限相符
select generate_series(1,10,-4) ;
generate_series
---------------


--负的也行。
select generate_series(-1 ,-10,-4) ; 
generate_series
---------------
             -1
             -5
             -9

--大小颠倒不会报错。
select generate_series(3,1) ;
generate_series
---------------


--null 不能是上限
select generate_series(3,null) ;
generate_series
---------------

--null不能是下限
select generate_series( null,3) ;
generate_series
---------------

--null不能是步伐
select generate_series(1,3, null ) ;
generate_series
---------------

--步伐不接受0
select generate_series(3,4,0) ;
SQL 错误 [22023]: ERROR: step size cannot equal zero
  ERROR: step size cannot equal zero
  ERROR: step size cannot equal zero

--日期上限下限
select generate_series('2018-10-01'::timestamp, '2018-10-02 00:03:00'::timestamp,' 1 day'  ) 
generate_series          
-------------------------
'2018-10-01 00:00:00.000'
'2018-10-02 00:00:00.000'

--日期上限下限可以自由设置
select generate_series('2018-10-01'::timestamp, '2018-10-01 00:03:00'::timestamp,' 1 minute'  ) 
generate_series          
-------------------------
'2018-10-01 00:00:00.000'
'2018-10-01 00:01:00.000'
'2018-10-01 00:02:00.000'
'2018-10-01 00:03:00.000'


--日期不接受 没有步伐内容。
select generate_series('2018-10-01'::timestamp, '2018-10-11'::timestamp   ) 
SQL 错误 [42883]: ERROR: function generate_series(timestamp without time zone, timestamp without time zone) does not exist
  Hint: No function matches the given name and argument types. You might need to add explicit type casts.
  Position: 8
  ERROR: function generate_series(timestamp without time zone, timestamp without time zone) does not exist
  Hint: No function matches the given name and argument types. You might need to add explicit type casts.
  Position: 8
  ERROR: function generate_series(timestamp without time zone, timestamp without time zone) does not exist
  Hint: No function matches the given name and argument types. You might need to add explicit type casts.
  Position: 8

  

  
  
