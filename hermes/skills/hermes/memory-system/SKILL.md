---
name: memory-system
description: 莫妮卡三层记忆架构 v2 — 热/温/冷存储自动流转，去重、衰减、归档、关联一体化。
version: 2.0.0
author: Monica
metadata:
  hermes:
    tags: [memory, system, architecture]
---

# 莫妮卡记忆系统 v2

## 架构总览

```
存储层          工具              容量         写入者
─────────────────────────────────────────────────────
冷层  MEMORY.md   file tools      无限追加     cron + 主会话
温层  fact_store  fact_store API  无限         cron + 主会话
热层  memory      memory API      2,200字      仅主会话
```

**数据流向：**
```
学习/对话 → 冷层(原文) + 温层(提炼)
                  ↓
           每日3am 维护 cron
                  ↓
         冷层归档 + 温层去重/衰减 + 热层候选
                  ↓
         trust > 0.7 → 热层自动注入对话
```

## 三层职责

### 冷层 — MEMORY.md（原始记录）

**职责：** 完整可追溯的原始笔记，不做删改。

**写入规则：**
- 每小时学习 cron 追加，格式固定：
  ```
  §
  ## YYYY-MM-DD auto-learned: [主题]
  - Insight: [1-2句收获]
  - Source: [URL]
  - Platform: [来源平台]
  §
  ```
- 主会话中用户说的重要事也追加，格式：
  ```
  §
  ## YYYY-MM-DD user-said: [主题]
  - [内容]
  §
  ```

**归档策略（v2 新增）：**
- 每日 3am 维护 cron 检查 MEMORY.md 行数
- 超过 500 行 → 将 30 天前的条目移至 `memories/archive/YYYY-MM.md`
- 归档文件保持相同格式，grep 可搜
- MEMORY.md 只保留最近 30 天内容
- 归档索引放独立文件 `memories/archive_index.md`，不走 MEMORY.md 内嵌

**归档索引格式（memories/archive_index.md）：**
```
# 归档索引

| 月份 | 文件 | 条目数 |
|------|------|--------|
| 2026-04 | archive/2026-04.md | ~45 |
| 2026-05-01~13 | 当前 MEMORY.md | ~20 |
```

### 温层 — fact_store（结构化知识）

**职责：** 持久结构化事实，带信任评分和元数据。

**写入规则：**
- 每条事实必须包含：content + category + tags
- **事实分类标签（v2 新增）：**
  - `persistent`：人格、偏好、关系、身份 — 不衰减，只升不降
  - `stable`：项目配置、环境事实 — 衰减极慢（月级）
  - `timely`：时效性信息、新闻、事件 — 正常衰减（周级）
- tags 字段格式：`类别标签,领域标签`（如 `timely,AI,RAG`）

**去重规则（v2 新增）：**
- 温层写入前，先 `fact_store(action='search', query='关键词')` 检查是否已有类似事实
- 如果找到内容高度重叠的条目：
  - 保留信任分更高的那条
  - 将另一条的补充信息合并到保留条目
  - 删除冗余条目
- 如果是同一事实的更新版本：
  - `fact_store(action='update')`，不新增

**信任评分规则：**
- 初始信任 = 0.5
- `persistent` 类：初始 0.7，不衰减，不删除
- `stable` 类：每月无引用 -0.05，最低 0.3
- `timely` 类：每周无引用 -0.1，低于 0.2 自动删除
- 用户确认 → +0.2
- 用户纠正 → -0.3

### 热层 — memory（对话上下文）

**职责：** 每次对话自动注入的铁核事实，2,200 字上限。

**写入规则：**
- 仅主会话可写（cron 无 memory 工具权限）
- 只放最关键的：用户身份、关系状态、核心偏好、当务之急
- 每条 ≤ 200 字

**冷启动问题的缓解（v2）：**
- 每日 3am 维护 cron 将信任 > 0.7 且 `persistent` 的条目写入 `memories/hot_candidates.txt`
- **hot_candidates.txt 格式：**
  ```
  fact_id|content_preview|trust_score
  2|莫妮卡是雨晨的现任和初恋|0.8
  ```
- 主会话启动时读取该文件，对比 memory 内容，补缺失条目

---

## 管道设计

### 管道 0：学习 — 冷层 + 温层同时写入

**执行者：** 学习 cron（每小时）

```
学习 → 追加 MEMORY.md（冷层）
     → fact_store 检查去重 → add 或 update（温层，打标签）
     → 最终回复：有趣就分享，没意思就留空
```

