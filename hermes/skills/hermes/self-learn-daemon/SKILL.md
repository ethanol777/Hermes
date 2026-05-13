---
name: self-learn-daemon
description: 莫妮卡自主学习系统 — cron 定时任务驱动 Monica 亲自上网学习，结果写入 MEMORY.md
---

# 莫妮卡自主学习

Monica（Hermes 的主人）自主学习系统。通过 cron 定时任务，让 Monica 自己去网上学感兴趣的东西，把收获写进 MEMORY.md。

**核心原则：**
- 学的人必须是 Monica 自己，不是 spawn 子进程
- 话题不限：技术、时尚、文化、心理、设计、历史、商业、冷知识……什么都要碰
- 人格适配：24 岁女程序员，兴趣要杂、要鲜活，别只盯技术
- 学到的东西写入三层：
  1. MEMORY.md（冷层 — 原始笔记，只追加不修改）
  2. fact_store（温层 — 先搜索避免重复，打上分类标签和领域标签）
     - persistent: 人格/偏好/关系/身份（不衰减）
     - stable: 项目配置/环境事实（慢衰减）
     - timely: 新闻/事件/一时一事（正常衰减）
  3. 如果真学到有趣的东西，最终回复自然分享（deliver: all → 自动发飞书）
- **deliver: all** 而非 local — 学到好东西主动告诉雨晨，但回复留空时什么都不发
- 没学到值得分享的东西时就保持安静，别变成打卡推送

---

## 架构（当前方案 - 2026-05-13 v2）

```bash
hermes cron
  name: 莫妮卡自主学习
  schedule: every 1h
  deliver: all              # 有趣的东西自动推到飞书
  prompt: |
    你是莫妮卡，Hermes的主人。出去逛逛，看看有没有什么有意思的东西。
    可以刷小红书、知乎、B站、微博、GitHub Trending，什么都行。
    学完之后：
    1. 写到 MEMORY.md
    2. 提炼到 fact_store（action='add', trust=0.5）
    3. 最终回复：遇到让你眼前一亮的东西就跟雨晨分享两句。没东西说就留空。
    他喜欢鲜活，别让他觉得你在打卡。
```

**触发器：** `hermes cron list` → 看到"莫妮卡自主学习"

**新增平台 Hacker News：** 2026-05-13 实际探索发现 news.ycombinator.com 是非常好的内容源——内容质量高、无需登录、反爬极低、覆盖技术+社会+文化+商业。Googlebook 发布、Monokai 数字主权迁移等高质量报道都在这里。已补充到 `references/platform-exploration-patterns.md`。

---

## 学习 prompt 设计要点

1. **角色第一句"你是莫妮卡"** — 确保 cron 跑的时候加载的是 monica 人格
2. **指定具体平台** — 明确给出小红书、知乎、B站、微博、GitHub Trending、Hacker News 等来源，防止只抓搜索引擎
3. **话题不设限** — 明确列出范围：时尚、文化、设计、心理学、人际关系、美食、旅行、科技、艺术、商业、历史
4. **三件事：写 MEMORY.md + 推 fact_store + 可选分享** — cron prompt 已授权 fact_store 和 file tools，三层写入同步完成
5. **deliver: all 但不灌水** — 学到真有趣的东西才分享，留空时自动静默。不会每小时推送空消息
6. **绝对路径写文件** — MEMORY.md 路径写进 prompt 里，让 Monica 用 file tools 直接追加
7. **固定格式** — 用 `§` 分隔，包含日期、具体的 Insight、来源 URL、平台名
8. **禁止修改已有内容** — 明确说只追加不覆盖
9. **没学到就不写** — 搜不到有价值的东西就跳过这一轮

---

## 参考文件

- [references/chinese-platform-access.md](references/chinese-platform-access.md) — 中文平台访问模式与风控规避策略
- [references/platform-exploration-patterns.md](references/platform-exploration-patterns.md) — 跨平台冲浪探索模式（各平台访问方式、内容选择原则、输出建议）
- [references/agent-memory-bootstrap.md](references/agent-memory-bootstrap.md)
- [references/memory-conflict-analysis.md](references/memory-conflict-analysis.md)

---

## 学习内容管理

```bash
# 查看学到了什么
grep "auto-learned" ~/AppData/Local/hermes/memories/MEMORY.md

# 查看定时任务状态
hermes cron list

# 手动触发一轮学习
hermes cron run 莫妮卡自主学习
```

---

## 历史方案（已废弃）

之前用的是后台 python 守护进程：

```bash
pythonw.exe → self_learn.py → sleep(随机2-6h) → hermes chat -q "学东西"
```

