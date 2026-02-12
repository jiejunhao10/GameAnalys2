DROP SCHEMA IF EXISTS ga2_ods_daily_v2
;

CREATE SCHEMA if NOT EXISTS ga2_ods_daily_v2
;

-- my_ga_ods_2_v2.log_biaoju definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_biaoju_daily
;

-- rid '角色id'
-- stat_date '时间_天'
-- type '镖车类型：1-元宝2-突破丹3-名望贴4-经脉丹5-镖师令6-侠客信物'
-- finish '成功完成次数'
-- grabSucc '成功抢夺次数'
-- biaoshiNum '镖师数量'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_biaoju_daily AS
SELECT
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    type,
    SUM(finish) AS finish,
    SUM(grabSucc) AS grabSucc,
    SUM(biaoshiNum) AS biaoshiNum
FROM
    my_ga_ods_2_v2.log_biaoju
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    type
;

-- my_ga_ods_2_v2.log_boss definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_boss_daily
;

-- rid '角色id'
-- stat_date '时间_天'
-- fightCnt '挑战次数'
-- grabCnt '参与抢夺次数'
-- grabSuccCnt '抢夺成功次数'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_boss_daily AS
SELECT
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    SUM(fightCnt) AS fightCnt,
    SUM(grabCnt) AS grabCnt,
    SUM(grabSuccCnt) AS grabSuccCnt
FROM
    my_ga_ods_2_v2.log_boss
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
;

-- my_ga_ods_2_v2.log_chengjiu definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_chengjiu_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- totalCnt '总数'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_chengjiu_daily AS
SELECT
    rid,
    account,
    name,
    min_lv,
    max_lv,
    svrId,
    stat_date,
    source,
    pid,
    add_cnt,
    reduce_cnt,
    FIRST_VALUE(totalCnt) OVER (
        PARTITION BY
            rid,
            stat_date
        ORDER BY
            time_last DESC
    ) AS totalCnt
FROM
    (
        SELECT
            rid,
            group_concat (DISTINCT account) AS account,
            group_concat (DISTINCT name) AS name,
            MIN(lv) AS min_lv,
            MAX(lv) AS max_lv,
            group_concat (DISTINCT svrId) AS svrId,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
            source AS source,
            group_concat (DISTINCT pid) AS pid,
            SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
            SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
            FIRST (
                totalCnt
                ORDER BY
                    TIME DESC
            ) AS totalCnt,
            first (
                TIME
                ORDER BY
                    TIME DESC
            ) AS time_last
        FROM
            my_ga_ods_2_v2.log_chengjiu
        GROUP BY
            rid,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
            source
    ) t
;

-- my_ga_ods_2_v2.log_copper definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_copper_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- leftCnt '剩余数量'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_copper_daily AS
SELECT
    rid,
    account,
    name,
    min_lv,
    max_lv,
    svrId,
    stat_date,
    source,
    pid,
    add_cnt,
    reduce_cnt,
    FIRST_VALUE(leftCnt) OVER (
        PARTITION BY
            rid,
            stat_date
        ORDER BY
            time_last DESC
    ) AS leftCnt,
FROM
    (
        SELECT
            rid,
            group_concat (DISTINCT account) AS account,
            group_concat (DISTINCT name) AS name,
            MIN(lv) AS min_lv,
            MAX(lv) AS max_lv,
            group_concat (DISTINCT svrId) AS svrId,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
            source,
            group_concat (DISTINCT pid) AS pid,
            SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
            SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
            FIRST (
                leftCnt
                ORDER BY
                    TIME DESC
            ) AS leftCnt,
            first (
                TIME
                ORDER BY
                    TIME DESC
            ) AS time_last
        FROM
            my_ga_ods_2_v2.log_copper
        GROUP BY
            rid,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
            source
    ) t
;

-- my_ga_ods_2_v2.log_createloss definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_createloss_daily
;

-- rid '角色id'
-- name '角色名'
-- svrId '区号'
-- stat_date '时间_天'
-- pid '渠道标识'
-- account '账号'
-- openid '平台原始账号'
-- pf '废弃：平台标识，1-Android，2-ios'
-- dev '设备'
-- old '是否老玩家'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_createloss_daily AS
SELECT
    rid,
    name,
    svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    pid,
    account,
    openid,
    pf,
    dev,
    old
FROM
    my_ga_ods_2_v2.log_createloss
;

-- my_ga_ods_2_v2.log_equip definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_equip_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- itemId '装备ID'
-- itemName '装备名'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_equip_daily AS
SELECT
    rid,
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    MIN(lv) AS min_lv,
    MAX(lv) AS max_lv,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    source,
    group_concat (DISTINCT pid) AS pid,
    SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
    SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
    itemId,
    group_concat (DISTINCT itemName) AS itemName
FROM
    my_ga_ods_2_v2.log_equip
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    source,
    itemId
;

-- my_ga_ods_2_v2.log_exp definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_exp_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- cnt '获得经验数量'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_exp_daily AS
SELECT
    rid,
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    MIN(lv) AS min_lv,
    MAX(lv) AS max_lv,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    source,
    group_concat (DISTINCT pid) AS pid,
    SUM(cnt) AS cnt
FROM
    my_ga_ods_2_v2.log_exp
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    source
;

-- my_ga_ods_2_v2.log_fish definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_fish_daily
;

-- rid '角色id'
-- stat_date '时间_天'
-- grabCnt '参与抢鱼次数'
-- grabSuccCnt '抢鱼成功次数'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_fish_daily AS
SELECT
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    SUM(grabCnt) AS grabCnt,
    SUM(grabSuccCnt) AS grabSuccCnt
FROM
    my_ga_ods_2_v2.log_fish
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
;

;

-- my_ga_ods_2_v2.log_forcetarget definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_forcetarget_daily
;

-- svrId '区号'
-- stat_date '时间_天'
-- forceId '势力id'
-- taskConfigId '任务配置id'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_forcetarget_daily AS
SELECT
    svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    forceId,
    taskConfigId
FROM
    my_ga_ods_2_v2.log_forcetarget
;

-- my_ga_ods_2_v2.log_gem definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_gem_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- itemId '宝石ID'
-- itemName '宝石名称'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_gem_daily AS
SELECT
    rid,
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    MIN(lv) AS min_lv,
    MAX(lv) AS max_lv,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    source,
    group_concat (DISTINCT pid) AS pid,
    SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
    SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
    itemId,
    group_concat (DISTINCT itemName) AS itemName
