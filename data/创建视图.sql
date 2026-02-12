CREATE  or replace  VIEW ga2_dwd_v2.retention_14d_prediction_view AS WITH target_users AS (
SELECT
    rid,
    CAST(first_login_date AS DATE) AS reg_date
FROM
    ga2_dwd_v2.dim_role
WHERE
    (CAST(first_login_date AS DATE) BETWEEN CAST('2024-01-01' AS DATE) AND CAST('2024-01-30' AS DATE))),
base_info AS (
SELECT
    r.rid,
    r.first_login_date,
    r.first_recharge_date,
    CASE
        WHEN ((r.first_recharge_date IS NULL)) THEN (0)
        ELSE 1
    END AS is_payer_first,
    CASE
        WHEN ((r.first_recharge_date IS NOT NULL)) THEN (datediff('day', CAST(r.first_login_date AS DATE), CAST(r.first_recharge_date AS DATE)))
        ELSE 9999
    END AS days_to_first_pay,
    CASE
        WHEN ((r.first_recharge_money IS NULL)) THEN (0)
        WHEN ((r.first_recharge_money <= 6)) THEN (1)
        WHEN ((r.first_recharge_money <= 30)) THEN (2)
        WHEN ((r.first_recharge_money <= 98)) THEN (3)
        WHEN ((r.first_recharge_money <= 198)) THEN (4)
        ELSE 5
    END AS first_pay_bin,
    COALESCE(r.first_recharge_money, 0) AS first_recharge_money,
    r.is_old_player,
    CASE
        WHEN (d.is_workday) THEN (1)
        ELSE 0
    END AS reg_is_workday
FROM
    ga2_dwd_v2.dim_role AS r
LEFT JOIN ga2_dwd_v2.dim_date AS d ON
    ((CAST(strftime(CAST(r.first_login_date AS DATE), '%Y%m%d') AS INTEGER) = d.date_key))
WHERE
    (CAST(r.first_login_date AS DATE) BETWEEN CAST('2024-01-01' AS DATE) AND CAST('2024-01-30' AS DATE))),
act7 AS (
SELECT
    a.rid,
    CAST(a.stat_date AS DATE) AS log_date,
    u.reg_date,
    COALESCE(a.exp_get, 0) AS exp_get,
    COALESCE(a.chengjiu_get, 0) AS chengjiu_get,
    COALESCE(a.yuanbao_get, 0) AS yuanbao_get,
    COALESCE(a.yuanbao_cost, 0) AS yuanbao_cost,
    COALESCE(a.copper_get, 0) AS copper_get,
    COALESCE(a.copper_cost, 0) AS copper_cost,
    COALESCE(a.biaoju_cnt, 0) AS biaoju_cnt,
    COALESCE(a.boss_cnt, 0) AS boss_cnt,
    COALESCE(a.fish_cnt, 0) AS fish_cnt,
    COALESCE(a.gumu_cnt, 0) AS gumu_cnt,
    COALESCE(a.haoling_cnt, 0) AS haoling_cnt,
    COALESCE(a.leitaibiwu_cnt, 0) AS leitaibiwu_cnt,
    COALESCE(a.paimai_cnt, 0) AS paimai_cnt,
    COALESCE(a.task_cnt, 0) AS task_cnt,
    COALESCE(a.trunk_fb_cnt, 0) AS trunk_fb_cnt,
    COALESCE(a.wanansi_cnt, 0) AS wanansi_cnt,
    COALESCE(a.war_fb_cnt, 0) AS war_fb_cnt,
    COALESCE(a.zhangmen_cnt, 0) AS zhangmen_cnt,
    COALESCE(a.zhaomu_cnt, 0) AS zhaomu_cnt
FROM
    ga2_dwd_v2.fact_player_activity AS a
INNER JOIN target_users AS u ON
    ((a.rid = u.rid))
WHERE
    (CAST(a.stat_date AS DATE) BETWEEN u.reg_date AND (u.reg_date + to_days(CAST(trunc(CAST(6 AS DOUBLE)) AS INTEGER))))),
