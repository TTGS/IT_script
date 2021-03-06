 --to create a table by record result .
 --drop table SEGMENT_FREE_table;
create table SEGMENT_FREE_table
(
create_time timestamp , --create the row date time 
OWNER varchar2(300),  --user
SEGMENT_NAME  varchar2(300), --segment name 
segment_type   varchar2(300), --segment type 
partition_name varchar2(300),  --segment partition name
free_025_blocks number, --0-25%   Free blocks
free_025_bytes number,  --0-25%   Free bytes
free_2550_blocks number, --25-50%  Free blocks
free_2550_bytes number,  --25-50%  Free bytes
free_5075_blocks number, --50-75%  Free blocks
free_5075_bytes number,  --50-75%  Free bytes
free_75100_blocks number, --75-100% Free blocks
free_75100_bytes number,  --75-100% Free bytes
free_full_blocks number, --Full    Free blocks
free_full_bytes number   --Full    Free bytes 
);
-- Add comments to the tables 
comment on table SEGMENT_FREE_table is 'segment free mapping';
-- Add comments to the columns 
comment on column SEGMENT_FREE_table.create_time is 'create the row date time';
comment on column SEGMENT_FREE_table.OWNER is 'segment user';
comment on column SEGMENT_FREE_table.SEGMENT_NAME is 'segment name';
comment on column SEGMENT_FREE_table.partition_NAME is 'segment partition name';
comment on column SEGMENT_FREE_table.segment_type is 'segment type';
comment on column SEGMENT_FREE_table.free_025_blocks is '0-25% Free blocks ';
comment on column SEGMENT_FREE_table.free_025_bytes is '0-25% Free bytes ';
comment on column SEGMENT_FREE_table.free_2550_blocks is '25-50% Free blocks ';
comment on column SEGMENT_FREE_table.free_2550_bytes is '25-50% Free bytes ';
comment on column SEGMENT_FREE_table.free_5075_blocks is '50-75% Free blocks ';
comment on column SEGMENT_FREE_table.free_5075_bytes is '50-75% Free bytes ';
comment on column SEGMENT_FREE_table.free_75100_blocks is '75-100% Free blocks ';
comment on column SEGMENT_FREE_table.free_75100_bytes is '75-100% Free bytes ';
comment on column SEGMENT_FREE_table.free_full_blocks is 'Full Free blocks(unformatted) ';
comment on column SEGMENT_FREE_table.free_full_bytes is 'Full Free bytes(unformatted) ';

