安装编译PL/python  
报错：
checking Python.h usability... no
checking Python.h presence... no
checking for Python.h... no
configure: error: header file <Python.h> is required for Python
[postgres@hp postgresql-11.6]$ echo $?
1
[postgres@hp postgresql-11.6]$ python
python     python2    python2.7  
[postgres@hp postgresql-11.6]$ python --version
Python 2.7.5
[postgres@hp postgresql-11.6]$ 

解决方法： yum install python python-devel


注：pg可以支持python2 或者python3 。
重新编译configure文件，不一定能解决问题，还要initdb初始化。
如果是只有python2 ，那么扩展就会有plpython2u  plpythonu 
