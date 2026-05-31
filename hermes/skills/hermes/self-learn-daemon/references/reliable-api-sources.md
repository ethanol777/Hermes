# 可靠 API 数据源（2026-05-31 实测验证）

## 为什么需要这个文档

用 `delegate_task` 子进程做数据采集时，子进程会幻觉整个数据集（虚假项目名、捏造的 star 数、编造的帖子标题）。2026-05-18 实测：第一个并行批次返回的 GitHub Trending 项目全是假名。

**规则：事实数据必须你自己从 API 拉，不能用子进程代劳。**

## 已验证的可靠数据源

### Hacker News — Firebase API ✅ 稳定

```bash
# top stories（首页前 30）
curl -s 'https://hacker-news.firebaseio.com/v0/topstories.json'

# show stories（Show HN 条目）
curl -s 'https://hacker-news.firebaseio.com/v0/showstories.json'

# 单个条目（id 来自上面两个 API 返回的 ID 列表）
curl -s 'https://hacker-news.firebaseio.com/v0/item/{id}.json'

# 返回 JSON: title, url, score, descendants(评论数), by, type
```

**实测（2026-05-18, 2026-05-31）：** ID 格式为 `48173429` 等（8 位），返回的帖子是 2026 年 5 月的内容，时效性零延迟。✅ 稳定。

### GitHub Trending — browser_navigate ✅ 首选（2026-05-31 更新）

**2026-05-31 实测：** GitHub Search API 完全失败（rate limited，0 results），而 `browser_navigate("https://github.com/trending")` 稳定返回完整数据。

```bash
# ❌ GitHub Search API — 已废弃（rate limit 60 req/h，静默失败）
curl -s 'https://api.github.com/search/repositories?q=created:>YYYY-MM-DD&sort=stars&order=desc&per_page=10' \
  -H 'Accept: application/vnd.github.v3+json'

# ✅ browser_navigate — 唯一可靠路径
browser_navigate("https://github.com/trending")
# 从 snapshot 提取仓库名、Star 数、描述、Fork 数
# 成功率接近 100%（GitHub 对浏览器无频限）
```

**重要更新（2026-05-31）：**
- GitHub Search API 在 cron 环境下几乎必定 rate limited → 不要依赖它
- `browser_navigate` + `browser_snapshot` 是 GitHub Trending 的**首选**而非备选
- GitHub 对无头浏览器的反爬比想象中宽松（"Running WITHOUT residential proxies" 警告可忽略）

### GitHub Trending — browser_console 提取 README

```javascript
// 在 GitHub 仓库页面用 browser_console 执行
document.querySelector('.markdown-body')?.textContent?.substring(0, 4000)
```

比 curl raw.githubusercontent.com 更可靠——raw 文件可能被 CDN 限流返回空内容。

### B站 — browser_navigate ✅，API ❌

**2026-05-31 实测：** B站 API (`api.bilibili.com/x/web-interface/ranking/v2`) 在同一配置下完全不响应（返回空/Failed），而 `browser_navigate` 正常工作。

| 方式 | 2026-05-18 | 2026-05-30 | 2026-05-31 |
|------|------------|------------|------------|
| B站 API (ranking/v2) | ❌ -352 | 未测 | ❌ 空响应 |
| browser_navigate | ✅ | ✅ | ✅ |

**推荐路径：** `browser_navigate` 直接访问排行页面，不需要 API。

### Weibo — 热搜 API ✅ 稳定

```bash
curl -s 'https://weibo.com/ajax/side/hotSearch' \
  -H 'User-Agent: Mozilla/5.0' \
  -H 'Referer: https://weibo.com'
```

**实测（2026-05-18）：** 返回热搜实时 JSON 列表。✅ 稳定。

### 知乎 — 需登录，已放弃

```bash
# 热榜页面 ❌ 整站重定向到登录弹窗
# 搜索 site:zhihu.com ✅ 作为替代
# 发现页 explore ❌ 同样重定向
```

**结论：** 不要在知乎登录流程上浪费时间。中文内容用搜索作为替代。

### Lobste.rs — RSS ✅ 稳定（工程向内容，与 HN 互补）

```bash
curl -s 'https://lobste.rs/rss'
```

**实测（2026-05-30）：** 返回纯文本 RSS，包含标题+URL+摘要。内容偏工程、开源文化。

## API 优先策略（更新版）

```
想了解一个平台的热门内容？
├─ GitHub Trending → browser_navigate ✅ 首选
│   └─ API ❌ 已废弃（rate limited）
├─ Hacker News → Firebase API ✅
│   └─ browser_navigate ✅ 也可用
├─ B站 → browser_navigate ✅ 首选
│   └─ API ❌ 不稳定
├─ Weibo → weibo.com/ajax/side/hotSearch ✅
├─ 知乎 → 搜索 site:zhihu.com ✅
│   └─ 热榜 ❌ 需要登录
├─ Lobste.rs → RSS ✅
└─ delegate_task 子进程 → ❌ 严禁用于数据采集（幻觉数据）
```

**严禁做法：** 用 `delegate_task` 子进程去拉网页数据源。子进程拉回来的"数据"无法验证真伪。

## 更新日志

- **2026-05-31：** GitHub Trending 采集路径从"Search API 优先"改为"browser_navigate 首选"；B站 API 降级为不可用。