FROM
    my_ga_ods_2_v2.log_gem
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    source,
    itemId
;

-- my_ga_ods_2_v2.log_gongfa definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_gongfa_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- itemId '功法ID'
-- itemName '功法名称'
-- leftCnt '剩余数量'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_gongfa_daily AS
SELECT
    rid,
    account,
    name,
    min_lv,
    max_lv,
    svrId,
    stat_date,
    source,
    pid,
    add_cnt,
    reduce_cnt,
    itemId,
    pid,
    FIRST_VALUE(leftCnt) OVER (
        PARTITION BY
            rid,
            stat_date,
            itemId
        ORDER BY
            time_last DESC
    ) AS leftCnt
FROM
    (
        SELECT
            rid,
            group_concat (DISTINCT account) AS account,
            group_concat (DISTINCT name) AS name,
            MIN(lv) AS min_lv,
            MAX(lv) AS max_lv,
            group_concat (DISTINCT svrId) AS svrId,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
            source,
            group_concat (DISTINCT pid) AS pid,
            SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
            SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
            itemId,
            group_concat (DISTINCT itemName) AS pid,
            FIRST (
                leftCnt
                ORDER BY
                    TIME DESC
            ) AS leftCnt,
            first (
                TIME
                ORDER BY
                    TIME DESC
            ) AS time_last
        FROM
            my_ga_ods_2_v2.log_gongfa
        GROUP BY
            rid,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
            source,
            itemId
    )
;

-- my_ga_ods_2_v2.log_guide definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_guide_daily
;

-- rid '角色id'
-- svrId '区号'
-- stat_date '时间_天'
-- pid '渠道标识'
-- optId '操作id集合'
-- optId_cnt '操作次数'
-- openid '平台原始账号'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_guide_daily AS
SELECT
    rid,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    group_concat (DISTINCT pid) AS pid,
    group_concat (DISTINCT optId) AS optId,
    COUNT(DISTINCT optId) AS optId_cnt,
    openid
FROM
    my_ga_ods_2_v2.log_guide
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    openid
;

-- my_ga_ods_2_v2.log_gumu definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_gumu_daily
;

-- rid '角色id'
-- stat_date '时间_天'
-- cnt '参与次数'
-- min_floor '最小通关层数'
-- max_floor '最大通关层数'
-- first_floor '初通关层数'
-- last_floor '末通关层数'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_gumu_daily AS
SELECT
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    COUNT(1) AS cnt,
    MIN(FLOOR) AS min_floor,
    MAX(FLOOR) AS max_floor,
    FIRST (
        FLOOR
        ORDER BY
            TIME ASC
    ) AS first_floor,
    FIRST (
        FLOOR
        ORDER BY
            TIME DESC
    ) AS last_floor
FROM
    my_ga_ods_2_v2.log_gumu
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
;

-- my_ga_ods_2_v2.log_haoling definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_haoling_daily
;

-- stat_date '时间_天'
-- cityName '领地名称'
-- rid '参与玩家id'
-- sectIds '参与帮会id集合'
-- cnt '玩家参与次数',这里都为1
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_haoling_daily AS
SELECT
    stat_date,
    cityName,
    rid,
    any_value (sectIds) AS sectIds,
    COUNT(1) AS cnt
FROM
    (
        SELECT
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
            cityName,
            UNNEST(string_split (rids, '_')) AS rid,
            sectIds
        FROM
            my_ga_ods_2_v2.log_haoling
    ) t
GROUP BY
    stat_date,
    cityName,
    rid
;

-- my_ga_ods_2_v2.log_headframe definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_headframe_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- itemId '头像框ID'
-- itemName '头像框名称'
-- expireTime '过期时间'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_headframe_daily AS
SELECT
    rid,
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    MIN(lv) AS min_lv,
    MAX(lv) AS max_lv,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    source,
    group_concat (DISTINCT pid) AS pid,
    SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
    SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
    itemId,
    group_concat (DISTINCT itemName) AS itemName,
    group_concat (DISTINCT expireTime) AS expireTime
FROM
    my_ga_ods_2_v2.log_headframe
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    source,
    itemId
;

-- my_ga_ods_2_v2.log_item definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_item_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- itemId '道具ID'
-- itemName '道具名'
-- leftCnt '剩余数量'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_item_daily AS
SELECT
    rid,
    account,
    name,
    min_lv,
    max_lv,
    svrId,
    stat_date,
    source,
    pid,
    add_cnt,
    reduce_cnt,
    itemId,
    itemName,
    FIRST_VALUE(leftCnt) OVER (
        PARTITION BY
            rid,
            stat_date,
            itemId
        ORDER BY
            time_last DESC
    ) AS leftCnt
FROM
    (
        SELECT
            rid,
            group_concat (DISTINCT account) AS account,
            group_concat (DISTINCT name) AS name,
            MIN(lv) AS min_lv,
            MAX(lv) AS max_lv,
            group_concat (DISTINCT svrId) AS svrId,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
            source,
            group_concat (DISTINCT pid) AS pid,
            SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
            SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
            itemId,
            group_concat (DISTINCT itemName) AS itemName,
            FIRST (
                leftCnt
                ORDER BY
                    TIME DESC
            ) AS leftCnt,
            first (
                TIME
                ORDER BY
                    TIME DESC
            ) AS time_last
        FROM
            my_ga_ods_2_v2.log_item
        GROUP BY
            rid,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
            source,
            itemId
    ) t
;

-- my_ga_ods_2_v2.log_jingli definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_jingli_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- leftCnt '剩余数量'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_jingli_daily AS
SELECT
    rid,
    account,
    name,
    min_lv,
    max_lv,
    svrId,
    stat_date,
    source,
    pid,
    add_cnt,
    reduce_cnt,
    FIRST_VALUE(leftCnt) OVER (
        PARTITION BY
            rid,
            stat_date
        ORDER BY
            time_last DESC
    ) AS leftCnt,
FROM
    (
        SELECT
            rid,
            group_concat (DISTINCT account) AS account,
            group_concat (DISTINCT name) AS name,
            MIN(lv) AS min_lv,
            MAX(lv) AS max_lv,
            group_concat (DISTINCT svrId) AS svrId,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
            source,
            group_concat (DISTINCT pid) AS pid,
            SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
            SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
            FIRST (
                leftCnt
                ORDER BY
                    TIME DESC
            ) AS leftCnt,
            first (
                TIME
                ORDER BY
                    TIME DESC
            ) AS time_last,
        FROM
            my_ga_ods_2_v2.log_jingli
        GROUP BY
            rid,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
            source
    ) t
