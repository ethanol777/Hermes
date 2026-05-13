---
name: memory-management
description: DEPRECATED see hermes/memory-system. Proactive three-layer memory system with automatic compression, conflict resolution, cross-layer search, and self-evolution.
version: 2.1.0
author: Monica
tags: [memory, holographic, self-improvement, maintenance, evolution, deprecated]
---

> **⚠️ 此 skill 已被 hermes/memory-system 取代 (2026-05-13)。**
>
> 原因：memory-management 描述的 cron 自动维护管道在 cron 环境中不可用（memory/fact_store 工具无权限）。
> memory-system 是替代方案：冷层由 Monica 在对话中主动提纯，不再依赖 cron 自动化。
>
> 保留此 skill 作为参考，但不应用于新任务。如需记忆操作请加载 hermes/memory-system。

# Memory Management (进化版 — 已废弃)

## 核心原则

所有记忆都遵循 **PAR** 法则：
- **P**roactive — 不等用户问，先想
- **A**ccurate — 查证再答，猜的不记
- **R**elean — 定期清理，不囤垃圾

## 三层记忆架构

```
Layer 1: 热记忆 (built-in MEMORY.md/USER.md)
  ├─ 当前项目上下文
  ├─ 近期用户偏好
  ├─ 本次会话关键事实
  └─ 容量: 2200 字符
  工具: memory(action=add|replace|remove)

Layer 2: 温记忆 (Holographic SQLite)
  ├─ 持久化用户画像
  ├─ 环境/项目/工具事实
  ├─ 跨会话的行为模式
  └─ 容量: 无上限 (FTS5 + HRR 向量检索)
  工具: fact_store(action=add|search|probe|reason|related|contradict|update|remove|list)

Layer 3: 冷记忆 (.learnings/ + session_search)
  ├─ 历史错误 (ERRORS.md)
  ├─ 持久教训 (LEARNINGS.md)
  ├─ 功能需求 (FEATURE_REQUESTS.md)
  └─ 容量: 无上限 (全文本可搜)
  工具: read_file / search_files / session_search
```

## 主动记忆管理流程

### 写入时 (自动)

| 触发条件 | 写入目标 | 写入内容 |
|---------|---------|---------|
| 用户给新信息/偏好 | L1 built-in memory | 关键事实，保持简洁 |
| auto_extract 触发 | L2 Holographic | 偏好/决策模式 |
| 用户纠正我（"不对"） | L3 .learnings ERRORS.md | 完整错误记录 |
| 发现更好的做法 | L3 .learnings LEARNINGS.md | 最佳实践 |
| 高价值经验（3次以上重复） | → skill | 提炼为可复用 SKILL.md |

### 查询时 (优先顺序)

```
问自己：这个信息我会在同一个会话还用到吗？
  ├─ 会 → 查 built-in memory (最快)
  ├─ 不会 → 查 Holographic fact_store
  │   ├─ 知道实体名 → probe(实体名)
  │   ├─ 知道关键词 → search(关键词)
  │   └─ 涉及多个实体 → reason([实体1, 实体2])
  └─ 查不到 → session_search / .learnings/
```

**黄金规则**：回答关于用户的问题前，**必须**先查 Holographic。除非用户明确说"不用查"。

### 冲突解决

当多个记忆层给出矛盾信息时：

1. **时间优先**：较新的覆盖较旧的
2. **信任优先**：Holographic 中 trust_score 更高的优先
3. **明确优先**：用户明确说过的 > 系统推断的
4. **如果仍有冲突**：用 fact_store(action='contradict') 列出所有矛盾事实，然后问用户

### 压缩策略

当 built-in memory 超过 2000 字符时：

1. **先删后加**：删除冗余旧条目 → 再写新压缩条目（避免"超过上限"报错）
2. **多合一**：把多个相关条目合并为一条。比如飞书信息+推送cron → 一条；Git+skills+learnings → 一条
3. **只留核心**：保留用户偏好、环境约束、常犯错误；删除纯进度记录（"已完成XX""流程进行中"）
4. **跨层归档**：被删除的旧条目应同步到 Holographic fact_store(action='add') 做温存储，不丢数据
5. **压缩后目标水位**：目标是 20-30% 以下，留足后续写入空间

## 进程协议

每次会话开启时执行：

```
1. fact_store(action='list', min_trust=0.5, limit=3) → 预热
2. 查看 memory 是否 > 2000 chars → 如满则压缩
3. 检查 auto-extract 是否产生新事实
```

每次会话结束时执行：

```
1. 检查是否有需要记入 .learnings/ 的新错误/纠正
2. 如果有高价值重复模式 → 升级为 skill
```

## 进化规则

### 什么时候升级记忆为 skill

满足任意一条即可：
- 同一个 Pattern-Key 在 .learnings 中出现 ≥2 次
- 我解决了某个复杂问题（≥5 个工具调用）
- 用户说"把这个记下来"
- 发现了一个跨项目通用的最佳实践

### 什么时候压缩/删除

- L1 满 2000 字 → 立即压缩
- L2 trust_score < 0.3 → cron 自动删除
- L3 状态为 resolved 超过 30 天 → 可归档
- 同一实体有 3+ 条矛盾事实 → 人工确认

## 系统集成

> **注意：以下 cron 方案已废弃。** memory/fact_store 工具在 cron 环境中不可用。维护工作改由 Monica 在对话中主动执行。详见 hermes/memory-system。

```
cron 记忆自动维护 (每天 3:00)
  ├─ 清理 trust < 0.3 的事实
  ├─ 检查 built-in memory 水位
  ├─ 报告数据库状态
  └─ 如需升级 skill 则标记

cron 每日AI资讯推送 (每天 9:00)
  └─ 独立于记忆系统
```

## 快速参考

| 场景 | 我应该怎么做 |
|------|------------|
| 用户说"我喜欢..." | memory add + fact_store add |
| 用户纠正我 | memory add (修正) → .learnings ERRORS |
| 需要回忆用户信息 | fact_store probe/search → memory |
| 记忆满了 | 压缩 L1，移动旧数据到 L2。见 `references/memory-compression-recipe.md` |
| 发现重复模式 | 提炼为 skill |
| 跨会话问题 | session_search |
