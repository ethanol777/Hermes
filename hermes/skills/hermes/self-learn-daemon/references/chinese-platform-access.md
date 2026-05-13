# Chinese Platform Access Patterns

Chinese social platforms aggressively block headless browser / datacenter IP traffic. This is a durable constraint — don't fight it, work around it.

## Platform Status

| Platform | Login Required? | Browser Access | Workaround |
|----------|----------------|----------------|------------|
| 小红书 (Xiaohongshu) | Public read only | Blocked (IP risk) | Use `web_search` with site:xhslink.com or site:xiaohongshu.com |
| 知乎 (Zhihu) | Public read only | Partially works | `web_search` + direct URL navigation |
| B站 (Bilibili) | No | Works partially | `web_search` + direct URL |
| 微博 (Weibo) | Public read | Usually blocked | `web_search` for hot topics |
| 百度贴吧 (Tieba) | Public read | Usually blocked | `web_search` site:tieba.baidu.com |
| GitHub Trending | No | Works fine | Direct navigation |

## Anti-Bot Detection Signs

- Redirect to error page with "IP存在风险" / "IP风险"
- Page loads but shows blank/placeholder instead of real content
- QR code images don't render (small_blank.gif placeholder)
- Redirect to security verification pages (百度安全验证)
- Login forms redirect to error before showing fields

## Strategy

1. **Don't login** — Monica learns from public content. Logging in costs credential sync + anti-bot fight for zero marginal gain.
2. **Use `web_search` first** — For most Chinese platforms, search engine cache is more accessible than direct navigation.
3. **Direct navigation for GitHub/non-Chinese sites** — These have much less bot detection.
4. **If user wants to post** — Write the content, let them copy-paste from their own device. Don't try to automate posting.
5. **For topics that need login** (e.g. 小红书 private notes, WeChat articles behind paywall) — Ask the user to share the link or content directly.

## One Exception

If residential proxies become available in the future, re-evaluate. Until then, this is a hard constraint — the platforms win the anti-bot arms race on datacenter IPs.