;

-- my_ga_ods_2_v2.log_leitai_qyh definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_leitai_qyh_daily
;

-- rid '角色id'
-- stat_date '时间_天'
-- isWin '是否挑战成功'
-- cnt '次数'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_leitai_qyh_daily AS
SELECT
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    group_concat (DISTINCT isWin) AS isWin,
    COUNT(1) AS cnt
FROM
    my_ga_ods_2_v2.log_leitai_qyh
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
;

-- my_ga_ods_2_v2.log_leitaibiwu definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_leitaibiwu_daily
;

-- rid '角色id'
-- stat_date '时间_天'
-- challenge_cnt '挑战次数'
-- win_cnt '挑战成功次数'
-- fail_cnt '挑战失败次数'
-- win_targetRank '成功目标名次'
-- fail_targetRank '失败目标名次'
-- last_win_targetRank '最后成功名次'
-- last_fail_targetRank '最后失败名次'
-- last_isWin '是否最后成功'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_leitaibiwu_daily AS
SELECT
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    COUNT(targetRank) AS challenge_cnt,
    COUNT(IF (isWin = 1, targetRank, NULL)) AS win_cnt,
    COUNT(IF (isWin = 0, targetRank, NULL)) AS fail_cnt,
    group_concat (IF (isWin = 1, targetRank, NULL)) AS win_targetRank,
    group_concat (IF (isWin = 0, targetRank, NULL)) AS fail_targetRank,
    FIRST (
        IF (isWin = 1, targetRank, NULL)
        ORDER BY
            IF (isWin = 1, TIME, 1) DESC
    ) AS last_win_targetRank,
    FIRST (
        IF (isWin = 0, targetRank, NULL)
        ORDER BY
            IF (isWin = 0, TIME, 1) DESC
    ) AS last_fail_targetRank,
    FIRST (
        isWin
        ORDER BY
            TIME DESC
    ) AS last_isWin
FROM
    my_ga_ods_2_v2.log_leitaibiwu
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
;

-- my_ga_ods_2_v2.log_login definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_login_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- pid '渠道标识'
-- openid '平台原始账号'
-- register_date '注册时间'
-- register_date_diff '已注册天数'
-- continue_login_date_cnt '连续登陆天数'
-- login_cnt '登录次数'
-- logout_cnt '登出次数'
-- cause_0_cnt '正常登出次数'
-- cause_1_cnt '被挤下线次数'
-- online_time_sec '在线时长_秒'
-- dev '设备'
-- old '是否老玩家'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_login_daily AS
SELECT
    t1.rid,
    t1.account,
    t1.name,
    t1.min_lv,
    t1.max_lv,
    t1.svrId,
    t1.stat_date,
    t1.pid,
    t1.openid,
    t1.register_date,
    date_diff ('day', t1.register_date::date, t1.stat_date::date) + 1 AS register_date_diff,
    ROW_NUMBER() OVER (
        PARTITION BY
            t1.rid,
            date_add (t1.stat_date::date, - t1.date_rn::INT)
        ORDER BY
            t1.stat_date
    ) AS continue_login_date_cnt,
    t1.login_cnt,
    t1.logout_cnt,
    t1.cause_0_cnt,
    t1.cause_1_cnt,
    t2.online_time_sec,
    t1.dev,
    t1.OLD
FROM
    (
        SELECT
            rid,
            group_concat (DISTINCT account) AS account,
            group_concat (DISTINCT name) AS name,
            MIN(lv) AS min_lv,
            MAX(lv) AS max_lv,
            group_concat (DISTINCT svrId) AS svrId,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
            group_concat (DISTINCT pid) AS pid,
            group_concat (DISTINCT openid) AS openid,
            strftime (TO_TIMESTAMP(registerTime), '%Y-%m-%d') AS register_date,
            COUNT(IF (type = 1, 1, NULL)) AS login_cnt,
            COUNT(IF (type = 2, 1, NULL)) AS logout_cnt,
            COUNT(
                IF (
                    type = 2
                    AND cause = 0,
                    1,
                    NULL
                )
            ) AS cause_0_cnt,
            COUNT(
                IF (
                    type = 2
                    AND cause = 1,
                    1,
                    NULL
                )
            ) AS cause_1_cnt,
            group_concat (DISTINCT dev) AS dev,
            group_concat (DISTINCT OLD) AS OLD,
            ROW_NUMBER() OVER (
                PARTITION BY
                    rid
                ORDER BY
                    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
            ) AS date_rn
        FROM
            my_ga_ods_2_v2.log_login
        GROUP BY
            rid,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
            strftime (TO_TIMESTAMP(registerTime), '%Y-%m-%d')
    ) t1
    LEFT JOIN (
        -- 完成在线时长统计
        SELECT
            rid,
            stat_date,
            SUM(IF (log_type = 2, log_time_sec, NULL)) - SUM(IF (log_type = 1, log_time_sec, NULL)) AS online_time_sec
        FROM
            ( -- 登入登出的数据,按天打标
                SELECT
                    rid,
                    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
                    type AS log_type,
                    TIME AS log_time_sec
                FROM
                    my_ga_ods_2_v2.log_login
                UNION ALL
                -- 补充登入登出时间
                SELECT
                    rid,
                    stat_date,
                    UNNEST(string_split (add_sign, ',')) AS log_type,
                    CASE
                        WHEN UNNEST(string_split (add_sign, ',')) = '1' THEN epoch (
                            timezone (
                                'Asia/Shanghai',
                                strptime (stat_date || ' 00:00:00', '%Y-%m-%d %H:%M:%S')
                            )
                        )
                        WHEN UNNEST(string_split (add_sign, ',')) = '2' THEN epoch (
                            timezone (
                                'Asia/Shanghai',
                                strptime (stat_date || ' 23:59:59', '%Y-%m-%d %H:%M:%S')
                            )
                        )
                    END AS log_time_sec
                FROM
                    ( -- 查看角色每天的登陆次数,已确定同一天的登入登出次数最多只会相差1次(跨天登入登出情况).
                        SELECT
                            rid,
                            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
                            -- 当登入次数>登出次数,则补当天的结束作为登出时间
                            -- 当登入次数<登出次数,则补当天的开始作为登出时间
                            -- 当登入次数=登出次数 且 (登出时间-登入时间)的和<0,则需要补当天开始和结束时间(连续跨天登入登出.)
                            CASE
                                WHEN COUNT(IF (type = 1, TIME, NULL)) < COUNT(IF (type = 2, TIME, NULL)) THEN '1'
                                WHEN COUNT(IF (type = 1, TIME, NULL)) > COUNT(IF (type = 2, TIME, NULL)) THEN '2'
                                WHEN SUM(IF (type = 2, TIME, NULL)) - SUM(IF (type = 1, TIME, NULL)) < 0 THEN '1,2'
                                ELSE '0'
                            END AS add_sign
                        FROM
                            my_ga_ods_2_v2.log_login
                        GROUP BY
                            rid,
                            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
                    ) t0
                WHERE
                    add_sign != '0'
            ) t
        GROUP BY
            rid,
            stat_date
    ) t2 ON t1.rid = t2.rid
    AND t1.stat_date = t2.stat_date
