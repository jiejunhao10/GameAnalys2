# GameAnalys2 - 游戏数据分析系统

Game Data Analysis System / 游戏数据分析系统

## 简介 (Introduction)

GameAnalys2 是一个用于游戏数据分析的 Python 工具。它可以帮助游戏开发者和运营人员分析玩家行为、游戏表现和关键指标。

GameAnalys2 is a Python tool for game data analysis. It helps game developers and operators analyze player behavior, game performance, and key metrics.

## 功能特性 (Features)

- **玩家分析** (Player Analysis)
  - 玩家排行榜（按分数、游戏时长、等级）
  - 玩家留存率计算
  - 玩家活跃度分析

- **游戏会话分析** (Session Analysis)
  - 平均游戏时长
  - 得分分析
  - 关卡进度追踪

- **游戏模式分析** (Game Mode Analysis)
  - 各模式受欢迎度
  - 各模式平均表现
  - 模式对比分析

- **数据可视化** (Data Visualization)
  - ASCII 图表显示
  - JSON 数据导出
  - 每日活跃用户趋势

## 安装 (Installation)

```bash
# 克隆仓库 (Clone the repository)
git clone https://github.com/jiejunhao10/GameAnalys2.git
cd GameAnalys2

# 无需额外依赖，使用 Python 3.7+ 即可
# No additional dependencies required, use Python 3.7+
```

## 使用方法 (Usage)

### 快速开始 (Quick Start)

运行示例程序：

```bash
python main.py
```

### 使用自己的数据 (Using Your Own Data)

```python
from game_data import GameSession, PlayerProfile
from analyzer import GameAnalyzer
from visualizer import GameVisualizer
from datetime import datetime

# 创建玩家数据
players = [
    PlayerProfile(
        player_id="P001",
        username="TestPlayer",
        registration_date=datetime.now(),
        sessions=[
            GameSession(
                session_id="S001",
                player_id="P001",
                start_time=datetime.now(),
                end_time=datetime.now(),
                score=1000,
                level_reached=10,
                game_mode="Classic"
            )
        ]
    )
]

# 创建分析器
analyzer = GameAnalyzer(players)

# 生成报告
print(analyzer.generate_summary_report())

# 创建可视化
visualizer = GameVisualizer(analyzer)
print(visualizer.create_top_players_chart())
```

## 数据模型 (Data Models)

### GameSession (游戏会话)

- `session_id`: 会话ID
- `player_id`: 玩家ID
- `start_time`: 开始时间
- `end_time`: 结束时间
- `score`: 得分
- `level_reached`: 达到的关卡
- `game_mode`: 游戏模式

### PlayerProfile (玩家档案)

- `player_id`: 玩家ID
- `username`: 用户名
- `registration_date`: 注册日期
- `sessions`: 游戏会话列表

## 分析功能 (Analysis Features)

### GameAnalyzer

- `get_top_players(n, by)`: 获取排名前N的玩家
- `get_game_mode_statistics()`: 获取游戏模式统计
- `get_player_retention_rate(days)`: 计算玩家留存率
- `get_daily_active_users()`: 获取每日活跃用户
- `generate_summary_report()`: 生成汇总报告

### GameVisualizer

- `create_top_players_chart()`: 创建玩家排行榜图表
- `create_game_mode_chart()`: 创建游戏模式图表
- `create_daily_users_chart()`: 创建每日用户图表
- `export_to_json(filename)`: 导出JSON格式数据

## 输出示例 (Output Example)

程序会生成详细的分析报告，包括：

- 总体统计数据
- 玩家排行榜
- 游戏模式分析
- ASCII 图表可视化
- JSON 数据文件

## 许可证 (License)

MIT License

## 贡献 (Contributing)

欢迎提交 Issues 和 Pull Requests！

Welcome to submit Issues and Pull Requests!