# Chinese Social Platform Access

Chinese social platforms (小红书 Xiaohongshu, 微博 Weibo, 抖音 Douyin, B站 Bilibili, etc.) often block non-Chinese datacenter IPs, Cloudflare workers, and headless browsers. This reference covers lightweight techniques for accessing these platforms without a full Scrapling setup.

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

## When to Use Scrapling vs Simple curl

| Use case | Tool |
|----------|------|
| Quick content grab from known URL | `curl` + mobile UA |
| Multi-page crawl with JS rendering | Scrapling `DynamicFetcher` |
| Cloudflare-protected page | Scrapling `StealthyFetcher` |
| Search across Chinese platforms | Bing China or platform-specific API |

## Pitfalls

- Mobile UA may return simplified content vs full desktop version
- Xiaohongshu SSR JSON is minified — parse with Python `json.loads()`
- All these platforms change their anti-bot frequently — techniques may break
- Respect robots.txt, ToS, and local regulations
- Playwright-based crawlers won't help if the IP is blocked at the edge — don't waste time installing Playwright for Xiaohongshu from a datacenter IP
- The user's mobile app is the most reliable search interface — asking them to share links saves the most time
