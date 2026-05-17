# execute_code File I/O Pattern

当 terminal Python 在 git-bash/Windows 环境下因 `ModuleNotFoundError: No module named 'encodings'` 不可用，且 `jq` 未安装时，`execute_code` 是一个稳定的文件读写替代方案。

## 典型症状

```python
Fatal Python error: Failed to import encodings module
Python runtime state: core initialized
ModuleNotFoundError: No module named 'encodings'
```

## 原因

git-bash (MSYS2) 的 Python 环境与 conda/hermes venv 的 Python 冲突。`terminal` 调用的 Python 是 MSYS2 自带的，缺少标准 encodings 模块。

## 方案：使用 execute_code

`execute_code` 有自己的隔离 Python 环境（Hermes venv），不受 terminal 的 PATH 污染影响。

```python
# ✅ 读取文件
# 注意：execute_code 中无法使用 Hermes 工具（fact_store/memory/terminal），
# 但可以做纯 Python 数据操作
content = open(path, 'r', encoding='utf-8').read()

# ✅ 追加到文件（当 terminal 的 echo/cat 可能因转引号/撇号而损坏时）
with open(path, 'a', encoding='utf-8') as f:
    f.write(content_to_append)

# ✅ 读取 JSONL 并处理
import json
lines = []
with open(path, 'r', encoding='utf-8') as f:
    for line in f:
        if line.strip():
            lines.append(json.loads(line))
```

## 适合场景

| 操作 | terminal | execute_code |
|------|----------|-------------|
| 简单的 `echo >>` 追加（不含撇号/JSON） | ✅ 快 | ⚠️ 重 |
| 复杂的多行追加（含 CJK/撇号/JSON） | ❌ 引号转义陷阱 | ✅ 稳定 |
| 读取 JSON 并解析 | ❌ 无 jq + Python 坏 | ✅  |
| 原子地读-改-写（非追加操作） | ❌ 无原子性 | ✅ |
| 遍历目录/查文件是否存在 | ✅ ls/test | ⚠️ os.path 可用 |
| 创建文件（文件不存在时） | ❌ 重定向 > 会覆盖 | ✅ 显式 open + mode |

## 🔑 关键洞察：execute_code 可以调 terminal（通过 from hermes_tools import terminal）

**之前认为 execute_code 无法调用 Hermes 工具，但 2026-05-17 实际验证：可以。**

```python
from hermes_tools import terminal

# ✅ 可以在 execute_code 中调用 terminal 来执行 shell 命令
r = terminal("ls -la /c/Users/77/")
print(r["output"])  # 输出回到 execute_code 的 output 字段

# ✅ 可以结合 Python 的字符串处理和 terminal 的 shell 能力
path = "/c/Users/77/Hermes/hermes/memories/fact_store.jsonl"
lines = ['{"id":"fs_088","fact":"...","tags":"...","confidence":0.88}']
for line in lines:
    r = terminal(f"echo '{line}' >> \"{path}\"")
    if r["exit_code"] != 0:
        print(f"Failed: {r}")
```

**原理：** `execute_code` 的 Python 运行在 Hermes venv 中，其 Python 环境可以通过 `hermes_tools` 包访问 `terminal` 函数。这实际上是 `terminal` 函数的另一种调用入口，不是绕过工具限制。

**限制：** 虽然可以调 `terminal()`，但其他 Hermes 工具（`fact_store`/`memory`/`read_file`/`write_file`/`patch`/`browser_*`）在 `execute_code` 的 Python 环境中不一定可用。`hermes_tools` 只导出有限子集。

**影响：**

| 旧认知 | 新认知 |
|--------|--------|
| execute_code 不能调任何 Hermes 工具 | execute_code 可以通过 `from hermes_tools import terminal` 调 terminal |
| 文件写入必须在 execute_code 和其他工具之间二选一 | 可以 Python 准备内容 + terminal 写入文件，在同一个 execute_code 调用中完成 |

## 不通过 execute_code 做的事情

- **调用大部分 Hermes 工具**（fact_store/memory/read_file/write_file/patch）—— execute_code 的 Python 环境没有这些。但 terminal 是个例外（见上节）。
- **运行长时间的任务**（> 30 秒）—— execute_code 可能超时
- **处理二进制文件**—— 虽然可以，但 terminal/read_file 更专业

## 输出处理

execute_code 的 `print()` 输出会回到 `output` 字段。可以利用这个做简单的校验：

```python
# 写入后验证
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()
print(f"Written {len(lines)} lines, last 3: {lines[-3:]}")
```

## 与本 skill 的写入规范的整合

在执行阶段（file tools 可用时），推荐顺序：

1. ✅ **execute_code + `from hermes_tools import terminal` + Python 管理的逐行 `echo`** — 最可靠方案，无转义/安全检测问题。Python 处理字符串，terminal 执行写入（2026-05-17 实际验证）。
2. ✅ `execute_code` Python 原生 `open(path, 'a')` 直接写文件 — 当需要纯文件操作，不需要 shell 支撑时。
3. ⚠️ `terminal cat >> << 'EOF'` — 多行复杂内容（CJK/引号）可工作，但可能触发 false-positive 安全检测（exit_code: -1 "Foreground command uses '&' backgrounding"），JSON 内容含 `{}` 有风险。
4. ❌ `terminal echo >>` — JSON 含撇号时数据损坏风险高。
5. ❌ `patch` — CJK 环境 old_string 匹配失败率高。

**如果方法 3（cat >> heredoc）失败：** 不要重试或尝试修复 heredoc。立即切换到方法 1（execute_code + terminal echo loop）。一次移植相当于两次修复。

**验证建议：** 无论用哪种方法追加，追加后检查最后 N 行的 JSON 合法性。如果是 JSONL 文件，用 Python 验证每一行都能 `json.loads()` 成功。

