---
name: bazi-python
description: >
  Python 八字排盘计算库。核心功能：四柱排盘、五行分数计算、冲合刑会害分析、命理评判。
  参考《三命通会》《滴天髓》《渊海子平》等典籍的算法实现。
  Use when: 用户需要精确的八字计算（而非对话式分析），或需要排盘数据供其他工具使用。
triggers:
  - "八字排盘 python"
  - "bazi calculation"
  - "五行分数"
  - "冲合刑会"
  - "命理算法"
---

# 八字排盘 Python 库

基于 `china-testing/bazi` 仓库的 Python 排盘引擎。

## 安装

```bash
git clone --depth=1 https://github.com/china-testing/bazi
cd bazi
```

## 核心模块

| 文件 | 功能 |
|------|------|
| `bazi.py` | 八字排盘主模块，含冲合刑会、五行分数、通会评判 |
| `convert.py` | 阳历↔农历转换 |
| `sizi.py` | 四柱计算 |
| `ganzhi.py` | 六十甲子、干支推算 |
| `yue.py` | 月令、月柱计算 |
| `shengxiao.py` | 生肖合婚 |
| `luohou.py` | 罗喉日时计算 |
| `datas.py` | 基础数据表 |
| `common.py` | 通用工具 |
| `books/` | 古籍资料 |

## 使用示例

```python
from bazi import Bazi

# 基本排盘
bz = Bazi(1990, 5, 15, 14, gender=1)  # 阳历日期，时辰，性别(1=男)
print(bz.get_result())

# 查看冲合刑会
print(bz.chong_list)   # 冲
print(bz.he_list)      # 合
print(bz.xing_list)    # 刑
print(bz.hui_list)     # 会
print(bz.hai_list)     # 害

# 五行分数
print(bz.wuxing_scores)

# 三命通会评判
bz.pingjia()
```

## 输出格式

排盘结果包含：
- 四柱天干地支
- 十神
- 藏干
- 五行分数
- 冲合刑会害关系
- 《三命通会》核心评判

## 注意事项

- 书籍资料在 `books/` 目录
- 罗喉日时用于风水择日
- 生肖合婚在 `shengxiao.py`
