"""
Game Data Analyzer
游戏数据分析器

This module provides analytics functionality for game data.
"""

from typing import List, Dict, Tuple
from collections import defaultdict
from datetime import datetime
from game_data import GameSession, PlayerProfile


class GameAnalyzer:
    """Analyzes game data and generates insights"""
    
    def __init__(self, players: List[PlayerProfile]):
        self.players = players
        self.all_sessions = []
        for player in players:
            self.all_sessions.extend(player.sessions)
    
    def get_top_players(self, n: int = 10, by: str = 'score') -> List[Tuple[str, float]]:
        """
        Get top N players by specified metric
        
        Args:
            n: Number of top players to return
            by: Metric to sort by ('score', 'playtime', 'level')
        
        Returns:
            List of tuples (username, metric_value)
        """
        if by == 'score':
            sorted_players = sorted(
                self.players, 
                key=lambda p: p.average_score, 
                reverse=True
            )
            return [(p.username, p.average_score) for p in sorted_players[:n]]
        elif by == 'playtime':
            sorted_players = sorted(
                self.players, 
                key=lambda p: p.total_playtime_hours, 
                reverse=True
            )
            return [(p.username, p.total_playtime_hours) for p in sorted_players[:n]]
        elif by == 'level':
            sorted_players = sorted(
                self.players, 
                key=lambda p: p.highest_level, 
                reverse=True
            )
            return [(p.username, p.highest_level) for p in sorted_players[:n]]
        else:
            raise ValueError(f"Unknown metric: {by}")
    
    def get_game_mode_statistics(self) -> Dict[str, Dict[str, float]]:
        """
        Get statistics by game mode
        
        Returns:
            Dictionary with game mode statistics
        """
        mode_stats = defaultdict(lambda: {
            'total_sessions': 0,
            'avg_score': 0,
            'avg_duration': 0,
            'total_score': 0,
            'total_duration': 0
        })
        
        for session in self.all_sessions:
            mode = session.game_mode
            mode_stats[mode]['total_sessions'] += 1
            mode_stats[mode]['total_score'] += session.score
            mode_stats[mode]['total_duration'] += session.duration_minutes
        
        # Calculate averages
        for mode, stats in mode_stats.items():
            if stats['total_sessions'] > 0:
                stats['avg_score'] = stats['total_score'] / stats['total_sessions']
                stats['avg_duration'] = stats['total_duration'] / stats['total_sessions']
        
        return dict(mode_stats)
    
    def get_player_retention_rate(self, days: int = 7) -> float:
        """
        Calculate player retention rate
        
        Args:
            days: Number of days to consider for retention
        
        Returns:
            Retention rate as percentage
        """
        if not self.players:
            return 0.0
        
        # Find the latest session date
        if not self.all_sessions:
            return 0.0
        
        latest_date = max(session.end_time for session in self.all_sessions)
        
        # Count players who played within the retention period
        active_players = 0
        for player in self.players:
            if player.sessions:
                last_session = max(player.sessions, key=lambda s: s.end_time)
                days_since_last = (latest_date - last_session.end_time).days
                if days_since_last <= days:
                    active_players += 1
        
        return (active_players / len(self.players)) * 100
    
    def get_daily_active_users(self) -> Dict[str, int]:
        """
        Get daily active user counts
        
        Returns:
            Dictionary with date as key and user count as value
        """
        daily_users = defaultdict(set)
        
        for session in self.all_sessions:
            date_str = session.start_time.strftime('%Y-%m-%d')
            daily_users[date_str].add(session.player_id)
        
        return {date: len(users) for date, users in sorted(daily_users.items())}
    
    def get_average_session_duration(self) -> float:
        """Get average session duration in minutes"""
        if not self.all_sessions:
            return 0.0
        return sum(s.duration_minutes for s in self.all_sessions) / len(self.all_sessions)
    
    def generate_summary_report(self) -> str:
        """Generate a comprehensive summary report"""
        report = []
        report.append("=" * 60)
        report.append("游戏数据分析报告 (Game Data Analysis Report)")
        report.append("=" * 60)
        report.append("")
        
        # Overall statistics
        report.append("总体统计 (Overall Statistics):")
        report.append(f"  总玩家数 (Total Players): {len(self.players)}")
        report.append(f"  总游戏场次 (Total Sessions): {len(self.all_sessions)}")
        report.append(f"  平均游戏时长 (Avg Session Duration): {self.get_average_session_duration():.2f} 分钟")
        report.append(f"  玩家留存率 (7-day Retention): {self.get_player_retention_rate(7):.2f}%")
        report.append("")
        
        # Top players by score
        report.append("最高分玩家 (Top Players by Score):")
        top_players = self.get_top_players(5, 'score')
        for i, (username, score) in enumerate(top_players, 1):
            report.append(f"  {i}. {username}: {score:.2f}")
        report.append("")
        
        # Game mode statistics
        report.append("游戏模式统计 (Game Mode Statistics):")
        mode_stats = self.get_game_mode_statistics()
        for mode, stats in mode_stats.items():
            report.append(f"  {mode}:")
            report.append(f"    场次 (Sessions): {stats['total_sessions']}")
            report.append(f"    平均分数 (Avg Score): {stats['avg_score']:.2f}")
            report.append(f"    平均时长 (Avg Duration): {stats['avg_duration']:.2f} 分钟")
        report.append("")
        
        report.append("=" * 60)
        
        return "\n".join(report)
