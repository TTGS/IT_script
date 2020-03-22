今天碰到一个超有意思的事情。

我们这里有一个pg数据库，作为mysql的汇总库存在，也就是mysql在前线作为程序的好伙伴进行抗压，看清楚哟，只是抗压，不是查询。而pg数据库利用扩展对mysql进行集中汇总到一起，让业务人员可以进行跨库查询的工作。

这里再次感谢 EnterpriseDB 公司提供了mysql_fdw组件。
https://github.com/EnterpriseDB/mysql_fdw

taxidb=> select mysql_fdw_version();
 mysql_fdw_version 
-------------------
             20400
(1 row)


业务人员写的语句也是比较简单，这俩表都是外部表，是去连接mysql数据库得到的内容。
不用太在意sql内容的细节。主要记住这里是用的in进行两表进行连接就好。
select 
round(sum(cc)/ count(cc)::numeric ,2)  from 
(
select   count(*) cc 
  from  order_info a 
 where  status=50 
   and  city_id=83 
   and  service_end_date  < '2018-05-29'::date+interval '1' day
   and  order_id in (select order_id 
                       from  order_settle_detail
                      where online_pay_status=1 
                        and pay_status=1
                        and city_id=83)
group by driver_id 
  having min(service_end_date) >= '2018-05-29'::date 
     and min(service_end_date) < '2018-05-29'::date+interval '1' day )abc

这个语句据业务人员说，执行10多分钟没有结果返回。他们希望帮忙优化，
帮着他们修改了语句 把 in 改成了 exists ，然后10多秒出来了。
他们很高兴的走了，不过我倒是很想知道原因。是什么原因造成了速度如此之慢？

于是我用explain verbose 调出了执行计划，肯定有人问你为什么不用explain analyze 呢？因为他出不来哇 (T_T)

in的执行计划
 Aggregate  (cost=1040.00..1040.02 rows=1 width=32)
   Output: round((sum((count(*))) / (count((count(*))))::numeric), 2)
   ->  HashAggregate  (cost=1035.00..1037.00 rows=200 width=40)
         Output: count(*), a.driver_id
         Group Key: a.driver_id
         Filter: ((min(a.service_end_date) >= '2018-05-29 00:00:00'::timestamp without time zone) AND (min(a.service_end_date) < '2018-05-30 00:00:00'::timestamp without time zone))
         ->  Foreign Scan on mysql.order_info a  (cost=25.00..1025.00 rows=1000 width=40)
               Output: a.order_id, a.estimated_amount, a.total_amount, a.dispatch_cost_amount, a.fact_amount, a.booking_user_id, a.booking_user_name, a.rider_user_id, a.rider_user_name, a.rider_user_phone, a.driver_id, a.driver_name, a.booking_current_addr, a.booking_current_point, a.order_type, a.booking_date, a.booking_start_addr, a.booking_start_name, a.booking_start_point, a.booking_end_addr, a.booking_end_name, a.booking_end_point, a.fact_start_addr, a.fact_start_name, a.fact_start_point, a.fact_start_date, a.fact_end_addr, a.fact_end_name, a.fact_end_point, a.fact_end_date, a.city_id, a.license_plates, a.status, a.create_date, a.update_date, a.pay_type, a.evaluation, a.reason_type, a.reason_id, a.order_canel_reason, a.canel_date, a.channel, a.service_driver_id, a.service_driver_name, a.customer_app_id, a.driver_app_id, a.customer_supplier_id, a.driver_supplier_id, a.supplier_order_id, a.fact_pay_amount, a.other_amount, a.dis_count_amount, a.fact_distance, a.fact_duration, a.pay_method, a.service_end_date
               Filter: (SubPlan 1)
               Remote server startup cost: 25
               Remote query: SELECT `order_id`, `driver_id`, `city_id`, `service_end_date` FROM `taxi_0`.`order_info` WHERE ((`service_end_date` < '2018-05-30 00:00:00')) AND ((`status` = 50)) AND ((`city_id` 
= 83))
               SubPlan 1
                 ->  Result  (cost=25.00..1025.00 rows=1000 width=218)
                       Output: b.order_id
                       One-Time Filter: (a.city_id = '83'::numeric)
                       ->  Foreign Scan on mysql.order_settle_detail b  (cost=25.00..1025.00 rows=1000 width=218)
                             Output: b.id, b.order_id, b.online_pay_status, b.pay_type, b.pay_method, b.total_amount, b.other_amount, b.dispatch_amount, b.dis_count_amount, b.fact_pay_amount, b.taximeter_amount, b.discount_way, b.discount_id, b.discount_txt, b.create_time, b.update_time, b.pay_status, b.dispatch_cost_type
                             Remote server startup cost: 25
                             Remote query: SELECT `order_id` FROM `taxi_0`.`order_settle_detail` WHERE ((`online_pay_status` = 1)) AND ((`pay_status` = 1))
