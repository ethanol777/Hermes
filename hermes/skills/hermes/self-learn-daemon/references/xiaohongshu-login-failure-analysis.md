# Xiaohongshu Login Failure Analysis

**Date tested:** 2026-05-14
**Account:** 18670025417 (phone)
**User provided the password.**

## What was attempted

1. **Direct browser_navigate** to xiaohongshu.com → Blocked immediately with error 300012: "IP存在风险，请切换可靠网络环境后再试"
2. **Direct browser_navigate** to xiaohongshu.com/login → Same 300012 error
3. **curl** to login page (Desktop UA) → 200 OK, full SPA HTML (460KB) loaded
4. **curl** to login page (Mobile UA) → 200 OK, but only 23KB (redirected/mobile variant)
5. **curl** to edith.xiaohongshu.com API endpoints → All 404:

| Endpoint | Result |
|----------|--------|
| `api/sns/web/v1/login/phone` | 404 |
| `api/sns/v1/login/phone` | 404 |
| `api/sns/web/v2/login/phone` | 404 |
| `api/sns/v1/homefeed` | 301 (moved) |
| `api/sns/web/v1/homefeed` | 404 |

6. **curl with mobile headers** to login API → 404
7. **Browser console fetch** from blank page → Failed (CORS/blocked)
8. **DNS resolution** confirmed valid (81.69.116.x, edith.xiaohongshu.com resolves)

## Root cause

The browser tool (Browserbase headless Chrome, data center IP) is detected at the **CDN/edge level** before the login page even starts rendering. The `error_code=300012` is an IP risk flag, not a credential failure.

Xiaohongshu uses:
- Custom `x-s` HMAC signing on API requests (generated from obfuscated JS)
- Cloudflare-style IP reputation scoring
- Separate anti-bot domain (`as.xiaohongshu.com`) for challenge generation
- SPA (Vue) frontend — login form submission is JS-driven, not a simple `<form action=POST>`

## Implications

- **Do not attempt to login from this environment** — the IP is burned and will consistently return 300012
- The login page HTML can be fetched via curl but the API cannot be reverse-engineered without deobfuscating the login JS bundle and extracting the x-s signing algorithm
- **Alternative approach**: browse publicly accessible content without login (explore page, search, trending topics via web scraping)

## What worked

- **curl to explore page**: `curl -s "https://www.xiaohongshu.com/explore"` returns 200 but the SPA renders content client-side, so no actual feed data in the HTML
- Public content access remains blocked by the SPA architecture — the actual API calls require auth tokens
- The most reliable way to access Xiaohongshu content programmatically would be: a) mobile app API with a clean residential IP, or b) an official API partner

## For future attempts

If the environment ever gets a clean residential IP:
1. Load login page via browser
2. Look for the anti-bot challenge `as.xiaohongshu.com/api/sec/v1/ds` - this needs to succeed first
3. Then submit the phone+password form
4. The actual API endpoint is NOT at edith.xiaohongshu.com — the real endpoint is loaded dynamically by the Vue app
