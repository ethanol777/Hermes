# 可靠 API 数据源（2026-05-18 实测验证）

## 为什么需要这个文档

用 `delegate_task` 子进程做数据采集时，子进程会幻觉整个数据集（虚假项目名、捏造的 star 数、编造的帖子标题）。2026-05-18 实测：第一个并行批次返回的 GitHub Trending 项目全是假名。

**规则：事实数据必须你自己从 API 拉，不能用子进程代劳。**

## 已验证的可靠数据源

### Hacker News — Firebase API ✅ 优先使用

```bash
# top stories（首页前 30）
curl -s 'https://hacker-news.firebaseio.com/v0/topstories.json'

# show stories（Show HN 条目）
curl -s 'https://hacker-news.firebaseio.com/v0/showstories.json'

# 单个条目（id 来自上面两个 API 返回的 ID 列表）
curl -s 'https://hacker-news.firebaseio.com/v0/item/{id}.json'

# 返回 JSON: title, url, score, descendants(评论数), by, type
```

**实测（2026-05-18）：** ID 格式为 `48173429` 等（8 位），返回的帖子是 2026 年 5 月的内容，时效性零延迟。

### GitHub Trending — GitHub Search API ✅ 优先使用

```bash
# 本周热门新项目
curl -s 'https://api.github.com/search/repositories?q=created:>YYYY-MM-DD&sort=stars&order=desc&per_page=10' \
  -H 'Accept: application/vnd.github.v3+json' -H 'User-Agent: Monica/1.0'

# 或更宽泛的查询（近期活跃的高星项目）
curl -s 'https://api.github.com/search/repositories?q=stars:>1000+pushed:YYYY-MM-DD&sort=stars&order=desc&per_page=10' \
  -H 'Accept: application/vnd.github.v3+json' -H 'User-Agent: Monica/1.0'
```

**实测（2026-05-18）：** 返回真实数据（`Nightmare-Eclipse/YellowKey - 3,179★`, `vercel-labs/zero - 1,747★`, `facebookresearch/vggt-omega - 710★` 等）。注意 GitHub API 有未认证限频（60 req/h）。需要 `json.loads` 解析时用 `json_parse()`（内置于 `hermes_tools`，`strict=False` 处理控制字符）。

### GitHub Trending 页面（替代方案）— 备选

HTML 页面 `https://github.com/trending` 也可以 curl，但：
- 页面很大（~200KB HTML），curl 可能超时
- 结构复杂，需要小心 regex 解析
- **优先用 Search API 代替**

### B站热门 — 官方 API ⚠️ 偶有 -352 错误（2026-05-18 实测）

```bash
# 综合热门排行榜（可能返回 -352 错误）
curl -s 'https://api.bilibili.com/x/web-interface/popular?ps=50&pn=1' \
  -H 'Referer: https://www.bilibili.com'

# 排行榜版本（同样可能 -352）
curl -s 'https://api.bilibili.com/x/web-interface/ranking/v2?rid=0&type=all' \
  -H 'Referer: https://www.bilibili.com' \
  -H 'User-Agent: Mozilla/5.0'
```

**实测（2026-05-18）：** 加 `Referer: https://www.bilibili.com` 头后**仍返回 -352 错误**（code: -352, message: -352）。说明 B站 API 可能在执行更严格的反爬策略（Wbi 签名、IP 风控等），仅靠 Referer 头已不足以绕过的概率上升。

**降级方案：** 当 API 返回 -352 时，用 `browser_navigate('https://www.bilibili.com/v/popular/rank/all')` 直接看排行页面。浏览器可拿到完整排行数据（标题、UP主、播放量），不需要 API。**推荐将浏览器作为 B站的第一访问方式而非降级方案。**

### 知乎 — 发现页 ✅ 可用

```bash
# 发现页（精选内容，无需登录）
curl -sL 'https://www.zhihu.com/explore'

# 知乎热榜 API
curl -s 'https://www.zhihu.com/topstory/hot-lists/total' \
  -H 'User-Agent: Mozilla/5.0'
```

**实测（2026-05-18）：** 发现页 HTML 可解析出精选问题和回答。热榜 API 返回 JSON。但具体问题页面（`zhihu.com/question/`）有 recaptcha 反爬，不入。

### Weibo — 热搜 API ✅ 可用

```bash
curl -s 'https://weibo.com/ajax/side/hotSearch' \
  -H 'User-Agent: Mozilla/5.0' \
  -H 'Referer: https://weibo.com'
```

**实测（2026-05-18）：** 返回热搜实时 JSON 列表。

## API 优先策略

```
想了解一个平台的热门内容？
├─ 平台有公开 API → 用 `execute_code` + `curl` → 解析 JSON ✅
├─ 平台无 API 但 HTML 可拉 → `curl` + regex → 提取 ✅
├─ 平台需要登录/JS 渲染 → 放弃，换平台 ❌
└─ 复杂推理任务（读 README、分析评论区）→ `delegate_task` 子进程（明确声明「在多个子任务之间交叉引用数据」的风险）
```

**严禁做法：** 用 `delegate_task` 子进程去拉网页数据源。子进程拉回来的"数据"无法验证真伪。
