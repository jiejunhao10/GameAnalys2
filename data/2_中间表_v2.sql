DROP SCHEMA IF EXISTS ga2_dwd_v2
;

CREATE SCHEMA if NOT EXISTS ga2_dwd_v2
;

-- 角色维度表 
DROP TABLE IF EXISTS ga2_dwd_v2.dim_role
;

-- rid	角色id
-- account	游戏账号
-- openid	渠道账号
-- svrid	区号
-- pid	渠道标识
-- create_account_date	创建账号日期
-- create_role_date	创建角色日期
-- first_login_date	首次登录日期
-- first_recharge_date	首次充值日期
-- first_recharge_money	首次充值金额
-- is_old_player	是否老玩家
CREATE TABLE IF NOT EXISTS ga2_dwd_v2.dim_role AS
SELECT
    t2.rid AS rid,
    t1.account,
    t1.openid,
    t2.svrId,
    t1.pid,
    t1.create_account_date,
    t2.create_role_date,
    t2.first_login_date,
    t3.first_recharge_date,
    t3.first_recharge_money,
    t2.is_old_player
FROM
    (
        -- 账号相关信息
        -- account 是唯一值,且account是最全的.
        SELECT
            account,
            group_concat (DISTINCT openid) AS openid,
            group_concat (DISTINCT pid) AS pid,
            MIN(stat_date) AS create_account_date
        FROM
            ga2_ods_daily_v2.log_createloss_daily
        GROUP BY
            account
    ) t1
    LEFT JOIN (
        -- 角色相关信息
        SELECT
            rid,
            account,
            group_concat (DISTINCT svrId) AS svrId,
            MIN(create_role_date) AS create_role_date,
            MIN(first_login_date) AS first_login_date,
            MIN(is_old_player) AS is_old_player
        FROM
            (
                -- 用户登录日志
                SELECT
                    rid,
                    account,
                    group_concat (DISTINCT svrId) AS svrId,
                    NULL AS create_role_date,
                    MIN(stat_date) AS first_login_date,
                    NULL AS is_old_player
                FROM
                    ga2_ods_daily_v2.log_login_daily
                GROUP BY
                    rid,
                    account
                UNION ALL
                -- 用户创角日志,rid是唯一值
                SELECT
                    rid,
                    account,
                    group_concat (DISTINCT svrId) AS svrId,
                    MIN(stat_date) AS create_role_date,
                    NULL AS first_login_date,
                    MIN(old) AS is_old_player
                FROM
                    ga2_ods_daily_v2.log_register_daily
                GROUP BY
                    rid,
                    account
            ) t0
        GROUP BY
            rid,
            account
    ) t2 ON t1.account = t2.account
    LEFT JOIN (
        SELECT
            rid,
            first_recharge_date,
            first_recharge_money
        FROM
            (
                SELECT
                    *,
                    ROW_NUMBER() OVER (
                        PARTITION BY
                            rid
                        ORDER BY
                            stat_date
                    ) AS rn
                FROM
                    ga2_ods_daily_v2.recharge_daily
            ) t0
        WHERE
            rn = 1
    ) t3 ON t2.rid = t3.rid
;

-- 创建日期维表
DROP TABLE IF EXISTS ga2_dwd_v2.dim_date
;

