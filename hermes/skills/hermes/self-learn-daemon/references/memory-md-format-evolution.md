# MEMORY.md 格式演变与不一致性

## 问题

MEMORY.md 的 line-prefix 格式在 cron 历史的多个 session 中不一致。早期条目（~2026-05-14）使用纯 markdown 格式（`## 标题`），后期条目（~2026-05-19+）开始带有 `|` 前缀（`|## 标题`）。这导致：

1. **patch old_string 匹配困难**：不知道文件有多少 `|` 前缀时，写的 old_string 可能匹配失败
2. **追加时格式选择困难**：新追加的条目该不该加 `|` 前缀？
3. **格式污染风险**：追加了一个带 `|` 的条目后，下一次追加时看到这个条目，会以为「文件就是用 `|` 前缀的」，继续添加 `|`，固化不一致性

## 根因

混乱来自 `read_file` + `patch` 两个因素叠加：

1. `read_file` 返回格式为 `LINE|CONTENT|`（如 `  1800|## 标题`），其中 `|` 既是行号分隔符也在内容中出现
2. 早期 session 用 `patch` 追加时，直接复制了 read_file 输出中的 `|##` 作为 old_string 的前缀——而 `patch` 匹配的是实际文件内容，在文件没有 `|` 前缀时匹配失败；在文件有 `|` 前缀时匹配成功
3. 后期 session 改用 Python `open().read()` 直接读写文件，能看到真实的纯文件内容，但为了「格式匹配」，主动加上了 `|` 前缀——导致新条目带 `|` 而旧条目不带

## 当前状态（2026-05-19）

```
行号范围   格式                   来源
───────────────────────────────────
1738-1760  ## 标题 (无|前缀)     早期 cron session，patch 追加
1779-1797   |## 标题 (有|前缀)   中期 cron session，Python I/O 追加（主动加了 |）
1800+       |## 标题 (有|前缀)   本次 session，Python I/O 追加（主动加了 |）
```

## 处理策略

### 追加新条目时

```python
# 不要猜！先检查文件最后一节条目的格式
with open('MEMORY.md', 'r') as f:
    lines = f.readlines()

# 找到最后一个 auto-learned 条目，看前缀格式
for i in range(len(lines)-1, -1, -1):
    if '## ' in lines[i] and ('auto-learned' in lines[i] or '今天真正打动' in lines[i]):
        last_heading = lines[i]
        print(f"Last heading format: {repr(last_heading[:20])}")
        # 确定前缀风格：如果以 |## 开头则用 pipe，如果以 ## 开头则不用
        has_pipe = last_heading.lstrip().startswith('|')
        break

# 追加时统一使用检测到的格式
prefix = '|' if has_pipe else ''
new_line = f'{prefix}## {date} auto-learned: {topic}\n'
```

### 长期方案

不需要「修复」历史不一致性——两种格式的条目都能正常被 grep、read_file、Python 解析。真正的问题只在「追加时选择什么格式」。所以：

- 追加新条目时，**保持与最近条目一致的格式**
- 如果最近带 `|`，新条目也带 `|`
- 反过来如果后续某个 session 把格式改回去了（去掉 `|`），也保持一致
- **不要在同一个追加批次中混用两种格式**

### 避免走的弯路

- ❌ 不要尝试全量重写 MEMORY.md 来统一格式——文件太大，全量重写风险高
- ❌ 不要用 `patch(replace_all=true)` 来「把旧条目前面加 `|`」——会破坏文件结构
- ❌ 不要为了「修复」格式浪费多轮 cron 的资源——用户只看内容，不介意 `|` 有没有