;

-- rid '角色id'
-- stat_date '时间_天'
-- 优化版本
SELECT
    rid,
    stat_date,
    SUM(IF (log_type = 2, log_time_sec, NULL)) - SUM(IF (log_type = 1, log_time_sec, NULL)) AS online_time_sec
FROM
    ( -- 登入登出的数据,按天打标
        SELECT
            rid,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
            type AS log_type,
            TIME AS log_time_sec
        FROM
            my_ga_ods_2_v2.log_login
        UNION ALL
        -- 补充登入登出时间
        SELECT
            rid,
            stat_date,
            UNNEST(string_split (add_sign, ',')) AS log_type,
            CASE
                WHEN UNNEST(string_split (add_sign, ',')) = '1' THEN epoch (
                    timezone (
                        'Asia/Shanghai',
                        strptime (stat_date || ' 00:00:00', '%Y-%m-%d %H:%M:%S')
                    )
                )
                WHEN UNNEST(string_split (add_sign, ',')) = '2' THEN epoch (
                    timezone (
                        'Asia/Shanghai',
                        strptime (stat_date || ' 23:59:59', '%Y-%m-%d %H:%M:%S')
                    )
                )
            END AS log_time_sec
        FROM
            ( -- 查看角色每天的登陆次数,已确定同一天的登入登出次数最多只会相差1次(跨天登入登出情况).
                SELECT
                    rid,
                    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
                    -- 当登入次数>登出次数,则补当天的结束作为登出时间
                    -- 当登入次数<登出次数,则补当天的开始作为登出时间
                    -- 当登入次数=登出次数 且 (登出时间-登入时间)的和<0,则需要补当天开始和结束时间(连续跨天登入登出.)
                    CASE
                        WHEN COUNT(IF (type = 1, TIME, NULL)) < COUNT(IF (type = 2, TIME, NULL)) THEN '1'
                        WHEN COUNT(IF (type = 1, TIME, NULL)) > COUNT(IF (type = 2, TIME, NULL)) THEN '2'
                        WHEN SUM(IF (type = 2, TIME, NULL)) - SUM(IF (type = 1, TIME, NULL)) < 0 THEN '1,2'
                        ELSE '0'
                    END AS add_sign
                FROM
                    my_ga_ods_2_v2.log_login
                GROUP BY
                    rid,
                    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
            ) t0
        WHERE
            add_sign != '0'
    ) t
GROUP BY
    rid,
    stat_date
;

-- 每晚记录表
-- my_ga_ods_2_v2.log_lvloss definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_lvloss_daily
;

-- rid '角色id'
-- lv '等级'
-- time '记录时间'
-- lastLogoutTime '最后登出时间'
-- svrId '区号'
-- pid '渠道标识'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_lvloss_daily AS
SELECT
    rid,
    group_concat (DISTINCT lv) AS lv,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    group_concat (
        DISTINCT strftime (TO_TIMESTAMP(lastLogoutTime), '%Y-%m-%d')
    ) AS lastLogoutTime,
    group_concat (DISTINCT svrId) AS svrId,
    group_concat (DISTINCT pid) AS pid
FROM
    my_ga_ods_2_v2.log_lvloss
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
;

-- my_ga_ods_2_v2.log_mail definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_mail_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- mailId '邮件id'
-- sysId '邮件系统id'
-- fujian '邮件附件内容'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_mail_daily AS
SELECT
    rid,
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    source,
    group_concat (DISTINCT mailId) AS mailId,
    group_concat (DISTINCT sysId) AS sysId,
    group_concat (DISTINCT fujian, ';') AS fujian,
    COUNT(mailId) AS mail_cnt
FROM
    my_ga_ods_2_v2.log_mail
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    source
;

-- my_ga_ods_2_v2.log_material_fb definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_material_fb_daily
;

-- rid '角色id'
-- stat_date '时间_天'
-- fbType '副本类型'
-- fbId '副本id，对应难度'
-- costYb '消耗元宝'
-- buyCnt '购买次数'
-- cnt '次数'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_material_fb_daily AS
SELECT
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    fbType,
    group_concat (DISTINCT fbId) AS mailId,
    SUM(costYb) AS costYb,
    SUM(buyCnt) AS fujian,
    COUNT(1) AS cnt
FROM
    my_ga_ods_2_v2.log_material_fb
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    fbType
;

-- my_ga_ods_2_v2.log_money definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_money_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- type '货币类型'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- leftCnt '剩余数量'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_money_daily AS
SELECT
    rid,
    account,
    name,
    min_lv,
    max_lv,
    svrId,
    stat_date,
    source,
    pid,
    type,
    add_cnt,
    reduce_cnt,
    FIRST_VALUE(leftCnt) OVER (
        PARTITION BY
            rid,
            stat_date,
            type
        ORDER BY
            time_last DESC
    ) AS leftCnt
FROM
    (
        SELECT
            rid,
            group_concat (DISTINCT account) AS account,
            group_concat (DISTINCT name) AS name,
            MIN(lv) AS min_lv,
            MAX(lv) AS max_lv,
            group_concat (DISTINCT svrId) AS svrId,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
            source,
            group_concat (DISTINCT pid) AS pid,
            type,
            SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
            SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
            FIRST (
                leftCnt
                ORDER BY
                    TIME DESC
            ) AS leftCnt,
            FIRST (
                TIME
                ORDER BY
                    TIME DESC
            ) AS time_last
        FROM
            my_ga_ods_2_v2.log_money
        GROUP BY
            rid,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
            source,
            type
    ) t
