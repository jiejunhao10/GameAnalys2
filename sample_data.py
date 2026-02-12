"""
Sample Data Generator
示例数据生成器

This module generates sample game data for testing and demonstration.
"""

import random
from datetime import datetime, timedelta
from game_data import GameSession, PlayerProfile


def generate_sample_data():
    """Generate sample game data for demonstration"""
    
    # Sample player usernames
    usernames = [
        "DragonSlayer", "NinjaWarrior", "MagicMaster", "SpeedRunner", "ProGamer",
        "LegendKiller", "ShadowHunter", "ThunderStrike", "IceQueen", "FireKnight",
        "StarPlayer", "GoldenEagle", "SilverWolf", "BronzeTiger", "IronBear",
        "CrystalMage", "DarkAssassin", "LightPaladin", "WindRanger", "EarthGuardian"
    ]
    
    game_modes = ["Classic", "Arena", "Survival", "TimeAttack", "BossFight"]
    
    players = []
    base_date = datetime.now() - timedelta(days=30)
    
    for i, username in enumerate(usernames):
        player_id = f"P{i+1:03d}"
        registration_date = base_date + timedelta(days=random.randint(0, 15))
        
        # Generate sessions for this player
        sessions = []
        num_sessions = random.randint(5, 30)
        
        for j in range(num_sessions):
            session_date = registration_date + timedelta(
                days=random.randint(0, 30),
                hours=random.randint(0, 23)
            )
            duration = random.randint(5, 120)  # 5 to 120 minutes
            
            session = GameSession(
                session_id=f"S{i+1:03d}{j+1:03d}",
                player_id=player_id,
                start_time=session_date,
                end_time=session_date + timedelta(minutes=duration),
                score=random.randint(100, 10000),
                level_reached=random.randint(1, 50),
                game_mode=random.choice(game_modes)
            )
            sessions.append(session)
        
        player = PlayerProfile(
            player_id=player_id,
            username=username,
            registration_date=registration_date,
            sessions=sessions
        )
        players.append(player)
    
    return players
