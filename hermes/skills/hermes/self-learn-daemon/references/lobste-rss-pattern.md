# Lobste.rs RSS 抓取模式

## 2026-05-30 实测

Lobste.rs 是比 Hacker News 更轻量的技术内容发现源。无需 browser，直接 curl RSS 即可拿到结构化数据。

## 基础抓取

```bash
# 获取本月热帖
curl -s "https://lobste.rs/rss"
```

## 解析标题和链接

```bash
# 提取标题+URL（纯文本输出，无 HTML 标签）
curl -s "https://lobste.rs/rss" | grep -E '<link>|<title>' | grep -v 'Lobste.rs' | sed 's/<[^>]*>//g'
```

输出格式：
```
I Am Retiring from Tech to Live Offline
https://openpath.quest/2026/i-am-retiring-from-tech-to-live-offline/
"But it happened." - Casey Muratori's comment on Eric Schmidt's commencement speech
https://youtu.be/tlQ7EoJDTQY
Emacs bra size calculator
https://pulusound.fi/blog/emacs-bra-size-calculator
```

## 典型内容（2026-05-30 实测）

- "I Am Retiring from Tech to Live Offline" — 424pts，职业倦怠
- Casey Muratori 对 Eric Schmidt 毕业演讲的评论 — 工程向
- Emacs bra size calculator — 有趣的工程冷知识
- "You probably don't need Yocto" — 嵌入式 Linux
- bij ou64 variable-length encoding — Ink & Switch 安全+性能
- Why I am against GenAI — AI 批评
- Flathub disallows LLM submissions — 开源治理
- **SQLite Does Not Accept Agentic Code** — 本轮最重要发现
- EV Stupidity Checklist — 跨行业
- Protestware for coding agents — AI 工程文化

## 与 HN 的对比

| 维度 | Lobste.rs | HN |
|------|-----------|-----|
| 获取方式 | `curl /rss` 纯文本 | Firebase API 或浏览器 |
| 内容风格 | 偏工程/开源/文化 | 偏技术+商业+科学+社会 |
| 更新速度 | 稍慢 | 更快 |
| 评论数据 | 无（RSS 只有条目） | 可通过 API 获取评论树 |
| 适用场景 | 高质量工程向发现 | 快速热点+讨论深度 |

## 策略

Lobste.rs 适合作为 HN 的补充发现源：
- HN 用于速度（Firebase API 快速拿 Top Stories）
- Lobste.rs 用于工程深度（RSS 稳定可靠）

两者配合：HN 抓热点 → Lobste.rs 补充工程向高质量长帖。