activity_agg AS (
SELECT
    rid,
    sum(exp_get) AS exp_get_7d,
    sum(chengjiu_get) AS chengjiu_get_7d,
    sum(yuanbao_get) AS yuanbao_get_7d,
    sum(yuanbao_cost) AS yuanbao_cost_7d,
    sum(copper_get) AS copper_get_7d,
    sum(copper_cost) AS copper_cost_7d,
    sum(biaoju_cnt) AS biaoju_cnt_7d,
    sum(boss_cnt) AS boss_cnt_7d,
    sum(fish_cnt) AS fish_cnt_7d,
    sum(gumu_cnt) AS gumu_cnt_7d,
    sum(haoling_cnt) AS haoling_cnt_7d,
    sum(leitaibiwu_cnt) AS leitaibiwu_cnt_7d,
    sum(paimai_cnt) AS paimai_cnt_7d,
    sum(task_cnt) AS task_cnt_7d,
    sum(trunk_fb_cnt) AS trunk_fb_cnt_7d,
    sum(wanansi_cnt) AS wanansi_cnt_7d,
    sum(war_fb_cnt) AS war_fb_cnt_7d,
    sum(zhangmen_cnt) AS zhangmen_cnt_7d,
    sum(zhaomu_cnt) AS zhaomu_cnt_7d,
    sum(((((((((((((biaoju_cnt + boss_cnt) + fish_cnt) + gumu_cnt) + haoling_cnt) + leitaibiwu_cnt) + paimai_cnt) + task_cnt) + trunk_fb_cnt) + wanansi_cnt) + war_fb_cnt) + zhangmen_cnt) + zhaomu_cnt)) AS play_cnt_total_7d,
    ((((((((((((CASE
        WHEN ((sum(biaoju_cnt) > 0)) THEN (1)
        ELSE 0
    END + CASE
        WHEN ((sum(boss_cnt) > 0)) THEN (1)
        ELSE 0
    END) + CASE
        WHEN ((sum(fish_cnt) > 0)) THEN (1)
        ELSE 0
    END) + CASE
        WHEN ((sum(gumu_cnt) > 0)) THEN (1)
        ELSE 0
    END) + CASE
        WHEN ((sum(haoling_cnt) > 0)) THEN (1)
        ELSE 0
    END) + CASE
        WHEN ((sum(leitaibiwu_cnt) > 0)) THEN (1)
        ELSE 0
    END) + CASE
        WHEN ((sum(paimai_cnt) > 0)) THEN (1)
        ELSE 0
    END) + CASE
        WHEN ((sum(task_cnt) > 0)) THEN (1)
        ELSE 0
    END) + CASE
        WHEN ((sum(trunk_fb_cnt) > 0)) THEN (1)
        ELSE 0
    END) + CASE
        WHEN ((sum(wanansi_cnt) > 0)) THEN (1)
        ELSE 0
    END) + CASE
        WHEN ((sum(war_fb_cnt) > 0)) THEN (1)
        ELSE 0
    END) + CASE
        WHEN ((sum(zhangmen_cnt) > 0)) THEN (1)
        ELSE 0
    END) + CASE
        WHEN ((sum(zhaomu_cnt) > 0)) THEN (1)
        ELSE 0
    END) AS play_type_cnt_7d
FROM
    act7
GROUP BY
    rid),
user7 AS (
SELECT
    f.rid,
    CAST(f.stat_date AS DATE) AS log_date,
    u.reg_date,
    f.online_time_sec,
    f.continue_login_date_cnt,
    COALESCE(f.real_cnt, 0) AS real_cnt,
    COALESCE(f.real_money, 0) AS real_money
FROM
    ga2_dwd_v2.fact_player_login_recharge AS f
INNER JOIN target_users AS u ON
    ((f.rid = u.rid))
WHERE
    (CAST(f.stat_date AS DATE) BETWEEN u.reg_date AND (u.reg_date + to_days(CAST(trunc(CAST(6 AS DOUBLE)) AS INTEGER))))),
user7_with_day AS (
SELECT
    *,
    (log_date - reg_date) AS day_no
FROM
    user7),
login_agg AS (
SELECT
    rid,
    sum(online_time_sec) AS total_7d_sec,
    sum(CASE WHEN ((day_no BETWEEN 0 AND 2)) THEN (online_time_sec) ELSE 0 END) AS first3_sec,
    sum(CASE WHEN ((day_no BETWEEN 4 AND 6)) THEN (online_time_sec) ELSE 0 END) AS last3_sec,
    max(CASE WHEN ((day_no = 6)) THEN (1) ELSE 0 END) AS is_active_day7,
    max(continue_login_date_cnt) AS max_consecutive_days_7d,
    sum(real_cnt) AS pay_cnt_7d,
    sum(real_money) AS pay_amt_7d,
    count(DISTINCT CASE WHEN ((real_money > 0)) THEN (log_date) ELSE NULL END) AS pay_days_7d,
    sum(CASE WHEN ((day_no BETWEEN 4 AND 6)) THEN (real_money) ELSE 0 END) AS pay_last3_amt
FROM
    user7_with_day
GROUP BY
    rid),
