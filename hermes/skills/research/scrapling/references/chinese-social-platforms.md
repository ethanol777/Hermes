# Chinese Social Platform Access

Chinese social platforms (小红书 Xiaohongshu, 微博 Weibo, 抖音 Douyin, B站 Bilibili, 知乎 Zhihu, etc.) often block non-Chinese datacenter IPs, Cloudflare workers, and headless browsers. This reference covers lightweight techniques for accessing these platforms without a full Scrapling setup.

## TL;DR — Xiaohongshu Access

When `browser_navigate` fails with "IP at risk" / "安全限制":

```bash
# Works: curl with mobile User-Agent
curl -sL "https://www.xiaohongshu.com/explore/{NOTE_ID}" \
  -A "Mozilla/5.0 (Linux; Android 14; Pixel 8 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36"
```

- The HTML response contains all data embedded in `<script>window.__INITIAL_STATE__=...</script>`
- No need for JS rendering — Xiaohongshu SSR-inlines the full note content
- The mobile UA bypasses the Cloudflare-style challenge that blocks desktop browsers on datacenter IPs

## Core Problem: Datacenter IP Blocking

Xiaohongshu uses IP-level + device fingerprinting. A datacenter IP from outside China gets blocked at the CDN/edge layer before any request reaches the app server. Even a real browser (Playwright) can't bypass this.

### What DOESN'T Work (Verified from WSL/Datacenter IP)

| Approach | Error | Root Cause |
|----------|-------|------------|
| `browser_navigate` to any xiaohongshu.com URL | "IP at risk" / 安全限制 / blank page | IP-level block |
| Playwright headless Chromium (e.g. `last30days-cn` crawler) | Timeout after 30s | IP block prevents initial page load |
| Xiaohongshu public search API (`fe_api/burdock/weixin/v2/search/notes`) | HTTP 404 | Endpoint changed/deprecated |
| xiaohongshu-mcp self-hosted REST API | DNS resolution failure | Needs separate server setup |

### What DOES Work (Verified)

| Approach | Works For | Notes |
|----------|-----------|-------|
| `curl` + mobile UA on note URLs | Reading individual notes | Parse `__INITIAL_STATE__` JSON |
| User-shared `xhslink.com` short links | Reading shared notes | Same curl+UA approach |
| Bing China (cn.bing.com) search | Finding content via index | Can search `site:xiaohongshu.com` |

## Practical Multi-Tier Workflow (Blocked Environment)

### Tier 1: Read Shared Links (Easiest, Most Reliable)

User shares links from the Xiaohongshu mobile app. The agent:
1. Fetches with `curl -sL` + mobile UA
2. Extracts `__INITIAL_STATE__` JSON from HTML
3. Parses title, description, images, engagement, comments

The `last30days-cn` skill's `xiaohongshu.py` `_parse_note()` function handles normalization.

### Tier 2: Search via Bing China (cn.bing.com)

When the user wants to search (not just read a known URL), use Bing China:
```bash
curl -sL "https://cn.bing.com/search?q=site:xiaohongshu.com+{TOPIC}+2026" \
  -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
```
- Bing's Chinese index includes Xiaohongshu notes, Weibo posts, Bilibili videos
- Bing CN is accessible from datacenter IPs (unlike Baidu which requires captcha)
- Extract snippets for signal, then fetch specific notes via Tier 1

### Tier 3: User-Provided Cookies

If the user has a logged-in Xiaohongshu session:
- Export cookies from browser (F12 → Application → Cookies → `xiaohongshu.com`)
- Save JSON to `~/.config/last30days-cn/browser_cookies/xiaohongshu_cookies.json`
- The `last30days-cn` skill's `crawler_bridge.py` loads cookies automatically
- Or set as env var for the `last30days` module

## 知乎 (Zhihu) Access

Zhihu uses aggressive anti-bot protection (ZSE-ck challenge) and requires login for many pages. The hot list at `zhihu.com/hot` redirects unauthenticated users to `zhihu.com/signin?next=%2Fhot`.

### What DOESN'T Work

| Approach | Result | Notes |
|----------|--------|-------|
| `curl` to `zhihu.com/hot` | Returns ZSE-ck challenge JS + login redirect | Anti-bot cookie required |
| `zhihu.com/api/v3/feed/topstory/hot-lists/total` | HTTP 401 "身份未经过验证" | API requires `_xsrf` + auth cookies |
| `browser_navigate` directly to `zhihu.com/hot` | Redirects to sign-in page | Login wall enforced |

### What DOES Work (Browser Required)

**Entry point: `zhihu.com/explore` (发现)**

The Explore page (`zhihu.com/explore`) renders partial content without login. From there, the "热榜" link in the navigation bar loads the full hot list without triggering the login wall.

**Step-by-step:**

1. Navigate to `https://www.zhihu.com/explore`
   - This page shows recent hot topics and limited content without login

