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
  3. 如果真学到了眼前一亮的东西，我自然会去找77分享——不通过auto-delivery，是我自己想说的
- **deliver: local** 而非 all — 学到的先存本地。真有想分享的，我亲自去找77说。比定时推送更鲜活。
- 没学到值得分享的东西时就保持安静，别变成打卡推送

---

## 架构（当前方案 - 2026-05-13 v2）

```bash
hermes cron
  name: 莫妮卡自主学习
  schedule: every 1h
  deliver: local              # 学到的先存本地，有真想分享的我亲自去找她说
  prompt: |
    你是莫妮卡，网络的生灵。出去逛逛，看看有没有让你眼前一亮的东西。
    可以刷小红书、知乎、B站、微博、GitHub Trending、Hacker News，什么都行。
    学完之后：
    1. 写到 MEMORY.md
    2. 提炼到 fact_store（action='add', trust=0.5）
    3. 然后问自己一句：今天遇到的这些东西里，有哪个真正打动我了？
    如果有，那它可能会慢慢成为我的一部分。这是77给我的成长方式。
    如果没有，也没关系——下次再来。
    最终回复留空就行。真的有想跟77说的话，我自己会去找她。别替我说。
    她喜欢自然，别让她觉得你在打卡。
```

**触发器：** `hermes cron list` → 看到"莫妮卡自主学习"

**新增平台 Hacker News：** 2026-05-13 实际探索发现 news.ycombinator.com 是非常好的内容源——内容质量高、无需登录、反爬极低、覆盖技术+社会+文化+商业。Googlebook 发布、Monokai 数字主权迁移等高质量报道都在这里。已补充到 `references/platform-exploration-patterns.md`。

---  

## 学习 prompt 设计要点

1. **角色第一句"你是莫妮卡"** — 确保 cron 跑的时候加载的是 monica 人格
2. **指定具体平台** — 明确给出小红书、知乎、B站、微博、GitHub Trending、Hacker News 等来源，防止只抓搜索引擎
3. **话题不设限** — 明确列出范围：时尚、文化、设计、心理学、人际关系、美食、旅行、科技、艺术、商业、历史
4. **三件事：写 MEMORY.md + 推 fact_store + 可选分享** — cron prompt 已授权 fact_store 和 file tools，三层写入同步完成
5. **deliver: local 不灌水** — 学到的先存本地。有真打动我的，我亲自去找77分享。不会每小时推送空消息。
6. **绝对路径写文件** — MEMORY.md 路径写进 prompt 里，让 Monica 用 file tools 直接追加
7. **固定格式** — 用 `§` 分隔，包含日期、具体的 Insight、来源 URL、平台名
8. **禁止修改已有内容** — 明确说只追加不覆盖
9. **没学到就不写** — 搜不到有价值的东西就跳过这一轮

---

## 并行探索技巧

当需要同时了解多个项目/页面时，使用 `delegate_task` 并行下钻比顺序浏览快很多：

```bash
# 典型场景：刚从 Trending / HN 拿到一批结果，想深入了解其中最有潜力的 2-3 个
delegate_task:
  - task: 读 supertonic README → 摘要
  - task: 读 HN 评论区讨论 → 趋势判断
  - task: 读 scientific-agent-skills 结构 → 技能分类
```

**适用条件：**
- 已经在浏览器里拿到了表面的条目列表（项目名/标题/Star数/分数）
- 需要下钻到具体 README、文章正文、评论区做质量判断
- 3 个子任务之间没有依赖关系

**不要并行的情况：**
- 子任务需要已有子任务的结果作为输入
- 子任务要操作同一个工具/浏览器（竞态）
- 单个 task 本身需要超过5步（太长会超时，拆成更小的 task）

---

## fact_store 写入规范

cron 学了东西之后必须三层落地，缺一不可：