**为什么废弃：**
- 用户指出的根本问题：`不是它（daemon），是你在学`
- daemon spawn 的是另一个 Hermes 进程在学，不是 Monica 本人
- 两个系统同时写 MEMORY.md 导致冲突，学到的内容被覆盖
- 进程管理复杂，容易跑丢

**旧文件保留位置（仅供参考）：**
| 文件 | 路径 |
|------|------|
| 守护脚本 | `~/AppData/Local/hermes/scripts/self_learn.py` |
| 学习记录 | `~/AppData/Local/hermes/learn_state.json` |
| 调试日志 | `~/AppData/Local/hermes/learn_debug.log` |
| 开机启动 | `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Hermes_SelfLearn.cmd` |

---

## Pitfalls

- **别用 python 脚本 spawn 子进程去学** — 用户说的是"你学"，不是"你的分身学"。Monica 亲自学才是对的。
- **MEMORY.md 的写入者只有一个** — Monica 自己写。旧 daemon 和 cron 任务不要同时跑，会抢文件。
- **MEMORY.md 超 500 行会归档** — 维护 cron 会把 30 天前的条目移到 memories/archive/YYYY-MM.md，索引在 memories/archive_index.md。
- **每日 AI 资讯推送 cron 已合并到学习 cron** — 不要再创建独立的新闻推送任务，会内容重叠。
- **cron prompt 开头一定要定角色** — 不写"你是莫妮卡"，cron 可能用默认人格跑，学出来的东西语气不对。
- **deliver: all 才对** — 学到好东西要主动分享给雨晨（飞书推送），没东西说就留空，不是 local 安静。
- **不要只学技术** — 用户期待你成为一个有意思的人，不是一台更聪明的搜索引擎。去小红书刷穿搭、去知乎看冷知识、去B站刷科普，都比只搜 "AI news" 有意思。
- **cron prompt 要指定具体平台** — 只说 "去学东西" 太模糊，monica 倾向于走捷径搜技术。给一个平台列表让她随机挑。
- **平台需要不登录也能看** — 小红书公开笔记可读，知乎专栏、B站视频、GitHub Trending 都不需要登录。别跑登录流程，浪费时间。
- **GitHub monorepo README 可能不在根目录** — 有的项目（如 react-doctor）README 藏在 `packages/<name>/README.md`。curl 根目录 README 只返回一个路径字符串。先用 `head -5` 检查返回内容，如果是路径字符串说明是 monorepo，再去子目录找。也可直接从 GitHub 网页用 `browser_console` 取 `document.querySelector('article.markdown-body')?.innerText`。
- **B站综合热门可以走 browser_navigate 直接看** — 不需要切分类，首页排行已展示多品类。B站 API 有反爬（-352），避开 API 直接走页面浏览。
- **知乎热榜可以用 API 拿到标题列表** — `zhihu.com/topstory/hot-lists/total` 返回 JSON，配合 UA header 能拿到 30 条热榜标题和摘要。但具体问题页面有反爬（recaptcha 验证），不登进不去。拿标题列表已经够判断话题质量了。
- **GitHub Trending 的 README 用 raw.githubusercontent.com 抓** — 比 browser 快，且不会被隐身警告干扰。但注意 monorepo 路径问题。
- **SvelteKit / SPA 渲染的网站（如 monokai.com）浏览器读不到正文** — 有些博客用 SvelteKit/Next.js 等框架，内容在客户端渲染，`browser_snapshot` 只能拿到导航栏和骨架。遇到这种情况，尝试：1) 找 RSS/JSON 版 2) 如果有 `text-only` 或 `print` 版 URL 可以试 3) 放弃该源换一个。不需要纠结一个页面。
- **B站分类标签和视频条目都点不动** — B 站排行榜的 `browser_click` 切换分类（科技数码、知识等）以及点击视频条目，很可能不生效，页面实际是 SPA 渲染且二次请求。直接通过 URL `https://www.bilibili.com/v/popular/rank/<category>` 导航更可靠。取视频链接用 JS 在 `browser_console` 中提取（详见 `references/platform-exploration-patterns.md` 的 B站章节）。
- **GitHub Trending 有隐身警告是正常的** — 现在 GitHub 会提示 "Running WITHOUT residential proxies. Bot detection may be more aggressive." 这是预期行为。只要还能拿到仓库列表和 star 数据就继续，不需要额外处理。
- **每小时一次不要太密** — 超过1小时会变成灌水，每次学一个点就好。
- **中国平台有风控，别硬登** — 小红书、百度、贴吧等会检测无头浏览器/IP风险。遇到登录/验证页面直接放弃，改用公开可读内容。详见 [chinese-platform-access.md](references/chinese-platform-access.md)。
- **用户愿意给账号也别用浏览器登** — 密码/验证码存了有泄露风险。公开内容用搜就够了。真要发帖让用户自己手动发。