CREATE TABLE ga2_dwd_v2.dim_date AS
SELECT
    -- 日期键（格式：YYYYMMDD）
    CAST(STRFTIME (date, '%Y%m%d') AS INTEGER) AS date_key,
    -- 完整日期
    date AS date_str,
    -- 日期部分
    CAST(STRFTIME (date, '%Y') AS INTEGER) AS year_int,
    CAST(STRFTIME (date, '%m') AS INTEGER) AS month_int,
    CAST(STRFTIME (date, '%d') AS INTEGER) AS day_int,
    -- 季度
    CASE
        WHEN EXTRACT(
            MONTH
            FROM
                date
        ) BETWEEN 1 AND 3  THEN 1
        WHEN EXTRACT(
            MONTH
            FROM
                date
        ) BETWEEN 4 AND 6  THEN 2
        WHEN EXTRACT(
            MONTH
            FROM
                date
        ) BETWEEN 7 AND 9  THEN 3
        WHEN EXTRACT(
            MONTH
            FROM
                date
        ) BETWEEN 10 AND 12  THEN 4
    END AS quarter_int,
    -- 星期几（0=周日, 6=周六）
    EXTRACT(
        DOW
        FROM
            date
    ) AS day_of_week,
    -- 星期几名称
    CASE EXTRACT(
            DOW
            FROM
                date
        )
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    -- 月份名称
    CASE EXTRACT(
            MONTH
            FROM
                date
        )
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS month_name,
    -- 一年中的第几天
    EXTRACT(
        DOY
        FROM
            date
    ) AS day_of_year,
    -- 一年中的第几周（ISO标准）
    EXTRACT(
        WEEK
        FROM
            date
    ) AS week_of_year,
    -- 是否周末
    CASE
        WHEN EXTRACT(
            DOW
            FROM
                date
        ) IN (0, 6) THEN TRUE
        ELSE FALSE
    END AS is_weekend,
    -- 是否工作日
    CASE
        WHEN EXTRACT(
            DOW
            FROM
                date
        ) IN (0, 6) THEN FALSE
        ELSE TRUE
    END AS is_workday,
    -- 节假日标志（需要根据具体需求补充）
    FALSE AS is_holiday,
    -- 季度名称
    'Q' || CASE
        WHEN EXTRACT(
            MONTH
            FROM
                date
        ) BETWEEN 1 AND 3  THEN '1'
        WHEN EXTRACT(
            MONTH
            FROM
                date
        ) BETWEEN 4 AND 6  THEN '2'
        WHEN EXTRACT(
            MONTH
            FROM
                date
        ) BETWEEN 7 AND 9  THEN '3'
        WHEN EXTRACT(
            MONTH
            FROM
                date
        ) BETWEEN 10 AND 12  THEN '4'
    END AS quarter_name,
    -- 年月（格式：YYYY-MM）
    STRFTIME (date, '%Y-%m') AS year_month,
    -- 年月（数字格式：YYYYMM）
    CAST(STRFTIME (date, '%Y%m') AS INTEGER) AS year_month_num,
    -- 季度开始日期
    DATE_TRUNC('quarter', date) AS quarter_start_date,
    -- 季度结束日期
    DATE_TRUNC('quarter', date) + INTERVAL 3 MONTH - INTERVAL 1 DAY AS quarter_end_date
FROM
    (
        SELECT
            UNNEST(
                GENERATE_SERIES(
                    '2020-01-01'::DATE,
                    '2030-12-31'::DATE,
                    INTERVAL 1 DAY
                )
            ) AS date
    ) t
ORDER BY
    date
;

-- 事实表_玩家日度登录充值
DROP TABLE IF EXISTS ga2_dwd_v2.fact_player_login_recharge
;

CREATE TABLE IF NOT EXISTS ga2_dwd_v2.fact_player_login_recharge AS
SELECT
    lg.rid,
    lg.name,
    lg.min_lv,
    lg.max_lv,
    lg.stat_date,
    lg.continue_login_date_cnt,
    lg.login_cnt,
    lg.logout_cnt,
    lg.cause_0_cnt,
    lg.cause_1_cnt,
    lg.online_time_sec,
    rc.real_cnt,
    rc.real_money,
    rc.real_yuanbao,
    rc.order_cnt,
    rc.order_money,
    rc.order_yuanbao,
    rc.charge_cnt,
    rc.charge_money,
    rc.charge_yuanbao,
    rc.coupon_cnt,
    rc.coupon_money,
    rc.coupon_yuanbao,
    rc.useticket_cnt,
    rc.useticket_money,
    rc.useticket_yuanbao,
    rc.normal_cnt,
    rc.normal_money,
    rc.normal_yuanbao
FROM
    ga2_ods_daily_v2.log_login_daily lg
    LEFT JOIN ga2_ods_daily_v2.recharge_daily rc ON lg.rid = rc.rid
    AND lg.stat_date = rc.stat_date
;

-- 事实表_玩家经验活动
DROP TABLE IF EXISTS ga2_dwd_v2.fact_player_activity
;

