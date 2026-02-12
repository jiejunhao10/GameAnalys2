-- 创建mysql连接配置
CREATE PERSISTENT SECRET mysql8 (
    TYPE mysql,
    HOST localhost,
    PORT 3306,
    DATABASE my_ga_ods_2,
    USER 'root',
    PASSWORD 'root'
);

-- 连接mysql
ATTACH '' AS mysql8 (TYPE mysql, SECRET mysql8);



-- 把mysql数据库复制到duck数据库
COPY FROM DATABASE mysql8 TO game_analysis;

-- 把mysql数据库的表结构复制到duck数据库
COPY FROM DATABASE mysql8 TO game_analysis (SCHEMA);


-- 分离mysql
DETACH mysql8;

-- 删除mysql连接配置
DROP PERSISTENT SECRET mysql8;