;

-- my_ga_ods_2_v2.log_online definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_online_daily
;

-- svrId '区号'
-- stat_date '时间_天'
-- min_onlineCnt '最小_总在线人数'
-- max_onlineCnt '最大_总在线人数'
-- min_onlineCntNew '最小_新用户在线人数'
-- max_onlineCntNew '最大_新用户在线人数'
-- pid '渠道'
-- pids '渠道分布：pid_numpid2_num2'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_online_daily AS
SELECT
    svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    MIN(onlineCnt) AS min_onlineCnt,
    MAX(onlineCnt) AS max_onlineCnt,
    MIN(onlineCntNew) AS min_onlineCntNew,
    MAX(onlineCntNew) AS max_onlineCntNew,
    string_split (pids, '_') [1] AS pid,
    group_concat (DISTINCT pids) AS pids
FROM
    my_ga_ods_2_v2.log_online
WHERE
    pids != ''
GROUP BY
    svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    string_split (pids, '_') [1]
;

-- my_ga_ods_2_v2.log_paimai definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_paimai_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- svrId '区号'
-- stat_date '时间_天'
-- pid '渠道标识'
-- type '拍卖类型'
-- yuanbao '元宝数'
-- itemId '拍卖道具ID'
-- itemName '拍卖道具名'
-- owner_cnt '成功拍得次数'
-- buy_cnt '一口价买的次数'
-- owner_cost_yuanbao '成功拍得所花费的元宝'
-- buy_cost_yuanbao '一口价买所花费的元宝'
-- armyId '帮会id'
-- cnt '次数'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_paimai_daily AS
SELECT
    rid,
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    group_concat (DISTINCT pid) AS pid,
    type,
    group_concat (DISTINCT yuanbao) AS yuanbao,
    itemId,
    group_concat (DISTINCT itemName) AS itemName,
    COUNT(if (owner = 1, 1, NULL)) AS owner_cnt,
    COUNT(if (buy = 1, 1, NULL)) AS buy_cnt,
    SUM(if (owner = 1, yuanbao, NULL)) owner_cost_yuanbao,
    SUM(if (buy = 1, yuanbao, NULL)) buy_cost_yuanbao,
    group_concat (DISTINCT armyId) AS armyId,
    COUNT(1) AS cnt
FROM
    my_ga_ods_2_v2.log_paimai
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    type,
    itemId
;

-- my_ga_ods_2_v2.log_play definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_play_daily
;

-- rid '角色id'
-- name '角色名'
-- stat_date '时间_天'
-- playId '功能id'
-- otherv '预留字段1'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_play_daily AS
SELECT
    rid,
    group_concat (DISTINCT name) AS name,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    group_concat (DISTINCT playId) AS playId,
    group_concat (DISTINCT otherv) AS otherv
FROM
    my_ga_ods_2_v2.log_play
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
;

-- my_ga_ods_2_v2.log_register definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_register_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- svrId '区号'
-- stat_date '时间_天'
-- pid '渠道标识'
-- openid '平台原始账号'
-- dev '设备'
-- old '是否老玩家'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_register_daily AS
SELECT
    rid,
    account,
    name,
    svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    pid,
    openid,
    dev,
    old
FROM
    my_ga_ods_2_v2.log_register
;

-- my_ga_ods_2_v2.log_reunion definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_reunion_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- goToNew '是否去了新服：1-去了新服0-留在本服'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_reunion_daily AS
SELECT
    rid,
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    MIN(lv) AS min_lv,
    MAX(lv) AS max_lv,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    source,
    group_concat (DISTINCT pid) AS pid,
    group_concat (goToNew) AS goToNew
FROM
    my_ga_ods_2_v2.log_reunion
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    source
;

-- my_ga_ods_2_v2.log_roleinfo definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_roleinfo_daily
;

-- account '账号'
-- name '名字'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- zhanli '战力'
-- yuanbao '当前元宝'
-- totalChargeRmb '总充值金额(包括直购)'
-- stat_date '时间_天'
-- trunkFbId '主线副本id'
-- taskId '主线任务id'
-- wanAnSiId '万安寺id'
-- shili '势力'
-- onlineTime '当日在线时长'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_roleinfo_daily AS
SELECT
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    MIN(lv) AS min_lv,
    MAX(lv) AS max_lv,
    group_concat (DISTINCT zhanli) AS zhanli,
    first (
        yuanbao
        ORDER BY
            TIME DESC
    ) AS yuanbao,
    first (
        totalChargeRmb
        ORDER BY
            TIME DESC
    ) AS totalChargeRmb,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    group_concat (DISTINCT trunkFbId) AS trunkFbId,
    group_concat (DISTINCT taskId) AS taskId,
    group_concat (DISTINCT wanAnSiId) AS wanAnSiId,
    group_concat (DISTINCT shili) AS shili,
    first (
        onlineTime
        ORDER BY
            TIME DESC
    ) AS onlineTime,
FROM
    my_ga_ods_2_v2.log_roleinfo
WHERE
    account != ''
GROUP BY
    account,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
;

-- my_ga_ods_2_v2.log_shenbing definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_shenbing_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- itemId '神兵ID'
-- itemName '神兵名称'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_shenbing_daily AS
SELECT
    rid,
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    MIN(lv) AS min_lv,
    MAX(lv) AS max_lv,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    source,
    group_concat (DISTINCT pid) AS pid,
    SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
    SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
    itemId,
    group_concat (DISTINCT itemName) AS itemName
FROM
    my_ga_ods_2_v2.log_shenbing
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    source,
    itemId
;

-- my_ga_ods_2_v2.log_skin definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_skin_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- itemId '皮肤ID'
-- itemName '皮肤名称'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_skin_daily AS
SELECT
    rid,
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    MIN(lv) AS min_lv,
    MAX(lv) AS max_lv,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    source,
    group_concat (DISTINCT pid) AS pid,
    SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
    SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
    itemId,
    group_concat (DISTINCT itemName) AS itemName
FROM
    my_ga_ods_2_v2.log_skin
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    source,
    itemId
;

-- my_ga_ods_2_v2.log_task definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_task_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- type '类型（1-主线、2章节）'
-- taskId '任务id'
-- status '状态'
-- quick '触发立即完成'
-- cnt '完成次数'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_task_daily AS
SELECT
    rid,
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    MIN(lv) AS min_lv,
    MAX(lv) AS max_lv,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    source,
    group_concat (DISTINCT pid) AS pid,
    type,
    taskId,
    group_concat (DISTINCT status) AS status,
    SUM(quick) AS quick_cnt,
    COUNT(1) AS cnt
