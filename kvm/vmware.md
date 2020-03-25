1，vmware 多个硬盘存储文件可以合并成一个
答：在vmware里带一个工具，vmware-vdiskmanager
例如：vmware-vdiskmanager -r ./Windows7_x64_QQ.vmdk -t 0  ../Windows7_x64_QQ.vmdk
说明： vmware-vdiskmanager -r 源 -t 0  合成之后的文件。  