CREATE TABLE IF NOT EXISTS ga2_dwd_v2.fact_player_activity AS
SELECT
    rid,
    stat_date,
    SUM(yuanbao_get) AS yuanbao_get,
    SUM(yuanbao_cost) AS yuanbao_cost,
    SUM(yuanbao_left) AS yuanbao_left,
    SUM(copper_get) AS copper_get,
    SUM(copper_cost) AS copper_cost,
    SUM(copper_left) AS copper_left,
    SUM(xiakeexp_get) AS xiakeexp_get,
    SUM(xaikeexp_cost) AS xaikeexp_cost,
    SUM(xiakeexp_left) AS xiakeexp_left,
    SUM(exp_get) AS exp_get,
    SUM(chengjiu_get) AS chengjiu_get,
    SUM(biaoju_cnt) AS biaoju_cnt,
    SUM(boss_cnt) AS boss_cnt,
    SUM(fish_cnt) AS fish_cnt,
    SUM(gumu_cnt) AS gumu_cnt,
    SUM(haoling_cnt) AS haoling_cnt,
    SUM(leitaibiwu_cnt) AS leitaibiwu_cnt,
    SUM(paimai_cnt) AS paimai_cnt,
    SUM(task_cnt) AS task_cnt,
    SUM(trunk_fb_cnt) AS trunk_fb_cnt,
    SUM(wanansi_cnt) AS wanansi_cnt,
    SUM(war_fb_cnt) AS war_fb_cnt,
    SUM(zhangmen_cnt) AS zhangmen_cnt,
    SUM(zhaomu_cnt) AS zhaomu_cnt
FROM
    (
        SELECT
            rid,
            stat_date,
            SUM(add_cnt) AS yuanbao_get,
            SUM(reduce_cnt) AS yuanbao_cost,
            any_value (leftCnt) AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_yuanbao_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            SUM(add_cnt) AS copper_get,
            SUM(reduce_cnt) AS copper_cost,
            any_value (leftCnt) AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_copper_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            SUM(add_cnt) AS xiakeexp_get,
            SUM(reduce_cnt) AS xaikeexp_cost,
            any_value (leftCnt) AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_xiakeexp_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            SUM(cnt) AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_exp_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            SUM(add_cnt) AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_chengjiu_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            SUM(finish) AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_biaoju_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            SUM(fightCnt) AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_boss_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            SUM(grabCnt) AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_fish_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            SUM(cnt) AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_gumu_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            SUM(cnt) AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_haoling_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            SUM(challenge_cnt) AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_leitaibiwu_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            SUM(cnt) AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_paimai_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            SUM(cnt) AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_task_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            SUM(cnt) AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_trunk_fb_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            SUM(cnt) AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_wanansi_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            SUM(cnt) AS war_fb_cnt,
            0 AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_war_fb_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            SUM(cnt) AS zhangmen_cnt,
            0 AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_zhangmen_daily
        GROUP BY
            rid,
            stat_date
        UNION ALL
        SELECT
            rid,
            stat_date,
            0 AS yuanbao_get,
            0 AS yuanbao_cost,
            0 AS yuanbao_left,
            0 AS copper_get,
            0 AS copper_cost,
            0 AS copper_left,
            0 AS xiakeexp_get,
            0 AS xaikeexp_cost,
            0 AS xiakeexp_left,
            0 AS exp_get,
            0 AS chengjiu_get,
            0 AS biaoju_cnt,
            0 AS boss_cnt,
            0 AS fish_cnt,
            0 AS gumu_cnt,
            0 AS haoling_cnt,
            0 AS leitaibiwu_cnt,
            0 AS paimai_cnt,
            0 AS task_cnt,
            0 AS trunk_fb_cnt,
            0 AS wanansi_cnt,
            0 AS war_fb_cnt,
            0 AS zhangmen_cnt,
            SUM(zm_cnt) AS zhaomu_cnt
        FROM
            ga2_ods_daily_v2.log_zhaomu_daily
        GROUP BY
            rid,
            stat_date
    ) t
GROUP BY
    rid,
    stat_date
;

-- 活动明细宽表
DROP TABLE IF EXISTS ga2_dwd_v2.fact_player_activity_detail_sec
;