detail7 AS (
SELECT
    d.rid,
    CAST(to_timestamp(CAST(d.time_sec AS BIGINT)) AS DATE) AS log_date,
    u.reg_date,
    d.leitaibiwu_isWin,
    d.wanansi_isWin,
    d.war_fb_isThrough,
    d.wanansi_floor,
    d.gumu_floor,
    d.trunk_fb_chapter,
    d.task_status
FROM
    ga2_dwd_v2.fact_player_activity_detail_sec AS d
INNER JOIN target_users AS u ON
    ((d.rid = u.rid))
WHERE
    (CAST(to_timestamp(CAST(d.time_sec AS BIGINT)) AS DATE) BETWEEN u.reg_date AND (u.reg_date + to_days(CAST(trunc(CAST(6 AS DOUBLE)) AS INTEGER))))),
detail_agg AS (
SELECT
    rid,
    sum(CASE WHEN ((leitaibiwu_isWin IS NOT NULL)) THEN (1) ELSE 0 END) AS leita_cnt,
    sum(CASE WHEN ((leitaibiwu_isWin = 1)) THEN (1) ELSE 0 END) AS leita_win_cnt,
    sum(CASE WHEN ((wanansi_isWin IS NOT NULL)) THEN (1) ELSE 0 END) AS wanansi_cnt,
    sum(CASE WHEN ((wanansi_isWin = 1)) THEN (1) ELSE 0 END) AS wanansi_win_cnt,
    sum(CASE WHEN ((war_fb_isThrough IS NOT NULL)) THEN (1) ELSE 0 END) AS warfb_cnt,
    sum(CASE WHEN ((war_fb_isThrough = 1)) THEN (1) ELSE 0 END) AS warfb_win_cnt,
    max(wanansi_floor) AS max_wanansi_floor,
    max(gumu_floor) AS max_gumu_floor,
    max(trunk_fb_chapter) AS max_trunk_chapter,
    sum(CASE WHEN ((task_status IS NOT NULL)) THEN (1) ELSE 0 END) AS task_cnt,
    sum(CASE WHEN ((task_status = 1)) THEN (1) ELSE 0 END) AS task_finish_cnt
FROM
    detail7
GROUP BY
    rid),
