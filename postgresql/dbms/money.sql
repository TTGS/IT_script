money 类型受到lc_monetary 参数影响，改变lc_monetary 参数，就可以得到不同的货币符号。

select *from pg_settings 
where name='lc_monetary'

set session lc_monetary='zh_CN.UTF-8';
select 1.00::money ;


set session lc_monetary='en_US.UTF-8';
select 1.00::money ;

只能保留两位小数，第三位是四舍五入。第一位增加货币符号。
select 1.00::money , 1.005::money , 1.004::money 


如果需要查询utf8的货币区域可以查询下列语句
select * from pg_collation where collencoding=6 

