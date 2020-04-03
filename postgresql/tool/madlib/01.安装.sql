madpack.py: ERROR : Failed executing m4 on ... 
这个原因就是没有安装m4 这个软件，
用[root@hp postgres]# yum install m4  解决

官方基本要求
Requirements for installing MADlib:

    gcc and g++ (For OSX, Clang will work for compiling the source, but not for documentation.)
    m4
    patch
    cmake
    pgxn installed
    PostgreSQL (64-bit) 9.2+ with plpython support enabled. Note: plpython may not be enabled in Postgres by default.
来源：
    https://cwiki.apache.org/confluence/display/MADLIB/Installation+Guide
