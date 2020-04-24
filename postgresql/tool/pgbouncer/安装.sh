这是轻量级共享池  
官网 ： http://www.pgbouncer.org/  

安装基本要求 pgbouncer 1.12  
    GNU Make 3.81+
    Libevent 2.0+
    pkg-config
    OpenSSL 1.0.1+ for TLS support
    (optional) c-ares as alternative to Libevent’s evdns
    (optional) PAM libraries

安装命令  
$ ./configure --prefix=安装路径  
$ make
$ make install

注意：如果没有openssl 安装会报错，需要你使用--without-openssl 参数   


