-收缩
 可以用来收缩段，消除空间碎片的方法有两种：

1.alter table table_name move

需要注意：

1）move操作会锁表。（如果是很小的表，可以在线做。如果是大表一定要注意，会长时间锁表，只能查询，影响正常业务运行。）
2）move操作会使索引失效，一定要rebuild。（因为move操作会改变一些记录的ROWID，所以MOVE之后索引会变为无效，需要REBUILD。）


2.使用shrink space

alter table table_name shrink space

前提条件

1) 必须启用行记录转移(enable row movement)

2) 仅仅适用于堆表,且位于自动段空间管理的表空间(堆表包括:标准表,分区表,物化视图容器,物化视图日志表)

优点：

提高缓存利用率，提高OLTP的性能

减少磁盘I/O，提高访问速度，节省磁盘空间

段收缩是在线的，索引在段收缩期间维护，不要求额外的磁盘空间

加参数

cascade: 缩小表及其索引，并移动高水位线，释放空间

compact: 仅仅是缩小表和索引，并不移动高水位线，不释放空间

如果在业务繁忙时做压缩，

可以使用alter table shrink space compact来对表格进行碎片整理，而不调整高水位线，之后再次调用alter table table_name shrink space来释放空间。

也可以使用alter table table_name shrink space cascade来同时对索引都进行收缩，这等同于同时执行alter index idxname shrink space。
