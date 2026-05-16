# Chinese Platform Research (merged from last30days-cn)

## Supported Platforms

| Platform | Module | Data Type | Config Required |
|----------|--------|-----------|-----------------|
| 微博 (Weibo) | weibo | Posts/Trends | Crawler (no API key); API mode: WEIBO_ACCESS_TOKEN |
| 小红书 (Xiaohongshu) | xiaohongshu | Notes/Curation | Crawler: XHR interception; MCP API optional |
| B站 (Bilibili) | bilibili | Videos/Danmaku | None (public API + crawler) |
| 知乎 (Zhihu) | zhihu | Q&A/Articles | None (public search + crawler) |
| 抖音 (Douyin) | douyin | Short Video | Crawler (no API key); API: TIKHUB_API_KEY |
| 微信公众号 | wechat | Articles | WECHAT_API_KEY (optional; Sogou fallback) |
| 百度 (Baidu) | baidu | Web Search | Public search may be blocked; auto Bing fallback; BAIDU_API_KEY (recommended) |
| 今日头条 | toutiao | News/Trending | None (public API) |

## Zero-Cost Sources (no config needed)

- B站 (public API)
- 知乎 (public search)
- 百度 (public search + Bing fallback; API key recommended for stability)
- 今日头条 (public endpoints)

## Anti-Crawl Countermeasures

For platforms with anti-crawl protection:
- Use `curl` with mobile User-Agent headers
- Use XHR response interception instead of DOM parsing
- Access via Bing search index: `site:zhihu.com {topic}` or `site:weibo.com {topic}`
- For Xiaohongshu: extract data from HTML's `__INITIAL_STATE__` JSON
- When Python scripts fail, fall back to Agent's built-in browser with Bing cn search

## Scripts

The `cn-scripts/` directory contains the Python search engine:
```
cd cn-scripts && python3 last30days.py "<query>" --emit compact
```

Optional flags: `--quick`, `--deep`, `--days N`, `--search weibo,bilibili,zhihu`
