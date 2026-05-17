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

## 不通过 execute_code 做的事情

- **调用 Hermes 工具**（fact_store/memory/terminal）—— execute_code 的 Python 环境没有这些
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

在执行阶段（file tools 可用时），优先顺序：

1. ✅ `execute_code`（当 terminal Python 坏了 + 要写复杂内容时）— **首选稳定方案**
2. ⚠️ `terminal cat >> << 'EOF'`（当 terminal Python 正常、内容不含复杂引号时）
3. ❌ `terminal echo >>`（JSON 含撇号时数据损坏风险高）
4. ❌ `patch`（CJK 环境 old_string 匹配失败率高）

