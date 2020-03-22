
#清除之前的用户，redhat会在安装系统的时候自动安装老版的PostgreSQL内容，
#删除掉原有用户即可，之前的需要卸载就rpm卸载，
#老版本不卸载也行，PostgreSQL启动的时候是看$PGDATA这个目录启动内容的。
#除非你不指定可能造成混乱。
#请确保你的服务器是UTF8的字符集或兼容字符集。
[root@ttgs ~]# userdel -rf postgres 


#新建一个PostgreSQL数据库在当前操作系统的管理用户。
#并且设置该操作系统管理用户密码。
#注：
#1，这里的操作系统的管理用户叫什么都行，只不过如果使用postgres可以在登录的时候少写数据库用户名。
#2，这里一定不要用root用户，不过可以用root编译，然后集体赋宿主给别的用户，但要在初始化initdb前，否则initdb会阻止你的初始化。
[root@ttgs ~]# useradd postgres
[root@ttgs ~]# echo postgres |passwd --stdin postgres
Changing password for user postgres.
passwd: all authentication tokens updated successfully.

#将源代码复制过去，并且确保操作系统的管理用户有权对包操作。
[root@ttgs ~]# cp postgresql-10.6.tar.gz /home/postgres/
[root@ttgs ~]# chown postgres.postgres /home/postgres/postgresql-10.6.tar.gz 
[root@ttgs ~]# ll /home/postgres/postgresql-10.6.tar.gz
-rw-r--r--. 1 postgres postgres 26902911 Dec  4 06:23 /home/postgres/postgresql-10.6.tar.gz

#切换到该用户并解压缩。
#官方提供两种源代码压缩包一个是gz一个是zip，我这里选择了一个。
[root@ttgs ~]# su - postgres 
[postgres@ttgs ~]$ tar -zxvf postgresql-10.6.tar.gz 
postgresql-10.6/
postgresql-10.6/.dir-locals.el
postgresql-10.6/contrib/
... 省略部分内容 ...
postgresql-10.6/aclocal.m4
postgresql-10.6/configure.in
postgresql-10.6/INSTALL

#创建一个安装目录，确保操作系统的管理用户有绝对控制权限（读写是必须的）。
[postgres@ttgs ~]$ mkdir pg106
[postgres@ttgs ~]$ ll
total 26276
drwxrwxr-x. 2 postgres postgres        6 Dec  4 06:23 pg106
drwxrwxr-x. 6 postgres postgres      273 Nov  5 16:59 postgresql-10.6
-rw-r--r--. 1 postgres postgres 26902911 Dec  4 06:23 postgresql-10.6.tar.gz
[postgres@ttgs ~]$ cd postgresql-10.6/

#编译需要先对编译文件进行配置和基本的包检查。
#可以先看一下帮助内容。
#用注释的方式说明一些比较有用的东西。
[postgres@ttgs postgresql-10.6]$ ./configure --help
'configure' configures PostgreSQL 10.6 to adapt to many kinds of systems.

Usage: ./configure [OPTION]... [VAR=VALUE]...

To assign environment variables (e.g., CC, CFLAGS...), specify them as
VAR=VALUE.  See below for descriptions of some of the useful variables.

Defaults for the options are specified in brackets.

Configuration:
  -h, --help              display this help and exit
      --help=short        display options specific to this package
      --help=recursive    display the short help of all the included packages
  -V, --version           display version information and exit
  -q, --quiet, --silent   do not print 'checking ...' messages
      --cache-file=FILE   cache test results in FILE [disabled]
  -C, --config-cache      alias for '--cache-file=config.cache'
  -n, --no-create         do not create output files
      --srcdir=DIR        find the sources in DIR [configure dir or '..']

Installation directories:
  --prefix=PREFIX         install architecture-independent files in PREFIX
                          [/usr/local/pgsql] #软件的安装目录，中括号里的是默认路径。
  --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX
                          [PREFIX]

By default, 'make install' will install all the files in
'/usr/local/pgsql/bin', '/usr/local/pgsql/lib' etc.  You can specify
an installation prefix other than '/usr/local/pgsql' using '--prefix',
for instance '--prefix=$HOME'.