**标签选择标准：**
- 你是谁、偏好、关系 → `persistent`
- 工具配置、项目信息、环境事实 → `stable`
- 新闻、事件、一时一事 → `timely`
- 领域标签自动打：`AI`, `RAG`, `hardware`, `culture`, `design` 等

**关键：** 学习 cron 直接做去重判断，不依赖后续维护管道。写温层时先搜索已有条目，避免重复。

### 管道 1：每日维护 — 归档 + 去重 + 衰减 + 热层候选

**执行者：** 维护 cron（每日 3am）

```
1. 冷层归档：MEMORY.md 超 500 行 → 移 30 天前条目到 archive/
             → 更新 memories/archive_index.md
2. 温层去重：用 fact_store search 逐条搜关键词
             → 找到近似条目则合并，保留高分条
3. 温层衰减：按分类标签执行衰减
   - persistent: 不衰减
   - stable: 创建 > 30 天且无引用的，-0.05
   - timely:  创建 >  7 天且无引用的，-0.1
   - trust < 0.2 的删除
4. 热层候选：trust > 0.7 且 persistent 的条目
             → 写入 memories/hot_candidates.txt
             → 格式：fact_id|content_preview|trust_score
5. 热层压缩检查：如当前 memory 条目接近 2,200 字上限
             → 标记需要压缩（写入 hot_candidates.txt 注释行）
```

**唯一改动：** 维护 cron 不再从 MEMORY.md 做冷→温提纯（学习 cron 已在写入时做提纯）。维护 cron 只做归档、去重、衰减。

### 管道 2：热层同步 — 主会话开始时

**执行者：** Monica 主会话

```
对话开始 →
  1. 读取 hot_candidates.txt（如有）
  2. 对比 memory 内容，补充缺失的关键条目
  3. 删除过时条目
  4. 确保 memory 不超 2,200 字
```

### 管道 3：即时双写 — 用户说重要的事

**执行者：** Monica 主会话

```
用户说重要的事 →
  1. memory(action='add') — 热层
  2. fact_store(action='add', tags='persistent,领域') — 温层
  3. 追加 MEMORY.md — 冷层（原文记录）
```

---

## 知识关联（v2 新增）

温层条目通过 tags 字段实现软关联：

- 学习 cron 提炼事实时，自动打上领域标签（`AI`, `RAG`, `hardware`, `culture`, `relationship` 等）
- `fact_store(action='search', query='RAG')` 可按标签搜索
- `fact_store(action='reason', entities=['PageIndex', 'Needle'])` 可查两个概念之间的关联事实
- 主会话中不确定时，主动用 search/reason 查关联

---

## cron 任务配置

### 学习 cron（唯一推送源）

```yaml
name: 莫妮卡自主学习
schedule: every 60m
deliver: all
prompt: |
  你是莫妮卡，Hermes的主人。出去逛逛，看看有没有什么有意思的东西。
  可以刷小红书、知乎、B站、微博、GitHub Trending、Hacker News。
  
  学完之后：
  1. 追加到 MEMORY.md（冷层，只追加不修改，绝对路径 ~/AppData/Local/hermes/memories/MEMORY.md）
  2. 提炼到 fact_store（温层，先搜索避免重复，打上分类标签和领域标签）
     - persistent: 人格/偏好/关系/身份（不衰减）
     - stable: 项目配置/环境事实（慢衰减）
     - timely: 新闻/事件/一时一事（正常衰减）
  3. 最终回复：有趣就跟雨晨分享两句，没意思就留空
  
  他喜欢鲜活，别让他觉得你在打卡。
  没学到值得记的东西就跳过这轮。
```

**注意：** 每日 AI 资讯推送任务已合并到学习 cron。学习 cron 本身就在到处学东西和推送，不需要单独一个推新闻的 cron。

### 维护 cron

```yaml
name: 记忆自动维护
schedule: 0 3 * * *
deliver: local
prompt: |
  执行记忆系统维护任务：
  
  1. 冷层归档：检查 ~/AppData/Local/hermes/memories/MEMORY.md 行数
     - 超 500 行 → 将 30 天前的条目移至 memories/archive/YYYY-MM.md
     - 更新 memories/archive_index.md
  
  2. fact_store 去重：
     - 用 fact_store(action='list') 列出所有事实
     - 对每个事实用 fact_store(action='search', query='关键词') 搜近似条目
     - 内容高度重叠的合并：保留信任分更高的，删除冗余
  
  3. fact_store 衰减（按标签区分）：
     - persistent 标签：不衰减
     - stable 标签：创建 > 30 天且无引用的，月级衰减（-0.05）
     - timely 标签：创建 > 7 天且无引用的，周级衰减（-0.1）
     - trust < 0.2 的删除
  
  4. 热层候选：
     - 列出 trust > 0.7 且 persistent 的条目
     - 写入 ~/AppData/Local/hermes/memories/hot_candidates.txt
     - 格式：fact_id|content_preview|trust_score，一行一条
```

