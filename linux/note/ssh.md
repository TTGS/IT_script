ssh 服务叫sshd ，配置文件在/etc/ssh/sshd_config里



如果远程上不去报错或者scp报错，例如
scp linux.x64_11gR2_database_1of2.zip root@172.16.179.191:/root
root@172.16.179.191's password: 
Permission denied, please try again.
root@172.16.179.191's password: 
Permission denied, please try again.
root@172.16.179.191's password: 
root@172.16.179.191: Permission denied (publickey,gssapi-with-mic,password).
lost connection

需要检查：
1，ssh服务是否开启
2，配置文件配置
  a,将PasswordAuthentication no中的“no”改为yes
  b,如果登录用户是root，那么还要检查  PermitRootLogin 是否为yes . 
