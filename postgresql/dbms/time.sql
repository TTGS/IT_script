
--当然PostgreSQL还支持 闰秒，闰秒是60秒，也就是任意时间秒是60，这回计算到下一个时刻中。
select '2019-01-01 23:59:59'::timestamp+interval '1' second  
,'2019-01-01 23:59:60'::timestamp
,'2019-01-01 03:19:60'::timestamp
,'2019-01-01 13:59:60'::timestamp

-- 当然你写61秒就是不行了。
select '2019-01-01 13:59:61'::timestamp


-- 时间也可以的
 
select '2019-01-01 23:59:59'::time +interval '1' second  
,'2019-01-01 23:59:60'::time 
,'2019-01-01 03:19:60'::time 
,'2019-01-01 13:59:60'::time 
 
select '2019-01-01 13:59:61'::time 
