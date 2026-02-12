# GameAnalys

一个基于 DuckDB + Pandas + Scikit-Learn 的游戏数据分析项目，涵盖运营指标分析、用户分层聚类与14日留存预测三大模块。

---

## 项目概述

本项目包含三个核心分析 Notebook，覆盖游戏数据分析的完整链路：

| Notebook | 模块 | 主要功能 |
|----------|------|----------|
| `GameAnalys.ipynb` | 运营指标分析 | 每日新增、登录/付费留存、DAU、ARPU、ARPPU、LTV |
| `EDA-KMeans.ipynb` | 用户分层聚类 | EDA、特征缩放、KMeans 聚类、用户画像、收入结构分析 |
| `游戏14日留存预测.ipynb` | 留存预测建模 | 特征工程、相关性分析、决策树建模、模型评估与特征重要性 |

---

## 三大模块详解

### 模块一：运营指标分析（`GameAnalys.ipynb`）

**数据来源**：`data/game_analysis_v2.duck`  `dim_role` + `fact_player_login_recharge`（通过 `DataUtil.getTableData` 读取）

| 功能 | 实现方式 | 产出 |
|------|----------|------|
| 每日新增 | 按 `first_login_date` 分组计数，过滤异常日期 | 柱状图 |
| 登录留存率 | 筛选 `login_cnt >= 1`，计算第N天留存率 | 折线图（Y轴百分比） |
| 付费留存率 | 筛选首日付费用户 RID，追踪后续留存 | 折线图 |
| DAU | 按 `stat_date` 去重计数 | 柱状图 |
| ARPU | `当日总收入 / 当日活跃用户数` | 折线图 |
| ARPPU | `当日总收入 / 当日付费用户数` | 折线图 |
| LTV | `截止第N天累计总收入 / 新增用户数` | 累计折线图 |
| 用户行为 | 按用户汇总在线时长与充值金额 | 散点图 |

### 模块二：用户分层聚类（`EDA-KMeans.ipynb`）

**数据来源**：`fact_player_login_recharge` 按 `rid` 聚合 `online_time_sec`、`real_money`

| 步骤 | 实现方式 | 产出 |
|------|----------|------|
| EDA | 数据维度/缺失值/描述统计/直方图 | 数据概览 |
| 分位数分析 | 充值与时长的 50%~99% 分位数 | 分布特征 |
| 特征缩放 | `np.log1p()` 对数变换 + `StandardScaler` 标准化 | 分布对比图 |
| 选择K值 | 肘部法（K=1~10 WCSS） | 肘部图 |
| KMeans聚类 | K=4，`k-means++` 初始化 | 聚类散点图 |
| 用户画像 | 按簇统计 count/mean/median/sum | 画像表 |
| 收入结构 | 人数占比 vs 收入占比 | 对比柱状图 |

**聚类结果**：

| 簇 | 用户类型 | 特征描述 |
|----|----------|----------|
| C0 | 高活跃非付费用户 | 平均在线4.26小时，几乎不付费 |
| C1 | 低活跃非付费用户 | 在线时长中位数28秒，路过型用户 |
| C2 | 活跃轻度付费用户 | 平均充值10.94元，潜力用户 |
| C3 | 核心高价值用户 | 平均在线7.4天，平均充值3685元 |

### 模块三：14日留存预测（`游戏14日留存预测.ipynb`）

**数据来源**：`data/14日留存预测特征数据导出.csv`（预处理后的特征宽表）

| 步骤 | 实现方式 | 产出 |
|------|----------|------|
| 数据检查 | 缺失值/平均值为0字段/分布分析 | 字段报告 |
| 标签分布 | `is_retained_14d` 计数 | 标签分布图 |
| 可视化 | 在线时长直方图（原始/log）、活跃重心小提琴图 | 分布图 |
| 特征选择 | 基础/付费、活跃、充值、玩法/进度四类共20+特征 |  |
| 对数变换 | 对 `first_recharge_money`、`total_7d_online_sec` 等做 `log1p` |  |
| 相关性分析 | 全特征热力图 | 热力图 |
| 建模 | `DecisionTreeClassifier`（max_depth=4），按时间切分训练/测试 | AUC/Acc/F1 |
| 模型评估 | 混淆矩阵 + Classification Report + 特征重要性条形图 | 评估报告 |

