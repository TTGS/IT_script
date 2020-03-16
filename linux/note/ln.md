1,ln 的软链接格式？
答：ln -s 目录 软件链接名字 ,例如 ln -s /root a

2,如何删除软链接？
答：rm 软链接名 ，例如 rm a 不是rm a/ 

3，如何知道是软链接？
答：如果是链接文件的file 就行了，如果链接是目录用file看不出来，在rmdir的时候会报错
[root@gp ~]# rmdir  CentOS7/
rmdir: failed to remove ‘CentOS7/’: Not a directory
[root@gp ~]# rmdir  CentOS7
rmdir: failed to remove ‘CentOS7’: Not a directory
[root@gp ~]# file CentOS7/
CentOS7/: directory
[root@gp ~]# rm
rm             rmail.postfix  rmid           rmmod          
rmail          rmdir          rmiregistry    
[root@gp ~]# rmdir CentOS7/
rmdir: failed to remove ‘CentOS7/’: Not a directory
[root@gp ~]# rm CentOS7/
rm: cannot remove ‘CentOS7/’: Is a directory
[root@gp ~]# rm CentOS7
rm: remove symbolic link ‘CentOS7’? y
