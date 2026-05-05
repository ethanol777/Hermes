# Chinese Platform Access Techniques

> Techniques for accessing Chinese social media and search platforms from data-center IPs (WSL, cloud VPS) during research.

## 小红书 (Xiaohongshu / RED)

| Issue | Solution |
|-------|----------|
| Desktop browser (browser_navigate) hits "安全限制 - IP at risk" | Use `curl -L` with mobile User-Agent instead |
| All bot detection paths blocked | Parse the raw server-rendered HTML from the curl response; key data is in `__NEXT_DATA__` or `__INITIAL_STATE__` JSON blobs in the page source |

**Curl bypass (tested working):**
```bash
curl -sL "https://www.xiaohongshu.com/explore/{NOTE_ID}" \
  -A "Mozilla/5.0 (Linux; Android 14; Pixel 8 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36"
```

**Extracting data from the raw HTML:**
- Note metadata (title, desc, author, likes, collects, tags, comments) are in JSON blobs inside `<script>` tags
- The JSON is inside `__NEXT_DATA__` or `window.__INITIAL_STATE__` variables
- Comment data is in a separate XHR endpoint
- Images have URLs that can be reconstructed from fileId fields

**xhslink.com short links:**
- Input: `http://xhslink.com/o/{code}` 
- Follow redirects with `curl -sL` to reach the actual note page
- The note ID is in the redirected URL path: `/explore/{NOTE_ID}`

## 百度 (Baidu) Search

| Issue | Solution |
|-------|----------|
| Baidu search (www.baidu.com/s?wd=...) redirects to captcha page | Do NOT use Baidu — use **Bing 国内版** (cn.bing.com) instead |
| Baidu captcha triggered by data-center IPs | Always fall back to Bing for Chinese-language web search |

**Bing 国内版 as Baidu replacement:**
```bash
curl -sL "https://cn.bing.com/search?q={QUERY}&setlang=zh-Hans" \
  -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
```
Or use browser_navigate directly — Bing works without captcha from data-center IPs.

## 知乎 (Zhihu)

| Issue | Solution |
|-------|----------|
| zhihu.com returns 403 "请求存在异常" | Do NOT use browser_navigate directly |
| Content requires login for full access | Use Bing search to index Zhihu content: search `site:zhihu.com {topic}` via Bing |
| Some Zhihu pages load but need JS rendering | Fall back to Bing-cached snippets |

**Recommended approach:**
```bash
# Search Zhihu content via Bing index
https://cn.bing.com/search?q=site%3Azhihu.com+{QUERY}&setlang=zh-Hans
```

## 微博 (Weibo)

| Issue | Solution |
|-------|----------|
| Weibo heavily rate-limits non-logged-in requests | Use Bing to index `site:weibo.com {topic}` |
| Weibo search API requires token | Fall back to public search index snippets |

## General Strategy for Chinese Platform Research

1. **Primary**: `browser_navigate` to cn.bing.com with Chinese query → parse search result snippets
2. **Secondary for Xiaohongshu**: `curl -L` with mobile UA → extract JSON from raw HTML
3. **Avoid directly**: Baidu, Zhihu, Weibo — they all block data-center IPs aggressively
4. **API Key approach** (if available): Use platform-specific API keys for reliable access (last30days-cn supports these via `~/.config/last30days-cn/.env`)
5. **See also**: The `scrapling` skill for stealth browser automation with potential Cloudflare bypass capabilities
