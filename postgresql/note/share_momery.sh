1，在主机中，可以使用共享内存段将表空间创建在上面，这个是利用了内存部分，比如创建是临时表空间。即便主机瘫痪，重启这个内容也会被清空。


先需要创建一个 /RAM2 的文件夹，这样好挂在。 指定大小10M ， 这样就创建好了。命令如下。

mount tmpfs /RAM2/ -t tmpfs -o size=10M

因为挂载完成是root的，所以需要一个修改权限
chown dev.dev /u02/rawdisk/


df -h 可以看到内容
数据库中按照步骤创建就好了。


2，这里个参数官方推荐大小为总大小的25%，是因为，pg还会额外的使用文件系统的缓存，据说会作为打开文件的缓存。  
