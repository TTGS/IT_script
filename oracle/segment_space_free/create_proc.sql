CREATE OR REPLACE PROCEDURE SEGMENT_FREE_proc(
  v_segmentname  in varchar2 DEFAULT NULL,
  v_owner      IN VARCHAR2 DEFAULT USER,
  v_partitionname in varchar2 default null,
  v_report    in varchar2 default 'TABLE'
)
AS
l_setp int;
l_owner varchar2(300);
l_segmentname varchar2(300);
l_partitionname varchar2(300);
l_type varchar2(300);
l_fs1_bytes NUMBER ;
l_fs2_bytes NUMBER ;
l_fs3_bytes NUMBER ;
l_fs4_bytes NUMBER ;
l_fs1_blocks NUMBER ;
l_fs2_blocks NUMBER ;
l_fs3_blocks NUMBER ;
l_fs4_blocks NUMBER ;
l_full_bytes NUMBER ;
l_full_blocks NUMBER ;
l_unformatted_bytes NUMBER;
l_unformatted_blocks NUMBER;
BEGIN
  l_setp:=1;
  IF  LENGTH(v_segmentname)=0  THEN
  return;
  END IF ;
    l_setp:=2;
  IF   upper(v_segmentname)='!HELP'   THEN
dbms_output.put_line('The PROCEDURE need four the parameter .');
dbms_output.put_line('v_segmentname is stroage segment name (ex. table name );');
dbms_output.put_line('v_owner is the  segment of the user ;');
dbms_output.put_line('v_partitionname is partition name (partition or subpartition) ,it can discriminate partition or subpartition;');
dbms_output.put_line('v_report is show class default TABLE (ex. TEXT or TABLE);');
  /*
create table SEGMENT_FREE_TABLE
(
  create_time       TIMESTAMP(6),
  owner             VARCHAR2(300),
  segment_name      VARCHAR2(300),
  partition_name    VARCHAR2(300),
  segment_type      VARCHAR2(300),
  free_025_blocks   NUMBER,
  free_025_bytes    NUMBER,
  free_2550_blocks  NUMBER,
  free_2550_bytes   NUMBER,
  free_5075_blocks  NUMBER,
  free_5075_bytes   NUMBER,
  free_75100_blocks NUMBER,
  free_75100_bytes  NUMBER,
  free_full_blocks  NUMBER,
  free_full_bytes   NUMBER
);
-- Add comments to the table
comment on table SEGMENT_FREE_TABLE   is 'segment free mapping';
-- Add comments to the columns
comment on column SEGMENT_FREE_TABLE.create_time  is 'create the row date time';
comment on column SEGMENT_FREE_TABLE.owner  is 'segment user';
comment on column SEGMENT_FREE_TABLE.segment_name  is 'segment name';
comment on column SEGMENT_FREE_TABLE.partition_name  is 'segment partition name';
comment on column SEGMENT_FREE_TABLE.segment_type  is 'segment type';
comment on column SEGMENT_FREE_TABLE.free_025_blocks  is '0-25% Free blocks ';
comment on column SEGMENT_FREE_TABLE.free_025_bytes  is '0-25% Free bytes ';
comment on column SEGMENT_FREE_TABLE.free_2550_blocks  is '25-50% Free blocks ';
comment on column SEGMENT_FREE_TABLE.free_2550_bytes  is '25-50% Free bytes ';
comment on column SEGMENT_FREE_TABLE.free_5075_blocks  is '50-75% Free blocks ';
comment on column SEGMENT_FREE_TABLE.free_5075_bytes  is '50-75% Free bytes ';
comment on column SEGMENT_FREE_TABLE.free_75100_blocks  is '75-100% Free blocks ';
comment on column SEGMENT_FREE_TABLE.free_75100_bytes  is '75-100% Free bytes ';
comment on column SEGMENT_FREE_TABLE.free_full_blocks  is 'Full Free blocks(unformatted) ';
comment on column SEGMENT_FREE_TABLE.free_full_bytes  is 'Full Free bytes(unformatted) ';
  */
/*  dbms_output.put_line('V_segmentname ='||V_segmentname||';');
  dbms_output.put_line('V_partitionname ='||V_partitionname||';');
  dbms_output.put_line('l_owner = '||l_owner||';');*/
return;
  END IF ;
  /* check v_owner,v_segmentname,v_partitionname,v_type is ok */
   l_setp:=3;
 SELECT owner,table_name,NVL(SUBPARTITION_name,PARTITION_name),TAB_TYPE
