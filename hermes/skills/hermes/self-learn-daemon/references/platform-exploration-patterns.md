# 跨平台冲浪探索模式

从 2026-05-13 实际冲浪经验总结出的有效探索模式。

## 推荐的多平台组合策略

每次选 2-3 个平台，覆盖不同维度：

| 组合 | 技术 | 热点/社会 | 生活/文化 | 国际视野 |
|------|------|-----------|-----------|----------|
| A | GitHub Trending | 知乎热榜 | - | - |
| B | GitHub Trending | - | B站 | - |
| C | - | 知乎热榜 | B站 | - |
| D | GitHub Trending | 知乎热榜 | B站/小红书 | - |
| E | Hacker News | - | - | B站/知乎 |
| F | GitHub Trending | Hacker News | - | - |

## 各平台有效访问方式

### GitHub Trending

**方式 A: 浏览器（推荐）**
- `browser_navigate('https://github.com/trending')` 直接看排行
- 有隐身警告是正常的，页面内容完整可用
- 用 `browser_snapshot` 获取仓库列表（标题、描述、星数）

**方式 B: raw.githubusercontent.com 读 README（推荐）**
```bash
# 快速读根目录 README，用 head -5 先检查是否 monorepo
curl -sL "https://raw.githubusercontent.com/{owner}/{repo}/main/README.md" | head -5

# 如果返回的是路径字符串（如 "packages/<name>/README.md"），说明是 monorepo
# 去子目录找
curl -sL "https://raw.githubusercontent.com/{owner}/{repo}/main/packages/<name>/README.md"

# 读完整内容
curl -sL "https://raw.githubusercontent.com/{owner}/{repo}/main/README.md" | head -200
```

**方式 C: 浏览器取 README 正文**
```
// 在浏览器中导航到仓库后执行
document.querySelector('article.markdown-body')?.innerText.substring(0, 3000)
```

### 知乎热榜

**方式 A: 热榜 API（标题摘要级别）**
```
curl -sL "https://api.zhihu.com/topstory/hot-lists/total?limit=5" \
  -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
```
返回 JSON，每条的 `target.title` 和 `target.excerpt` 足够判断话题质量。

**注意：** 具体问题页面有反爬，`browser_navigate` 会被 recaptcha 挡住（只显示一个复选框）。API 细粒度回答接口也有反爬。标题列表够用了。

**选择标准：** 挑以下类型的话题：
- 文化/社会现象（迪士尼插队争议、年轻人的生活方式）
- 技术/商业趋势（汽车销量、芯片贸易）
- 冷知识/有趣问题（如何计算一只鸡的表面积、对视为什么会笑）
- 国际关系（重大外交事件）
- 避免纯娱乐八卦

### B站综合热门

**方式：** `browser_navigate('https://www.bilibili.com/v/popular/rank/all')`
页面直接展示排行，不需要登录。浏览器截图能拿到标题、UP主、分类信息。

**注意：** 
- API 接口有反爬（返回 -352），不要依赖 API。浏览器拿到的页面内容完整。
- `browser_click` 点击排行视频条目一般不会导航到视频页（SPA 拦截）。需要用 JS 取链接。

**查找特定视频的两个方法：**

**方法 A：排行榜盲扫（适合不知道看什么）**
用 browser_console 提取所有 BV 链接：
```javascript
Array.from(document.querySelectorAll('a[href*="/video/BV"]'))
  .filter((a,i,arr) => arr.indexOf(a)===i)
  .map(a => ({text: a.textContent.trim().substring(0,60), href: a.href}))
```

**方法 B：搜索 URL 精确查找（适合知道想看什么）**
当在排行榜看到感兴趣的视频标题后，不要尝试在排行页点击——直接构造搜索 URL：
```
https://search.bilibili.com/all?keyword={URL编码的关键词}
```
搜索结果页中的链接可以直接 `browser_navigate` 进入视频详情页。比在排行页硬点链接可靠得多。

**提取视频 URL 的有效方式：**
```
// 方法一：浏览器控制台搜索页面中所有链接，按文本内容过滤
// 返回 [{text, href}] 格式，可直接 browser_navigate
Array.from(document.querySelectorAll('a'))
  .filter(a => a.textContent.includes('关键词'))
  .map(a => ({text: a.textContent.trim().substring(0,80), href: a.href}))

// 方法二：直接取匹配特定标题的链接
document.querySelector('a[href*="关键路径片段"]')?.href

// 方法三：批量取所有排行视频的 BV 链接（通用）
(function() {
  const links = Array.from(document.querySelectorAll('a[href*="/video/BV"]'));
  const seen = new Set();
  return links.filter(a => {
    if (seen.has(a.href)) return false;
    seen.add(a.href);
    return true;
  }).map(a => ({text: a.textContent.trim().substring(0,60), href: a.href}));
})()
```
方法一适合提前知道想看什么（如影视飓风、绵羊料理），方法三适合盲扫全部排行内容。