For better control, use the options below.
#下面的参数是可以将PostgreSQL的对应内容编译在不同的文件夹中。默认放在一起。
Fine tuning of the installation directories:
  --bindir=DIR            user executables [EPREFIX/bin]
  --sbindir=DIR           system admin executables [EPREFIX/sbin]
  --libexecdir=DIR        program executables [EPREFIX/libexec]
  --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
  --sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
  --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
  --libdir=DIR            object code libraries [EPREFIX/lib]
  --includedir=DIR        C header files [PREFIX/include]
  --oldincludedir=DIR     C header files for non-gcc [/usr/include]
  --datarootdir=DIR       read-only arch.-independent data root [PREFIX/share]
  --datadir=DIR           read-only architecture-independent data [DATAROOTDIR]
  --infodir=DIR           info documentation [DATAROOTDIR/info]
  --localedir=DIR         locale-dependent data [DATAROOTDIR/locale]
  --mandir=DIR            man documentation [DATAROOTDIR/man]
  --docdir=DIR            documentation root [DATAROOTDIR/doc/postgresql]
  --htmldir=DIR           html documentation [DOCDIR]
  --dvidir=DIR            dvi documentation [DOCDIR]
  --pdfdir=DIR            pdf documentation [DOCDIR]
  --psdir=DIR             ps documentation [DOCDIR]

System types:
  --build=BUILD     configure for building on BUILD [guessed]
  --host=HOST       cross-compile to build programs to run on HOST [BUILD]

Optional Features:
  --disable-option-checking  ignore unrecognized --enable/--with options
  --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
  --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
  --disable-integer-datetimes
                          obsolete option, no longer supported
  --enable-nls[=LANGUAGES]
                          enable Native Language Support
  --disable-rpath         do not embed shared library search path in
                          executables
  --disable-spinlocks     do not use spinlocks
  --disable-atomics       do not use atomic operations
  --disable-strong-random do not use a strong random number source
  --enable-debug          build with debugging symbols (-g)
  --enable-profiling      build with profiling enabled
  --enable-coverage       build with coverage testing instrumentation
  --enable-dtrace         build with DTrace support
  --enable-tap-tests      enable TAP tests (requires Perl and IPC::Run)
  --enable-depend         turn on automatic dependency tracking
  --enable-cassert        enable assertion checks (for debugging)
  --disable-thread-safety disable thread-safety in client libraries
  --disable-largefile     omit support for large files
  --disable-float4-byval  disable float4 passed by value
  --disable-float8-byval  disable float8 passed by value

Optional Packages:
  --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
  --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
  --with-extra-version=STRING
                          append STRING to version
  --with-template=NAME    override operating system template
  --with-includes=DIRS    look for additional header files in DIRS
  --with-libraries=DIRS   look for additional libraries in DIRS
  --with-libs=DIRS        alternative spelling of --with-libraries
  --with-pgport=PORTNUM   set default port number [5432] #默认的数据库端口，这个可以在后期修改
  --with-blocksize=BLOCKSIZE #物理表的最小保存单位，默认8k，最大32k，直接影响单表最大是多大。
                          set table block size in kB [8] 
  --with-segsize=SEGSIZE  set table segment size in GB [1] 
  # 数据库在底层将一个表分成多个文件，每个文件有多大，这个是为了躲避某些文件系统大小限制的问题。
  --with-wal-blocksize=BLOCKSIZE # wal是PostgreSQL的日志，每个日子块有多大。PostgreSQL 12 将自己带动态修改能力。
                          set WAL block size in kB [8]
  --with-wal-segsize=SEGSIZE # 每个wal日志的文件有多大，默认是16M ,可以对应弄大点。
                          set WAL segment size in MB [16]
  --with-CC=CMD           set compiler (deprecated)
  --with-icu              build with ICU support
  --with-tcl              build Tcl modules (PL/Tcl)  #可以在函数中用tcl代码写，需要tcl编译器。
  --with-tclconfig=DIR    tclConfig.sh is in DIR
  --with-perl             build Perl modules (PL/Perl) #可以在函数中用perl代码写，需要perl编译器。
  --with-python           build Python modules (PL/Python) #可以在函数中用python代码写，需要python编译器。
  --with-gssapi           build with GSSAPI support
  --with-krb-srvnam=NAME  default service principal name in Kerberos (GSSAPI)
                          [postgres]
  --with-pam              build with PAM support
  --with-bsd-auth         build with BSD Authentication support
  --with-ldap             build with LDAP support
  --with-bonjour          build with Bonjour support
  --with-openssl          build with OpenSSL support
  --with-selinux          build with SELinux support
  --with-systemd          build with systemd support
  --without-readline      do not use GNU Readline nor BSD Libedit for editing
  --with-libedit-preferred
                          prefer BSD Libedit over GNU Readline
  --with-uuid=LIB         build contrib/uuid-ossp using LIB (bsd,e2fs,ossp) #数据库可以使用uuid扩展。
  --with-ossp-uuid        obsolete spelling of --with-uuid=ossp
  --with-libxml           build with XML support
  --with-libxslt          use XSLT support when building contrib/xml2
  --with-system-tzdata=DIR
                          use system time zone data in DIR
  --without-zlib          do not use Zlib
  --with-gnu-ld           assume the C compiler uses GNU ld [default=no]

