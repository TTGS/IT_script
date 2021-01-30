

--看分区名字
select  TABLE_OWNER,TABLE_NAME,PARTITION_NAME
from dba_tab_partitions 
where TABLE_OWNER='SH' and TABLE_NAME='TEST';


--删除分区，默认的不能删除。
alter table sh.test drop partition @@;

--删除的时候就更新索引。全局和部分都有效。
alter table sh.test drop  partition @@ Update GLOBAL  indexes;


--看索引分区内容是否有效。
select a.INDEX_NAME,a.UNIQUENESS ,a.TABLE_NAME ,b.partition_name, b.status 
from dba_indexes a join dba_ind_partitions b 
on a.INDEX_NAME=b.INDEX_NAME and a.OWNER=b.INDEX_OWNER
where a.table_name='TEST';
 
 
--重建部分分区索引。
alter index id_pk rebuild partition SYS_P81 ;

 
--查看是否有效。
select index_name,partition_name, status from DBA_ind_partitions where index_name='ID_PK';
status: 
   N/A说明这个是分区索引需要查user_ind_partitions或者user_ind_subpartitions来确定每个分区是否用；
    VAILD   说明这个索引可用；
    UNUSABLE说明这个索引不可用；
    USABLE  说明这个索引的分区是可用的。
    
    
--普通索引在这里看
select owner, INDEX_NAME,TABLE_NAME,UNIQUENESS,status  from dba_indexes where index_name='ID_G' ; 

alter index id_pk rebuild ;
