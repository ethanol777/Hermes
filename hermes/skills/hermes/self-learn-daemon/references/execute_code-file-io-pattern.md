# execute_code 文件 I/O 模式（已降级为备选）

> **⚠️ 2026-05-30 重大更新：** `execute_code` 的 sandbox Python 在某些 session 中整体损坏（`re`、`json`、`encodings` 模块全部 import 失败，`AssertionError: SRE module mismatch`）。**execute_code 不再是可靠的首选方案**。纯 shell 路线（`terminal curl`/`grep`/`cat >>` heredoc）反而更稳定。

## 当前可用工具的可靠性

| 工具 | 状态 | 用途 |
|------|------|------|
| `terminal('curl ...')` | ✅ 稳定 | API 数据采集（GitHub、HN Firebase） |
| `terminal('grep/cat/tail ...')` | ✅ 稳定 | 文件内容读取 |
| `patch` | ✅ 稳定 | MEMORY.md 追加（用唯一 old_string） |
| `terminal cat >> << 'EOF'` | ✅ 稳定 | MEMORY.md 多行追加 |
| `terminal echo '...' >> file` | ⚠️ 仅限纯文本 | JSONL 追加（内容含单引号/撇号会损坏） |
| `execute_code` | ❌ 降级 | stdlib 损坏时不可用 |

## 典型 execute_code 损坏症状

```python
# 本 session 实测：execute_code Python 启动即崩溃
>>> import re
Traceback (most recent call last):
  File "...\re/__init__.py", line 125, in <module>
    from . import _compiler, _parser
  File "...\re/_compiler.py", line 18, in <module>
    assert _sre.MAGIC == MAGIC, "SRE module mismatch"
AssertionError: SRE module mismatch

# json 同理
>>> import json
File "...\json\__init__.py", line 106, in <module>
  from .decoder import JSONDecoder, JSONDecodeError
AssertionError: SRE module mismatch
```

**这意味着 `from hermes_tools import terminal` 路线在 execute_code 损坏时同样不可用。**

## 推荐的纯 shell 替代路线

```bash
# MEMORY.md 追加
terminal('''cat >> '/c/Users/77/Hermes/hermes/memories/MEMORY.md' << 'MONICADATA'
§

## 2026-05-30 auto-learned: [主题]
- Insight: ...
- Source: https://...
MONICADATA''')

# fact_store.jsonl 追加（内容不含单引号时）
terminal("echo '{\"id\":\"fs_188\",\"fact\":\"...\",\"tags\":\"timely,HN\",\"confidence\":0.87}' >> '/c/Users/77/Hermes/hermes/memories/fact_store.jsonl'")
```

## 历史背景

execute_code 曾经是首选方案（2026-05-17 ~ 2026-05-19），因为当时它是隔离在 Hermes venv 中的稳定 Python 环境。但 2026-05-30 发现其 stdlib 可以整体损坏，导致 `re`、`json`、`encodings` 等核心模块全部不可用。这比 MSYS2 Python 的 `encodings` 模块缺失更严重——那是单个模块问题，这是整个运行时损坏。

## 参考

- 写入首选方案：见 SKILL.md 主文档「写入首选方案」章节
- GitHub Trending 解析：见 `references/github-trending-parsing.md`
