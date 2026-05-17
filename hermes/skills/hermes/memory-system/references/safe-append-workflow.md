# MEMORY.md / fact_store 安全追加工作流

## 问题：为什么不用 `patch` 做大块追加？

| 方案 | 风险 | 适用场景 |
|------|------|----------|
| `patch(old, new)` | new_string 中的特殊字符（`\|`, `#`, `-`）可能被误解析为格式标记；多行 old_string 很难唯一匹配 | 小修改（<5 行），唯一 old_string |
| `patch(replace_all=true)` | ⚠️ 极高风险，匹配所有重复位置，瞬间破坏文件 | **绝对不要用** |
| `execute_code` + `read_file` + `write_file` | 无特殊字符风险，全量写回保证一致性 | **大幅追加的首选方案** |

## 推荐方案：`execute_code` + Python 文件 I/O

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

## 2026-05-18 auto-learned: 网络闲逛记录 — 午后版

### Hacker News 上的意外发现

**Something Interesting** — description here.

- Insight: Key takeaway from today's exploration.
- Source: https://example.com
"""

# 4. 追加并写回
clean_lines.append(new_section)
write_file('/path/to/MEMORY.md', '\n'.join(clean_lines))
```

### 追加到 fact_store（温层文件）

```python
from hermes_tools import read_file, write_file

content = read_file('/path/to/facts_2026-05-18.md')['content']
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

# 或者如果 section 已存在，直接在最后一个条目后面追加
# 找到当前文件末尾位置
content_rstrip = content.rstrip()
content_rstrip += '\n' + '\n'.join(new_facts)
write_file('/path/to/facts_2026-05-18.md', content_rstrip)
```

### 更可靠的方式：完全在 execute_code 内部构建新文件

```python
from hermes_tools import write_file

# 如果文件较小（< 200 行），直接全量构建
new_content = """# 事实 - 2026-05-18 cron 巡检

## persistent
- **CLI-Anything**: description (persistent)

## stable
- **Existing stable**: description (stable)

## timely
- **Existing timely**: description (timely)
"""

write_file('/path/to/facts_2026-05-18.md', new_content)
```

## 恢复指南

如果 `patch` 已经损坏了文件：

1. **检测**：检查是否有行首 `|`、重复的章节标题、双写行号
2. **清洗**：用 regex 剥离行号前缀，移除 `|` 行
3. **重组**：用 `write_file` 全量写回

详见 `memory-corruption-recovery.md` 中的「方法 B：清理管道符」和「方法 A：提取+重组」。
