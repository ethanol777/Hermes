# fact_store.jsonl 预检同步数据丢失事故（2026-05-19）

## 背景

本轮自主学习 cron 执行中，检测到两个 fact_store 副本存在严重发散：

| 副本 | 路径 | 条目 | 行数 | 大小 |
|------|------|------|------|------|
| Hermes | `~/Hermes/hermes/memories/fact_store.jsonl` | fs_119~fs_138 | 20 | ~11KB |
| AppData | `~/AppData/Local/hermes/memories/fact_store.jsonl` | fs_001~fs_118 | 122 | ~52KB |

按照 SKILL.md 中「预检同步」的规则——「比较末尾 ID，大的覆盖小的」——认为 Hermes 版（末尾 fs_138）比 AppData 版（末尾 fs_041）更新，执行了 `cp Hermes→AppData`。

## 事故经过

```
检测到发散 → Hermes 末尾 ID fs_138 > AppData 末尾 fs_041 → 假设 Hermes 更新 → cp 覆盖
                                                                         ↓
                                                          AppData 版 122 条覆盖为 20 条
                                                                         ↓
                                                          102 条历史事实永久丢失
```

## 根因

### 1. 预检同步逻辑的致命缺陷

预检逻辑「比较末尾 ID，大的覆盖小的」对**顺序追加的单向发散**有效——即一个副本拥有另一个的所有条目外加新条目。但本次的两个副本是**双向发散**：

- **Hermes 版**（20条）：仅包含最近 1-2 个 session 的 fs_119~fs_138
- **AppData 版**（122条）：包含过去 5 天所有 session 的 fs_001~fs_118

Hermes 版 fs_138 > AppData 版 fs_041 不意味着 Hermes「更新」——Hermes 版是「较少的条目但编号较大」，AppData 版是「较多的条目但编号较小」。两个副本存储的是**不同时间段的事实集**，非一个超越另一个。

### 2. 行数差异的视觉盲点

20 行 vs 122 行（6 倍差距）本应触发直觉：「不对，这看起来不像是简单的先后手问题。」但预检同步代码只比较了末尾 ID，忽略了行数对比这一步。

### 3. JSONL 文件未受 git 追踪

Hermes 版的 fact_store.jsonl 在 `ls -la` 中可看到，但 Git 仓库的 `git show` 对各 commit 的 fact_store.jsonl 均返回空——文件一直不被 git 追踪。AppData 版则完全没有版本控制。没有 git = 没有恢复点 = 覆盖即永久丢失。

## 损失评估

| 维度 | 影响 |
|------|------|
| 温层索引丢失 | 102 条事实（fs_001~fs_118）的结构化 JSON 从温层消失 |
| 冷层原始笔记 | ✅ 完好——完整内容在 MEMORY.md 的 auto-learned 条目中 |
| 未来 session 检索 | ⚠️ 受影响——温层事实是 FTS5 可检索的，冷层只能 grep |
| 数据可恢复性 | ❌ 无法恢复——无 git、无备份、无 RPO |

**缓解因素：** 事实的原始笔记在 MEMORY.md 冷层中完整保留。损失的是结构化的温层索引，不是原始内容。

## 修复后的规则

### 预检同步：三步判断法

```python
# 步骤 1：获取两个版本的基本信息
hermes_lines = wc_l("~/Hermes/hermes/memories/fact_store.jsonl")
appdata_lines = wc_l("~/AppData/Local/hermes/memories/fact_store.jsonl")
hermes_tail_id = extract_id(tail("~/Hermes/hermes/memories/fact_store.jsonl"))
appdata_tail_id = extract_id(tail("~/AppData/Local/hermes/memories/fact_store.jsonl"))

# 步骤 2：检查行数差异
ratio = max(hermes_lines, appdata_lines) / min(hermes_lines, appdata_lines)
if ratio > 1.2:  # 差异超过 20%
    # ⚠️ 严重发散！不是简单的新旧关系
    # 不要覆盖！执行合并流程：
    # 1. cp old_path old_path.bak（备份老的）
    # 2. cat old new | sort -t, -k1,1 -u > merged（合并去重）
    # 3. 用合并版替换两个副本
    MERGE_REQUIRED = True
elif hermes_tail_id > appdata_tail_id:
    # Hermes 更新（正常追加）→ 复制到 AppData
    COPY_HERMES_TO_APPDATA = True
else:
    # AppData 更新 → 复制到 Hermes
    COPY_APPDATA_TO_HERMES = True
```

### 核心原则

- **不要假设「ID 大 = 更新」** — 双向发散时，两个副本可能是独立增长的不同数据集
- **行数差异 > 20% 必须合并** — 先用 `wc -l` 检查，差异大就 `cat + sort -u` 合并，别直接 cp
- **合并前先备份** — `cp old_path old_path.bak`，至少有一个恢复点
- **永远假设 fact_store 没有版本控制** — 即使有 git，也要确认文件已被追踪（本事故中 fact_store.jsonl 不在 git 中）
- **同步写入策略：每次写入后立即同步** — 不要等到最后统一同步，后处理 session 没有文件工具

## 预防性监控

```bash
# 每次 cron 写事实前，检查两个副本的发散程度
wc -l /c/Users/77/Hermes/hermes/memories/fact_store.jsonl
wc -l /c/Users/77/AppData/Local/hermes/memories/fact_store.jsonl

# 如果差异 > 20%，走合并流程而非覆盖
# 参见 skill pitfall「预检同步「ID 大→覆盖小」逻辑可能导致数据丢失」
```

## 相关文件

- `self-learn-daemon/SKILL.md` — 含「预检同步」pitfall 和「双副本无声发散」pitfall
- `fact_store-jsonl-patch-corruption-incident.md` — 另一类 fact_store 事故（patch 写入损坏）
- `fact_store-tool-vs-direct-write.md` — fact_store 工具 vs 直写的决策指南
- `file-layout-2026-05-19.md` — 实际冷层/温层文件布局
