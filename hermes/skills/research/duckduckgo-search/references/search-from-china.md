# Searching from China (WSL Environment)

When running Hermes in a WSL environment behind the Great Firewall, foreign search engines are mostly unreachable and domestic ones are JS-heavy or CAPTCHA-protected. This reference documents what works.

## What's Blocked

| Engine | Status | Notes |
|--------|--------|-------|
| Google | ❌ Timed out | Fully blocked |
| DuckDuckGo | ❌ Timed out | `ddgs` CLI always throws `DDGSException(TimeoutException)` |
| Bing / cn.bing.com | ❌ CAPTCHA/400 | Redirects to cn.bing.com, curl returns 400 |
| Baidu | ❌ CAPTCHA | Both curl and browser tool trigger CAPTCHA |
| Sogou | ❌ CAPTCHA | Triggers image-select CAPTCHA after first search query |

## What Works

| Engine | Status | Method |
|--------|--------|--------|
| **360 Search (so.com)** | ✅ Works | Browser tool navigation + snapshot |
| GitHub | ✅ Works | curl / browser |
| Cloudflare | ✅ Works | curl / browser |
| RSS feeds | ✅ Works | curl with User-Agent header |

## Preferred Search Workflow

### Method 1: 360 Search via Browser (Recommended for Chinese queries)

```python
# Navigate directly to 360 search results
browser_navigate(url="https://www.so.com/s?q=<URL_ENCODED_QUERY>")
# Then browser_snapshot() to read results
```

The `so.com` search engine returns usable snapshots without CAPTCHA in most cases.

### Method 2: Direct Known Sites (GitHub, Cloudflare, etc.)

For tech queries, try GitHub first — it's reliably accessible:
```bash
curl -s "https://api.github.com/search/repositories?q=<query>" -H "Accept: application/vnd.github.v3+json"
```

Or search GitHub via browser:
```bash
browser_navigate(url="https://github.com/search?q=<query>&type=repositories")
```

### Method 3: RSS Feeds (fallback when search is blocked)

See the main `duckduckgo-search` skill for RSS feed approach — works because RSS XML is plain-text and hosted on accessible CDNs.

### Method 4: Model Knowledge (for well-known topics)

For popular/recent services, products, or technologies, the model's training data often contains enough information to answer without a live search. Try this first before falling back to search.

## VPN/机场 Investigation Workflow

When a user shares a VPN subscription link or asks about an airport service:

1. **Test the link** with curl first — if it returns 502 or errors, the server may be down
2. **Search 360** via browser for the service name (e.g., "精灵学院 机场", "Riolu 官网")
3. **Look for review/aggregator sites** — many Chinese VPN reviews list official URLs, pricing, and promo codes
4. **Check multiple domains** — try common patterns: `www.<name>.work`, `dome.<name>.work`, `v2board.<name>.work`
5. **Try DNS probes** to discover related subdomains quickly

## Limitations

- No reliable way to scrape search results as plain text from Chinese engines — browser snapshot is the best option
- 360 search may eventually rate-limit; space out requests
- Some content on Chinese search engines is censored or SEO-gamed
