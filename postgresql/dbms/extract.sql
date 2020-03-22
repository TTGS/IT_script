名称： extract

说明：extract将时间戳，日期，时间将对应要求的内容提取出来，返回成数字。如果提供的是时间戳，日期都会提供全部内容，如果是时间，那么日期相关的都不能提供。

--时间戳 
select t
, EXTRACT(CENTURY   FROM t )   "世纪"
, EXTRACT(year      FROM t )   "年"
, EXTRACT(quarter   FROM t )   "季度"
, EXTRACT(month     FROM t )   "月"
, EXTRACT(day       FROM t )   "日"
, EXTRACT(hour      FROM t )   "小时"
, EXTRACT(minute    FROM t )   "分钟"
, EXTRACT(second    FROM t )   "秒"
, EXTRACT(week      FROM t )   "周（一年内第几周）"
, EXTRACT(doy       FROM t )   "天（一年内第几天）"
, EXTRACT(dow       FROM t )   "周（周日（0）到周六（6））"
, EXTRACT(epoch     FROM t )   "秒（本地1970-01-01 00:00:00计时共秒）" 
from (select '2018-11-1 13:00:12'::timestamp t )t   



--日期，时间默认都是0
select t
, EXTRACT(CENTURY   FROM t )   "世纪"
, EXTRACT(year      FROM t )   "年"
, EXTRACT(quarter   FROM t )   "季度"
, EXTRACT(month     FROM t )   "月"
, EXTRACT(day       FROM t )   "日"
, EXTRACT(hour      FROM t )   "小时"
, EXTRACT(minute    FROM t )   "分钟"
, EXTRACT(second    FROM t )   "秒"
, EXTRACT(week      FROM t )   "周（一年内第几周）"
, EXTRACT(doy       FROM t )   "天（一年内第几天）"
, EXTRACT(dow       FROM t )   "周（周日（0）到周六（6））"
, EXTRACT(epoch     FROM t )   "秒（本地1970-01-01 00:00:00计时共秒）" 
from (select '2018-11-2'::date t )t   


--时间，所有和日期相关的都不能用。 
select t
--, EXTRACT(CENTURY   FROM t )   "世纪"
--, EXTRACT(year      FROM t )   "年"
--, EXTRACT(quarter   FROM t )   "季度"
--, EXTRACT(month     FROM t )   "月"
--, EXTRACT(day       FROM t )   "日"
, EXTRACT(hour      FROM t )   "小时"
, EXTRACT(minute    FROM t )   "分钟"
, EXTRACT(second    FROM t )   "秒"
--, EXTRACT(week      FROM t )   "周（一年内第几周）"
--, EXTRACT(doy       FROM t )   "天（一年内第几天）"
--, EXTRACT(dow       FROM t )   "周（周日（0）到周六（6））"
--, EXTRACT(epoch     FROM t )   "秒（本地1970-01-01 00:00:00计时共秒）" 
from (select '19:22:42'::time  t )t   
