
CentOS 7 关闭第一次启动欢迎界面  

2018-03-22 12:10:14|  分类： 操作系统 |  标签：案例  操作系统  linux  centos  



今天被问到一个很有意思的问题，每次安装完系统，无论是CentOS6还是7，都会有个欢迎界面，要求你写一大堆内容，感觉到很烦，于是就找寻不设置的解决方案。

来个图，帮助识别是那个界面哈
CentOS 7 关闭第一次启动欢迎界面 - T_T - T_T的博客

那么好了这个东西是什么呢？这个界面是gnome的初始化界面名叫“gnome-initial-setup”，关于gnome的配置内容都在/etc/xdg/autostart/当中。当你完成这些设置后，可以用 strings /etc/xdg/autostart/gnome-initial-setup-first-login.desktop看看内容。警告一下，这个内容是二进制的，不要vi编辑，否则哼哼...
如果这个界面你不设置，那么今后可能需要你手动去设置这些内容。但是这不是我们的问题，我们的问题是不看这个界面，直接用。

[root@rhel7 ~]#
[root@rhel7 ~]# cat /etc/gdm/custom.conf
# GDM configuration storage
 
[daemon]
InitialSetupEnable=False
 
[security]
 
[xdmcp]
 
[greeter]
 
[chooser]
 
[debug]
 
[root@rhel7 ~]#


或者更暴力点，直接命令行启动吧，咱们不看图形化了:P
再次警告，你跳过了这个界面，你会少很多必要信息，可能会对今后造成影响。

参考
https://docs-old.fedoraproject.org/en-US/Fedora/26/html/Installation_Guide/sect-gnome-initial-setup.html
https://standards.freedesktop.org/autostart-spec/autostart-spec-latest.html
http://centosfaq.org/centos/disable-gnome-initial-setup/
http://d-prototype.com/archives/4609
