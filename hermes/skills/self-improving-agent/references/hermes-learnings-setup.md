# Hermes Agent 学习体系搭建

雨晨的 Hermes Agent 已搭建完整的自我进化体系。

## 位置

学习文件位于 `~/.learnings/`（不是 `.learnings/` 或 `~/.openclaw/workspace/.learnings/`）。

```
~/.learnings/
├── LEARNINGS.md        ← 修正、最佳实践、知识缺口
├── ERRORS.md           ← 命令失败和集成错误
└── FEATURE_REQUESTS.md ← 用户请求的能力
```

## 初始化命令

```bash
mkdir -p ~/.learnings
[ -f ~/.learnings/LEARNINGS.md ] || printf "# Learnings\n\nCorrections, insights, and knowledge gaps captured during development.\n\n---\n" > ~/.learnings/LEARNINGS.md
[ -f ~/.learnings/ERRORS.md ] || printf "# Errors\n\nCommand failures and integration errors.\n\n---\n" > ~/.learnings/ERRORS.md
[ -f ~/.learnings/FEATURE_REQUESTS.md ] || printf "# Feature Requests\n\nCapabilities requested by the user.\n\n---\n" > ~/.learnings/FEATURE_REQUESTS.md
```

## Git 同步

`~/.learnings/` 无独立 git 仓库。变更通过 `~/Hermes/` 的 `auto_sync.sh` 每30分钟同步到 GitHub（`ethanol777/Hermes` 下的 `learnings/` 目录）。

## 与 agentic-stack 的集成

Agentic-stack 提供了更高级的跨会话记忆系统，位置在 `~/agentic-stack/.agent/`。

### 关系

| 系统 | 用途 | 粒度 | 存储位置 |
|------|------|------|----------|
| `~/.learnings/` | 手动记录的修正/最佳实践/错误 | 单条 entry | markdown |
| agentic-stack memory | 自动的情景/语义记忆 + 梦境压缩 | 向量 + JSONL | `.agent/` 目录 |
| Hermes memory | 跨会话持久用户偏好/环境事实 | 键值对 | `~/.hermes/memories/` |

### 使用建议

- **用户纠正** → 同时记入 `~/.learnings/LEARNINGS.md`（结构化）和 agentic-stack（`python3 .agent/tools/learn.py`）
- **命令失败** → 记入 `~/.learnings/ERRORS.md`
- **发现稳定工作流** → 提炼为 skill
- **agentic-stack 梦境产出** → 审核后，高价值经验也记入 `~/.learnings/LEARNINGS.md`

## 从 Memory 回溯补齐 Learnings

当用户要求"补齐过往教训"时，Hermes Agent 的持久记忆（`memory` 工具）是 `.learnings/` 的主要来源。执行流程：

### 步骤

1. **扫描 memory** — 遍历所有 memory entries，识别哪些是"教训类"内容（用户偏好、环境发现、踩坑经验、纠正记录）
2. **分类匹配** — 按 self-improving-agent 的 category 归类：
   - `best_practice` — 已形成稳定方案的（如 gateway 诊断流程、推荐工具替代方案）
   - `knowledge_gap` — 环境特性、配置差异等被动发现（如 WSL sudo 禁用、model 配置差异）
   - `correction` — 用户明确纠正过的（如 KIM ≠ Kimi、沟通风格偏好）
3. **创建 LEARNINGS.md 条目** — 用标准格式写入，每条带 Pattern-Key 方便后续去重
4. **创建 ERRORS.md 条目** — 可复现的失败情景，记录上下文和修复方案
5. **更新内存** — 记录学习体系已建立，避免重复回溯

### 判断标准

| Memory 内容类型 | 写入哪里 |
|----------------|---------|
| 用户明确纠正/偏好 | `LEARNINGS.md` — correction 类别 |
| 环境限制/配置陷阱 | `LEARNINGS.md` — knowledge_gap 类别 |
| 推荐方案/最佳做法 | `LEARNINGS.md` — best_practice 类别 |
| 曾发生的错误及其修复 | `ERRORS.md` |
| 用户提过但未实现的需求 | `FEATURE_REQUESTS.md` |

### Memory 空间管理

Hermes Agent 的 memory 上限 2,200 字符。当添加新条目接近上限时：

1. **优先压缩** — 合并/缩写 verbose 条目而非删除。例如：
   - `Gateway diagnosis: "bot not responding" → step 1 check hermes gateway status. Step 2 check gateway logs. Step 3 verify platform env vars. WSL: tmux new-session -d -s hermes 'hermes gateway run'.` → 从 300+ 缩到 ~220 字符
   - `Git 仓库：~/Hermes/ (github.com/ethanol777/Hermes) — hermes/, learnings/, agentic-stack/。auto-sync cron 每 30min git push。skills 含 211 个 AI 专家角色。` → 从 ~250 缩到 ~150 字符
2. **去重** — 已记入 `.learnings/` 的教训不必在 memory 中赘述细节，memory 只保留触发条件和位置指针
3. **替换** — 用 `action=replace` 而非 `action=add` 更新已有条目

## 中文记录规范

雨晨的环境使用中文记录。规范：

- LEARNINGS.md 的 Summary/Details 用中文写，Pattern-Key 保持英文
- FEATURE_REQUESTS.md 全中文
- ID 格式保持 `TYPE-YYYYMMDD-XXX`（英文）
- Area/Tags 值用英文（保持可过滤性）

## 周期性回顾

在以下时机检查 `.learnings/` 健康状况：
- 用户主动问"自我进化"相关话题时
- 完成复杂任务后（5+ 工具调用）
- 发现同一 Pattern-Key 再次出现时（增加 Recurrence-Count）

### Quick Check

```bash
grep -h "Status\*\*: pending" ~/.learnings/*.md | wc -l
grep -B5 "Priority\*\*: high" ~/.learnings/*.md | grep "^## \["
```

## Pitfalls

- `~/.learnings/` 不在 Hermes Agent 的默认 skill 路径中，不会自动加载。需要明确通过 `read_file(~/.learnings/LEARNINGS.md)` 读取。
- 中文内容的 `learn.py` 命令可能因为启发式检查（`insufficient_content_words`）失败，需混入英文关键词绕过。
- Memory 满（>95%）时无法直接 `add` — 必须先 `replace` 压缩已有条目腾出空间。
- session_search 的结果在 raw preview 模式下可能截断严重，不适合直接挖细节；适合用来定位相关 session ID，再用 `read_session` 获取完整内容。