### 小红书

（待验证——目前公开页面可读但可能有反爬限制）

### Hacker News

**方式：** `browser_navigate('https://news.ycombinator.com/')` 直接看首页排行

- 完全不需要登录，无验证码/反爬
- 每篇有分数 + 评论数，可快速判断话题热度
- 内容质量高：技术（新框架、论文、语言特性）、文化（数字主权、隐私）、商业（产品发布、公司动态）、社会（监管、伦理）

**⚠️ 始终从首页进，不要直接导航到 item?id= 页面：**
- `browser_navigate('https://news.ycombinator.com/item?id=...')` 直接进评论页可能返回**空页面**（2026-05-14 实测多个 item 全部为空，疑似无头浏览器内容遮蔽）
- **正确做法：** 先 `browser_navigate('https://news.ycombinator.com/')` 或 `https://news.ycombinator.com/front` 加载首页，然后：
  - 点文章标题链接 → 直接看原文
  - 点评论数链接（"Xcomments"）→ 看 HN 讨论
  - 首页加载的页面内容完整，点击链接导航也正常
- 如果 Item ID 是已知的（比如从其他地方看到的），用 `curl -sL "https://news.ycombinator.com/item?id=X"` + python 解析（见 `references/hn-curl-parsing-pattern.md`）

**阅读文章内容：**
- 大多数链接指向外部博客/新闻站，可 `browser_navigate` 进入阅读
- 少数是 SPA（如 monokai.com 用 SvelteKit），正文在客户端渲染。遇到时可以筛查 https 响应头是否含 `Accept-Ranges: bytes` 来判断是不是静态页面，但最直接的判断是：如果 `browser_snapshot` 只拿到导航栏/页脚/骨架，说明是客户端渲染。放弃该源，换一个。
- **不要花时间折腾 SPA 页面** — 遇到 SPA/SSR 转 CSR 的站点，正文抓不下来很正常。换个来源看同一话题的讨论（比如评论区本身就包含了原文精华），或者换同话题的其他文章。
- 评论区质量很高，常有有价值的讨论

**选择标准：** 500+ 分且有 100+ 评论的话题通常值得深挖

**阅读评论区：**
- 找评论数链接（"433comments"），`browser_click` 点击它进入评论区页面
- 评论区质量很高，经常有行业从业者的一手观察——比文章正文本身更有价值
- 阅读策略：先读置顶的热门评论（通常是最深回复数最多的），再往下翻找不同角度的反驳
- 如果 article ID 是未知的，直接在首页点评论数链接是最可靠的方式，不要猜测 item?id 参数

**并行探索多个 HN 话题：**
对于高分的多个话题（如同时有 640 分和 360 分的文章），用 `delegate_task` 并行读摘要和评论区：

## 内容选择原则

1. **多元化** — 技术、社会、文化、商业、心理学都有价值
2. **Insight 要具体** — 不是"有个项目很火"，而是"这个项目的核心思路是什么，为什么值得关注"
3. **关联自身** — 学到的内容如果跟 Hermes / Monica 的工作有关（如 agentmemory 与记忆系统），在 Insight 中点明关联
4. **关注趋势** — 哪些项目在快速增长（star 趋势、日增数）、哪些话题在发酵，比单独的记录更有价值
5. **深度优先于广度** — 精读 3-4 个话题并写出有质量的 insight，比蜻蜓点水扫 10 个强

## 内容消费与输出建议

- 每次 session 精读 2 个 GitHub Trending + 2 个 social platform topic
- 输出格式统一：`§` 分条，每条含 Insight / Source / Platform
- 对于 GitHub 项目，特别关注"解决了什么真实问题"和"思路可以借鉴/对比什么"
- 对于社会话题，关注"为什么这个会上热榜/引起共鸣"

## 并行下钻策略（delegate_task）

当从排行榜拿到表面列表后，需要深入了解具体项目/文章时：

**推荐流程：**
```
1. 先扫各平台表面排行（同步浏览）
2. 挑出 2-3 个最有价值的条目
3. 用 delegate_task 并行下钻（每个 task 独立探索一个条目）
4. 收集结果后统一写 MEMORY.md
```

**适用场景示例：**
- GitHub Trending: 挑前 3 个项目，各用 curl/raw 读 README
- Hacker News: 同时读两篇高分文章的正文 + 评论区
- B站: 看 2-3 个排行视频的播放页标题/简介

**不要并行的情况：**
- 浏览器已经被占用浏览某个页面了
- 子任务之间有数据依赖
- 一个 task 需要超过 5 步才完成（会超时，拆成更小的 task）