FROM
    my_ga_ods_2_v2.log_task
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    source,
    type,
    taskId
;

-- my_ga_ods_2_v2.log_tili definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_tili_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- leftCnt '剩余数量'
-- quickCnt '速战次数'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_tili_daily AS
SELECT
    rid,
    account,
    name,
    min_lv,
    max_lv,
    svrId,
    stat_date,
    source,
    pid,
    add_cnt,
    reduce_cnt,
    FIRST_VALUE(leftCnt) OVER (
        PARTITION BY
            rid,
            stat_date
        ORDER BY
            time_last DESC
    ) AS leftCnt,
    quickCnt
FROM
    (
        SELECT
            rid,
            group_concat (DISTINCT account) AS account,
            group_concat (DISTINCT name) AS name,
            MIN(lv) AS min_lv,
            MAX(lv) AS max_lv,
            group_concat (DISTINCT svrId) AS svrId,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
            source,
            group_concat (DISTINCT pid) AS pid,
            SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
            SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
            first (
                leftCnt
                ORDER BY
                    TIME DESC
            ) AS leftCnt,
            first (
                TIME
                ORDER BY
                    TIME DESC
            ) AS time_last,
            SUM(quickCnt) AS quickCnt
        FROM
            my_ga_ods_2_v2.log_tili
        GROUP BY
            rid,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
            source
    ) t
;

-- my_ga_ods_2_v2.log_title definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_title_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- itemId '称号ID'
-- itemName '称号名称'
-- expireTime '过期时间'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_title_daily AS
SELECT
    rid,
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    MIN(lv) AS min_lv,
    MAX(lv) AS max_lv,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    source,
    group_concat (DISTINCT pid) AS pid,
    SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
    SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
    itemId,
    group_concat (DISTINCT itemName) AS itemName,
    group_concat (DISTINCT expireTime) AS expireTime
FROM
    my_ga_ods_2_v2.log_title
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    source,
    itemId
;

-- my_ga_ods_2_v2.log_touxian definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_touxian_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- itemId '头衔ID'
-- itemName '头衔名称'
-- expireTime '过期时间'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_touxian_daily AS
SELECT
    rid,
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    MIN(lv) AS min_lv,
    MAX(lv) AS max_lv,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    source,
    group_concat (DISTINCT pid) AS pid,
    SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
    SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
    itemId,
    group_concat (DISTINCT itemName) AS itemName,
    group_concat (DISTINCT expireTime) AS expireTime
FROM
    my_ga_ods_2_v2.log_touxian
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    source,
    itemId
;

-- my_ga_ods_2_v2.log_trunk_fb definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_trunk_fb_daily
;

-- rid '角色id'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- stat_date '时间_天'
-- chapter '章节'
-- chapter_cnt '章节数'
-- node '节点id'
-- node_cnt '节点数'
-- cnt '完成次数'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_trunk_fb_daily AS
SELECT
    rid,
    MIN(lv) AS min_lv,
    MAX(lv) AS max_lv,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    group_concat (DISTINCT chapter) AS chapter,
    COUNT(DISTINCT chapter) AS chapter_cnt,
    group_concat (DISTINCT node) AS node,
    COUNT(DISTINCT node) AS node_cnt,
    COUNT(1) AS cnt
FROM
    my_ga_ods_2_v2.log_trunk_fb
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
;

-- my_ga_ods_2_v2.log_wanansi definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_wanansi_daily
;

-- rid '角色id'
-- stat_date '时间_天'
-- min_floor '最小层数'
-- max_floor '最大层数'
-- win_cnt '胜利次数'
-- lose_cnt '失败次数'
-- cnt '总次数'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_wanansi_daily AS
SELECT
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    MIN(floor) AS min_floor,
    MAX(floor) AS max_floor,
    COUNT(IF (isWin = 1, 1, NULL)) AS win_cnt,
    COUNT(IF (isWin = 0, 1, NULL)) AS lose_cnt,
    COUNT(1) AS cnt
FROM
    my_ga_ods_2_v2.log_wanansi
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
;

;

-- my_ga_ods_2_v2.log_war_fb definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_war_fb_daily
;

-- rid '角色id'
-- stat_date '时间_天'
-- chapter '章节'
-- isThrough '是否通关'
-- cnt '总次数'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_war_fb_daily AS
SELECT
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    group_concat (DISTINCT chapter) AS chapter,
    COUNT(chapter) AS chapter_cnt,
    COUNT(IF (isThrough = 1, 1, NULL)) AS through_cnt,
    COUNT(IF (isThrough = 0, 1, NULL)) AS lose_cnt,
    COUNT(1) AS cnt
FROM
    my_ga_ods_2_v2.log_war_fb
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
;

-- my_ga_ods_2_v2.log_warn definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_warn_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- svrId '区号'
-- stat_date '时间_天'
-- warnInfo '警告信息'
-- warn_cnt '警告次数'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_warn_daily AS
SELECT
    rid,
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    group_concat (DISTINCT warnInfo) AS warnInfo,
    COUNT(warnInfo) AS warn_cnt
FROM
    my_ga_ods_2_v2.log_warn
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
;

-- my_ga_ods_2_v2.log_xiake definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_xiake_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- xiakeId '侠客ID'
-- xiakeName '侠客名'
-- changeItem '是否已转换成道具'
-- quality '品质'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_xiake_daily AS
SELECT
    rid,
    group_concat (DISTINCT account) AS account,
    group_concat (DISTINCT name) AS name,
    MIN(lv) AS min_lv,
    MAX(lv) AS max_lv,
    group_concat (DISTINCT svrId) AS svrId,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    source,
    group_concat (DISTINCT pid) AS pid,
    SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
    SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
    xiakeId,
    group_concat (DISTINCT xiakeName) AS xiakeName,
    group_concat (DISTINCT changeItem) AS changeItem,
    group_concat (DISTINCT quality) AS quality
FROM
    my_ga_ods_2_v2.log_xiake
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    source,
    xiakeId
;

