1，yum的配置用/etc/yum.repos.d/下的文件，如果碰到路径有空格怎么办？  
答：有空个没事，用“\”转意即可，或者ls那个目录，能ls出来的也就可以。

2，yum配置文件里用启用改得是哪个参数  
答：enabled 这个参数 ， 1 启用， 0停用

3，yum刷新命令  
答：需要先清除缓存用yum clean all ,然后用yum repolist 命令刷新出来的正确结果为  
[root@gp CentOS 7 x86_64]# yum clean all 
Loaded plugins: fastestmirror, langpacks
Cleaning repos: base
Cleaning up list of fastest mirrors
[root@gp CentOS 7 x86_64]# yum repolist 
Loaded plugins: fastestmirror, langpacks
Determining fastest mirrors
base                                                            | 3.6 kB  00:00:00     
(1/2): base/group_gz                                            | 165 kB  00:00:00     
(2/2): base/primary_db                                          | 6.0 MB  00:00:00     
repo id                             repo name                                    status
base                                CentOS-7 - Base                              10,097
repolist: 10,097  
[root@gp CentOS 7 x86_64]#   


4，yum配置文件在本地文件系统里全路径写到什么目录下即可？  
答：包所在的文件上一层即可，例如，包都在/root/Packages里，那么我写到/root即可。


5，yum如何修改成本地配置  
答：  
name=CentOS-$releasever - Base  
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra  
baseurl=file:///media    ##这里改成本地地址  
enabled=1  
gpgcheck=0  
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7    

6，如何刷新yum？如何知道配置是否可用？  
答：  
[root@gpb yum.repos.d]# yum repolist all   
已加载插件：fastestmirror, langpacks  
Loading mirror speeds from cached hostfile  
源标识                       源名称                                 状态  
base                         CentOS-7 - Base                        启用: 10,097  
repolist: 10,097  