(19 rows)

exists的执行计划
Aggregate  (cost=2075.19..2075.21 rows=1 width=32)
   Output: round((sum((count(*))) / (count((count(*))))::numeric), 2)
   ->  HashAggregate  (cost=2070.19..2072.19 rows=200 width=40)
         Output: count(*), a.driver_id
         Group Key: a.driver_id
         Filter: ((min(a.service_end_date) >= '2018-05-29 00:00:00'::timestamp without time zone) AND (min(a.service_end_date) < '2018-05-30 00:00:00'::timestamp without time zone))
         ->  Hash Join  (cost=1057.00..2065.19 rows=500 width=40)
               Output: a.driver_id, a.service_end_date
               Inner Unique: true
               Hash Cond: ((a.order_id)::text = (b.order_id)::text)
               ->  Foreign Scan on mysql.order_info a  (cost=25.00..1025.00 rows=1000 width=556)
                     Output: a.order_id, a.estimated_amount, a.total_amount, a.dispatch_cost_amount, a.fact_amount, a.booking_user_id, a.booking_user_name, a.rider_user_id, a.rider_user_name, a.rider_user_phone, a.driver_id, a.driver_name, a.booking_current_addr, a.booking_current_point, a.order_type, a.booking_date, a.booking_start_addr, a.booking_start_name, a.booking_start_point, a.booking_end_addr, a.booking_end_name, a.booking_end_point, a.fact_start_addr, a.fact_start_name, a.fact_start_point, a.fact_start_date, a.fact_end_addr, a.fact_end_name, a.fact_end_point, a.fact_end_date, a.city_id, a.license_plates, a.status, a.create_date, a.update_date, a.pay_type, a.evaluation, a.reason_type, a.reason_id, a.order_canel_reason, a.canel_date, a.channel, a.service_driver_id, a.service_driver_name, a.customer_app_id, a.driver_app_id, a.customer_supplier_id, a.driver_supplier_id, a.supplier_order_id, a.fact_pay_amount, a.other_amount, a.dis_count_amount, a.fact_distance, a.fact_duration, a.pay_method, a.service_end_date
                     Remote server startup cost: 25
                     Remote query: SELECT `order_id`, `driver_id`, `service_end_date` FROM `taxi_0`.`order_info` WHERE ((`service_end_date` < '2018-05-30 00:00:00')) AND ((`status` = 50)) AND ((`city_id` = 83))
               ->  Hash  (cost=1029.50..1029.50 rows=200 width=218)
                     Output: b.order_id
                     ->  HashAggregate  (cost=1027.50..1029.50 rows=200 width=218)
                           Output: b.order_id
                           Group Key: (b.order_id)::text
                           ->  Foreign Scan on mysql.order_settle_detail b  (cost=25.00..1025.00 rows=1000 width=218)
                                 Output: b.order_id, b.order_id
                                 Remote server startup cost: 25
                                 Remote query: SELECT `order_id` FROM `taxi_0`.`order_settle_detail` WHERE ((`online_pay_status` = 1)) AND ((`pay_status` = 1))
(23 rows)


简单的解释一下，in的执行计划是系统将这俩个语句当作两个内容去执行，即 in 中的子查询作为单独的内容进行查询，得到结果全部输出出来后保存到pg这里，然后在外层的内容进行查询，筛选子查询的内容，再进行所谓的聚合之类的操作。
而exists这不是这样做，先到子表输出内容，注意这里输出的只是一列，子表中的一列内容，而in这里输出的是整个所有列内容，没用的也给你咯。然后输出父表，这里倒是大家差不多。最后使用我们比较常见的hashjoin的方式进行连接，最后输出了内容。

