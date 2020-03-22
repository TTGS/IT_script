psql 修改提示符
在psql进入后，可以使用\set 看到psql变量参数。
[dev@10-0-30-61 ~]$ psql -d postgres
Timing is on.
psql.bin (10.3)
Type "help" for help.

postgres=# \set 
...
PROMPT1 = '%/%R%# '
PROMPT2 = '%/%R%# '
PROMPT3 = '>> '
...
postgres=# 

在这些参数中，和提示符相关的参数是PROMPT1，PROMPT2，PROMPT3 。
以下内容来自官方文档10的内容
The prompts psql issues can be customized to your preference. The three variables PROMPT1, PROMPT2, and PROMPT3 contain strings and special escape sequences that describe the appearance of the prompt. Prompt 1 is the normal prompt that is issued when psql requests a new command. Prompt 2 is issued when more input is expected during command entry, for example because the command was not terminated with a semicolon or a quote was not closed. Prompt 3 is issued when you are running an SQL COPY FROM STDIN command and you need to type in a row value on the terminal.

psql问题的提示可以根据您的喜好进行自定义。 PROMPT1，PROMPT2和PROMPT3这三个变量包含描述提示外观的字符串和特殊转义序列。 PROMPT1是psql请求新命令时发出的正常提示。 如果在命令输入期间预期有更多输入，则会发出PROMPT2，例如，因为命令未以分号终止或报价未关闭。 当您运行SQL COPY FROM STDIN命令并且需要在终端上键入行值时，将发出PROMPT3。

在文档中的psql内容中有代替符号的内容。

如果想修改参数使用\set 然后参数 单引号内容。
例如 \set PROMPT1 '%m %~@%n %R%# '

这里说几个觉得有用的内容。
%m 数据库服务器主机名
%n 数据库会话的用户名
%/ 当前数据库的名称
%~ 当前数据库的名称如果是默认登录库，那么是~
%# 超级用户登录那么提示符是#，普通用户是>


这些设置可以放在~/.psqlrc中，每次启动psql会先用这个文件里的命令。
[local] postgres@dev =#   \q
[dev@10-0-30-61 ~]$ cat ~/.psqlrc
\timing on
\set PROMPT1 '%m %/@%n %R%# '
\set PROMPT2 '%m %/@%n %R%# '
\set PROMPT3 '%m %/@%n %R%# '
[dev@10-0-30-61 ~]$   psql -d taxidb 
Timing is on.
psql.bin (10.3)
Type "help" for help.

[local] taxidb@dev =# 

这样可以防止误操作。

在你的安装目录下 ./share/psqlrc.sample 有这样一个文件，里面这样描述了psqlrc情况
--
--      system-wide psql configuration file
--
--  This file is read before the .psqlrc file in the user's home directory.
--
--  Copy this to your installation's sysconf directory and rename it psqlrc.
--  The sysconf directory can be identified via "pg_config --sysconfdir".

这个需要在PGHOME目录里创建一个etc目录，里面新建一个psqlrc文件，那么psql启动进入数据库的时候，
会优先读取这个文件，然后才是～/.psqlrc配置。



