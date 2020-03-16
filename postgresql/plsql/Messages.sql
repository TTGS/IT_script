

在pg中，显示内容是使用raise关键词，格式如下
RAISE level format;

level是显示消息等级。format是消息格式。

消息等级由弱到强
    DEBUG     调试级别
    LOG       日志级别
    NOTICE    通告级别
    INFO      信息级别
    WARNING   警告级别
    exception 异常级别
最后异常级别是可以直接触发异常处理级别。一般使用也就是info或者notice就好了。
神马？你问我为什么？看下面

--匿名块
DO $$ 
BEGIN 
  RAISE DEBUG 'debug message ';
  RAISE LOG 'log message ';
  RAISE NOTICE 'notice message ';
  RAISE INFO 'information message ';
  RAISE WARNING 'warning message ';
  RAISE exception 'exception message';
EXCEPTION
    WHEN others  THEN
        RAISE NOTICE 'exception message in exception';
END $$;

--输出
00000: notice message 
00000: information message 
01000: warning message 
00000: exception message in exception

你会发现有很多级别根本没有显示嘛。
是的，我们挨个说。
'debug message '和'log message '没有输出，是因为这俩个级别太低了，
低到什么样子呢？他只会在数据库后台的log里进行输出，
但是'debug message '级别更惨淡，有时候你甚至都不能在日志级别中看到，
什么时候'debug message '我们还不能在数据库输出log日志中看到呢？
这个和数据库两个参数开启的级别有关——client_min_messages和log_min_messages ，
如果这俩参数你能开到细节最高，到达debug级别才能看到。

'exception message' 没有输出是因为 RAISE exception 可以直接触发异常处理，
所以你看到的是异常处理里面的内容 'exception message in exception'

肯定有人问raise 里我不写level默认是什么级别呢？请看下面的实验。

--匿名块
DO $$ 
BEGIN 
  RAISE  'wa';
EXCEPTION
    WHEN others  THEN
        RAISE NOTICE 'exception message in exception';
END $$;

输出
00000: exception message in exception

是的，RAISE默认级别是 exception 。

什么样的代码会用到exception级别呢？该级别一般被用作自定义异常。例如

DO $$ 
declare
a int :=1;
BEGIN 
	  IF a==1 THEN
     RAISE EXCEPTION 'any thing' ;
    END IF;
EXCEPTION
    WHEN others  THEN
        RAISE NOTICE 'PostgreSQL tell you a message';
END $$;

输出
00000: PostgreSQL tell you a message

当然有人问 RAISE EXCEPTION  后面写什么和输出有什么关系吗？其实没有太大关系
看下面的例子


DO $$ 
declare
a int :=1;
BEGIN 
	  IF a==1 THEN
     RAISE EXCEPTION   ;
    END IF;
EXCEPTION
    WHEN others  THEN
        RAISE NOTICE 'PostgreSQL tell you a message';
END $$;

输出
SQL Error [42601]: 错误: 语法错误 在 ";" 或附近的


抄袭官方文档一个例子让我们继续理解,提示略有修改

DO $$ 
declare
user_id int :=1;
BEGIN 
RAISE EXCEPTION 'user_id --> %', user_id USING HINT = 'it user_id';
END $$;

输出
SQL Error [P0001]: 错误: user_id --> 1
  Hint: it user_id


DO $$ 
declare
user_id int :=1;
BEGIN 
RAISE exception  'abc' USING ERRCODE = 'my exception';
END $$;

输出
SQL Error [42704]: 错误: 不可识别的异常条件"my exception"


DO $$ 
declare
user_id int :=1;
BEGIN 
RAISE exception 'abc' USING ERRCODE = '5432';
END $$;

输出
SQL Error [42704]: 错误: 不可识别的异常条件"5432"