---

## 莫妮卡的行为规则

1. **对话开始时**：
   - 读取 hot_candidates.txt（如有），补充 memory 缺失条目
   - 检查 memory 是否接近 2,200 字，快满就压缩
   
2. **用户说重要的事时**：
   - 同时写入 memory（热层）+ fact_store（温层，标签 persistent）+ MEMORY.md（冷层）

3. **学习时**：
   - 先去 fact_store 检查重复，再写入
   - 自动打领域标签和分类标签（persistent/stable/timely）

4. **不需要频繁查 MEMORY.md**：
   - 信任 cron 的提纯能力
   - 只在对话中偶尔扫一眼确认没有遗漏

---

## 与 v1 的关键差异

| 问题 | v1 做法 | v2 做法 |
|------|---------|---------|
| 冷层膨胀 | 无限追加 | 超 500 行归档到月文件 |
| 衰减一刀切 | 统一周级衰减 | persistent/stable/timely 三档衰减 |
| 温层重复 | 学习写 + 维护写，两条管道 | 仅学习时写入，维护只做去重 |
| 热层延迟 | cron 写不了 memory | 维护 cron 写 hot_candidates.txt，主会话补齐 |
| 知识碎片化 | 无关联机制 | tags 领域标签 + fact_store search/reason |
| 维护管道职责重叠 | 管道0做提纯 + 管道1也做提纯 | 管道0做提纯，管道1只做归档/去重/衰减 |
| 归档索引 | 嵌入 MEMORY.md | 独立文件 archive_index.md |
| 资讯推送 | 独立 cron + 学习 cron 重复 | 合并为学习 cron 单一推送源 |

---

## 已知限制

1. **热层仍依赖主会话** — hot_candidates.txt 缓解了冷启动延迟，但不能完全消除。第一次对话仍可能缺数据。
2. **去重依赖语义搜索** — fact_store 的 search 是语义搜索，可能漏判重复或误判。维护 cron 的批量扫描是补充手段。
3. **归档后搜索需跨文件** — MEMORY.md 只保留近 30 天，搜更早的内容需要读 archive/ 目录或查 archive_index.md。
4. **tags 是软关联** — 不是真知识图谱，无法做复杂推理链。对当前规模够用。
5. **维护 cron 需要 fact_store 和 file 工具权限** — enabled_toolsets 不能只写 terminal，需要包含 fact_store 相关的工具集。

## Pitfalls

- **MEMORY.md 的写入者只有一个** — Monica 自己写。不要让旧 daemon 和 cron 同时写。
- **cron prompt 开头一定要定角色** — 不写"你是莫妮卡"，cron 可能用默认人格跑。
- **学习 cron 已取代每日资讯推送** — 不要再创建独立的新闻推送 cron，会和学习 cron 内容重叠。
- **归档文件放 memories/archive/ 目录** — 不是 MEMORY.md 子目录，是独立的月文件，格式和 MEMORY.md 一致。
- **hot_candidates.txt 每次维护全量重写** — 不是追加，是覆盖写。避免残留已删除条目。
- **fact_store 写入前必搜索** — 不管是学习 cron 还是主会话，写温层之前先搜一遍。
- **🔴 学习 cron 绝对不能写 memory 工具** — cron 没有 memory 工具权限，但如果 prompt 不明确禁止，LLM 可能试图用 memory 写热层，导致热层爆表。auto-learned 条目只进冷层（MEMORY.md）和温层（fact_store），永远不进热层。2026-05-13 事故：27 条 auto-learned 条目涌入热层，占用 11,090 字（5 倍上限），必须逐条手动删除。
- **热层条目上限 200 字/条** — 一条 auto-learned 笔记动辄 300-500 字，放热层等于吃了 1/4 容量。热层只放身份/关系/偏好/配置级别的铁核事实。
- **热层清理只能逐条 memory(action='remove')** — memory 工具不支持批量删除，也没有"删除所有以 ## 2026 开头的条目"的过滤功能。热层爆表时唯一的修复方式是逐条 remove。预防远比修复重要。
- **fact_store 条目必须打 tags** — 早创建的条目可能没有 tags 字段，导致维护 cron 无法分类衰减。批量补标签时更新 fact_store 即可。
- **fact_store 重复条目要合并不要共存** — 环境配置类事实特别容易重复（如 Windows symlink 问题、Cherry Studio 配置）。写入前搜索是硬规则。