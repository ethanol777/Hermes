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

## Xiaohongshu: What DOESN'T Work from Datacenter IPs

Verified from a WSL (data center IP) environment — all of these fail:

| Approach | Error | Root Cause |
|----------|-------|------------|
| `browser_navigate` to any xiaohongshu.com URL | "IP at risk" / 安全限制 / blank page | IP-level block |
| Playwright (headless Chromium) via `last30days-cn` crawler | Timeout after 30s | IP block prevents initial page load |
| Xiaohongshu public search API (`fe_api/burdock/weixin/v2/search/notes`) | HTTP 404 | Endpoint changed or deprecated |
| xiaohongshu-mcp (self-hosted REST API) | DNS resolution failure | Needs separate server setup |

**Core problem:** Xiaohongshu uses IP-level + device fingerprinting. A datacenter IP from outside China gets blocked at the CDN/edge layer before any request reaches the app server. Even a real browser (Playwright) can't bypass this.

## Practical Workflow for Xiaohongshu Research (Blocked Environment)

When the agent's IP is blocked, use this multi-layered approach:

### Tier 1: Parse Shared Links (Easiest, Most Reliable)

User shares Xiaohongshu links from the mobile app (short `xhslink.com` links or full `xiaohongshu.com/explore/{id}` URLs). The agent:
1. Fetches with `curl` + mobile UA
2. Extracts `__INITIAL_STATE__` JSON from the HTML
3. Parses note title, description, images, author, engagement stats, comments

The `last30days-cn` skill's `xiaohongshu.py` module has a `_parse_note()` function that handles this normalization.

### Tier 2: Chinese Search Engines as Proxy

When the user wants to search (not just read a known URL), use **Bing China (cn.bing.com)** as a search proxy:
- Bing's Chinese index includes Xiaohongshu notes, Weibo posts, Bilibili videos
- Search queries like `site:xiaohongshu.com <topic> 2026` work via Bing
- Bing CN is accessible from datacenter IPs (unlike Baidu which requires captcha)
- Extract result snippets for initial signal, then fetch specific notes via Tier 1

### Tier 3: User-Provided Cookies for Search

If the user has a logged-in Xiaohongshu session, they can export browser cookies:
- Open chrome://settings/content/all?searchSubpage=cookies or F12 → Application → Cookies
- Export cookies for `xiaohongshu.com` domain as JSON
- Set `XIAOHONGSHU_COOKIE` env var (or use `last30days-cn`'s `COOKIE_DIR` at `~/.config/last30days-cn/browser_cookies/xiaohongshu_cookies.json`)
- The `crawler_bridge.py` module loads cookies automatically if present
- Proxies (residential/mobile) may also work but require external setup

## Platform-Specific Notes

### 小红书 (Xiaohongshu / RED)

| Approach | Works? | Notes |
|----------|--------|-------|
| `browser_navigate` (Browserbase/Playwright) | ❌ | IP blocked, returns "安全限制" page or blank |
| `curl` with mobile UA | ✅ | Gets SSR HTML; parse `__INITIAL_STATE__` embed |
| Short links (`xhslink.com`) | ⚠️ | Redirect chain works the same — mobile UA still needed |

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
| Search across Chinese platforms | `duckduckgo-search` or platform-specific API |

## Pitfalls

- Mobile UA may return simplified content vs full desktop version
- Xiaohongshu SSR JSON is minified — use `python3 -c "import json,sys; d=json.load(sys.stdin); ..."` to parse
- All these platforms change their anti-bot frequently — techniques may break
- Respect robots.txt, ToS, and local regulations — these are public-information read techniques, not aggressive scraping
