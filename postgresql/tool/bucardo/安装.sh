bucardo是一个异步数据框架软件。
他需要在你正式安装前安装 Perl 的 DBI 软件。

官方网站，
https://bucardo.org/Bucardo/

安装DBI软件会报错：
[postgres@hp DBIx-Safe-1.2.5]$ perl Makefile.PL 
Can't locate ExtUtils/MakeMaker.pm in @INC (@INC contains: /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .) at Makefile.PL line 2.
BEGIN failed--compilation aborted at Makefile.PL line 2.

解决方法， yum install perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker  

这里成功是：
[postgres@hp DBIx-Safe-1.2.5]$ perl Makefile.PL 
Checking if your kit is complete...
Looks good
Writing Makefile for DBIx::Safe
Writing MYMETA.yml and MYMETA.json
[postgres@hp DBIx-Safe-1.2.5]$ echo $?
0

DBI安装命令，在README里有写
   perl Makefile.PL
   make
   make test (but see below first)
   make install


其实安装bucardo也是这几个命令。
DBI和bucardo本用户即可安装。
