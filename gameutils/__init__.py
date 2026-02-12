import matplotlib.pyplot as plt

# 设置中文字体支持
plt.rcParams['font.sans-serif'] = ['SimHei', 'Microsoft YaHei', 'DejaVu Sans']  # 按优先级尝试
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号

from .DrawUtil import DrawUtil  # noqa: F401