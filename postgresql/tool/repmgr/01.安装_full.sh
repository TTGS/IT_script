#编译前我先声明了PGDATA和PGHOME两个变量并且使他们生效
[postgres@gpa ~]$ cat .bash_profile 
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

export PGHOME=/home/postgres/pg11.6
export PGDATA=/home/postgres/pg11.6/data

PATH=/home/postgres/pg11.6/bin::$PATH:$HOME/.local/bin:$HOME/bin

export PATH
[postgres@gpa repmgr-4.4.0]$     ./configure && make install  #安装编译repmgr
checking for a sed that does not truncate output... /bin/sed
checking for pg_config... /home/postgres/pg11.6/bin/pg_config
configure: building against PostgreSQL 11.6
configure: creating ./config.status
config.status: creating Makefile
config.status: creating Makefile.global
config.status: creating config.h
Building against PostgreSQL 11
...
.sql  '/home/postgres/pg11.6/share/extension/'
/bin/install -c -m 755 repmgr repmgrd '/home/postgres/pg11.6/bin/'
[postgres@gpa repmgr-4.4.0]$ echo $?   #确认成功
0
[postgres@gpa repmgr-4.4.0]$ ./configure && make install-doc    #编译repmgr文档 ， 不过我这里失败了。
checking for a sed that does not truncate output... /bin/sed
checking for pg_config... /home/postgres/pg11.6/bin/pg_config
configure: building against PostgreSQL 11.6
...
***
ERROR: `xsltproc' is missing on your system.
***
make[1]: *** [html-stamp] Error 1
make[1]: Leaving directory `/home/postgres/repmgr-4.4.0/doc'
make: *** [doc] Error 2
[postgres@gpa repmgr-4.4.0]$ cd ..


[postgres@gpa ~]$ rep           #检查是否安装成功  
repmgr               repoquery            reporter-ureport
repmgrd              repo-rss             reposync
repoclosure          report-cli           repotrack
repodiff             reporter-mailx       repquota
repo-graph           reporter-mantisbt    
repomanage           reporter-rhtsupport  


[postgres@gpa ~]$ repmgr --version   #安装成功
repmgr 4.4


[postgres@gpa ~]$ which repmgr   #安装在pg的里面了。
~/pg11.6/bin/repmgr


[postgres@gpa ~]$ vim pg11.6/data/postgresql.conf   #官方给出需要修改或者注意的参数
    # Enable replication connections; set this figure to at least one more
    # than the number of standbys which will connect to this server
    # (note that repmgr will execute `pg_basebackup` in WAL streaming mode,
    # which requires two free WAL senders)
    max_wal_senders = 10
    # Ensure WAL files contain enough information to enable read-only queries
    # on the standby.
    #
    #  PostgreSQL 9.5 and earlier: one of 'hot_standby' or 'logical'
    #  PostgreSQL 9.6 and later: one of 'replica' or 'logical'
    #    ('hot_standby' will still be accepted as an alias for 'replica')
    #
    # See: https://www.postgresql.org/docs/current/static/runtime-config-wal.html#GUC-WAL-LEVEL
    wal_level = 'hot_standby'
    # Enable read-only queries on a standby
    # (Note: this will be ignored on a primary but we recommend including
    # it anyway)
    hot_standby = on
    # Enable WAL file archiving
    archive_mode = on
    # Set archive command to a script or application that will safely store
    # you WALs in a secure place. /bin/true is an example of a command that
    # ignores archiving. Use something more sensible.
    archive_command = '/bin/true'
    # If you have configured "pg_basebackup_options"
    # in "repmgr.conf" to include the setting "--xlog-method=fetch" (from
    # PostgreSQL 10 "--wal-method=fetch"), *and* you have not set
    # "restore_command" in "repmgr.conf"to fetch WAL files from another
    # source such as Barman, you'll need to set "wal_keep_segments" to a
    # high enough value to ensure that all WAL files generated while
    # the standby is being cloned are retained until the standby starts up.
    #
    # wal_keep_segments = 5000
    
    
    
#数据库和repmgr的版本
[postgres@gpa ~]$ repmgr --version 
repmgr 4.4
[postgres@gpa ~]$ repmgrd --version
repmgrd 4.4
[postgres@gpa ~]$ pg_ctl --version
pg_ctl (PostgreSQL) 11.6
[postgres@gpa ~]$ gcc --version
gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-39)
Copyright (C) 2015 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
[postgres@gpa ~]$ make --version
GNU Make 3.82
Built for x86_64-redhat-linux-gnu
Copyright (C) 2010  Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
