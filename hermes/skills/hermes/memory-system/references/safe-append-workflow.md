# MEMORY.md / fact_store 安全追加工作流

## 问题：用 `patch` 还是 `execute_code` 做大块追加？

| 方案 | 风险 | 适用场景 |
|------|------|----------|
| `patch(old_string, new_string)` | new_string 中的特殊字符（`\|`, `#`, `-`）可能被误解析；多行 old_string 难唯一匹配 | **小修改（<5 行）或末尾追加（old_string 为最后一行）** |
| `patch(replace_all=true)` | ⚠️ 极高风险，匹配所有重复位置，瞬间破坏文件 | **绝对不要用** |
| `execute_code` + `read_file` + `write_file` | 无特殊字符风险，全量写回保证一致性 | **大幅追加的首选方案** |

## 关键发现（2026-05-18）：patch 对末尾追加是安全的

**只要满足两个条件，patch 对末尾追加完全可靠：**

1. **old_string = 文件最后一行**（确保唯一匹配，不会被文件中其他位置误匹配）
2. **new_string = old_string + 新内容**（保留最后一行，在其后插入新内容）

**实战验证：** 本 session 向 MEMORY.md 末尾追加了 ~100 行内容，old_string 选用文件最后一行 `| 2026-05-14 — 我在 Hermes 里搭了一套存在感系统`，new_string 为该行 + 全部新内容。patch 一次成功，零错误。

**所以，对于「末尾追加」场景，patch 是比 execute_code 更简单的方案**——不需要读全文件、不需要 JSON 序列化、不需要处理行号解码。

## 使用 `patch` 做末尾追加的模板

```patch
SELECT:
  old_string: "<文件最后一行>"
  new_string: "<文件最后一行>\n\n§\n\n## YYYY-MM-DD auto-learned: 新内容..."
  # ⚠️ 不要设 replace_all=true
```

**验证步骤：**
```bash
# 写入后用 read_file 确认追加成功
read_file("MEMORY.md", offset=-10)  # 看最后10行
```

## 何时必须用 `execute_code` + Python I/O

- 追加的内容中包含 `|` 作为行首字符（patch 会将其解析为格式标记）
- 需要修改文件中间部分而非末尾追加
- 需要做条件判断（如检查 section 是否已存在再决定是否追加）
- need_string 中包含 JSON 花括号 `{}` 导致 patch 匹配异常

## `execute_code` + Python 文件 I/O 方案（备选）

### 追加到 MEMORY.md

```python
from hermes_tools import read_file, write_file

# 1. 读全文件
content = read_file('/path/to/MEMORY.md')['content']
lines = content.split('\n')

# 2. 剥离 read_file 的行号前缀（如果存在）
# read_file 输出格式：'   N|CONTENT'
import re
def strip_line_prefix(line):
    current = line
    prev = None
    while current != prev:
        prev = current
        current = re.sub(r'^ *\d+\| *', '', current, count=1)
    return current

clean_lines = [strip_line_prefix(l) for l in lines]

# 3. 构造要追加的新内容
new_section = f"""
§

## YYYY-MM-DD auto-learned: 主题

- Insight: Key takeaway.
- Source: https://example.com
"""

# 4. 追加并写回
clean_lines.append(new_section)
write_file('/path/to/MEMORY.md', '\n'.join(clean_lines))
```

### 追加到 fact_store（温层文件，带 section 去重）

```python
from hermes_tools import read_file, write_file

content = read_file('/path/to/facts_YYYY-MM-DD.md')['content']
lines = content.split('\n')

# 检查 sections 是否存在，不要重复创建
has_stable = any('## stable' in l for l in lines)
has_timely = any('## timely' in l for l in lines)

new_facts = []

if not has_stable:
    new_facts.append('\n## stable')
    new_facts.append('- **New stable fact**: description (stable)')

if not has_timely:
    new_facts.append('\n## timely')
    new_facts.append('- **New timely fact**: description (timely)')

# 追加到末尾
content_rstrip = content.rstrip()
content_rstrip += '\n' + '\n'.join(new_facts)
write_file('/path/to/facts_YYYY-MM-DD.md', content_rstrip)
```

## 恢复指南

如果 `patch` 已经损坏了文件：

1. **检测**：检查是否有行首 `|`、重复的章节标题、双写行号
2. **清洗**：用 regex 剥离行号前缀，移除 `|` 行
3. **重组**：用 `write_file` 全量写回

详见 `memory-corruption-recovery.md` 中的「方法 B：清理管道符」和「方法 A：提取+重组」。
