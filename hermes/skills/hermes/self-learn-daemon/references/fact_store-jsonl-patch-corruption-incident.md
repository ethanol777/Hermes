# fact_store.jsonl patch 损坏事故记录（2026-05-18）

## 背景

本 session 是一次自主学习 cron 执行。在成功用 `patch` 向 MEMORY.md 追加了 8 条 auto-learned 条目后，试图用同样的方法向 fact_store.jsonl 追加 2 条新事实。

## 事故经过

### 第一次 patch 调用

```python
patch(
  path="C:/Users/77/Hermes/hermes/memories/fact_store.jsonl",
  old_string='retro","confidence":0.92}',
  new_string='retro","confidence":0.92}\n{...}\n{...}'
)
```

**问题：** old_string 是 JSON 行内的尾端子串，不是完整 JSON 行。

### 实际结果

patch 替换了从该尾端子串到行尾的部分，导致：

1. **fs_106 行首丢失**：原本以 `{"id":"fs_106","fact":"...` 开头的 JSON 行被截断为 `retro","confidence":0.92}` — 行首全部消失
2. **引号双重转义**：new_string 中的 `"` 被转义为 `\"`，JSON 格式损坏
3. **数据不可读**：后续读取时该 JSON 行无法被解析

### 修复过程

第二次 patch 调用修复了转义问题，但需要再修一次 fs_106 行首丢失。最终修复：

```
old_string = `"confidence": 0.87}\nretro","confidence":0.92}\n{转义版本 fs_107}\n{转义版本 fs_108}`
new_string = `"confidence": 0.87}\n{"id":"fs_106","fact":"原始的完整JSON行..."}\n{"id":"fs_107",...}\n{"id":"fs_108",...}`
```

一共用了 **2 次 patch + 3 次 read_file 验证** 才修复。

## 根因

1. **loaded the skill but didn't load the FULL skill** — `self-learn-daemon` 的 SKILL.md 在 available_skills 列表中可见，但**没有主动调用 `skill_view()` 加载全文**。导致文件中的「🔴 永远不要用 patch 追加或修改 fact_store.jsonl」警告未被看到。
2. **MEMORY.md patch 成功产生的错觉** — `patch` 对 MEMORY.md 的末尾追加一次成功（old_string = `§\n| 2026-05-14 — ...`），自然想复用同一模式到 JSONL。忽略了 markdown 和 JSONL 在 patch 行为上的根本差异。
3. **old_string 选择错误** — MEMORY.md 的 old_string 是完整的文件最后一行（包含换行的上下文），而 JSONL 的 old_string 选择了一个行内尾端子串。前者的匹配范围是整个文件最后一行，后者在行内开始匹配。

## 教训

### 硬规则

- **绝对不要用 `patch` 追加或修改 fact_store.jsonl** — 即使 old_string 唯一。本事故证明 old_string 唯一也不能保证行结构完整。
- **MEMORY.md 可以用 `patch` 做末尾追加**（`safe-append-workflow.md` 已验证），但**不要把这个模式延伸到 JSON 文件**。

### 推荐方案

| 场景 | 推荐方法 |
|------|---------|
| MEMORY.md 末尾追加 | `patch(old_string=文件最后一行)` ✅ 经过本 session 验证（8 条内容，~60 行） |
| fact_store.jsonl 追加 | `execute_code` + Python `json.dumps` + `open('...', 'a')` ✅ 零转义问题 |
| 不确定用什么 | `execute_code` + Python I/O 始终是安全的 |

### 加载纪律

`self-learn-daemon` 的警告和操作指南**都在 SKILL.md 里**，只有主动 `skill_view()` 才能看到。本 session 的根因不是「读了警告但违反」，而是「没加载 skill 所以没读到警告」——这是系统性的加载纪律失败。

## 恢复步骤（如果再次发生）

1. 检测：`read_file(fact_store.jsonl, offset=-5)` 看最后几行
2. 判断损坏类型：截断 / 转义 / 重复
3. 修复方法：
   - **截断 + 转义**（本事故）：构造包含完整 fs_NNN 行的 new_string，用 `patch` 替换损坏部分
   - **重复 ID**：删掉多出的行
   - **格式完全损坏**：用 `execute_code` + Python `json.dumps` 全量重写文件

## 相关文件

- `safe-append-workflow.md`（memory-system skill）— 安全追加的通用指南
- `fact_store-tool-vs-direct-write.md`（self-learn-daemon skill）— fact_store 工具 vs 直写的决策
- `execute_code-file-io-pattern.md`（self-learn-daemon skill）— execute_code Python I/O 方案