Some influential environment variables:
  CC          C compiler command
  CFLAGS      C compiler flags
  LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
              nonstandard directory <lib dir>
  LIBS        libraries to pass to the linker, e.g. -l<library>
  CPPFLAGS    (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
              you have headers in a nonstandard directory <include dir>
  CPP         C preprocessor
  PKG_CONFIG  path to pkg-config utility
  PKG_CONFIG_PATH
              directories to add to pkg-config's search path
  PKG_CONFIG_LIBDIR
              path overriding pkg-config's built-in search path
  ICU_CFLAGS  C compiler flags for ICU, overriding pkg-config
  ICU_LIBS    linker flags for ICU, overriding pkg-config
  LDFLAGS_EX  extra linker flags for linking executables only
  LDFLAGS_SL  extra linker flags for linking shared libraries only

Use these variables to override the choices made by 'configure' or to help
it to find libraries and programs with nonstandard names/locations.

Report bugs to <pgsql-bugs@postgresql.org>.


#设置好自己的参数就好，这里推荐使用全路径，避免编译造成问题。
#如果缺少包，这里会提示并且停止。安上对应的包和devel包就好了。
[postgres@ttgs postgresql-10.6]$ ./configure --prefix=/home/postgres/pg106 
checking build system type... x86_64-pc-linux-gnu
checking host system type... x86_64-pc-linux-gnu
checking which template to use... linux
checking whether NLS is wanted... no
checking for default port number... 5432
checking for block size... 8kB
checking for segment size... 1GB
checking for WAL block size... 8kB
checking for WAL segment size... 16MB
checking for gcc... gcc
... 省略部分内容 ...
config.status: linking src/backend/port/dynloader/linux.h to src/include/dynloader.h
config.status: linking src/include/port/linux.h to src/include/pg_config_os.h
config.status: linking src/makefiles/Makefile.linux to src/Makefile.port
[postgres@ttgs postgresql-10.6]$ echo $?
0

#虽然是说的make 就行，可用gmake world 进行编译，
#不同的是他会将contrib下的扩展一同编译，
#不加world，就给自己去contrib下自己编译全部组件扩展。
#单独make 和 gmake 是没有太多区别的。
#-j 10 说是可以开10个进程一起编译。
[postgres@ttgs postgresql-10.6]$ gmake world -j 10
gmake -C doc all
gmake -C src all
gmake -C config all
gmake[1]: Entering directory '/home/postgres/postgresql-10.6/doc'
gmake -C src all
... 省略部分内容 ...
gmake[2]: Leaving directory '/home/postgres/postgresql-10.6/contrib/pgcrypto'
gmake[1]: Leaving directory '/home/postgres/postgresql-10.6/contrib'
PostgreSQL, contrib, and documentation successfully made. Ready to install.
[postgres@ttgs postgresql-10.6]$ echo $?
0

#gmake之后需要正式安装了，
#可以用make install 或者 gmake install 
#如果是gmake world进行全部编译的，
#gmake install-world进行全部安装。
#-j 4 同时开4个进程进行安装。
[postgres@ttgs postgresql-10.6]$ gmake install-world -j 4
gmake -C doc install
gmake -C src install
gmake -C config install
gmake[1]: Entering directory '/home/postgres/postgresql-10.6/doc'
gmake[1]: Entering directory '/home/postgres/postgresql-10.6/config'
... 省略部分内容 ...
/bin/install -c -m 644 ./unaccent.rules '/home/postgres/pg106/share/tsearch_data/'
gmake[2]: Leaving directory '/home/postgres/postgresql-10.6/contrib/unaccent'
gmake[1]: Leaving directory '/home/postgres/postgresql-10.6/contrib'
PostgreSQL, contrib, and documentation installation complete.

#看到完成就可以退出去到安装目录了。软件安装完毕，需要初始化数据库了。
[postgres@ttgs postgresql-10.6]$ cd ..
[postgres@ttgs ~]$ ls
pg106  postgresql-10.6  postgresql-10.6.tar.gz
[postgres@ttgs ~]$ cd pg106/
[postgres@ttgs pg106]$ ls
bin  include  lib  share

#增加一个PATH变量读取内容，并且生效。
[postgres@ttgs pg106]$ vim ~/.bash_profile 
# .bash_profile

# Get the aliases and functions
        . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH
~
~
~
~
~
~
"~/.bash_profile" 12L, 219C written                                             
[postgres@ttgs pg106]$ source ~/.bash_profile

#初始化的数据库需要放在那里，创建一个初始化的目录，这个目录就是被称作$PGDATA
[postgres@ttgs pg106]$ mkdir pgdata

#初始化数据库是initdb命令，这个东西在安装的目录/bin里。
#可以看一下帮助。
[postgres@ttgs pg106]$ initdb --help
initdb initializes a PostgreSQL database cluster.

Usage:
  initdb [OPTION]... [DATADIR]

Options:
  -A, --auth=METHOD         default authentication method for local connections
      --auth-host=METHOD    default authentication method for local TCP/IP connections
      --auth-local=METHOD   default authentication method for local-socket connections
 [-D, --pgdata=]DATADIR     location for this database cluster  #初始化目录在哪里，这个是必须的。
  -E, --encoding=ENCODING   set default encoding for new databases 
  #这里如果操作系统是一个字符集，这里可以设置数据库的字符集，注意想支持非英语类内容需要UTF8
      --locale=LOCALE       set default locale for new databases
      --lc-collate=, --lc-ctype=, --lc-messages=LOCALE
      --lc-monetary=, --lc-numeric=, --lc-time=LOCALE
                            set default locale in the respective category for
                            new databases (default taken from environment)
      --no-locale           equivalent to --locale=C
      --pwfile=FILE         read password for the new superuser from file
  -T, --text-search-config=CFG
                            default text search configuration
  -U, --username=NAME       database superuser name
  -W, --pwprompt            prompt for a password for the new superuser
  -X, --waldir=WALDIR       location for the write-ahead log directory
  #指定wal日志在哪里，系统在pgdata/pg_wal建立一个软连接进行连接你指定的目录，这个可以手动建立进行。

Less commonly used options:
  -d, --debug               generate lots of debugging output
  -k, --data-checksums      use data page checksums 
  #如果是生产环境，推荐你使用该参数，他会最大确保你的数据块，数据页的安装完整，默认不用。
  #注意：如果开启，那么数据库在某些环境下出现比关闭情况要慢的情况。毕竟要校验数据。
  -L DIRECTORY              where to find the input files
  -n, --no-clean            do not clean up after errors
  -N, --no-sync             do not wait for changes to be written safely to disk
  -s, --show                show internal settings
  -S, --sync-only           only sync data directory

Other options:
  -V, --version             output version information, then exit
  -?, --help                show this help, then exit

If the data directory is not specified, the environment variable PGDATA
is used.

Report bugs to <pgsql-bugs@postgresql.org>.

#选择好了可以初始化了。
[postgres@ttgs pg106]$ initdb pgdata/
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.UTF-8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory pgdata ... ok
creating subdirectories ... ok
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting dynamic shared memory implementation ... posix
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok

WARNING: enabling "trust" authentication for local connections
You can change this by editing pg_hba.conf or using the option -A, or
--auth-local and --auth-host, the next time you run initdb.

Success. You can now start the database server using:

    pg_ctl -D pgdata/ -l logfile start

#初始化后，可以通过pg_ctl进行开启，当然你熟悉postgres命令，用postgres命令开启也行。
#指定$PGDATA相当于指定了开启的数据库实例。
#-D 这个推荐每次执行的时候都指定，不推荐你设置$PGDATA 参数去节省时间。
[postgres@ttgs pg106]$ pg_ctl start -D pgdata/
waiting for server to start....2018-12-04 06:41:10.583 EST [12942] LOG:  listening on IPv6 address "::1", port 5432
2018-12-04 06:41:10.583 EST [12942] LOG:  listening on IPv4 address "127.0.0.1", port 5432
2018-12-04 06:41:10.585 EST [12942] LOG:  listening on Unix socket "/tmp/.s.PGSQL.5432"
2018-12-04 06:41:10.593 EST [12943] LOG:  database system was shut down at 2018-12-04 06:41:03 EST
2018-12-04 06:41:10.595 EST [12942] LOG:  database system is ready to accept connections
 done
server started

#用psql进去看看吧，如果你使用其他的操作系统的管理用户，那么这里你需要指定登录用户 -U
#默认使用于操作系统管理用户相同的名称的用户和库名登录。
[postgres@ttgs pg106]$ psql
psql (10.6)
Type "help" for help.

postgres=# select version();
                                                 version                                          
       
--------------------------------------------------------------------------------------------------
-------
 PostgreSQL 10.6 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-16), 
64-bit
(1 row)

postgres=# \q
[postgres@ttgs pg106]$ 