是的，差在子表的输出列内容，in输出更多的内容，也就需要更多的空间，hash连接还是filter进行

下面是用explain analyze verbose追的内容。
 Aggregate  (cost=2075.19..2075.21 rows=1 width=32) (actual time=3591.280..3591.280 rows=1 loops=1)
   Output: round((sum((count(*))) / (count((count(*))))::numeric), 2)
   ->  HashAggregate  (cost=2070.19..2072.19 rows=200 width=40) (actual time=3591.135..3591.254 rows=14 loops=1)
         Output: count(*), a.driver_id
         Group Key: a.driver_id
         Filter: ((min(a.service_end_date) >= '2018-05-29 00:00:00'::timestamp without time zone) AND (min(a.service_end_date) < '2018-05-30 00:00:00'::timestamp without time zone))
         Rows Removed by Filter: 509
         ->  Hash Join  (cost=1057.00..2065.19 rows=500 width=40) (actual time=3416.819..3589.818 rows=2073 loops=1)
               Output: a.driver_id, a.service_end_date
               Inner Unique: true
               Hash Cond: ((a.order_id)::text = (b.order_id)::text)
               ->  Foreign Scan on mysql.order_info a  (cost=25.00..1025.00 rows=1000 width=556) (actual time=0.265..116.736 rows=25108 loops=1)
                     Output: a.order_id, a.estimated_amount, a.total_amount, a.dispatch_cost_amount, a.fact_amount, a.booking_user_id, a.booking_user_name, a.rider_user_id, a.rider_user_name, a.rider_user_phon
e, a.driver_id, a.driver_name, a.booking_current_addr, a.booking_current_point, a.order_type, a.booking_date, a.booking_start_addr, a.booking_start_name, a.booking_start_point, a.booking_end_addr, a.booking_en
d_name, a.booking_end_point, a.fact_start_addr, a.fact_start_name, a.fact_start_point, a.fact_start_date, a.fact_end_addr, a.fact_end_name, a.fact_end_point, a.fact_end_date, a.city_id, a.license_plates, a.sta
tus, a.create_date, a.update_date, a.pay_type, a.evaluation, a.reason_type, a.reason_id, a.order_canel_reason, a.canel_date, a.channel, a.service_driver_id, a.service_driver_name, a.customer_app_id, a.driver_a
pp_id, a.customer_supplier_id, a.driver_supplier_id, a.supplier_order_id, a.fact_pay_amount, a.other_amount, a.dis_count_amount, a.fact_distance, a.fact_duration, a.pay_method, a.service_end_date
                     Remote server startup cost: 25
                     Remote query: SELECT `order_id`, `driver_id`, `service_end_date` FROM `taxi_0`.`order_info` WHERE ((`service_end_date` < '2018-05-30 00:00:00')) AND ((`status` = 50)) AND ((`city_id` = 83)
)
               ->  Hash  (cost=1029.50..1029.50 rows=200 width=218) (actual time=3321.191..3321.191 rows=1161520 loops=1)
                     Output: b.order_id
                     Buckets: 1048576 (originally 1024)  Batches: 2 (originally 1)  Memory Usage: 45026kB
                     ->  HashAggregate  (cost=1027.50..1029.50 rows=200 width=218) (actual time=2361.621..2785.369 rows=1161520 loops=1)
                           Output: b.order_id
                           Group Key: (b.order_id)::text
                           ->  Foreign Scan on mysql.order_settle_detail b  (cost=25.00..1025.00 rows=1000 width=218) (actual time=0.116..1602.463 rows=1161520 loops=1)
                                 Output: b.order_id, b.order_id
                                 Remote server startup cost: 25
                                 Remote query: SELECT `order_id` FROM `taxi_0`.`order_settle_detail` WHERE ((`online_pay_status` = 1)) AND ((`pay_status` = 1))
 Planning time: 5.277 ms
 Execution time: 7338.893 ms
(27 rows)


另一个看不到用strace总是超时。
