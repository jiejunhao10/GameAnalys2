"""
Unit Tests for Game Data Analysis System
游戏数据分析系统单元测试
"""

import unittest
from datetime import datetime, timedelta
from game_data import GameSession, PlayerProfile
from analyzer import GameAnalyzer


class TestGameSession(unittest.TestCase):
    """Test GameSession model"""
    
    def setUp(self):
        """Set up test data"""
        self.start_time = datetime(2026, 1, 1, 10, 0, 0)
        self.end_time = datetime(2026, 1, 1, 11, 30, 0)
        self.session = GameSession(
            session_id="S001",
            player_id="P001",
            start_time=self.start_time,
            end_time=self.end_time,
            score=1000,
            level_reached=10,
            game_mode="Classic"
        )
    
    def test_duration_minutes(self):
        """Test session duration calculation"""
        self.assertEqual(self.session.duration_minutes, 90.0)
    
    def test_score_per_minute(self):
        """Test score per minute calculation"""
        expected_spm = 1000 / 90.0
        self.assertAlmostEqual(self.session.score_per_minute, expected_spm, places=2)
    
    def test_zero_duration(self):
        """Test handling of zero duration"""
        session = GameSession(
            session_id="S002",
            player_id="P001",
            start_time=self.start_time,
            end_time=self.start_time,
            score=1000,
            level_reached=5,
            game_mode="Arena"
        )
        self.assertEqual(session.score_per_minute, 0)


class TestPlayerProfile(unittest.TestCase):
    """Test PlayerProfile model"""
    
    def setUp(self):
        """Set up test data"""
        self.sessions = [
            GameSession(
                session_id=f"S00{i}",
                player_id="P001",
                start_time=datetime(2026, 1, i, 10, 0, 0),
                end_time=datetime(2026, 1, i, 11, 0, 0),
                score=1000 + i * 100,
                level_reached=i,
                game_mode="Classic"
            )
            for i in range(1, 6)
        ]
        
        self.player = PlayerProfile(
            player_id="P001",
            username="TestPlayer",
            registration_date=datetime(2026, 1, 1),
            sessions=self.sessions
        )
    
    def test_total_playtime_hours(self):
        """Test total playtime calculation"""
        # 5 sessions * 60 minutes = 300 minutes = 5 hours
        self.assertEqual(self.player.total_playtime_hours, 5.0)
    
    def test_average_score(self):
        """Test average score calculation"""
        # Scores: 1100, 1200, 1300, 1400, 1500
        # Average: (1100 + 1200 + 1300 + 1400 + 1500) / 5 = 1300
        self.assertEqual(self.player.average_score, 1300.0)
    
    def test_highest_level(self):
        """Test highest level reached"""
        self.assertEqual(self.player.highest_level, 5)
    
    def test_total_sessions(self):
        """Test total sessions count"""
        self.assertEqual(self.player.total_sessions, 5)
    
    def test_empty_sessions(self):
        """Test player with no sessions"""
        empty_player = PlayerProfile(
            player_id="P002",
            username="EmptyPlayer",
            registration_date=datetime(2026, 1, 1),
            sessions=[]
        )
        
        self.assertEqual(empty_player.total_playtime_hours, 0.0)
        self.assertEqual(empty_player.average_score, 0.0)
        self.assertEqual(empty_player.highest_level, 0)
        self.assertEqual(empty_player.total_sessions, 0)


class TestGameAnalyzer(unittest.TestCase):
    """Test GameAnalyzer functionality"""
    
    def setUp(self):
        """Set up test data"""
        # Create test players
        self.players = []
        for i in range(1, 4):
            sessions = [
                GameSession(
                    session_id=f"S{i}0{j}",
                    player_id=f"P00{i}",
                    start_time=datetime(2026, 1, j, 10, 0, 0),
                    end_time=datetime(2026, 1, j, 11, 0, 0),
                    score=i * 1000 + j * 100,
                    level_reached=i * 10 + j,
                    game_mode=["Classic", "Arena", "Survival"][j % 3]
                )
                for j in range(1, 4)
            ]
            
            player = PlayerProfile(
                player_id=f"P00{i}",
                username=f"Player{i}",
                registration_date=datetime(2026, 1, 1),
                sessions=sessions
            )
            self.players.append(player)
        
        self.analyzer = GameAnalyzer(self.players)
    
    def test_get_top_players_by_score(self):
        """Test getting top players by score"""
        top_players = self.analyzer.get_top_players(2, 'score')
        self.assertEqual(len(top_players), 2)
        # Player3 should have highest average score
        self.assertEqual(top_players[0][0], "Player3")
    
    def test_get_top_players_by_level(self):
        """Test getting top players by level"""
        top_players = self.analyzer.get_top_players(2, 'level')
        self.assertEqual(len(top_players), 2)
        # Player3 should have highest level
        self.assertEqual(top_players[0][0], "Player3")
    
    def test_get_game_mode_statistics(self):
        """Test game mode statistics"""
        stats = self.analyzer.get_game_mode_statistics()
        self.assertIn("Classic", stats)
        self.assertIn("Arena", stats)
        self.assertIn("Survival", stats)
        
        # Each mode should have 3 sessions (one from each player)
        for mode in ["Classic", "Arena", "Survival"]:
            self.assertEqual(stats[mode]['total_sessions'], 3)
            self.assertGreater(stats[mode]['avg_score'], 0)
    
    def test_get_average_session_duration(self):
        """Test average session duration calculation"""
        avg_duration = self.analyzer.get_average_session_duration()
        # All sessions are 60 minutes
        self.assertEqual(avg_duration, 60.0)
    
    def test_get_daily_active_users(self):
        """Test daily active users calculation"""
        daily_users = self.analyzer.get_daily_active_users()
        # Should have 3 different days
        self.assertEqual(len(daily_users), 3)
        # Each day should have 3 active users
        for count in daily_users.values():
            self.assertEqual(count, 3)
    
    def test_invalid_metric(self):
        """Test invalid metric raises ValueError"""
        with self.assertRaises(ValueError):
            self.analyzer.get_top_players(5, 'invalid_metric')


class TestGameAnalyzerEdgeCases(unittest.TestCase):
    """Test edge cases for GameAnalyzer"""
    
    def test_empty_players(self):
        """Test analyzer with no players"""
        analyzer = GameAnalyzer([])
        
        self.assertEqual(len(analyzer.get_top_players(5)), 0)
        self.assertEqual(len(analyzer.get_game_mode_statistics()), 0)
        self.assertEqual(analyzer.get_average_session_duration(), 0.0)
        self.assertEqual(analyzer.get_player_retention_rate(), 0.0)
    
    def test_players_with_no_sessions(self):
        """Test analyzer with players but no sessions"""
        players = [
            PlayerProfile(
                player_id="P001",
                username="EmptyPlayer",
                registration_date=datetime(2026, 1, 1),
                sessions=[]
            )
        ]
        analyzer = GameAnalyzer(players)
        
        self.assertEqual(analyzer.get_average_session_duration(), 0.0)
        self.assertEqual(len(analyzer.get_game_mode_statistics()), 0)


if __name__ == '__main__':
    unittest.main()
