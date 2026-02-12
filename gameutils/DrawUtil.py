from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
import pandas as pd


def _to_percent(x, _pos):
    return f"{x:.1%}"


@dataclass
class DrawUtil:
    """Plotting helper for this project.

    Keeps the notebook code small and consistent.
    """

    @staticmethod
    def draw_daily_new_bar(
        daily_counts: pd.DataFrame,
        *,
        date_index_name: str = "日期",
        count_column: str = "register_count",
        title: str = "每日创角数量统计",
        figsize=(12, 6),
    ) -> None:
        if daily_counts is None or daily_counts.empty:
            print("daily_counts 为空，跳过绘图")
            return

        plt.figure(figsize=figsize)
        plt.bar(
            daily_counts.index,
            daily_counts[count_column],
            color="skyblue",
            edgecolor="navy",
            alpha=0.7,
        )
        plt.title(title, fontsize=14, fontweight="bold")
        plt.xlabel(date_index_name, fontsize=12)
        plt.ylabel("创角数", fontsize=12)
        plt.xticks(rotation=45)
        plt.grid(axis="y", alpha=0.3)
        plt.tight_layout()
        plt.show()

    @staticmethod
    def draw_retention_line(
        rates: pd.Series,
        *,
        title: str = "登录留存率",
        ylabel: str = "留存率",
        xlabel: str = "天数",
        color: str = "red",
        figsize=(12, 6),
    ) -> None:
        if rates is None or len(rates) == 0:
            print("rates 为空，跳过绘图")
            return

        plt.figure(figsize=figsize)
        rates.plot(
            kind="line",
            title=title,
            grid=True,
            linewidth=2,
            color=color,
            marker="o",
            markersize=4,
        )
        plt.gca().yaxis.set_major_formatter(FuncFormatter(_to_percent))
        plt.ylabel(ylabel)
        plt.xlabel(xlabel)
        plt.xticks(rotation=45)
        plt.tight_layout()
        plt.show()

    @staticmethod
    def draw_cohort_retention_lines(
        cohort_rates: pd.DataFrame,
        *,
        max_cohorts: int = 20,
        title: str = "单日新号的留存率",
        ylabel: str = "留存率",
        xlabel: str = "天数",
        figsize=(12, 12),
        use_log_y: bool = False,
    ) -> None:
        if cohort_rates is None or cohort_rates.empty:
            print("cohort_rates 为空，跳过绘图")
            return

        draw_df = cohort_rates.iloc[: int(max_cohorts)]

        plt.figure(figsize=figsize)
        draw_df.T.plot()
        plt.title(title)
        plt.xlabel(xlabel)
        plt.ylabel(ylabel)
        if use_log_y:
            plt.yscale("log")
        plt.legend(title="日期", bbox_to_anchor=(1.05, 1), loc="upper left")
        plt.grid(True, alpha=0.3)
        plt.tight_layout()
        plt.show()
