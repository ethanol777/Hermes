# HN Algolia API — 结构化评论提取模式

当 `browser_navigate` 无法渲染 HN 评论区（空页面/内容遮蔽/连接超时）时，Algolia API 是可靠的结构化替代方案。

## 场景

浏览器访问 `https://news.ycombinator.com/item?id=<ID>` 时：
- 返回空页面（`(empty page)` 或首屏截断）
- 连接超时/ERR_CONNECTION_CLOSED
- 内容量太大（500+ 评论），看不全

## 方案

使用 HN Algolia API 的 `items` 端点获取完整的文章和评论树（JSON 格式）。

```
GET https://hn.algolia.com/api/v1/items/{story_id}
```

返回结构：
- 顶层字段：`title`, `points`, `author`, `children` (评论数组)
- 每个 `child` 包含：`author`, `text` (HTML), `points`, `children` (子评论递归)

## 代码模板

### 提取顶层评论

```python
import json, urllib.request, ssl, re

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

url = f"https://hn.algolia.com/api/v1/items/{story_id}"
req = urllib.request.Request(url, headers={"User-Agent": "Hermes/1.0"})
resp = urllib.request.urlopen(req, timeout=15, context=ctx)
data = json.loads(resp.read())

print(f"Title: {data['title']} | Points: {data['points']} | Comments: {len(data['children'])}")

for child in data.get('children', [])[:15]:
    author = child.get('author', '?')
    text = child.get('text', '') or ''
    text = re.sub(r'<[^>]+>', '', text)  # strip HTML
    text = re.sub(r'&[^;]+;', ' ', text)  # unescape
    points = child.get('points', 0)
    print(f"--- {author} ({points}pts) ---")
    print(text[:500])
    print()
```

### 提取子评论（递归）

```python
# 顶层评论的 child['children'] 包含回复
for child in children[:5]:
    replies = child.get('children', [])
    for reply in replies[:5]:
        ra = reply.get('author', '?')
        rt = re.sub(r'<[^>]+>', '', reply.get('text', '') or '')[:300]
        print(f"  → {ra}: {rt}")
```

## 限制

| 限制 | 说明 |
|------|------|
| 评论上限 | API 返回所有评论，但 `children` 数组不会超过 ~1000 条 |
| HTML 内容 | `story_text` 和 comment `text` 都包含 HTML 标签，需要 strip |
| Points 缺失 | 2026-05 发现的：Algolia API 返回的 child `points` 字段为 `None`（顶层 story 有 points，但评论层的 points 不返回） |
| 实时性 | Algolia 索引有 ~30s-5min 延迟，刚发布的评论可能不在 API 中 |
| 无投票/折叠状态 | 无法区分「评论被折叠」和「没有子评论」 |

## 流程决策

```
browser_navigate https://news.ycombinator.com/item?id=X
  ├── ✅ 正常渲染 → 直接浏览器读取评论区
  ├── ❌ 空页面/超时 → 尝试 Algolia API
  │     └── ✅ 成功 → 返回结构化 JSON 评论数据
  │     └── ❌ 失败 → 退回到首页的摘要信息
  └── ❌ 首屏截断（长帖） → 聚焦前 10-15 条最顶层评论
        └── Algolia API 可拿到完整树，不限浏览器渲染深度
```

## 获取 Story ID

从 HN 首页或 API 列表获知 story_id：

```python
# 通过 front_page 搜索
GET https://hn.algolia.com/api/v1/search?tags=front_page&hitsPerPage=20

# 每个 hit 的 objectID 即为 story_id，title/points/num_comments/url 都在顶层
```
