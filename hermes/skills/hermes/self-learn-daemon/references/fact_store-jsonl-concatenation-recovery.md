# fact_store.jsonl JSON 拼接损坏恢复（2026-05-19）

## 损坏模式

**症状：** 同一行上有两个 JSON 对象直接拼接，没有换行分隔。
```
...0.92}{"id": "fs_162", "fact": "...}
```

**文件表现：**
- `read_file` 显示两行数据被显示为一行，中间以 `}{` 连接
- JSON 解析器遇到 `}{` 会抛出异常，因为这不是合法的 JSON
- `tail -N` 看到的行数少于实际对象数
- 用 `wc -l` 统计行数 < 实际 JSON 对象数

**根因：** 
- 用错误的追加方法写入 JSONL（如 `echo ... >>` 中遗漏了 `\n`，或 fact_store tool 自身 bug）
- 两个 cron session 近乎同时写入，产生了竞态条件导致换行符丢失
- 不正确的 `patch` 操作将两行内容拼接到了一起

## 检测方法

```python
import json

with open('fact_store.jsonl', 'r', encoding='utf-8') as f:
    lines = f.readlines()

objects_found = 0
for i, line in enumerate(lines, 1):
    stripped = line.strip()
    if not stripped:
        continue
    try:
        json.loads(stripped)
        objects_found += 1
    except json.JSONDecodeError:
        print(f"⚠️ Line {i}: JSON parse error — likely concatenation corruption")
        print(f"   Preview: {stripped[:80]}...")
        # Check for }{ pattern
        if '}{' in stripped:
            print(f"   Confirmed: concatenation pattern found (}}{{ on same line)")
```

或者更简单的方式：看 `read_file` 输出的行内容里是否有 `}{` 出现在一起。

## 恢复流程（2026-05-19 实战验证）

### 步骤 1：读取所有行，深度解析

```python
path = "C:/Users/77/AppData/Local/hermes/memories/fact_store.jsonl"

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Split into lines
raw_lines = content.split('\n')

# Process each line: if corrupted, split by depth-tracking
all_entries = []
for line in raw_lines:
    line = line.strip()
    if not line:
        continue
    
    # Use brace-depth tracking to split concatenated objects
    result = []
    depth = 0
    buf = ''
    for ch in line:
        buf += ch
        if ch == '{':
            depth += 1
        elif ch == '}':
            depth -= 1
            if depth == 0:
                # End of a complete JSON object
                result.append(buf)
                buf = ''
    
    for item in result:
        if item.strip():
            all_entries.append(item)
```

### 步骤 2：解析并去重

```python
entries_by_id = {}
for item in all_entries:
    try:
        entry = json.loads(item)
        eid = entry.get('id')
        if eid in entries_by_id:
            print(f"DUPLICATE ID: {eid} — keeping first occurrence")
        else:
            entries_by_id[eid] = entry
    except json.JSONDecodeError as e:
        print(f"PARSE ERROR: {e} for: {item[:80]}...")
```

### 步骤 3：重写文件

```python
with open(path, 'w', encoding='utf-8') as f:
    for eid in sorted(entries_by_id.keys(), key=lambda x: int(x.split('_')[1])):
        f.write(json.dumps(entries_by_id[eid], ensure_ascii=False) + '\n')
```

### 步骤 4：验证

```python
# Verify: count objects in rewritten file
with open(path, 'r', encoding='utf-8') as f:
    final_count = sum(1 for line in f if line.strip())
    
print(f"Before repair: {len(all_entries)} raw objects found")
print(f"After dedup:   {len(entries_by_id)} unique entries")
print(f"Written:       {final_count} lines in file")

# Check the last entry's ID
with open(path, 'r', encoding='utf-8') as f:
    for line in f:
        pass
    last = json.loads(line.strip())
    print(f"Last entry ID: {last['id']}")
```

## 与其它损坏模式的区别

| 损坏模式 | 症状 | 修复方法 |
|---------|------|---------|
| JSON 拼接（本事故） | 一行上有 `}{` | 深度解析 + 拆分 |
| patch 截断（2026-05-18） | 行首丢失、引号转义 | 局部 patch 修复 |
| 预同步覆盖丢失（2026-05-19） | 整个文件的历史数据被短文件覆盖 | 从冷层恢复 |
| 重复 ID（常见） | 有序 JSONL 中出现 `fs_NNN` 两次 | 删掉多余行或 sort -u |

## 预防

1. **永远只追加 JSONL 文件**，用 `execute_code` + Python `open(path, 'a')`，不要用 shell echo
2. 追加后用 `wc -l` 验证行数等于预期新增条数
3. 定期做完整性检查：所有行都能被 `json.loads` 解析
4. 不要让两个进程同时写入同一个 JSONL 文件
