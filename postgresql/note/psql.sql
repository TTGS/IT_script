1,psql可以在每次登录的时候使用 ~/.psqlrc , 替你在每次登录前执行psql的环境命令。

2，psql 有个叫做 -E， 例如 psql -E ,可以看到psql使用的是什么sql命令调出的命令。

3，psql内的命令让 \timing on 就会变得失效，没有执行时间显示。
