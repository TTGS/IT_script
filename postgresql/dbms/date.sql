



--日期可以和数字相加，结果是天进位。时间和时间戳都不行，需要指定。
--当前日期可以直接加数字。
select current_date，current_date+1  ;

-- 时间和时间戳会保持。
select current_time，current_time +1 ;
select current_timestamp，current_timestamp  +1 ;

--使用指定单位进行相加。
select current_timestamp,current_timestamp  +interval '1' month  ;


--如果是列中数字，可以使用拼接加指定完成。比如我需要将当前时间戳加指定单位和间隔数据类型即可。
select i ，current_timestamp , current_timestamp + (i||' minute')::interval   
 from generate_series(1,100  ) t(i) ;
 

-- 这里注意下，如果是1月29日，加一个月，那么他不会变到2月29日，而是2月28日。除非这年是闰年。
select  '2019-01-29'::Date+interval '1' month  , '2019-01-30'::Date+interval '1' month  , '2019-01-31'::Date+interval '1' month  

-- 闰年的1月29日，那么加1个月就会有2月29日出现。
select  '2020-01-29'::Date+interval '1' month  , '2020-01-30'::Date+interval '1' month  , '2020-01-31'::Date+interval '1' month  

