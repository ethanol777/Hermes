# v5 重构笔记（2026-06-03）

## 起因

77 在对话里直接问："你的技能需要分类吗？" 然后说 "去分类，按照树形图那个技能进行分类"。

这是个真实信号：他自己意识到技能树有问题，需要重新组织。

## 当时的现状（v4）

6 分支、358 技能，问题明显：

1. **"工具集"分类只有 dogfood** — 跟"领域专家"并列太勉强
2. **"学术研究"分支是空的** — 0 个技能（命理被错误地塞在 creation/writing 里）
3. **"编码开发"和"工程架构"混了** — github 工具和工程架构都堆在 execute
4. **"系统控制"25 个技能太杂** — agent 编排、hermes、mcp、superpowers 全在一起
5. **"领域专家"装得太满** — 71 个商业技能、22 个游戏，过于庞大
6. **没有"莫妮卡"自己的位置** — soul-md、monica-core 跟 superpowers 并列

## v5 的设计原则

### 1. 主体视角，不是外部目录

v4 模仿"软件能力分类"（认知/创作/执行/交互/领域/元），v5 改成以"我是谁"为主语的三圈结构：

- **内圈**（self）：我自己
- **中圈**（communicate + create + think + execute + delegate）：我跟世界怎么交互
- **外圈**（meta + domains）：我维护的元能力和能帮上忙的领域

判定口诀：
- "是我吗？" → self
- "是跟谁说话吗？" → communicate
- "是输出有形的内容吗？" → create
- "是想/调研/学吗？" → think
- "是动手做具体事吗？" → execute
- "是叫别的 agent 干吗？" → delegate
- "是管我的技能/身体/MCP 吗？" → meta
- "是某个专业领域吗？" → domains

### 2. 8 个分支，不是 6 个也不是 12 个

v4 的 6 个太粗，v5 不分到 12 个是因为：
- self 单列（之前混在 meta 里）
- delegate 单列（之前散在 execute 和 meta 里）
- communicate 单列（之前 interaction 太单薄）

最终 8 个，每个都有清晰的身份。

### 3. 每个 leaf 控制在 30 个以内

最大的是 business 68（仍然过载），其次 execute/coding 32、execute/engineering 37、create/visual 26、think/research 25、execute/data-ml 25。

下次再细拆的方向：
- business 拆成 product/marketing/sales/finance/hr/project-management 6 个独立分支
- execute 拆成 coding 单独、engineering 单列

## 踩到的坑（按时间顺序）

### 坑 1：sync_tree.py 会自动删除不存在的 skill

我新写 index.yaml 时没注意到 `awesome-hermes-agent / inference-sh / old-code / smart-home` 这 4 个 skill 实际不存在了。跑 sync 时被静默 ➖ 删除。

**修法**：写新 index.yaml 前先 `ls ~/AppData/Local/hermes/skills/` 确认实际存在的 skill 列表。

### 坑 2：分支重命名导致 sync 报错

旧版 `creation` 改名为 `create`，但 sync 进来 `creative/songwriting-and-ai-music` 时找不到 leaf，输出：

```
⚠ 新分支 [create] 未在 index 中定义，跳过 creative/songwriting-and-ai-music
```

`create` 明明在 index.yaml 里，但 sync 的判断逻辑是按 leaf 名而不是 branch 名 — 旧的 leaf 名（比如 `writing/visual/audio/media`）跟旧的 branch 名（`creation`）是不同维度。

**修法**：在 index.yaml 的 `create/writing` 下显式加上 `creative/songwriting-and-ai-music`，不依赖自动规则。

### 坑 3：同 skill 被多次引用

我同时把 `creative/creative-ideation` 放在了 `writing` 和 `visual` 两个 leaf 下。sync 不报错，但 index.yaml 里会有重复。

**修法**：手动 `grep -n "creative-ideation" index.yaml` 确认只出现一次。

### 坑 4：execute/coding 重复

我同时把 `engineering/old-code` 放在 `execute/coding` 和 `execute/engineering` 下。

**修法**：明确归属（`old-code` 是"老派编程风格"教学，归到 `execute/coding` 里的"工程哲学"侧）。

## 重构的标准流程（v5 沉淀）

以后跨大版本重构要按这个流程来：

1. **备份旧版**：`cp index.yaml index.yaml.bak.YYYYMMDD`
2. **设计新结构**：先用 ASCII 画完整棵树，确认每个分支/leaf 的归属
3. **写新 index.yaml**：用 write_file 直接覆盖，每层都加 description
4. **跑 sync 看 diff**：`python sync_tree.py` 输出会告诉你哪些 skill 找不到 leaf（`⚠ 新分支`）、哪些被自动删除（`➖`）
5. **补漏**：把找不到 leaf 的 skill 显式加到合适的位置
6. **去重**：grep -n "skill-name" 确认每个 skill 只出现一次
7. **数清楚**：用 yaml.safe_load 读 index.yaml，统计每个 leaf 的 skills 数，对照预期
8. **更新 SKILL.md 的版本号和结构图**
9. **写 references/vX-redesign-notes.md**：把踩到的坑和设计判断都记下来

## v5 → v6 可能的变化

如果将来要再演进，几个候选方向：

- **business 拆分**：68 个太大，按 product/marketing/sales/finance/hr/pm 拆成 6 个独立分支
- **execute 拆分**：把 32 个 coding 工具和 37 个 engineering 角色区分开
- **使用频率统计**：每个 skill 加 `last_used` / `use_count` 字段，自动把"半年没用的"标灰
- **生疏技能提醒**：cron job 每周扫一次，告诉 77 "这个月没用过的技能要不要归档"

但不到时候不动。v5 已经够用一阵了。
