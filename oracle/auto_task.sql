--收集hr用户统计信息的存储过程
create or replace  Procedure gather_stats
as 
begin
dbms_stats.gather_database_stats;
--dbms_stats.gather_schema_stats('HR',CASCADE=>TRUE,DEGREE=>DBMS_STATS.AUTO_DEGREE);
end;
/
--创建一个简单的job，每月1日2：30分执行，间隔1个月。
declare 
a varchar2(10000);
begin
   dbms_job.submit(job=>a
   ,what=>'gather_stats;'
   , NEXT_DATE=>to_date(201711010230,'yyyymmddhh24mi') 
     ,interval =>'TRUNC(LAST_DAY(SYSDATE))+1+1/24');
 dbms_output.put_line(a);
end;
/

--查看任务情况。
select  *from DBA_JOBS； 

--删除自动任务。
exec DBMS_JOB.REMOVE(3)

--运行自动任务。
exec dbms_job.run(4)

--执行过程中，可以看到执行情况。
select * from DBA_JOBS_RUNNING

/* 
1:每分钟执行
Interval => TRUNC(sysdate,'mi') + 1/(24*60)
2:每天定时执行
例如：每天的凌晨1点执行
Interval => TRUNC(sysdate) + 1 +1/(24)
3:每周定时执行
例如：每周一凌晨1点执行
Interval => TRUNC(next_day(sysdate,'星期一'))+1/24
4:每月定时执行
例如：每月1日凌晨1点执行
Interval =>TRUNC(LAST_DAY(SYSDATE))+1+1/24
5:每季度定时执行
例如每季度的第一天凌晨1点执行
Interval => TRUNC(ADD_MONTHS(SYSDATE,3),'Q') + 1/24
6:每半年定时执行
例如：每年7月1日和1月1日凌晨1点
Interval => ADD_MONTHS(trunc(sysdate,'yyyy'),6)+1/24
7:每年定时执行
例如：每年1月1日凌晨1点执行
Interval =>ADD_MONTHS(trunc(sysdate,'yyyy'), 12)+1/24

job的运行频率设置
1.每天固定时间运行，比如早上8:10分钟：Trunc(Sysdate+1) + (8*60+10)/24*60
2.Toad中提供的：
每天：trunc(sysdate+1)
每周：trunc(sysdate+7)
每月：trunc(sysdate+30)
每个星期日：next_day(trunc(sysdate),'星期日')
每天6点：trunc(sysdate+1)+6/24
半个小时：sysdate+30/(24*60)
3.每个小时的第15分钟运行，比如：8:15，9:15，10:15…：trunc(sysdate,'hh')+(60+15)/(24*60)。
*/
