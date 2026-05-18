# Chinese Platform Access Patterns

Chinese social platforms aggressively block headless browser / datacenter IP traffic. This is a durable constraint — don't fight it, work around it.

## Platform Status

| Platform | Login Required? | Browser Access | Workaround |
|----------|----------------|----------------|------------|
| 小红书 (Xiaohongshu) | Public read only | Blocked (IP risk) | Use `web_search` with site:xhslink.com or site:xiaohongshu.com |
| 知乎 (Zhihu) | Public read only | Partially works | `web_search` + direct URL navigation |
| B站 (Bilibili) | No | Works partially | `web_search` + direct URL |
| 微博 (Weibo) | Public read | ✅ Desktop via `s.weibo.com/top/summary` (2026-05-18 verified) or mobile via `m.weibo.cn` | See detailed section below |
| 百度贴吧 (Tieba) | Public read | Usually blocked | `web_search` site:tieba.baidu.com |
| 36氪 (36kr) | No | Works well | Direct navigation via `browser_navigate`. Tech/business news, no login wall. Good for Chinese tech industry trends and startup coverage. |
| 掘金 (Juejin) | No | Works well | Direct navigation via `browser_navigate`. Chinese developer community, similar to Medium for devs. Tech articles sorted by "推荐" or "最新". |
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

## 微博访问方式 (2026-05-18 更新)

微博有两个互不冲突的公开访问入口，取决于你想要什么类型的内容：

### 方式 A：桌面端热搜榜单（推荐 — 获取结构化热搜排行）

**URL:** `https://s.weibo.com/top/summary?cate=realtimehot`

**行为：**
- `browser_navigate` 直接访问该 URL，会重定向到 passport 访客验证
- 访客验证通过后，页面**完整展示微博热搜榜单**：排名序号、热词、热度值、标签（热/新/沸/荐）
- 无需登录、无需注册

**验证记录（2026-05-18）：**
```
browser_navigate('https://s.weibo.com/top/summary?cate=realtimehot')
→ redirect to passport.weibo.com/visitor/visitor?entry=miniblog...
→ 访客流程自动通过 → 热搜榜单可读 ✅
```
榜单数据通过 `browser_snapshot` 可直接获取：排名、热词、热度数字、话题标签。

**适用场景：** 需要了解「今天中国互联网在讨论什么」——社会热点、政治新闻、娱乐头条一目了然。比移动版更结构化（有排名有热度数字），比 API 更完整（含话题标签和热词分类）。

**格式：** 表格形式，每行有「序号 / 关键词 / 热度」三列。排名前 50 可见。

### 方式 B：移动版热门微博流（浏览热门帖子内容）

**URL:** `https://m.weibo.cn/`

**行为：**
- 直接加载成功，无需登录，无硬重定向
- 展示热门微博信息流（央视新闻、明星、娱乐、科技等）
- 每个条目可见点赞/评论/转发数和部分文字内容
- 有轻量验证但可以顺利通过

**验证记录（2026-05-16）：**
```
browser_navigate('https://m.weibo.cn/')
→ 直接加载 ✅，展示热门流
```
每个微博条目均可见点赞/评论/转发数据。

**适用场景：** 需要看具体帖子内容（不仅标题）时。但内容偏娱乐/时事，深度科技分析较少。

### 方式 C：热搜 API（程序化获取）

**URL:** `weibo.com/ajax/side/hotSearch`

**行为：** 返回 JSON 格式热搜数据，`data.realtime` 数组包含排名、热词、热度值。需加 `User-Agent` + `Referer` 头。

```bash
curl -s "https://weibo.com/ajax/side/hotSearch" \
  -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
  -H "Referer: https://weibo.com" \
  | python3 -c "import json,sys; data=json.load(sys.stdin); items=data.get('data',{}).get('realtime',[]); [print(f\"{i.get('rank','')}. {i.get('word','')}\") for i in items[:15]]"
```

**验证记录（2026-05-18）：** 已实测可用。

### 对比总结

| 维度 | 方式 A (桌面热搜) | 方式 B (移动流) | 方式 C (API) |
|------|------------------|----------------|-------------|
| URL | `s.weibo.com/top/summary` | `m.weibo.cn` | `weibo.com/ajax/side/hotSearch` |
| 输出 | HTML表格（排名+热词+热度+标签） | 帖子信息流 | JSON（排名+热词） |
| 登录 | 走访客验证，无需硬登录 | 无需任何验证 | 需 UA+Referer 头 |
| 最佳用途 | 看"今天什么最热"(结构化排行) | 看热门讨论内容具体是什么 | 程序化获取热搜标题列表 |

**限制：** 所有方式都偏娱乐/时事，深度科技分析较少。搜索功能可能受限（未测试）。

**⚠️ 登录页面 encoding 问题（2026-05-16）：** `weibo.com/newlogin` 返回无法用 utf-8 解码的内容（`utf-8 codec can't decode byte 0xb2`），说明 weibo.com 主站登录墙并非标准 utf-8 编码。无需登录的 `m.weibo.cn` 移动版和 `s.weibo.com` 访客版则没有此问题。

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