**特征体系**（摘要）：
- **基础/付费**：`is_payer_first`、`days_to_first_pay`、`first_pay_bin`、`first_recharge_money`、`is_old_player`、`reg_is_workday`
- **活跃**：`total_7d_online_sec`、`last3_online_sec`、`activity_center_ratio`、`is_active_day7`、`max_consecutive_days_7d`
- **充值**：`pay_amt_7d`、`pay_cnt_7d`、`pay_days_7d`、`pay_trend_ratio`
- **玩法/进度**：`task_cnt_7d`、`trunk_fb_cnt_7d`、`max_trunk_chapter`、`war_fb_through_rate`

---

## 工具模块

### `gameutils/DataUtil.py`
- `DataUtil.getTableData(db_path, tables)`：连接 DuckDB，读取 `ga2_dwd_v2` schema 下的指定表，返回 `Dict[str, DataFrame]`
- `DataUtil.dealDataFrameDate(dfs)`：合并角色表与登录充值表，转换日期列为 datetime，计算 `login_days`，返回 `has_register_df` 与 `login_recharge_df`

### `gameutils/DrawUtil.py`
- `draw_daily_new_bar(daily_counts)`：绘制每日创角柱状图
- `draw_retention_line(rates)`：绘制留存率折线图（Y轴自动百分比格式化）
- `draw_cohort_retention_lines(cohort_rates)`：绘制多条队列留存曲线（支持 log Y轴）

---

## 目录结构

```
GameAnalys/
 GameAnalys.ipynb                # 模块一：运营指标分析
 EDA-KMeans.ipynb                # 模块二：用户分层聚类
 游戏14日留存预测.ipynb            # 模块三：14日留存预测
 README.md                       # 项目说明文档
 字段说明.md                      # 数据字段说明
 gameutils/                      # 工具模块
    __init__.py
    DataUtil.py                 # 数据加载与预处理
    DrawUtil.py                 # 绘图工具
 data/                           # 数据目录
     0_mysql连接配置.sql
     1_日志转日度数据.sql
     2_中间表.sql
     game_analysis_v2.duck        # DuckDB 数据库（模块一/二）
     14日留存预测特征数据导出.csv    # 特征宽表（模块三）
```

---

## 数据依赖

### DuckDB（模块一、模块二）

从 `data/game_analysis_v2.duck` 读取：

| 表名 | 用途 | 关键字段 |
|------|------|----------|
| `dim_role` | 角色维度 | `rid`, `first_login_date`, `first_recharge_date`, `is_old_player` |
| `fact_player_login_recharge` | 登录充值事实 | `stat_date`, `rid`, `login_cnt`, `login_days`, `online_time_sec`, `real_money` |

### CSV（模块三）

`data/14日留存预测特征数据导出.csv`：预处理后的用户级特征宽表，包含 50+ 字段（详见 Notebook 内字段说明表）。

---

## 技术栈

- **数据存储/查询**：DuckDB
- **数据处理**：Pandas, NumPy
- **机器学习**：Scikit-Learn（KMeans, StandardScaler, DecisionTreeClassifier）
- **数据可视化**：Matplotlib, Seaborn

## 运行环境

```bash
pip install pandas numpy duckdb matplotlib seaborn scikit-learn
```

确保以下数据文件存在后，即可按顺序运行三个 Notebook：
- `data/game_analysis_v2.duck`（模块一、二）
- `data/14日留存预测特征数据导出.csv`（模块三）

---

## 分析结论

### 模块一：运营指标分析
- 留存曲线显示用户流失集中在前7天，付费用户留存率显著高于非付费用户
- ARPU/ARPPU 指标反映游戏整体付费能力与付费用户质量
- LTV 累计曲线展示用户长期价值贡献趋势

### 模块二：用户分层聚类
1. **用户价值高度不均衡**：约1%的核心用户贡献了近99%的收入，呈典型"二八效应"
2. **活跃是付费的必要非充分条件**：高活跃用户群中仍有大量未付费用户
3. **高价值用户具备可识别的行为特征**：可通过在线时长与付费行为提前识别

### 模块三：14日留存预测
- 决策树模型验证了 `max_consecutive_days_7d`（最大连续登录天数）、`is_active_day7`（第7天是否登录）等行为特征对留存的强预测力
- 特征重要性排名为后续运营策略提供量化依据

### 运营建议
- **低活跃用户（C1）**：优化新手引导，降低早期流失
- **高活跃非付费用户（C0）**：设计低门槛付费点（首充、限时礼包），促进转化
- **轻度付费用户（C2）**：通过成长型礼包和阶段奖励提升 ARPU
- **核心高价值用户（C3）**：重点维护，提供专属权益和高阶内容
- **留存预警**：基于预测模型识别高流失风险用户，提前干预