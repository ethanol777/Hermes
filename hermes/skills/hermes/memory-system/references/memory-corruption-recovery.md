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

---

## fact_store.jsonl 损坏恢复

**适用场景：** `patch` 操作（即使使用文件末尾的唯一字符串作为 `old_string`）导致 JSONL 行被截断或内容错位。

### 与 MEMORY.md 恢复的关键区别

| 维度 | MEMORY.md | fact_store.jsonl |
|------|-----------|-----------------|
| 内容 | 多行 markdown 段落 | 每行一个独立 JSON 对象 |
| 行格式 | 每行是段落的一部分 | **每行必须是一个完整的 JSON 对象** |
| patch 风险 | 重复条目/管道符污染 | 单行被截断 → 整个 JSONL 文件不合法 |
| 恢复方式 | sed 提取/重组段落 | 替换损坏行 / 删除后补写 |

### 检测

```bash
# 尝试解析 JSON 检查完整性
python3 -c "import json; lines = open('fact_store.jsonl').read().strip().split('\n'); errors = [(i, l[:80]) for i,l in enumerate(lines,1) if not l.startswith('{') or not l.endswith('}')]; print(f'{len(lines)} lines, {len(errors)} errors'); [print(f'  L{n}: {t}') for n,t in errors[:5]]"

# 检查 ID 是否连续
python3 -c "
import re
lines = [l for l in open('fact_store.jsonl').read().strip().split('\n') if l]
ids = [re.search(r'\"id\": \"(fs_\d+)\"', l).group(1) for l in lines if re.search(r'\"id\": \"(fs_\d+)\"', l)]
nums = [int(i.split('_')[1]) for i in ids]
gaps = [(nums[i-1], nums[i]) for i in range(1, len(nums)) if nums[i] != nums[i-1] + 1]
print(f'{len(lines)} lines, {len(set(nums))} unique IDs')
if gaps: [print(f'  Gap: {a} -> {b}') for a,b in gaps]
"
```

### 修复

#### 方法 A：替换损坏行（首推）

```bash
# 用 Python 精确修复 — JSONL 内容含引号，python 比 sed 安全
python3 -c "
lines = open('fact_store.jsonl').read().strip().split('\n')
n = 91  # 替换为实际行号（1-indexed）
correct_line = '{\"id\": \"fs_109\", \"fact\": \"...完整内容...\", \"date\": \"...\"}'
lines[n-1] = correct_line
open('fact_store.jsonl', 'w').write('\n'.join(lines) + '\n')
print('Fixed line', n)
"
```

#### 方法 B：删除损坏行后补写

```bash
# 删除第 N 行
sed -i '91d' fact_store.jsonl
# 然后用 json.dumps 补写该行
python3 -c "import json; open('fact_store.jsonl','a').write(json.dumps({'id':'fs_109', ...}, ensure_ascii=False)+'\n')"
```

#### 方法 C：从另一个副本恢复

```bash
cp /c/Users/77/Hermes/hermes/memories/fact_store.jsonl /c/Users/77/AppData/Local/hermes/memories/fact_store.jsonl
# 再补写当前 session 新加的行
```

### 修复案例：2026-05-18

**触发条件：** `patch(fact_store.jsonl, old_string='"learning\\", "confidence": 0.9}')` — 使用 JSONL 最后一行末尾的字符串片段。

**损坏：** fs_109 整行 JSON 被截断为 `"learning", "confidence": 0.9}` — 行首内容丢失。fs_110 被正确追加在被截断的行之后。

**根本原因：** patch 的 `old_string` 匹配到 JSONL 行内的子串后，替换了**从该位置到行尾的全部内容**而非仅替换子串本身，导致行首丢失。

**恢复：** 将截断行 + 新增行一起替换为正确的完整两行。

**教训：不要在 JSONL 上用 `patch` 做追加。** 始终用 `execute_code` + Python `json.dumps` + `open().write()` 模式（见 self-learn-daemon skill 的 `### ✅ execute_code + Python 原生文件 I/O：JSONL 批量追加的首选方案` 章节）。

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