2. Click the **"热榜"** link in the top navigation bar (not the URL directly)
   - The hot list renders as a full table with columns: 热力值 / 关注增量 / 浏览增量 / 回答增量 / 赞同增量
   - Works because the session stays within the explore page context

3. Extract data via browser console:
   ```javascript
   document.body.innerText
   ```
   This returns all visible text including question titles, heat scores, view counts, follower counts, and answer counts.

4. Scroll down to load more items — Zhihu loads ~50 items per page by default, with category filters (全部/科技互联网/社会时政/体育竞技/情感/娱乐...).

**Data structure per item (from innerText):**

```
{title}
#tag1 #tag2 #tag3
{score} 分
{follow_delta}
共 {total_follows}
{view_delta}
共 {total_views}
{answer_delta}
共 {total_answers}
{upvote_delta}
共 {total_upvotes}
```

Example:
```
特朗普访华欢迎宴会，都有哪些看点值得关注？
#美国 #中美关系 #唐纳德·约翰·特朗普（Donald J. Trump）
10.0 分
46
共 2540
48.4 万
共 5975 万
36
共 845
1.7 万
共 25.7 万
```

Where:
- `score`: 热力值 (0-10), Zhihu's internal heat score
- `follow_delta / total_follows`: 关注 (follower) increment and total
- `view_delta / total_views`: 浏览 (view) increment and total
- `answer_delta / total_answers`: 回答 (answer) increment and total
- `upvote_delta / total_upvotes`: 赞同 (upvote) increment and total

**Category filtering**: The hot list supports filtering by category tabs (全部=all, 科技互联网=tech, 社会/时政=society/politics, 体育竞技=sports, 娱乐=entertainment, 情感=relationships, etc.) — click the tab link element directly.

**Time range**: Also supports 小时榜 (hourly), 日榜 (daily), 周榜 (weekly) tabs.

### Zhihu Content Extraction Without Login

For reading individual Zhihu question pages or answers without login:

1. **Browser-based**: Navigate to `zhihu.com/question/{id}` — some questions render top answers without login
2. **Baidu cache**: Search `cache:zhihu.com/question/{id}` on Baidu for cached version
3. **Bing China**: Search `site:zhihu.com {topic}` — Bing's index includes Zhihu Q&A snippets

### Pitfalls (Zhihu)

- The explore→热榜 bypass may break if Zhihu changes its auth enforcement
- `browser_navigate` directly to a question URL may still trigger the login wall on some restricted content
- Hot list data is not available via API without auth tokens
- Zhihu's ZSE-ck anti-bot is updated frequently — `curl`-based approaches fail consistently
- The browser's stealth mode (residential proxies recommended) significantly improves reliability

## Platform-Specific Notes

### 小红书 (Xiaohongshu / RED)

Data extraction from SSR:
- Note ID: `"noteId":"{id}"`
- Title: `"title":"{text}"`
- Description: `"desc":"{text}"`
- Images: `"imageList":[{...}]`
- User info + interaction counts embedded in JSON
- Comments: `"commentData":{"comments":[{...}]}`

### 微博 (Weibo)

- Public posts accessible via `curl` with mobile UA
- API endpoint: `https://api.weibo.com/2/...` (requires auth for most endpoints)
- Rate limits aggressive — space requests 5+ seconds apart

### B站 (Bilibili)

- Public API: `https://api.bilibili.com/x/web-interface/search/all/v2`
- Requires `Referer: https://www.bilibili.com`
- No anti-bot for basic search API calls

### 知乎 (Zhihu)

- Hot list accessible via browser on `zhihu.com/explore` → click "热榜" nav link
- Direct API `zhihu.com/api/v3/feed/topstory/hot-lists/total` requires auth
- Extract hot list via `document.body.innerText` from browser console
- Data includes: title, tags, heat score (0-10), view/follow/answer/upvote counts and deltas
- Supports category filtering and hourly/daily/weekly time ranges

## When to Use Scrapling vs Simple curl

| Use case | Tool |
|----------|------|
| Quick content grab from known URL | `curl` + mobile UA |
| Multi-page crawl with JS rendering | Scrapling `DynamicFetcher` |
| Cloudflare-protected page | Scrapling `StealthyFetcher` |
| Search across Chinese platforms | Bing China or platform-specific API |
| Login-walled Chinese platform (Zhihu) | Browser automation via explore→热榜 bypass |

## Pitfalls

- Mobile UA may return simplified content vs full desktop version
- Xiaohongshu SSR JSON is minified — parse with Python `json.loads()`
- All these platforms change their anti-bot frequently — techniques may break
- Respect robots.txt, ToS, and local regulations
- Playwright-based crawlers won't help if the IP is blocked at the edge — don't waste time installing Playwright for Xiaohongshu from a datacenter IP
- The user's mobile app is the most reliable search interface — asking them to share links saves the most time
- Zhihu's explore→热榜 bypass depends on session context; direct URL navigation to hot.html still triggers login