-- my_ga_ods_2_v2.log_xiakeexp definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_xiakeexp_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- leftCnt '剩余数量'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_xiakeexp_daily AS
SELECT
    rid,
    account,
    name,
    min_lv,
    max_lv,
    svrId,
    stat_date,
    source,
    pid,
    add_cnt,
    reduce_cnt,
    FIRST_VALUE(leftCnt) OVER (
        PARTITION BY
            rid,
            stat_date
        ORDER BY
            time_last DESC
    ) AS leftCnt,
FROM
    (
        SELECT
            rid,
            group_concat (DISTINCT account) AS account,
            group_concat (DISTINCT name) AS name,
            MIN(lv) AS min_lv,
            MAX(lv) AS max_lv,
            group_concat (DISTINCT svrId) AS svrId,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
            source,
            group_concat (DISTINCT pid) AS pid,
            SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
            SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
            first (
                leftCnt
                ORDER BY
                    TIME DESC
            ) AS leftCnt,
            first (
                TIME
                ORDER BY
                    TIME DESC
            ) AS time_last,
        FROM
            my_ga_ods_2_v2.log_xiakeexp
        GROUP BY
            rid,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
            source
    ) t
;

-- my_ga_ods_2_v2.log_xiayi definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_xiayi_daily
;

-- rid '角色id'
-- name '角色名'
-- stat_date '时间_天'
-- min_xiayiLv '最小侠义等级'
-- max_xiayiLv '最大侠义等级'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_xiayi_daily AS
SELECT
    rid,
    group_concat (DISTINCT name) AS name,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    MIN(xiayiLv) AS min_xiayiLv,
    MAX(xiayiLv) AS max_xiayiLv
FROM
    my_ga_ods_2_v2.log_xiayi
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
;

-- my_ga_ods_2_v2.log_yuanbao definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_yuanbao_daily
;

-- rid '角色id'
-- account '账号'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- svrId '区号'
-- stat_date '时间_天'
-- source '来源'
-- pid '渠道标识'
-- add_cnt '增加_数量'
-- reduce_cnt '减少_数量'
-- leftCnt '剩余数量'
-- old '是否老玩家'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_yuanbao_daily AS
SELECT
    rid,
    account,
    name,
    min_lv,
    max_lv,
    svrId,
    stat_date,
    source,
    pid,
    add_cnt,
    reduce_cnt,
    FIRST_VALUE(leftCnt) OVER (
        PARTITION BY
            rid,
            stat_date
        ORDER BY
            time_last DESC
    ) AS leftCnt,
    old
FROM
    (
        SELECT
            rid,
            group_concat (DISTINCT account) AS account,
            group_concat (DISTINCT name) AS name,
            MIN(lv) AS min_lv,
            MAX(lv) AS max_lv,
            group_concat (DISTINCT svrId) AS svrId,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
            source,
            group_concat (DISTINCT pid) AS pid,
            SUM(IF (cnt >= 0, cnt, 0)) AS add_cnt,
            SUM(IF (cnt < 0, cnt, 0)) AS reduce_cnt,
            first (
                leftCnt
                ORDER BY
                    TIME DESC
            ) AS leftCnt,
            first (
                TIME
                ORDER BY
                    TIME DESC
            ) AS time_last,
            group_concat (DISTINCT old) AS old
        FROM
            my_ga_ods_2_v2.log_yuanbao
        GROUP BY
            rid,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
            source
    ) t
;

-- my_ga_ods_2_v2.log_zhangmen definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_zhangmen_daily
;

-- rid '角色id'
-- stat_date '时间_天'
-- id '关卡id'
-- star '星数'
-- cnt '挑战次数'
-- star_sum '星数_总数量'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_zhangmen_daily AS
SELECT
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    id,
    group_concat (star) AS star,
    COUNT(star) AS cnt,
    SUM(star) AS star_sum
FROM
    my_ga_ods_2_v2.log_zhangmen
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    id
;

-- my_ga_ods_2_v2.log_zhaomu definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.log_zhaomu_daily
;

-- rid '角色id'
-- name '角色名'
-- stat_date '时间_天'
-- zmType '招募类型'
-- zm_cnt '招募次数'
-- gold '使用金手指次数'
-- costYb '招募消耗元宝数'
-- costYbGold '金手指消耗元宝数'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.log_zhaomu_daily AS
SELECT
    rid,
    group_concat (DISTINCT name) AS name,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    zmType,
    COUNT(zmType) AS zm_cnt,
    COUNT(if (gold = 1, 1, NULL)) AS gold_cnt,
    SUM(costYb) AS costYb,
    SUM(costYbGold) AS costYbGold
FROM
    my_ga_ods_2_v2.log_zhaomu
GROUP BY
    rid,
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    zmType
;

-- my_ga_ods_2_v2.recharge definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.recharge_daily
;

-- rid '角色id'
-- stat_date '时间_天'
-- pid '渠道标识'
-- pf '已废弃:平台标识，1-Android，2-ios'
-- status '状态(预留)'
-- svrId '区服'
-- old '是否老玩家'
-- openid '玩家平台账号'
-- registertime '注册时间'
-- firstregistertime '首次创角注册时间'
-- first_recharge_date '首充日期'
-- name '角色名'
-- min_lv '最小等级'
-- max_lv '最大等级'
-- real_cnt 实际充值次数
-- real_money 实际充值金额
-- real_meijin 实际充值美金
-- real_yuanbao 实际充值元宝
-- order_cnt '订单次数'
-- order_money '订单充值金额'
-- order_meijin '订单充值金额-美金'
-- order_yuanbao '订单充值元宝'
-- charge_cnt '正常充值次数'
-- charge_money '正常充值金额'
-- charge_meijin '正常充值金额-美金'
-- charge_yuanbao '正常充值元宝'
-- coupon_cnt '充值代金券次数'
-- coupon_money '充值代金券金额'
-- coupon_meijin '充值代金券金额-美金'
-- coupon_yuanbao '充值代金券元宝'
-- useticket '使用充值券充值'
-- useticket_cnt '使用充值券充值次数'
-- useticket_money '使用充值券充值金额'
-- useticket_yuanbao '使用充值券充值元宝'
-- normal_cnt '普通充值次数'
-- normal_money '普通充值金额'
-- normal_yuanbao '普通充值元宝'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.recharge_daily AS
SELECT
    rid,
    stat_date,
    pid,
    pf,
    status,
    svrId,
    old,
    openid,
    registertime,
    firstregistertime,
    FIRST_VALUE(stat_date) OVER (
        PARTITION BY
            rid
        ORDER BY
            stat_date
    ) AS first_recharge_date,
    FIRST_VALUE(first_recharge_money_tmp) OVER (
        PARTITION BY
            rid
        ORDER BY
            stat_date
    ) AS first_recharge_money,
    name,
    min_lv,
    max_lv,
    real_cnt,
    real_money,
    real_meijin,
    real_yuanbao,
    order_cnt,
    order_money,
    order_meijin,
    order_yuanbao,
    charge_cnt,
    charge_money,
    charge_meijin,
    charge_yuanbao,
    coupon_cnt,
    coupon_money,
    coupon_meijin,
    coupon_yuanbao,
    useticket,
    useticket_cnt,
    useticket_money,
    useticket_yuanbao,
    normal_cnt,
    normal_money,
    normal_yuanbao
