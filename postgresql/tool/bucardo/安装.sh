bucardo是一个异步数据框架软件。
他需要在你正式安装前安装 Perl 的 DBI 软件。
并且要求你在数据库里有pgperl扩展。（源代码编译configure 的时候 需要加 --with-perl 即可获得这个扩展。）

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

 
bucardo安装命令 
   perl Makefile.PL
   make
   make test 
  sudo  make install

安装完成后，需要在bucardo的压缩包里执行安装数据库命令，（我当时的数据库是开启的）
bucardo install 



