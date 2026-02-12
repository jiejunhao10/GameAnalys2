#!/usr/bin/env python3
"""
Game Data Analysis Example
游戏数据分析示例

This script demonstrates how to use the game data analysis system.
"""

from sample_data import generate_sample_data
from analyzer import GameAnalyzer
from visualizer import GameVisualizer


def main():
    """Main function to run the game data analysis"""
    
    print("正在加载游戏数据... (Loading game data...)")
    print()
    
    # Generate sample data
    players = generate_sample_data()
    print(f"成功加载 {len(players)} 位玩家的数据")
    print(f"Successfully loaded data for {len(players)} players")
    print()
    
    # Create analyzer
    analyzer = GameAnalyzer(players)
    
    # Generate and display summary report
    print(analyzer.generate_summary_report())
    print()
    
    # Create visualizer
    visualizer = GameVisualizer(analyzer)
    
    # Display various charts
    print(visualizer.create_top_players_chart(10, 'score'))
    print()
    
    print(visualizer.create_top_players_chart(10, 'playtime'))
    print()
    
    print(visualizer.create_game_mode_chart())
    print()
    
    print(visualizer.create_daily_users_chart())
    print()
    
    # Export to JSON
    output_file = "game_analysis_results.json"
    result = visualizer.export_to_json(output_file)
    print(result)
    print()
    
    print("分析完成！(Analysis complete!)")


if __name__ == "__main__":
    main()