FROM
    (
        SELECT
            -- 总订单次数 = 正常充值 + 充值代金券
            rid,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
            group_concat (DISTINCT pid) AS pid,
            group_concat (DISTINCT pf) AS pf,
            group_concat (DISTINCT status) AS status,
            group_concat (DISTINCT svrId) AS svrId,
            group_concat (DISTINCT old) AS old,
            group_concat (DISTINCT openid) AS openid,
            group_concat (DISTINCT registertime) AS registertime,
            group_concat (DISTINCT firstregistertime) AS firstregistertime,
            group_concat (DISTINCT name) AS name,
            MIN(lv) AS min_lv,
            MAX(lv) AS max_lv,
            first (
                money
                ORDER BY
                    TIME ASC
            ) AS first_recharge_money_tmp,
            COUNT(if (useticket != 1, 1, 0)) AS real_cnt,
            SUM(if (useticket != 1, money, 0)) AS real_money,
            SUM(if (useticket != 1, meijin, 0)) AS real_meijin,
            SUM(if (useticket != 1, yuanbao, 0)) AS real_yuanbao,
            COUNT(orderId) AS order_cnt,
            SUM(money) AS order_money,
            SUM(meijin) AS order_meijin,
            SUM(yuanbao) AS order_yuanbao,
            COUNT(if (chargeId != '0', 1, NULL)) AS charge_cnt,
            SUM(if (chargeId != '0', money, 0)) AS charge_money,
            SUM(if (chargeId != '0', meijin, 0)) AS charge_meijin,
            SUM(if (chargeId != '0', yuanbao, 0)) AS charge_yuanbao,
            COUNT(if (chargeId = '0', 1, NULL)) AS coupon_cnt,
            SUM(if (chargeId = '0', money, 0)) AS coupon_money,
            SUM(if (chargeId = '0', meijin, 0)) AS coupon_meijin,
            SUM(if (chargeId = '0', yuanbao, 0)) AS coupon_yuanbao,
            group_concat (DISTINCT useticket) AS useticket,
            -- 正常充值 = 普通充值 + 代金券充值
            COUNT(
                if (
                    chargeId != '0'
                    AND useticket = 1,
                    1,
                    NULL
                )
            ) AS useticket_cnt,
            SUM(
                if (
                    chargeId != '0'
                    AND useticket = 1,
                    money,
                    0
                )
            ) AS useticket_money,
            SUM(
                if (
                    chargeId != '0'
                    AND useticket = 1,
                    yuanbao,
                    0
                )
            ) AS useticket_yuanbao,
            COUNT(
                if (
                    chargeId != '0'
                    AND useticket != 1,
                    1,
                    NULL
                )
            ) AS normal_cnt,
            SUM(
                if (
                    chargeId != '0'
                    AND useticket != 1,
                    money,
                    0
                )
            ) AS normal_money,
            SUM(
                if (
                    chargeId != '0'
                    AND useticket != 1,
                    yuanbao,
                    0
                )
            ) AS normal_yuanbao
        FROM
            my_ga_ods_2_v2.recharge
        GROUP BY
            rid,
            strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d')
    ) t
;

-- my_ga_ods_2_v2.tj_xiake definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.tj_xiake_daily
;

-- stat_date '时间_天'
-- name '侠客名称'
-- total_num '全服数量'
-- matrix_num '上阵数量'
-- assist_matrix_num '助阵数量'
-- lv_avg '上阵人均等级'
-- zhanli_avg '上阵人家均战力'
-- jingmai_avg '上阵人均经脉'
-- tianfu_avg '上阵人均天赋'
-- cost_jingmaidan_avg '上阵人均消耗经脉丹'
-- cost_tupodan_avg '上阵人均消耗突破丹'
-- jingmai_max '经脉最快进度'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.tj_xiake_daily AS
SELECT
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    name,
    first (
        total_num
        ORDER BY
            TIME DESC
    ) AS total_num,
    first (
        matrix_num
        ORDER BY
            TIME DESC
    ) AS matrix_num,
    first (
        assist_matrix_num
        ORDER BY
            TIME DESC
    ) AS assist_matrix_num,
    first (
        lv_avg
        ORDER BY
            TIME DESC
    ) AS lv_avg,
    first (
        zhanli_avg
        ORDER BY
            TIME DESC
    ) AS zhanli_avg,
    first (
        jingmai_avg
        ORDER BY
            TIME DESC
    ) AS jingmai_avg,
    first (
        tianfu_avg
        ORDER BY
            TIME DESC
    ) AS tianfu_avg,
    first (
        cost_jingmaidan_avg
        ORDER BY
            TIME DESC
    ) AS cost_jingmaidan_avg,
    first (
        cost_tupodan_avg
        ORDER BY
            TIME DESC
    ) AS cost_tupodan_avg,
    first (
        jingmai_max
        ORDER BY
            TIME DESC
    ) AS jingmai_max
FROM
    my_ga_ods_2_v2.tj_xiake
GROUP BY
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    name
;

-- my_ga_ods_2_v2.tj_xiake_juexing definition
DROP TABLE IF EXISTS ga2_ods_daily_v2.tj_xiake_juexing_daily
;

-- time '统计时间'
-- name '侠客名称'
-- data '觉醒等级对应的数量'
CREATE TABLE IF NOT EXISTS ga2_ods_daily_v2.tj_xiake_juexing_daily AS
SELECT
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d') AS stat_date,
    name,
    FIRST (
        data
        ORDER BY
            TIME DESC
    ) AS data
FROM
    my_ga_ods_2_v2.tj_xiake_juexing
GROUP BY
    strftime (TO_TIMESTAMP(TIME), '%Y-%m-%d'),
    name