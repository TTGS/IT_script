current_catalog	 	    			当前数据库名（SQL 标准中称作“目录”）
current_database()	 				当前数据库名
current_query()	    				当前正在执行的查询的文本，和客户端提交的一样（可能包含多于一个语句）
current_role						等效于current_user
current_schema[()]					当前模式名
current_schemas(boolean)			搜索路径中的模式名，可以选择是否包含隐式模式
current_user						当前执行上下文的用户名
inet_client_addr()					远程的客户端连接地址
inet_client_port()					远程的客户端连接端口
inet_server_addr()					本地的服务端连接地址
inet_server_port()					本地的服务端连接端口
pg_backend_pid()					与当前会话关联的服务器进程的进程 ID 