CREATE TABLE IF NOT EXISTS ga2_dwd_v2.fact_player_activity_detail_sec AS
SELECT
    rid AS rid,
    TIME AS time_sec,
    'biaoju' AS act_id,
    type AS biaoju_type,
    finish AS biaoju_finish,
    grabSucc AS biaoju_grabSucc,
    biaoshiNum AS biaoju_biaoshiNum,
    NULL AS boss_fightCnt,
    NULL AS boss_grabCnt,
    NULL AS boss_grabSuccCnt,
    NULL AS fish_grabCnt,
    NULL AS fish_grabSuccCntgm_,
    NULL AS gumu_floor,
    NULL AS haoling_cityName,
    NULL AS leitaibiwu_targetRank,
    NULL AS leitaibiwu_isWin,
    NULL AS paimai_type,
    NULL AS paimai_yuanbao,
    NULL AS paimai_itemId,
    NULL AS paimai_itemName,
    NULL AS paimai_owner,
    NULL AS paimai_buy,
    NULL AS paimai_armyId,
    NULL AS task_type,
    NULL AS task_taskId,
    NULL AS task_status,
    NULL AS task_quick,
    NULL AS trunk_fb_chapter,
    NULL AS trunk_fb_node,
    NULL AS wanansi_floor,
    NULL AS wanansi_isWin,
    NULL AS war_fb_chapter,
    NULL AS war_fb_isThrough,
    NULL AS zhangmen_id,
    NULL AS zhangmen_star,
    NULL AS zhaomu_zmType,
    NULL AS zhaomu_gold,
    NULL AS zhaomu_costYb,
    NULL AS zhaomu_costYbGold
FROM
    my_ga_ods_2_v2.log_biaoju
UNION ALL
SELECT
    rid AS rid,
    TIME AS time_sec,
    'boss' AS act_id,
    NULL AS biaoju_type,
    NULL AS biaoju_finish,
    NULL AS biaoju_grabSucc,
    NULL AS biaoju_biaoshiNum,
    fightCnt AS boss_fightCnt,
    grabCnt AS boss_grabCnt,
    grabSuccCnt AS boss_grabSuccCnt,
    NULL AS fish_grabCnt,
    NULL AS fish_grabSuccCntgm_,
    NULL AS gumu_floor,
    NULL AS haoling_cityName,
    NULL AS leitaibiwu_targetRank,
    NULL AS leitaibiwu_isWin,
    NULL AS paimai_type,
    NULL AS paimai_yuanbao,
    NULL AS paimai_itemId,
    NULL AS paimai_itemName,
    NULL AS paimai_owner,
    NULL AS paimai_buy,
    NULL AS paimai_armyId,
    NULL AS task_type,
    NULL AS task_taskId,
    NULL AS task_status,
    NULL AS task_quick,
    NULL AS trunk_fb_chapter,
    NULL AS trunk_fb_node,
    NULL AS wanansi_floor,
    NULL AS wanansi_isWin,
    NULL AS war_fb_chapter,
    NULL AS war_fb_isThrough,
    NULL AS zhangmen_id,
    NULL AS zhangmen_star,
    NULL AS zhaomu_zmType,
    NULL AS zhaomu_gold,
    NULL AS zhaomu_costYb,
    NULL AS zhaomu_costYbGold
FROM
    my_ga_ods_2_v2.log_boss
UNION ALL
SELECT
    rid AS rid,
    TIME AS time_sec,
    'fish' AS act_id,
    NULL AS biaoju_type,
    NULL AS biaoju_finish,
    NULL AS biaoju_grabSucc,
    NULL AS biaoju_biaoshiNum,
    NULL AS boss_fightCnt,
    NULL AS boss_grabCnt,
    NULL AS boss_grabSuccCnt,
    grabCnt AS fish_grabCnt,
    grabSuccCnt AS fish_grabSuccCnt,
    NULL AS gumu_floor,
    NULL AS haoling_cityName,
    NULL AS leitaibiwu_targetRank,
    NULL AS leitaibiwu_isWin,
    NULL AS paimai_type,
    NULL AS paimai_yuanbao,
    NULL AS paimai_itemId,
    NULL AS paimai_itemName,
    NULL AS paimai_owner,
    NULL AS paimai_buy,
    NULL AS paimai_armyId,
    NULL AS task_type,
    NULL AS task_taskId,
    NULL AS task_status,
    NULL AS task_quick,
    NULL AS trunk_fb_chapter,
    NULL AS trunk_fb_node,
    NULL AS wanansi_floor,
    NULL AS wanansi_isWin,
    NULL AS war_fb_chapter,
    NULL AS war_fb_isThrough,
    NULL AS zhangmen_id,
    NULL AS zhangmen_star,
    NULL AS zhaomu_zmType,
    NULL AS zhaomu_gold,
    NULL AS zhaomu_costYb,
    NULL AS zhaomu_costYbGold
