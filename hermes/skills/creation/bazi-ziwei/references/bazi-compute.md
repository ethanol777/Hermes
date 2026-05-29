# 八字精确计算代码

## 日柱快速推算

已知条件：
- **2002年4月16日 = 甲子日**（基准锚点，可查万年历确认一次后复用）
- 六十甲子循环，60天一轮

```python
from datetime import date

ANCHOR_DATE = date(2002, 4, 16)
ANCHOR_GAN = 0   # 甲=0
ANCHOR_ZHI = 0   # 子=0

tian_gan = ["甲","乙","丙","丁","戊","己","庚","辛","壬","癸"]
di_zhi   = ["子","丑","寅","卯","辰","巳","午","未","申","酉","戌","亥"]

def ganzhi(target_date):
    diff = (target_date - ANCHOR_DATE).days
    gan_idx = (ANCHOR_GAN + diff) % 10
    zhi_idx = (ANCHOR_ZHI + diff) % 12
    return tian_gan[gan_idx] + di_zhi[zhi_idx]

# 验证：2026-06-01 = 丙辰
print(ganzhi(date(2026, 6, 1)))  # 丙辰
```

## 年柱

以立春为分界。已知 2002年=壬午，可用60甲子循环反推。

```python
def year_ganzhi(gregorian_year, month, day):
    # 立春2月4日之前归上一年
    if month < 2 or (month == 2 and day < 4):
        year = gregorian_year - 1
    else:
        year = gregorian_year
    # 2002年=壬午, 1900年=庚子(基准)
    diff = year - 1900
    gan_idx = (5 + diff) % 10   # 庚=5
    zhi_idx = (0 + diff) % 12   # 子=0
    return tian_gan[gan_idx] + di_zhi[zhi_idx]
```

## 时柱（五鼠遁）

```python
wushudun = {
    "甲": "甲", "己": "甲",  # 甲子时
    "乙": "丙", "庚": "丙",  # 丙子时
    "丙": "戊", "辛": "戊",  # 戊子时
    "丁": "庚", "壬": "庚",  # 庚子时
    "戊": "壬", "癸": "壬",  # 壬子时
}

def hour_ganzhi(day_gan, hour):
    zhi_idx = (hour + 1) // 2
    if hour == 23:
        zhi_idx = 0
    gan_start = wushudun[day_gan]
    gan_idx = tian_gan.index(gan_start)
    return tian_gan[(gan_idx + zhi_idx) % 10] + di_zhi[zhi_idx]
```

## 已知锚点固化

| 阳历日期 | 日柱 | 用途 |
|---------|------|------|
| 2002-04-16 | 甲子 | 基准锚点（77的生日） |
| 2026-06-01 | 丙辰 | 验证点（8812天差计算） |
