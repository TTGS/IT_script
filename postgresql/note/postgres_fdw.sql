创建后，需要给用户授权查询forgine表权限，使用的是  grant select on ALL tables in schema public TO cross_view ;命令 
 
 
--如果本库需要，那么本库就需要安装。
CREATE EXTENSION postgres_fdw;


--可以同时创建多个服务
CREATE SERVER foreign_server
        FOREIGN DATA WRAPPER postgres_fdw
        OPTIONS (host '192.83.123.89', port '5432', dbname 'foreign_db');
 

--一个用户可以挂上多个server内容。配置不同也可以。
CREATE USER MAPPING FOR local_user
        SERVER foreign_server
        OPTIONS (user 'foreign_user', password 'password');

 -- 创建的外部表，是没有单独授权的内容。
CREATE FOREIGN TABLE foreign_table (
        id integer NOT NULL,
        data text
)
        SERVER foreign_server
        OPTIONS (schema_name 'some_schema', table_name 'some_table');