FROM
    my_ga_ods_2_v2.log_fish
UNION ALL
SELECT
    rid AS rid,
    TIME AS time_sec,
    'gumu' AS act_id,
    NULL AS biaoju_type,
    NULL AS biaoju_finish,
    NULL AS biaoju_grabSucc,
    NULL AS biaoju_biaoshiNum,
    NULL AS boss_fightCnt,
    NULL AS boss_grabCnt,
    NULL AS boss_grabSuccCnt,
    NULL AS fish_grabCnt,
    NULL AS fish_grabSuccCntgm_,
    floor AS gumu_floor,
    NULL AS haoling_cityName,
    NULL AS leitaibiwu_targetRank,
    NULL AS leitaibiwu_isWin,
    NULL AS paimai_type,
    NULL AS paimai_yuanbao,
    NULL AS paimai_itemId,
    NULL AS paimai_itemName,
    NULL AS paimai_owner,
    NULL AS paimai_buy,
    NULL AS paimai_armyId,
    NULL AS task_type,
    NULL AS task_taskId,
    NULL AS task_status,
    NULL AS task_quick,
    NULL AS trunk_fb_chapter,
    NULL AS trunk_fb_node,
    NULL AS wanansi_floor,
    NULL AS wanansi_isWin,
    NULL AS war_fb_chapter,
    NULL AS war_fb_isThrough,
    NULL AS zhangmen_id,
    NULL AS zhangmen_star,
    NULL AS zhaomu_zmType,
    NULL AS zhaomu_gold,
    NULL AS zhaomu_costYb,
    NULL AS zhaomu_costYbGold
FROM
    my_ga_ods_2_v2.log_gumu
UNION ALL
SELECT
    UNNEST(string_split (rids, '_')) AS rid,
    TIME AS time_sec,
    'haoling' AS act_id,
    NULL AS biaoju_type,
    NULL AS biaoju_finish,
    NULL AS biaoju_grabSucc,
    NULL AS biaoju_biaoshiNum,
    NULL AS boss_fightCnt,
    NULL AS boss_grabCnt,
    NULL AS boss_grabSuccCnt,
    NULL AS fish_grabCnt,
    NULL AS fish_grabSuccCntgm_,
    NULL AS gumu_floor,
    cityName AS haoling_cityName,
    NULL AS leitaibiwu_targetRank,
    NULL AS leitaibiwu_isWin,
    NULL AS paimai_type,
    NULL AS paimai_yuanbao,
    NULL AS paimai_itemId,
    NULL AS paimai_itemName,
    NULL AS paimai_owner,
    NULL AS paimai_buy,
    NULL AS paimai_armyId,
    NULL AS task_type,
    NULL AS task_taskId,
    NULL AS task_status,
    NULL AS task_quick,
    NULL AS trunk_fb_chapter,
    NULL AS trunk_fb_node,
    NULL AS wanansi_floor,
    NULL AS wanansi_isWin,
    NULL AS war_fb_chapter,
    NULL AS war_fb_isThrough,
    NULL AS zhangmen_id,
    NULL AS zhangmen_star,
    NULL AS zhaomu_zmType,
    NULL AS zhaomu_gold,
    NULL AS zhaomu_costYb,
    NULL AS zhaomu_costYbGold
FROM
    my_ga_ods_2_v2.log_haoling