retention_label AS (
SELECT
    u.rid,
    max(CASE WHEN ((CAST(f.stat_date AS DATE) = (u.reg_date + to_days(CAST(trunc(CAST(14 AS DOUBLE)) AS INTEGER))))) THEN (1) ELSE 0 END) AS is_retained_14d,
    max(CASE WHEN ((CAST(f.stat_date AS DATE) = (u.reg_date + to_days(CAST(trunc(CAST(30 AS DOUBLE)) AS INTEGER))))) THEN (1) ELSE 0 END) AS is_retained_30d
FROM
    target_users AS u
LEFT JOIN ga2_dwd_v2.fact_player_login_recharge AS f ON
    ((u.rid = f.rid))
GROUP BY
    u.rid
)SELECT
    u.rid,
    u.reg_date,
    b.first_login_date,
    b.first_recharge_date,
    b.is_payer_first,
    b.days_to_first_pay,
    b.first_pay_bin,
    b.first_recharge_money,
    b.is_old_player,
    b.reg_is_workday,
    COALESCE(a.exp_get_7d, 0) AS exp_get_7d,
    COALESCE(a.chengjiu_get_7d, 0) AS chengjiu_get_7d,
    COALESCE(a.yuanbao_get_7d, 0) AS yuanbao_get_7d,
    COALESCE(a.yuanbao_cost_7d, 0) AS yuanbao_cost_7d,
    COALESCE(a.copper_get_7d, 0) AS copper_get_7d,
    COALESCE(a.copper_cost_7d, 0) AS copper_cost_7d,
    CASE
        WHEN ((a.yuanbao_get_7d > 0)) THEN (((a.yuanbao_cost_7d * 1.0) / a.yuanbao_get_7d))
        ELSE 0
    END AS yuanbao_spend_ratio,
    CASE
        WHEN ((a.copper_get_7d > 0)) THEN (((a.copper_cost_7d * 1.0) / a.copper_get_7d))
        ELSE 0
    END AS copper_spend_ratio,
    COALESCE(a.play_cnt_total_7d, 0) AS play_cnt_total_7d,
    COALESCE(a.play_type_cnt_7d, 0) AS play_type_cnt_7d,
    COALESCE(a.task_cnt_7d, 0) AS task_cnt_7d,
    COALESCE(a.trunk_fb_cnt_7d, 0) AS trunk_fb_cnt_7d,
    COALESCE(a.biaoju_cnt_7d, 0) AS biaoju_cnt_7d,
    COALESCE(a.boss_cnt_7d, 0) AS boss_cnt_7d,
    COALESCE(a.fish_cnt_7d, 0) AS fish_cnt_7d,
    COALESCE(a.gumu_cnt_7d, 0) AS gumu_cnt_7d,
    COALESCE(a.haoling_cnt_7d, 0) AS haoling_cnt_7d,
    COALESCE(a.leitaibiwu_cnt_7d, 0) AS leitaibiwu_cnt_7d,
    COALESCE(a.paimai_cnt_7d, 0) AS paimai_cnt_7d,
    COALESCE(a.wanansi_cnt_7d, 0) AS wanansi_cnt_7d,
    COALESCE(a.war_fb_cnt_7d, 0) AS war_fb_cnt_7d,
    COALESCE(a.zhangmen_cnt_7d, 0) AS zhangmen_cnt_7d,
    COALESCE(a.zhaomu_cnt_7d, 0) AS zhaomu_cnt_7d,
    COALESCE(l.total_7d_sec, 0) AS total_7d_online_sec,
    COALESCE(l.first3_sec, 0) AS first3_online_sec,
    COALESCE(l.last3_sec, 0) AS last3_online_sec,
    COALESCE(l.is_active_day7, 0) AS is_active_day7,
    CASE
        WHEN ((l.total_7d_sec > 0)) THEN (((l.last3_sec * 1.0) / l.total_7d_sec))
        ELSE 0
    END AS activity_center_ratio,
    CASE
        WHEN ((l.first3_sec > 0)) THEN (((l.last3_sec * 1.0) / l.first3_sec))
        ELSE NULL
    END AS last3_vs_first3,
    COALESCE(l.max_consecutive_days_7d, 0) AS max_consecutive_days_7d,
    CASE
        WHEN ((l.pay_amt_7d > 0)) THEN (1)
        ELSE 0
    END AS is_payer_7d,
    COALESCE(l.pay_amt_7d, 0) AS pay_amt_7d,
    COALESCE(l.pay_cnt_7d, 0) AS pay_cnt_7d,
    COALESCE(l.pay_days_7d, 0) AS pay_days_7d,
    CASE
        WHEN ((l.pay_cnt_7d > 0)) THEN (((l.pay_amt_7d * 1.0) / l.pay_cnt_7d))
        ELSE 0
    END AS avg_pay_per_txn,
    CASE
        WHEN ((l.pay_amt_7d > 0)) THEN (((l.pay_last3_amt * 1.0) / l.pay_amt_7d))
        ELSE 0
    END AS pay_trend_ratio,
    CASE
        WHEN ((d.leita_cnt > 0)) THEN (((d.leita_win_cnt * 1.0) / d.leita_cnt))
        ELSE 0
    END AS leita_win_rate,
    CASE
        WHEN ((d.wanansi_cnt > 0)) THEN (((d.wanansi_win_cnt * 1.0) / d.wanansi_cnt))
        ELSE 0
    END AS wanansi_win_rate,
    CASE
        WHEN ((d.warfb_cnt > 0)) THEN (((d.warfb_win_cnt * 1.0) / d.warfb_cnt))
        ELSE 0
    END AS war_fb_through_rate,
    COALESCE(d.max_wanansi_floor, 0) AS max_wanansi_floor,
    COALESCE(d.max_gumu_floor, 0) AS max_gumu_floor,
    COALESCE(d.max_trunk_chapter, 0) AS max_trunk_chapter,
    COALESCE(d.task_cnt, 0) AS task_cnt_detail,
    COALESCE(d.task_finish_cnt, 0) AS task_finish_cnt,
    CASE
        WHEN ((d.task_cnt > 0)) THEN (((d.task_finish_cnt * 1.0) / d.task_cnt))
        ELSE 0
    END AS task_complete_rate,
    COALESCE(r.is_retained_14d, 0) AS is_retained_14d,
    COALESCE(r.is_retained_30d, 0) AS is_retained_30d
FROM
    target_users AS u
LEFT JOIN base_info AS b ON
    ((u.rid = b.rid))
LEFT JOIN activity_agg AS a ON
    ((u.rid = a.rid))
LEFT JOIN login_agg AS l ON
    ((u.rid = l.rid))
LEFT JOIN detail_agg AS d ON
    ((u.rid = d.rid))
LEFT JOIN retention_label AS r ON
    ((u.rid = r.rid))
WHERE
    (l.first3_sec > 0);