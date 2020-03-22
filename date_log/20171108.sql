
PostgreSQL10的备库  

2017-11-08 21:06:28
标签：postgresql  数据库管理 

很多同学知道pg拥有主备复制功能，但问起备库除了为主库降低查询压力还能做什么的时候，就都不知道了。

当然有些同学是好学的，他们还知道备库不能备份，也就是说你想备份需要去主库备份。

这个确实没错，在9.4版本的时候至少备库是不能备份的，想备份的时候需要去主库做。
但是在今天10都出来的时候，备库不能备份已经是一个历史了。
以下是我在10的环境中做的测试。

--搭建主备
（略）

--主库先创建一个带数据的表。
[postgres@xiaoli pgdata]$ psql
psql (10.0)
Type "help" for help.

postgres=# create table test as select generate_series(1,3) id ;
SELECT 3
postgres=#
postgres=#
postgres=#


--备库直接用pg_dump
[postgres@model pgdata]$ pg_dump -t test -d postgres
--
-- PostgreSQL database dump
--

-- Dumped from database version 10.0
-- Dumped by pg_dump version 10.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: test; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE test (
    id integer
);


ALTER TABLE test OWNER TO postgres;

--
-- Data for Name: test; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY test (id) FROM stdin;
1
2
3
\.


--
-- PostgreSQL database dump complete
--

[postgres@model pgdata]$


你看，这不是备库也可以为主库分担备份的压力了？
