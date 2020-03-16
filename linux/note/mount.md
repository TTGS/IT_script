1，想在Linux里挂载光盘设备  
答：需要先用lsblk看下光盘是否被识别，例如  
[postgres@gpb postgresql-11.6]$ lsblk  
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT  
sda               8:0    0   20G  0 disk   
├─sda1            8:1    0    1G  0 part /boot  
└─sda2            8:2    0   19G  0 part   
  ├─centos-root 253:0    0   17G  0 lvm  /  
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]  
sr0              11:0    1 10.3G  0 rom    

有这个rom类型设备就可以，他就是光盘，用“mount /dev/cdrom /media” 即可  




