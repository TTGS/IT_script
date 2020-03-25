ERROR:  password is required
DETAIL:  Non-superuser cannot connect if the server does not request a password.
HINT:  Target server's authentication method must be changed.

如果这个错误触发的是一个postgres_fdw相关的外部表 forgine table ， 那么原因可能是提供方的pg_hba.conf 的ip地址认证方式错误。
如果你要带密码过去查询需要让 pg_hba.conf 的认证方式是md5 而不是trust 
