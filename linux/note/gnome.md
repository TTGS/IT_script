1,每个用户第一次登录的时候都有图形化设置界面，如何关闭？
答：执行ps -ef |grep gnome ，会看到有写gnome initial 字样

2，如何让用户永久不受这个界面骚扰？
答：执行yum erase gnome-initial-setup  《《--这里可能是gnome-initial-setup.x86_64 用tab看一下

3，不想yum掉如何关闭？
答：每个用户都执行
mkdir ~/.config
echo "yes" >> ~/.config/gnome-initial-setup-done