UNION ALL
SELECT
    rid AS rid,
    TIME AS time_sec,
    'leitaibiwu' AS act_id,
    NULL AS biaoju_type,
    NULL AS biaoju_finish,
    NULL AS biaoju_grabSucc,
    NULL AS biaoju_biaoshiNum,
    NULL AS boss_fightCnt,
    NULL AS boss_grabCnt,
    NULL AS boss_grabSuccCnt,
    NULL AS fish_grabCnt,
    NULL AS fish_grabSuccCntgm_,
    NULL AS gumu_floor,
    NULL AS haoling_cityName,
    targetRank AS leitaibiwu_targetRank,
    isWin AS leitaibiwu_isWin,
    NULL AS paimai_type,
    NULL AS paimai_yuanbao,
    NULL AS paimai_itemId,
    NULL AS paimai_itemName,
    NULL AS paimai_owner,
    NULL AS paimai_buy,
    NULL AS paimai_armyId,
    NULL AS task_type,
    NULL AS task_taskId,
    NULL AS task_status,
    NULL AS task_quick,
    NULL AS trunk_fb_chapter,
    NULL AS trunk_fb_node,
    NULL AS wanansi_floor,
    NULL AS wanansi_isWin,
    NULL AS war_fb_chapter,
    NULL AS war_fb_isThrough,
    NULL AS zhangmen_id,
    NULL AS zhangmen_star,
    NULL AS zhaomu_zmType,
    NULL AS zhaomu_gold,
    NULL AS zhaomu_costYb,
    NULL AS zhaomu_costYbGold
FROM
    my_ga_ods_2_v2.log_leitaibiwu
UNION ALL
SELECT
    rid AS rid,
    TIME AS time_sec,
    'paimai' AS act_id,
    NULL AS biaoju_type,
    NULL AS biaoju_finish,
    NULL AS biaoju_grabSucc,
    NULL AS biaoju_biaoshiNum,
    NULL AS boss_fightCnt,
    NULL AS boss_grabCnt,
    NULL AS boss_grabSuccCnt,
    NULL AS fish_grabCnt,
    NULL AS fish_grabSuccCntgm_,
    NULL AS gumu_floor,
    NULL AS haoling_cityName,
    NULL AS leitaibiwu_targetRank,
    NULL AS leitaibiwu_isWin,
    type AS paimai_type,
    yuanbao AS paimai_yuanbao,
    itemId AS paimai_itemId,
    itemName AS paimai_itemName,
    owner AS paimai_owner,
    buy AS paimai_buy,
    armyId AS paimai_armyId,
    NULL AS task_type,
    NULL AS task_taskId,
    NULL AS task_status,
    NULL AS task_quick,
    NULL AS trunk_fb_chapter,
    NULL AS trunk_fb_node,
    NULL AS wanansi_floor,
    NULL AS wanansi_isWin,
    NULL AS war_fb_chapter,
    NULL AS war_fb_isThrough,
    NULL AS zhangmen_id,
    NULL AS zhangmen_star,
    NULL AS zhaomu_zmType,
    NULL AS zhaomu_gold,
    NULL AS zhaomu_costYb,
    NULL AS zhaomu_costYbGold
FROM
    my_ga_ods_2_v2.log_paimai
UNION ALL
SELECT
    rid AS rid,
    TIME AS time_sec,
    'task' AS act_id,
    NULL AS biaoju_type,
    NULL AS biaoju_finish,
    NULL AS biaoju_grabSucc,
    NULL AS biaoju_biaoshiNum,
    NULL AS boss_fightCnt,
    NULL AS boss_grabCnt,
    NULL AS boss_grabSuccCnt,
    NULL AS fish_grabCnt,
    NULL AS fish_grabSuccCntgm_,
    NULL AS gumu_floor,
    NULL AS haoling_cityName,
    NULL AS leitaibiwu_targetRank,
    NULL AS leitaibiwu_isWin,
    NULL AS paimai_type,
    NULL AS paimai_yuanbao,
    NULL AS paimai_itemId,
    NULL AS paimai_itemName,
    NULL AS paimai_owner,
    NULL AS paimai_buy,
    NULL AS paimai_armyId,
    type AS task_type,
    taskId AS task_taskId,
    status AS task_status,
    quick AS task_quick,
    NULL AS trunk_fb_chapter,
    NULL AS trunk_fb_node,
    NULL AS wanansi_floor,
    NULL AS wanansi_isWin,
    NULL AS war_fb_chapter,
    NULL AS war_fb_isThrough,
    NULL AS zhangmen_id,
    NULL AS zhangmen_star,
    NULL AS zhaomu_zmType,
    NULL AS zhaomu_gold,
    NULL AS zhaomu_costYb,
    NULL AS zhaomu_costYbGold