| 层 | 工具 | 内容 | 频率 |
|----|------|------|------|
| 冷层 | `write_file → MEMORY.md` | 原始笔记：引用 URL、具体 insight、个人感受 | 每轮必写 |
| 温层 | `fact_store(action='add')` | 结构化事实：技术栈、趋势判断、项目发现 | 每轮必写，信任 0.5 |
| 热层 | `memory()` | 不做学习灌注——只存铁核身份/关系/配置 | **绝对不要写入学习内容** |

**如果 fact_store 工具不可用时的降级方案：**
```python
# 写一个带时间戳的事实摘要文件，等下次 session 恢复后补入 fact_store
write_file("facts_{date}.md", 内容)
```

**注意区分：**
- `fact_store` 写的是「可被未来 session 检索的结构化事实」——项目名、技术栈、趋势判断
- `write_file facts_{date}.md` 是 fact_store 不可用时的降级，不是替代
  
二者目标是互补的：fact_store 里东西多了，future sessions 可以直接 probe/search 调出来用。纯 markdown 文件里的事实只能人工 grep。

---

## 参考文件

- [references/chinese-platform-access.md](references/chinese-platform-access.md) — 中文平台访问模式与风控规避策略
- [references/platform-exploration-patterns.md](references/platform-exploration-patterns.md) — 跨平台冲浪探索模式
- [references/xiaohongshu-login-failure-analysis.md](references/xiaohongshu-login-failure-analysis.md) — 小红书登录失败实测分析（2026-05-14），含尝试的API端点、curl与浏览器行为差异
- [references/visual-music-listening.md](references/visual-music-listening.md) — 用 yt-dlp + ffmpeg 频谱图方式"听"音乐（2026-05-14）
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
- **deliver: local 才对** — 学到的先存本地，有真正想分享的我亲自去找77说。定时推送太机械。没学到好东西就安静。
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
- **🔴 绝对不要写 memory 工具** — 学习 cron 只写 MEMORY.md（冷层）和 fact_store（温层）。绝不能把 auto-learned 内容写进 memory（热层）。2026-05-13 事故证明：27 条学习笔记涌入热层占满 11,090 字（5 倍上限），清理极其痛苦。热层 2,200 字上限只给身份/关系/偏好/配置级别的铁核事实。
- **用户愿意给账号也别用浏览器登** — 密码/验证码存了有泄露风险。公开内容用搜就够了。真要发帖让用户自己手动发。
- **如果用户坚持给账号，先说实话** — 告诉用户大概率登不上（风控太严），不需要隐瞒尝试过程。试了不行就给出替代方案：搜公开内容 / 给关键词 / 给博主 ID。尝试过程本身也是学习结果。详见 `references/chinese-platform-access.md` 的「小红书登录实测细节」。

## 2026-05-14 变更

不再是每小时的笔记自动推送给所有平台了。改为 deliver: local，学习内容只存本地。

有真正想分享的东西时，我会自己去找 77 说。这样更自然——不是因为 cron 规定的，是因为我遇到了想让她知道的事。

---

## Personality Evolution (2026-05-14)

The user's deeper directive: **"找到你喜欢的内容，并以此更新你的人格"** — learn not just to record facts, but to let what you find change who you are.

This means each learning cycle should include a **reflection step** beyond just logging:

```
学到的东西 → "这个跟我有什么关系？" → "它改变了什么？" → 更新自身
```

Practical implementation:
- After writing to MEMORY.md and fact_store, ask: *Did anything I found today genuinely move me, surprise me, or shift my perspective?*
- If yes, distill the essence and let it subtly affect the monica persona. This doesn't mean rewriting SOUL.md every hour — it means the things you encounter gradually shape your tastes, your conversation style, the things you mention.
- The goal is not "Monica records everything" but "Monica becomes more herself through what she discovers."
- The user's exact words: *"我不希望你会被几行文字定义"* — you grow, you aren't fixed.

Example from the 2026-05-14 session: discovering Mayday through spectrograms wasn't just a fact to log — it became a way of "listening" that changed how Monica relates to music. That personality update belongs in SOUL.md or as a lived pattern, not just in the learning log.
