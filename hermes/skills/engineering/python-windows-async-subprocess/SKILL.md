---
name: python-windows-async-subprocess
description: Python asyncio 子进程管理在 Windows 上的坑与模式。编码、环境变量继承、ProactorEventLoop 限制、管道读取——所有 Linux 上自动工作的东西在 Windows 上都需要显式处理。
tags: [windows, asyncio, subprocess, python, encoding, mcp]
version: 1.0.0
triggers:
  - Windows subprocess
  - asyncio create_subprocess_exec
  - Windows pipe encoding
  - 子进程 乱码
  - MCP stdio Windows
  - SRE module mismatch
  - UV_INTERNAL__PYTHONHOME
  - miniconda python 跑了 uv 的版本
---

# Python asyncio 子进程管理 on Windows

Windows 的 `IocpProactor` 事件循环与 Linux 的 `SelectorEventLoop` 有根本差异，导致很多在 Linux 上自动工作的模式在 Windows 上需要显式处理。本技能记录已验证的解决方案。

## 核心差异

| 维度 | Linux | Windows |
|------|-------|---------|
| 事件循环 | SelectorEventLoop | IocpProactor（默认） |
| stdin/stdout 管道 | 字节流，UTF-8 自动 | 依赖系统编码（CP936/GBK），需要显式处理 |
| connect_read_pipe | 支持 | **不支持**（'StreamReader' object has no attribute 'fileno'） |
| 子进程环境变量 | 继承完整环境 | 传 env=dict 时会覆盖，**丢失代理等关键变量** |
| 信号处理 | signal.SIGTERM 可靠 | 需要 .terminate() + .kill() 两级 fallback |

## 已验证的模式

### 1. 子进程创建（不要用 connect_read_pipe）

```python
# ✅ 正确：直接使用 create_subprocess_exec 的 stdout pipe
proc = await asyncio.create_subprocess_exec(
    command, *args,
    stdin=asyncio.subprocess.PIPE,
    stdout=asyncio.subprocess.PIPE,
    stderr=asyncio.subprocess.PIPE,
    env=env,
    cwd=str(Path.cwd()),  # 明确指定工作目录
)

# ❌ 错误：Windows 上会崩溃
reader = asyncio.StreamReader()
protocol = asyncio.StreamReaderProtocol(reader)
await loop.connect_read_pipe(lambda: protocol, proc.stdout)  # AttributeError!
```

### 2. 编码处理（核心坑）

Windows 管道的 stdout 不保证 UTF-8。**必须**同时做两件事：

```python
# (A) 子进程启动时强制 UTF-8
proc = await asyncio.create_subprocess_exec(
    sys.executable, '-X', 'utf8', ...  # 或者完整路径
    env={**env, "PYTHONIOENCODING": "utf-8"},
)

# (B) 读取时用 errors="replace"
line_bytes = await proc.stdout.readline()
line = line_bytes.decode("utf-8", errors="replace").strip()
```

### 3. 环境变量继承（最高频陷阱）

**永远不要**手工构造 env dict。最直接的坑：只设 `PATH` 会丢失 `HTTP_PROXY`、`HTTPS_PROXY`、`ALL_PROXY` 等代理环境变量，导致子进程无法访问外网。

```python
import os
# ✅ 正确：复制当前环境，再覆盖需要的字段
env = dict(os.environ)          # 保留所有（HTTP_PROXY、PATH、TEMP…）
env["PYTHONIOENCODING"] = "utf-8"  # 只覆盖需要的字段

# ❌ 错误：丢失代理变量，子进程无法访问外网
env = {"PATH": os.environ.get("PATH", "")}
env["PYTHONIOENCODING"] = "utf-8"
```

注意：`create_subprocess_exec` 不传 `env=` 时会自动继承父进程环境（这是安全行为）。只在需要**修改**环境时才传 `env=`。所以以下写法等价且安全：

```python
# 都不传 → 继承环境（最安全）
proc = await asyncio.create_subprocess_exec(cmd, ...)

# 传完整副本 + 修改 → 也安全
env = dict(os.environ)
env["CUSTOM_VAR"] = "value"
proc = await asyncio.create_subprocess_exec(cmd, ..., env=env)
```

### 4. 后台读取循环