INTO l_owner,l_segmentname,l_partitionname,l_type
FROM (
select ROW_NUMBER()
OVER(PARTITION BY TABLE_NAME
ORDER BY SUBPARTITION_NAME DESC NULLS LAST
       , PARTITION_NAME DESC NULLS LAST
       , TABLE_NAME DESC NULLS LAST)
RW , owner,table_name,PARTITION_name,SUBPARTITION_name,OBJECT_TYPE,
CASE WHEN OBJECT_TYPE='TABLE' THEN 'TABLE'
  WHEN OBJECT_TYPE='PARTITION' THEN 'TABLE PARTITION'
    WHEN OBJECT_TYPE='SUBPARTITION' THEN 'TABLE SUBPARTITION'
      END TAB_TYPE
from all_tab_statistics
where upper(owner)=upper(user)
and  upper(table_name)=upper(v_segmentname)
AND  ( nvl(SUBPARTITION_name,PARTITION_name)=UPPER(v_partitionname) 
or nvl(SUBPARTITION_name,PARTITION_name) is null))
WHERE RW=1; 

l_setp:=4;
/* There is free space in the segment .*/
  dbms_space.space_usage(
  segment_owner=>l_owner ,
  segment_name=>l_segmentname ,
  segment_type=>l_type,
  PARTITION_NAME=>l_partitionname,
  fs1_bytes=>l_fs1_bytes,
  fs1_blocks=>l_fs1_blocks,
  fs2_bytes=>l_fs2_bytes,
  fs2_blocks=>l_fs2_blocks,
  fs3_bytes=>l_fs3_bytes,
  fs3_blocks=>l_fs3_blocks,
  fs4_bytes=>l_fs4_bytes,
  fs4_blocks=>l_fs4_blocks,
  full_bytes=>l_full_bytes,
  full_blocks=>l_full_blocks,
  unformatted_bytes=>l_unformatted_bytes,
  unformatted_blocks=>l_unformatted_blocks
  );
   l_setp:=5;
  if upper(v_report)='TEXT' then
  /*show free blocks and free bytes */
   l_setp:=6;
  dbms_output.put_line('user = '||l_owner||';');
  dbms_output.put_line('segment_name ='||l_segmentname||';');
  dbms_output.put_line('partition_name ='||l_partitionname||';');
  dbms_output.put_line('segment_type='||l_type||';');
  dbms_output.put_line('0-25%   Free blocks = '||l_fs1_blocks||'         Bytes ='||l_fs1_bytes);
  dbms_output.put_line('25-50%  Free blocks = '||l_fs2_blocks||'         Bytes ='||l_fs2_bytes);
  dbms_output.put_line('50-75%  Free blocks = '||l_fs3_blocks||'         Bytes ='||l_fs3_bytes);
  dbms_output.put_line('75-100% Free blocks = '||l_fs4_blocks||'        Bytes ='||l_fs4_bytes);
  dbms_output.put_line('Full    Free blocks = '||l_unformatted_blocks||'         Bytes ='||l_unformatted_bytes);
 elsif  upper(v_report)='TABLE' then
 /*to update the record in the result */
  l_setp:=7;
INSERT INTO SEGMENT_FREE_table (create_time,OWNER,SEGMENT_NAME,partition_NAME,segment_type,
  free_025_blocks,free_025_bytes,
  free_2550_blocks,free_2550_bytes,
  free_5075_blocks,free_5075_bytes,
  free_75100_blocks,free_75100_bytes,
  free_full_blocks,free_full_bytes)
    VALUES(SYSTIMESTAMP,l_owner,l_segmentname,l_partitionNAME,l_type ,
  l_fs1_blocks,l_fs1_bytes,
  l_fs2_blocks,l_fs2_bytes,
  l_fs3_blocks,l_fs3_bytes,
  l_fs4_blocks,l_fs4_bytes,
  l_unformatted_blocks,l_unformatted_bytes);
 l_setp:=7;
 COMMIT;
   l_setp:=8;
  end if;
   l_setp:=9;
/*if there is exception in the PROCEDURE , it will tell you .*/
EXCEPTION WHEN OTHERS THEN
ROLLBACK;
  dbms_output.put_line('V_owner = '||V_owner||';');
  dbms_output.put_line('V_segmentname ='||V_segmentname||';');
  dbms_output.put_line('V_partitionname ='||V_partitionname||';');
  dbms_output.put_line('l_owner = '||l_owner||';');
  dbms_output.put_line('l_segmentname ='||l_segmentname||';');
  dbms_output.put_line('l_partitionname ='||l_partitionname||';');
  dbms_output.put_line('l_type='||l_type||';');
dbms_output.put_line('the procedure has a error, this is exception.'|| l_setp);
raise_application_error(-20601,SQLERRM);
END ;
/
