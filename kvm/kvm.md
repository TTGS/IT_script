1,kvm检查命令是什么？  
答：egrep -o '(vmx|svm)' /proc/cpuinfo  有内容输出即可表示支持kvm

2，需要包都有什么？  
答：yum install qemu-kvm qemu-img virt-manager libvirt libvirt-client


3，启动kvm图形化命令是什么？  
答：virt-manager 


4，kvm虚拟机的克隆怎么修改mac地址  
答：克隆kvm后，mac地址会变。不用改。

5，kvm虚拟机需要定义一个储存池，存放硬盘文件，也需要定义一个文件路径指出iso所在目录。  

6，在创建kvm虚拟机的时候，如果没指定储存池，他会用default，如果default禁用，那么会提示错误，不过下面的有说custom   

7，在已建立好的kvm上挂光盘？  
答：需要在参数里增加一个新硬件（叫“存储” ） ，  右侧的“设备类型”的下拉菜单里有一个叫“CDROM设备”，添加ISO路径即可。  