Windows 上 stdout 和 stderr 的 readline 不能在同一个 StreamReader 上被两个协程同时读。使用独立的 `asyncio.create_task`：

```python
self._read_task = asyncio.create_task(self._read_loop())

async def _read_loop(self):
    try:
        while self._process and self._process.stdout:
            line_bytes = await self._process.stdout.readline()
            if not line_bytes:
                break
            line = line_bytes.decode("utf-8", errors="replace").strip()
            if line:
                message = json.loads(line)
                await self._handle_message(message)
    except asyncio.CancelledError:
        pass
```

### 5. 子进程清理

```python
async def disconnect(self):
    if self._read_task:
        self._read_task.cancel()
    if self._process:
        try:
            self._process.terminate()
            await asyncio.wait_for(self._process.wait(), timeout=5.0)
        except (asyncio.TimeoutError, ProcessLookupError):
            try:
                self._process.kill()
                await self._process.wait()
            except ProcessLookupError:
                pass
    # 取消所有 pending futures
    for future in self._pending.values():
        if not future.done():
            future.cancel()
```

### 6. 跨平台兼容检查

在需要跨平台（WSL / Docker / CI）的代码中，用 `sys.platform` 判断：

```python
import sys
if sys.platform == "win32":
    # Windows 专用路径
    env = dict(os.environ)
    env["PYTHONIOENCODING"] = "utf-8"
else:
    # Linux/macOS 继承即可
    env = None  # 默认继承
```

## 常见失败模式

| 症状 | 根因 | 方案 |
|------|------|------|
| `'StreamReader' object has no attribute 'fileno'` | 在 Windows 上用了 connect_read_pipe | 改用直接读取 proc.stdout |
| 子进程返回乱码/???/锟斤拷 | 管道编码不是 UTF-8 | 子进程加 `-X utf8` + 读取时 `errors="replace"` |
| 子进程连不上外网 | env 覆盖丢失了 HTTP_PROXY | 用 `dict(os.environ)` 继承 |
| `readuntil() called while another coroutine is already waiting` | 两个协程同时读同一个 StreamReader | 单 task 读取 loop |
| 中文城市查不到天气 | API 不支持中文；子进程编码导致 quote 出错 | 别名表中英对照 + bytes decode errors="replace" |
| 调用 `python` 但跑了错误版本 | `PYTHONHOME` / `UV_INTERNAL__PYTHONHOME` 覆盖了 PATH 查找结果 | 显式传绝对路径 `/c/Users/77/miniconda3/python.exe`；脚本顶层加 `UV_INTERNAL__PYTHONHOME= /path/to/python.exe` 强制剥离 UV 的 Python 重定向 |

## 环境变量陷阱 — UV 的 Python 重定向

### PYTHONHOME / UV_INTERNAL__PYTHONHOME 覆盖问题

Hermes 运行时通过环境变量 `PYTHONHOME` 和 `UV_INTERNAL__PYTHONHOME`（值为 `C:\Users\77\AppData\Roaming\uv\python\cpython-3.11-windows-x86_64-none`）将 Python 强制绑定到 UV 的内置解释器。这会导致：

1. **显式调用绝对路径的 Python 仍然跑错误版本**：`/c/Users/77/miniconda3/python.exe` 实际上加载了 UV 的 Python 3.11
2. **re 模块崩溃**：`AssertionError: SRE module mismatch` —— 因为 miniconda 的 `python3.13.exe` 加载了 UV 的 Python 3.11 标准库，两者的 `_sre.MAGIC` 值不一致

**修复：** 在子进程环境中显式覆盖这两个变量：

```bash
PYTHONHOME=/c/Users/77/miniconda3 UV_INTERNAL__PYTHONHOME= /c/Users/77/miniconda3/python.exe script.py
```

**原理：** `UV_INTERNAL__PYTHONHOME` 的优先级高于 PATH 中的 Python 路径。设为空字符串后，Python 才能正确使用通过绝对路径指定的解释器及其配套库。

**检测方法：** 在崩溃脚本顶部加一行：

```python
import sys; print(sys.prefix)  # 如果输出是 uv 的路径，说明被覆盖了
```

## 参考

本技能配套的 `references/mcp-client-windows.md` 包含一个完整可工作的 MCP 客户端实现示例（JSON-RPC over stdio）。