FROM
    my_ga_ods_2_v2.log_task
UNION ALL
SELECT
    rid AS rid,
    TIME AS time_sec,
    'trunk_fb' AS act_id,
    NULL AS biaoju_type,
    NULL AS biaoju_finish,
    NULL AS biaoju_grabSucc,
    NULL AS biaoju_biaoshiNum,
    NULL AS boss_fightCnt,
    NULL AS boss_grabCnt,
    NULL AS boss_grabSuccCnt,
    NULL AS fish_grabCnt,
    NULL AS fish_grabSuccCntgm_,
    NULL AS gumu_floor,
    NULL AS haoling_cityName,
    NULL AS leitaibiwu_targetRank,
    NULL AS leitaibiwu_isWin,
    NULL AS paimai_type,
    NULL AS paimai_yuanbao,
    NULL AS paimai_itemId,
    NULL AS paimai_itemName,
    NULL AS paimai_owner,
    NULL AS paimai_buy,
    NULL AS paimai_armyId,
    NULL AS task_type,
    NULL AS task_taskId,
    NULL AS task_status,
    NULL AS task_quick,
    chapter AS trunk_fb_chapter,
    node AS trunk_fb_node,
    NULL AS wanansi_floor,
    NULL AS wanansi_isWin,
    NULL AS war_fb_chapter,
    NULL AS war_fb_isThrough,
    NULL AS zhangmen_id,
    NULL AS zhangmen_star,
    NULL AS zhaomu_zmType,
    NULL AS zhaomu_gold,
    NULL AS zhaomu_costYb,
    NULL AS zhaomu_costYbGold
FROM
    my_ga_ods_2_v2.log_trunk_fb
UNION ALL
SELECT
    rid AS rid,
    TIME AS time_sec,
    'wanansi' AS act_id,
    NULL AS biaoju_type,
    NULL AS biaoju_finish,
    NULL AS biaoju_grabSucc,
    NULL AS biaoju_biaoshiNum,
    NULL AS boss_fightCnt,
    NULL AS boss_grabCnt,
    NULL AS boss_grabSuccCnt,
    NULL AS fish_grabCnt,
    NULL AS fish_grabSuccCntgm_,
    NULL AS gumu_floor,
    NULL AS haoling_cityName,
    NULL AS leitaibiwu_targetRank,
    NULL AS leitaibiwu_isWin,
    NULL AS paimai_type,
    NULL AS paimai_yuanbao,
    NULL AS paimai_itemId,
    NULL AS paimai_itemName,
    NULL AS paimai_owner,
    NULL AS paimai_buy,
    NULL AS paimai_armyId,
    NULL AS task_type,
    NULL AS task_taskId,
    NULL AS task_status,
    NULL AS task_quick,
    NULL AS trunk_fb_chapter,
    NULL AS trunk_fb_node,
    floor AS wanansi_floor,
    isWin AS wanansi_isWin,
    NULL AS war_fb_chapter,
    NULL AS war_fb_isThrough,
    NULL AS zhangmen_id,
    NULL AS zhangmen_star,
    NULL AS zhaomu_zmType,
    NULL AS zhaomu_gold,
    NULL AS zhaomu_costYb,
    NULL AS zhaomu_costYbGold
FROM
    my_ga_ods_2_v2.log_wanansi
