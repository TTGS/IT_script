1，zeromq
https://github.com/zeromq/libzmq

2,libtool   centos7 里有这个rpm包
https://www.gnu.org/software/libtool/ 官网
http://savannah.gnu.org/git/?group=libtool  文件官网
http://ftp.gnu.org/gnu/libtool/   下载文件地址


error
1,pipeline :src/pzmq.c:12:17: fatal error: zmq.h: No such file or directory
 #include <zmq.h>
                 ^
compilation terminated.
$./configure && make && make install 



2,zeromq : configure: error: Unable to find a working C++ compiler
yum install gcc-c++

3,zeromq:autogen.sh: error: could not find libtool.  libtool is required to run autogen.sh.
yum install libtool
