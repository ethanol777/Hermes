# Chinese Platform Access Patterns

Chinese social platforms aggressively block headless browser / datacenter IP traffic. This is a durable constraint — don't fight it, work around it.

## Platform Status

| Platform | Login Required? | Browser Access | Workaround |
|----------|----------------|----------------|------------|
| 小红书 (Xiaohongshu) | Public read only | Blocked (IP risk) | Use `web_search` with site:xhslink.com or site:xiaohongshu.com |
| 知乎 (Zhihu) | Public read only | Partially works | `web_search` + direct URL navigation |
| B站 (Bilibili) | No | Works partially | `web_search` + direct URL |
| 微博 (Weibo) | Public read | Partially works via mobile | `m.weibo.cn` mobile view (2026-05-16 实测可用) |
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

## 微博移动版实测 (2026-05-16)

初始假设：微博完全挡无头浏览器，需要 `web_search` 绕路。

实际测试：
- `weibo.com/ajax/statuses/hot_flow` 返回了一个奇怪的页面（含"美观输出"checkbox），不可用
- `m.weibo.cn` **直接加载成功**，无需登录，展示了热门微博流（央视新闻、周杰伦、迪奥广告、鹿晗等）
- 每个微博条目均可见点赞/评论/转发数和部分内容文字
- 有轻量验证但可以顺利通过，未触发 IP 封锁

**结论：** 微博移动版的恐怖风控在标准浏览器工具面前实际上是可访问的。之前 chinese-platform-access.md 记录为"Usually blocked"过于悲观。

**限制：**
- 内容偏娱乐/时事，深度科技分析较少
- 随机性大（取决于当下热点）
- 搜索功能可能受限（未测试）
- **登录页面 encoding 问题（2026-05-16）：** `weibo.com/newlogin` 返回无法用 utf-8 解码的内容（`utf-8 codec can't decode byte 0xb2`），说明 weibo.com 主站登录墙并非标准 utf-8 编码。无需登录的 `m.weibo.cn` 移动版则没有此问题。

## 知乎 API 标题获取 (已验证 2026-05-15)

之前记录知乎热榜 API 返回 JSON 标题列表是可用的。2026-05-15 实际测试：
- `browser_navigate('https://www.zhihu.com/hot')` → 被登录页阻挡（验证码登录/无障碍模式）
- 但 API 路径维持可用性：`curl -sL "https://api.zhihu.com/topstory/hot-lists/total?limit=5"` 需要合适 UA 头
- **注意：** 这个问题在现有的 chinese-platform-access.md 和 platform-exploration-patterns.md 中已有覆盖。

## Strategy

1. **Don't login** — Monica learns from public content. Logging in costs credential sync + anti-bot fight for zero marginal gain.
2. **Use `web_search` first** — For most Chinese platforms, search engine cache is more accessible than direct navigation.
3. **Try mobile subdomains before giving up** — m.weibo.cn worked when weibo.com didn't. The mobile version often has weaker bot protection.
4. **Direct navigation for GitHub/non-Chinese sites** — These have much less bot detection.
5. **If user wants to post** — Write the content, let them copy-paste from their own device. Don't try to automate posting.
6. **For topics that need login** (e.g. 小红书 private notes, WeChat articles behind paywall) — Ask the user to share the link or content directly.

## One Exception

If residential proxies become available in the future, re-evaluate. Until then, this is a hard constraint — the platforms win the anti-bot arms race on datacenter IPs.