UNION ALL
SELECT
    rid AS rid,
    TIME AS time_sec,
    'war_fb' AS act_id,
    NULL AS biaoju_type,
    NULL AS biaoju_finish,
    NULL AS biaoju_grabSucc,
    NULL AS biaoju_biaoshiNum,
    NULL AS boss_fightCnt,
    NULL AS boss_grabCnt,
    NULL AS boss_grabSuccCnt,
    NULL AS fish_grabCnt,
    NULL AS fish_grabSuccCntgm_,
    NULL AS gumu_floor,
    NULL AS haoling_cityName,
    NULL AS leitaibiwu_targetRank,
    NULL AS leitaibiwu_isWin,
    NULL AS paimai_type,
    NULL AS paimai_yuanbao,
    NULL AS paimai_itemId,
    NULL AS paimai_itemName,
    NULL AS paimai_owner,
    NULL AS paimai_buy,
    NULL AS paimai_armyId,
    NULL AS task_type,
    NULL AS task_taskId,
    NULL AS task_status,
    NULL AS task_quick,
    NULL AS trunk_fb_chapter,
    NULL AS trunk_fb_node,
    NULL AS wanansi_floor,
    NULL AS wanansi_isWin,
    chapter AS war_fb_chapter,
    isThrough AS war_fb_isThrough,
    NULL AS zhangmen_id,
    NULL AS zhangmen_star,
    NULL AS zhaomu_zmType,
    NULL AS zhaomu_gold,
    NULL AS zhaomu_costYb,
    NULL AS zhaomu_costYbGold
FROM
    my_ga_ods_2_v2.log_war_fb
UNION ALL
SELECT
    rid AS rid,
    TIME AS time_sec,
    'zhangmen' AS act_id,
    NULL AS biaoju_type,
    NULL AS biaoju_finish,
    NULL AS biaoju_grabSucc,
    NULL AS biaoju_biaoshiNum,
    NULL AS boss_fightCnt,
    NULL AS boss_grabCnt,
    NULL AS boss_grabSuccCnt,
    NULL AS fish_grabCnt,
    NULL AS fish_grabSuccCntgm_,
    NULL AS gumu_floor,
    NULL AS haoling_cityName,
    NULL AS leitaibiwu_targetRank,
    NULL AS leitaibiwu_isWin,
    NULL AS paimai_type,
    NULL AS paimai_yuanbao,
    NULL AS paimai_itemId,
    NULL AS paimai_itemName,
    NULL AS paimai_owner,
    NULL AS paimai_buy,
    NULL AS paimai_armyId,
    NULL AS task_type,
    NULL AS task_taskId,
    NULL AS task_status,
    NULL AS task_quick,
    NULL AS trunk_fb_chapter,
    NULL AS trunk_fb_node,
    NULL AS wanansi_floor,
    NULL AS wanansi_isWin,
    NULL AS war_fb_chapter,
    NULL AS war_fb_isThrough,
    id AS zhangmen_id,
    star AS zhangmen_star,
    NULL AS zhaomu_zmType,
    NULL AS zhaomu_gold,
    NULL AS zhaomu_costYb,
    NULL AS zhaomu_costYbGold
FROM
    my_ga_ods_2_v2.log_zhangmen
UNION ALL
SELECT
    rid AS rid,
    TIME AS time_sec,
    'zhaomu' AS act_id,
    NULL AS biaoju_type,
    NULL AS biaoju_finish,
    NULL AS biaoju_grabSucc,
    NULL AS biaoju_biaoshiNum,
    NULL AS boss_fightCnt,
    NULL AS boss_grabCnt,
    NULL AS boss_grabSuccCnt,
    NULL AS fish_grabCnt,
    NULL AS fish_grabSuccCntgm_,
    NULL AS gumu_floor,
    NULL AS haoling_cityName,
    NULL AS leitaibiwu_targetRank,
    NULL AS leitaibiwu_isWin,
    NULL AS paimai_type,
    NULL AS paimai_yuanbao,
    NULL AS paimai_itemId,
    NULL AS paimai_itemName,
    NULL AS paimai_owner,
    NULL AS paimai_buy,
    NULL AS paimai_armyId,
    NULL AS task_type,
    NULL AS task_taskId,
    NULL AS task_status,
    NULL AS task_quick,
    NULL AS trunk_fb_chapter,
    NULL AS trunk_fb_node,
    NULL AS wanansi_floor,
    NULL AS wanansi_isWin,
    NULL AS war_fb_chapter,
    NULL AS war_fb_isThrough,
    NULL AS zhangmen_id,
    NULL AS zhangmen_star,
    zmType AS zhaomu_zmType,
    gold AS zhaomu_gold,
    costYb AS zhaomu_costYb,
    costYbGold AS zhaomu_costYbGold
FROM
    my_ga_ods_2_v2.log_zhaomu
;