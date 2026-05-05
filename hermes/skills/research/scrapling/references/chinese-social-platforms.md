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
