from typing import Dict, List, Optional

import duckdb
import pandas as pd

# 数据加载类
class DataUtil:
    
    def __init__(self):
        print("LoadData 初始化")

    #获取duckdb数据库中的表数据
    def getTableData(self, db_path, tables) -> Dict[str, pd.DataFrame]:
        dataframes = {}
        conn = duckdb.connect(database=db_path, read_only=True)
        for tableName in tables:
            df = conn.execute(f"SELECT * FROM ga2_dwd_v2.{tableName}").df()
            dataframes[tableName] = df
            print(f"{tableName}: {df.shape}")
        conn.close()
        return self.dealDataFrameDate(dataframes)
    
    def dealDataFrameDate(self, dfs: Dict[str, pd.DataFrame]) -> Dict[str, pd.DataFrame]:
        dim_role_df = dfs["dim_role"]    #角色表
        fact_player_login_recharge = dfs["fact_player_login_recharge"]  #登录和充值表

        # 塞选出登录数据
        has_register_df = dim_role_df[dim_role_df['rid'].notnull()]    #筛选出有创角时间的角色
        print(f"有创角的角色数:{len(has_register_df)}")

        # 合并登录充值表和角色表，获取每个角色的首次登录时间
        login_recharge_df = pd.merge(
            fact_player_login_recharge, 
            has_register_df[['rid', 'first_login_date']], 
            on='rid', 
            how='left'
        )

        # 确保时间列是datetime类型
        login_recharge_df['first_login_date'] = pd.to_datetime(login_recharge_df['first_login_date'])
        login_recharge_df['stat_date'] = pd.to_datetime(login_recharge_df['stat_date'])

        # 计算登录天数
        login_recharge_df['login_days'] = (
            login_recharge_df['stat_date'] - login_recharge_df['first_login_date'] + pd.Timedelta(days=1)
        ).dt.days

        login_recharge_df.sort_values(by=['rid', 'stat_date'], inplace=True)

        # print(login_recharge_df.head(3))
        dict_df = {
            "has_register_df": has_register_df,
            "login_recharge_df": login_recharge_df
            }
        return dict_df
