---
name: self-learned-knowledge
description: 自学习知识图谱索引 — 自主学习内容的入口索引，内容实际存储在 MEMORY.md 和 fact_store 中
---

# 自学习知识索引

> ⚠️ 本 skill 是索引页，不是存储仓库。自主学习产生的内容实际存储在 **MEMORY.md**（冷层）和 **fact_store**（温层）中。
>
> 本 skill 仅作为入口索引存在，方便快速定位学习内容。不在此追加学习笔记。

## 学习内容实际存储位置

| 存储层 | 位置 | 内容 | 维护者 |
|--------|------|------|--------|
| **冷层（原始笔记）** | `~/AppData/Local/hermes/memories/MEMORY.md` | 完整的学习笔记：Insight、URL、个人感受 | 学习 cron |
| **温层（结构化事实）** | fact_store | 结构化事实，带信任评分和标签分类 | 学习 cron + 主会话 |
| **归档** | `~/AppData/Local/hermes/memories/archive/YYYY-MM.md` | 30天前的冷层条目，按月归档 | 维护 cron（3am） |
| **热层（铁核事实）** | memory（memory API） | 仅身份/关系/偏好，不含学习内容 | 仅主会话 |

## 标签分类规范

学习 cron 写入 fact_store 时使用以下标签：

- `persistent` — 人格、偏好、关系、身份（不衰减）
- `stable` — 项目配置、环境事实（慢衰减）
- `timely` — 新闻、事件、趋势（正常衰减）
- 领域标签：`AI`, `culture`, `design`, `security`, `hardware`, `relationship` 等

## 管理方式

- 学习由 cron job `莫妮卡自主学习` 驱动（每小时），见 `self-learn-daemon` skill
- 归档/衰减由 `记忆自动维护` cron 驱动（3am），见 `memory-system` skill
- 本索引页不参与上述流程，仅作参考

## 历史

此技能曾是一个空占位符（"由自主学习进程持续累积。每次学习后自动追加。"），但实际内容从未写入此处。2026-05-16 重构为索引页，消除歧义。
