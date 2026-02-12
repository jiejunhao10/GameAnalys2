"""
Game Data Visualizer
游戏数据可视化

This module provides visualization functionality for game data analysis.
"""

from typing import List, Dict
import json


class GameVisualizer:
    """Creates visualizations for game data"""
    
    def __init__(self, analyzer):
        self.analyzer = analyzer
    
    def create_ascii_bar_chart(self, data: Dict[str, float], title: str, max_width: int = 50) -> str:
        """
        Create an ASCII bar chart
        
        Args:
            data: Dictionary with labels and values
            title: Chart title
            max_width: Maximum width of bars
        
        Returns:
            ASCII bar chart as string
        """
        if not data:
            return f"{title}\n(No data available)"
        
        chart = [title, "=" * (max_width + 20), ""]
        
        max_value = max(data.values())
        if max_value == 0:
            return f"{title}\n(All values are zero)"
        
        for label, value in sorted(data.items(), key=lambda x: x[1], reverse=True):
            bar_length = int((value / max_value) * max_width)
            bar = "█" * bar_length
            chart.append(f"{label:20s} | {bar} {value:.2f}")
        
        chart.append("")
        return "\n".join(chart)
    
    def create_top_players_chart(self, n: int = 10, by: str = 'score') -> str:
        """Create a chart showing top players"""
        top_players = self.analyzer.get_top_players(n, by)
        data = {username: value for username, value in top_players}
        
        metric_names = {
            'score': '分数 (Score)',
            'playtime': '游戏时间 (Playtime Hours)',
            'level': '等级 (Level)'
        }
        
        title = f"排行榜 - {metric_names.get(by, by)} (Top {n} Players - {by})"
        return self.create_ascii_bar_chart(data, title)
    
    def create_game_mode_chart(self) -> str:
        """Create a chart showing game mode statistics"""
        mode_stats = self.analyzer.get_game_mode_statistics()
        
        # Chart by number of sessions
        sessions_data = {mode: stats['total_sessions'] for mode, stats in mode_stats.items()}
        sessions_chart = self.create_ascii_bar_chart(
            sessions_data,
            "游戏模式 - 场次 (Game Modes - Sessions)"
        )
        
        # Chart by average score
        score_data = {mode: stats['avg_score'] for mode, stats in mode_stats.items()}
        score_chart = self.create_ascii_bar_chart(
            score_data,
            "游戏模式 - 平均分数 (Game Modes - Avg Score)"
        )
        
        return sessions_chart + "\n\n" + score_chart
    
    def create_daily_users_chart(self) -> str:
        """Create a chart showing daily active users"""
        daily_users = self.analyzer.get_daily_active_users()
        return self.create_ascii_bar_chart(
            daily_users,
            "每日活跃用户 (Daily Active Users)"
        )
    
    def export_to_json(self, filename: str):
        """Export analysis results to JSON file"""
        data = {
            'summary': {
                'total_players': len(self.analyzer.players),
                'total_sessions': len(self.analyzer.all_sessions),
                'avg_session_duration': self.analyzer.get_average_session_duration(),
                'retention_rate_7d': self.analyzer.get_player_retention_rate(7)
            },
            'top_players': {
                'by_score': self.analyzer.get_top_players(10, 'score'),
                'by_playtime': self.analyzer.get_top_players(10, 'playtime'),
                'by_level': self.analyzer.get_top_players(10, 'level')
            },
            'game_modes': self.analyzer.get_game_mode_statistics(),
            'daily_active_users': self.analyzer.get_daily_active_users()
        }
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        return f"Data exported to {filename}"
