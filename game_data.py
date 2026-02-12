"""
Game Data Models
游戏数据模型

This module defines the core data structures for game data analysis.
"""

from dataclasses import dataclass
from datetime import datetime
from typing import List, Dict


@dataclass
class GameSession:
    """Represents a single game session"""
    session_id: str
    player_id: str
    start_time: datetime
    end_time: datetime
    score: int
    level_reached: int
    game_mode: str
    
    @property
    def duration_minutes(self) -> float:
        """Calculate session duration in minutes"""
        return (self.end_time - self.start_time).total_seconds() / 60
    
    @property
    def score_per_minute(self) -> float:
        """Calculate score per minute"""
        duration = self.duration_minutes
        return self.score / duration if duration > 0 else 0


@dataclass
class PlayerProfile:
    """Represents a player profile"""
    player_id: str
    username: str
    registration_date: datetime
    sessions: List[GameSession]
    
    @property
    def total_playtime_hours(self) -> float:
        """Calculate total playtime in hours"""
        total_minutes = sum(session.duration_minutes for session in self.sessions)
        return total_minutes / 60
    
    @property
    def average_score(self) -> float:
        """Calculate average score across all sessions"""
        if not self.sessions:
            return 0
        return sum(session.score for session in self.sessions) / len(self.sessions)
    
    @property
    def highest_level(self) -> int:
        """Get the highest level reached"""
        if not self.sessions:
            return 0
        return max(session.level_reached for session in self.sessions)
    
    @property
    def total_sessions(self) -> int:
        """Get total number of sessions"""
        return len(self.sessions)
