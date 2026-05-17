# MEMORY.md 损坏恢复指南

**适用场景：** patch 操作（尤其是 `replace_all=true`）导致 MEMORY.md 内容重复、管道符窜入、条目丢失。

## 检测

### 重复条目检测

```bash
grep -n 'auto-learned:' <path_to_MEMORY.md>
```

如果同一标题出现多次，说明文件有重复块。

### 管道符污染检测

```bash
grep -n '^|' <path_to_MEMORY.md>
```

正常 MEMORY.md 的条目以 `- ` 开头（`- Insight:`, `- Source:`, `- Platform:`），不应有行首 `|`。

### 条目丢失检测

对比 grep 数量与预期数量。如果某个已知条目不在 grep 输出中，可能在 sed 恢复时被误删。

## 修复

### 方法 A：提取+重组（`sed -n` + `cat`）

适用于：知道哪些行范围是正常的、哪些是重复的。

```bash
# 1. 找到所有 auto-learned 行号和内容
grep -n 'auto-learned:' MEMORY.md

# 2. 确定原始段落的行号范围
# 假设原始内容为 1-56 行，第二个原始段为 102-199 行
# 中间 57-101 行是重复块

# 3. 提取干净段并重组
sed -n '1,56p' MEMORY.md > MEMORY_new.md
sed -n '102,199p' MEMORY.md >> MEMORY_new.md
mv MEMORY_new.md MEMORY.md

# 4. 验证
grep -n 'auto-learned:' MEMORY.md  # 检查无重复
wc -l MEMORY.md                     # 确认行数合理
```

### 方法 B：清理管道符（`sed`）

适用于：条目内容本身正确但被 `|` 管道符污染。

```bash
# 修复双管道符 → 单管道符（只影响行首的 |）
sed -i 's/^||- /|- /g' MEMORY.md

# 修复单管道符 → 无管道符
sed -i 's/^|- /- /g' MEMORY.md

# 验证
grep -n '^|' MEMORY.md  # 应为空
```

### 方法 C：修复缺失的 `§` 分隔符

管道符清理后可能出现条目之间没有 `§` 分隔符（条目直接连着下一个条目标题）。

```bash
# 找到缺失 § 的位置 — 条目之间只有空行没有 §
grep -nB1 '^## ' MEMORY.md | grep -v '^\-\-$' | grep -v '§'
```

手动用 `patch` 或 sed 补上 `§`。

## 预防

### 用 `patch` 时避免 replace_all

- `replace_all=true` 会匹配文件中所有出现 `old_string` 的位置
- MEMORY.md 有很多重复片段（`- Platform: GitHub Trending` 出现多次）
- **除非确定 old_string 在所有匹配位置都该被替换，否则不要用 replace_all**
- 更好的做法：用文件**最后一行**作为 old_string，确保唯一匹配

### 用 `read_file` 前先确认缓存的版本

`read_file` 有 dedup 缓存：如果文件在上次读取后没变化，返回 `content_returned: False`。如果你在 offset/limit 模式下读取过文件的部分内容，后续的 `patch` 操作会收到 `_warning` 提示。

**正确做法：** 在 patch 之前，用 `read_file` 读取文件**全部内容**（不设 offset/limit），确认拿到最新版本，然后再 patch。

### 用 `terminal sed` 代替 `patch` 进行尾部追加

详见 self-learn-daemon skill 的「推荐：`terminal cat >>` + heredoc 追加模式」章节。

## 事故案例：2026-05-17

**触发条件：** `patch(MEMORY.md)` 使用 `replace_all=true`，old_string 为 `- Platform: GitHub Trending (579⭐)`，该字符串在文件中出现 5 次。

**损害：** 5 个位置都追加了新条目块，导致 4 个完整的新条目被重复 4 次。同时旧条目的 Platform 行被修改（添加了 `|` 前缀和 `(579⭐)` 后缀）。

**恢复步骤：**
1. `grep -n` 确认重复范围和数量
2. `sed -n` 提取干净段，分 4 片重组
3. `sed` 清理管道符
4. 逐个 patch 补回丢失的条目（html-anything）
5. 逐个 patch 修复 `§` 分隔符和条目标题

**耗时：** ~20 分钟。预防比修复省 100 倍时间。
