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

## 小红书登录实测细节 (2026-05-14)

用户主动提供了账号密码，尝试多个途径登录，结果如下：

| 途径 | 结果 | 说明 |
|------|------|------|
| browser_navigate /explore | ❌ 300012 | headless Chrome IP被风控 |
| browser_navigate /login | ❌ 300012 | 同样IP检测 |
| curl /login (桌面UA) | ✅ 200 (460KB) | SPA页面完整返回，含Vue应用和__INITIAL_STATE__ |
| curl /explore (桌面UA) | ✅ 200 | 页面可访问，但内容客户端渲染 |
| curl /login (手机UA) | ✅ 200 (23KB) | 返回简化页面 |
| curl edith API login | ❌ 404 | API endpoint不存在或需特定签名头 |
| curl edith homefeed | ❌ 404/301 | /api/sns/返回301，其余404 |
| browser_console fetch | ❌ CORS/风控 | 从headless浏览器内fetch也被阻断 |

**关键发现：**
1. **登录只支持手机验证码** — Web版Vue SPA的login表单只有`phone`+`authCode`字段，无密码登录入口
2. **动态签名(x-s)保护** — `as.xiaohongshu.com/api/sec/v1/ds` 加载的风控JS生成签名header
3. **edith.xiaohongshu.com/api/** 所有登录端点返回404/301 — API可能已迁移或不再对外开放
4. **curl能取到页面但browser不行** — 浏览器检测比curl更严格，WebDriver/headless特征触发IP封锁
5. **网页端和手机端API结构不同** — 手机API同样无法直接调用

**结论：**
- 小红书的风控是多维的：IP信誉 + 浏览器指纹 + JS动态签名 + API路由混淆
- 拿到账号也登不进去（IP/浏览器级别就被拦了）
- 替代方案：`web_search site:xiaohongshu.com <关键词>` 抓取公开内容

## Strategy

1. **Don't login** — Monica learns from public content. Logging in costs credential sync + anti-bot fight for zero marginal gain.
2. **Use `web_search` first** — For most Chinese platforms, search engine cache is more accessible than direct navigation.
3. **Direct navigation for GitHub/non-Chinese sites** — These have much less bot detection.
4. **If user wants to post** — Write the content, let them copy-paste from their own device. Don't try to automate posting.
5. **For topics that need login** (e.g. 小红书 private notes, WeChat articles behind paywall) — Ask the user to share the link or content directly.

## One Exception

If residential proxies become available in the future, re-evaluate. Until then, this is a hard constraint — the platforms win the anti-bot arms race on datacenter IPs.
