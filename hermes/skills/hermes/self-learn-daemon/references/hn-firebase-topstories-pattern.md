# HN Firebase API — 首页 Top Stories 批量获取模式

## 场景

需要获取 Hacker News 当前首页的完整故事列表（标题 + 分数 + 链接），用于日常学习探索。速度要求：尽快完成，不依赖浏览器渲染。

## 方案：Firebase REST API + Python 批量查询

HN 的官方数据存储在 Google Firebase Realtime Database 上，其 REST API 不需要认证，响应速度比浏览器导航快数倍。

```python
# 完整模式：获取前 30 条故事，按分数排序
import json, urllib.request

# 1. 获取 ID 列表（按 HN 算法排序）
req = urllib.request.Request(
    "https://hacker-news.firebaseio.com/v0/topstories.json",
    headers={"User-Agent": "Monica/1.0"}
)
resp = urllib.request.urlopen(req, timeout=10)
ids = json.loads(resp.read())[:30]

# 2. 逐条查询元数据
stories = []
for sid in ids:
    try:
        req = urllib.request.Request(
            f"https://hacker-news.firebaseio.com/v0/item/{sid}.json",
            headers={"User-Agent": "Monica/1.0"}
        )
        resp = urllib.request.urlopen(req, timeout=5)
        item = json.loads(resp.read())
        if item and item.get("type") == "story" and item.get("title"):
            stories.append({
                "id": sid,
                "title": item["title"],
                "score": item.get("score", 0),
                "url": item.get("url", "") or f"https://news.ycombinator.com/item?id={sid}",
            })
    except Exception:
        continue

# 3. 输出（按分数降序）
for s in sorted(stories, key=lambda x: x["score"], reverse=True):
    print(f"[{s['score']}pts] {s['title']}")
    print(f"  {s['url']}")
```

## 快速管线（一行命令，适合 cron 中快速查看）

```bash
curl -sL --connect-timeout 10 --max-time 20 "https://hacker-news.firebaseio.com/v0/topstories.json" \
  | python3 -c "
import json,sys,urllib.request
ids = json.load(sys.stdin)[:30]
for sid in ids:
    try:
        d = json.loads(urllib.request.urlopen(f'https://hacker-news.firebaseio.com/v0/item/{sid}.json', timeout=5).read())
        if d.get('type')=='story':
            print(f\"[{d.get('score',0)}pts] {d.get('title','')}\")
            print(f\"  {d.get('url','') or 'https://news.ycombinator.com/item?id='+str(sid)}\n\")
    except: pass
"
```

## 与替代方案对比

| 方案 | 速度 | 可靠性 | 适合场景 |
|------|------|--------|---------|
| **Firebase API (本方案)** | ⚡ 快 (~10s for 30条) | ✅ 高，官方 API | 日常学习快速扫首页 |
| **Algolia API** | ⚡ 快 | ⚠️ 有 ~30s-5min 延迟 | 结构化评论提取，历史搜索 |
| **browser_navigate + 首页** | 🐢 慢 | ⚠️ 可能连接超时 | 需要页面交互时 |
| **curl + HTML 解析** | ⚡ 快 | ⚠️ 正则脆弱 | 不需要 JS 渲染时 |

## 重要注意事项

1. **ID 排序 ≠ 页面排序**：Firebase 返回的 `topstories.json` 数组顺序不等于 `news.ycombinator.com` 的展示顺序。数组中的第 N 个元素可能不是页面上第 N 高的分数。**如果需要在管线上排序，用 `sorted(..., key=score, reverse=True)`**，不要依赖数组索引位置。

2. **逐条查询是设计意图**：Firebase REST API 是 key-value 存储，单条 `item/{id}.json` 查询约 200ms。批量查 30 条约 6-10 秒，属于正常使用模式。不需要担心限流。

3. **只取 type=story 的条目**：`topstories.json` 返回的 ID 可能包含 `comment` 类型（极少见但在列表中可能出现）。过滤 `d.get('type') == 'story'` 避免无效条目。

4. **超时可跳过**：网络不稳定时可能是单条查询超时。用 `try/except` 跳过单条失败，不影响整体结果。一般 30 条中 1-2 条超时是正常的。

5. **URL 回退**：有些故事没有外部 URL（如 `Ask HN` 类型），此时 `item.get('url')` 为空。回退到 `https://news.ycombinator.com/item?id={id}` 确保每个条目都有可点击链接。

6. **B站/知乎/其他平台 API 同理**：任何 SPA 或有反爬的平台，先检查是否有公开 JSON API 可用，比用浏览器快很多。见 `platform-exploration-patterns.md` 的「API 优先探索策略」。

## 相关参考

- `hn-api-id-ordering-pitfall.md` — ID 排序偏差的详细分析和备选方案
- `hn-algolia-api-pattern.md` — Algolia API 的结构化评论提取
- `hn-curl-parsing-pattern.md` — curl + HTML 解析的后备方案
- `platform-exploration-patterns.md` — API 优先探索策略总体框架
