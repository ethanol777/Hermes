# HN Firebase API: ID 排序偏差陷阱

## 问题

Hacker News Firebase API 的 `topstories.json` 返回的 story ID 数组**顺序与 news.ycombinator.com 页面展示顺序不一致**。

直接后果：当你按照 API 返回的数组位置（第 N 个元素）去对应页面上第 N 篇文章时，**标题/内容大概率匹配错误**。

## 实际案例（2026-05-16）

```
API 返回的前 15 个 ID（
[48158506, 48158606, 48150431, 48153379, 48114208,
 48157559, 48155212, 48132106, 48149259, 48130468,
 48122657, 48155324, 48148460, 48136000, 48118478, ...]

直觉认为位置/索引:
  索引 0 → 第 1 名（最高分）
  索引 1 → 第 2 名
  ...
  索引 12 → 第 13 名（383pts "Pixel 10 exploit"）

实际对应关系：
  索引 0 = 24pts  Δ-Mem           ← 排名第 1 的不是最高分
  索引 1 = 7pts   Futhark          ← 低分在第 2 位
  索引 2 = 954pts Project Gutenberg
  索引 3 = 1393pts AI Psychosis
  ...
  索引 12 = 125pts P2P meth       ← 以为这里是 Pixel 10
  索引 13 = 100pts Quasicrystals   ← 也不是
  索引 14 = 51pts  England Runestones
```

实际 Pixel 10 exploit（383pts）在索引 13（`48148460`）——与页面排名严重不一致。

## 原因

HN Firebase API 的 `topstories.json` 返回的是**算法排序**，不完全等于页面展示的纯 score 排序。Google Firebase 实时数据库会按某种内部权重（可能包括时间衰减、用户信号、算法调整）排列 ID，与前端渲染逻辑不完全同步。

## 解决方案

### 方案 A：逐条查询并自行按 score 排序（推荐）

```python
import json, urllib.request

# 获取 top 50 故事 ID
resp = urllib.request.urlopen("https://hacker-news.firebaseio.com/v0/topstories.json")
ids = json.loads(resp.read())[:50]

# 逐条查询，构建带 score 的列表
stories = []
for sid in ids:
    resp = urllib.request.urlopen(f"https://hacker-news.firebaseio.com/v0/item/{sid}.json")
    item = json.loads(resp.read())
    if item and item.get("title"):
        stories.append({
            "id": sid,
            "title": item["title"],
            "score": item.get("score", 0),
            "url": item.get("url", ""),
        })

# 按 score 降序排列
stories.sort(key=lambda s: s["score"], reverse=True)

for i, s in enumerate(stories, 1):
    print(f"{i}. [{s['score']}pts] {s['title']}")
    print(f"   {s['url']}")
```

### 方案 B：直接查已知的高分 ID（如果只对最高分感兴趣）

```python
# 先粗扫前 200 个 ID 的 score
# 筛选 score > 200 的再深入读
```

### 方案 C：从 HN 首页 HTML 解析（需要浏览器）

浏览器访问 `news.ycombinator.com` 后，页面直接展示按算法排名的列表，不需要处理 API ID 偏移。

## 最佳实践

| 场景 | 推荐方法 |
|------|---------|
| 快速了解今天有什么好话题 | 方案 A（API + 自行排序，前 20-30条） |
| 只看最高分 | 方案 A，设置 score 阈值 > 200 |
| 对特定话题深读 | 方案 A 找到文章后，用 curl + HTML 解析读评论区 |
| 需要准确阅读展示顺序 | 方案 C（浏览器） |

## 重要：逐条查询的性能

Firebase 的 REST API 是**针对随机访问优化的 key-value 存储**，逐条查询 30-50 条 story 是正常使用模式（每条请求 ~200ms）。HN API 没有公开的限流门槛，实测 50 条查询在 10 秒左右完成。

不要尝试一次取 500 条——防火墙/URL 长度可能限制。前 50 条已经覆盖了当天最有价值的内容。

## 验证检查

如果你在 API 结果中看到**低分排在高分前面**（如 7pts 排第 2），说明你遇到了这个排序偏差。此时停止依赖 API 的数组位置，改用方案 A 的 `sort(key=score)`。
