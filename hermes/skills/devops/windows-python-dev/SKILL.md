---
name: windows-python-dev
description: Windows 环境下 Python 开发的注意事项 — asyncio 子进程、管道编码、环境变量继承、路径处理、键盘检测等。
version: 1.0.0
tags: [windows, python, dev, asyncio, encoding]
---

# Windows Python 开发注意事项

Windows 与 macOS/Linux 在 Python 运行时行为上有显著差异。这份技能记录了跨平台兼容的关键模式。

## asyncio 子进程

### 环境变量继承（关键！）

**错误做法：**
```python
env = {"PATH": os.environ.get("PATH", "")}  # ❌ 只复制了 PATH
env["PYTHONIOENCODING"] = "utf-8"
```

这会丢失所有其他环境变量——包括 HTTP_PROXY、HTTPS_PROXY、NO_PROXY 等代理配置。在需要通过代理访问外网的环境中（如中国大陆开发者的常见配置），这会导致子进程请求失败。

**正确做法：**
```python
env = dict(os.environ)  # ✅ 复制完整环境
env["PYTHONIOENCODING"] = "utf-8"  # 在基座上叠加自定义变量
```

### 管道编码（中文显示乱码）

Windows 的管道默认不使用 UTF-8 编码。当子进程输出包含中文时，`line.decode("utf-8")` 会报 `UnicodeDecodeError`。

**解决方案（二选一，推荐都用）：**
1. 启动子进程时加 `-X utf8` 参数：`python -X utf8 script.py`
2. 设置环境变量 `PYTHONIOENCODING=utf-8`
3. 读取时用 `errors="replace"` 后备：
   ```python
   line = line_bytes.decode("utf-8", errors="replace").strip()
   ```

### asyncio.create_subprocess_exec vs asyncio.create_subprocess_shell

- 优先使用 `create_subprocess_exec`（传参数列表，避免 shell 注入）
- Windows 下 `create_subprocess_shell` 需要 `comspec` 环境变量
- stdin/stdout/stderr 用 `asyncio.subprocess.PIPE`（不是 `subprocess.PIPE`）
- stdout 读取用 `proc.stdout.readline()`，不要用 `connect_read_pipe`

**完整的子进程模式：**
```python
self._process = await asyncio.create_subprocess_exec(
    command, *args,
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    env=env,       # dict(os.environ)
    cwd=str(Path.cwd()),
)

# 后台读取循环
async def _read_loop(self):
    while self._process and self._process.returncode is None:
        line_bytes = await self._process.stdout.readline()
        if not line_bytes:
            break
        line = line_bytes.decode("utf-8", errors="replace").strip()
        # 处理 line...
```

### Process._transport 清理警告

Windows 下 asyncio 子进程退出时常见 `_ProactorBasePipeTransport.__del__` 异常。这是已知的 Python asyncio 问题，不影响功能但影响日志整洁度。

缓解方法：
- 在 disconnect 中正确 terminate/wait
- 忽略 `ValueError: I/O operation on closed pipe` 异常
- `try/except ProcessLookupError` 包围 kill 调用

## 键盘非阻塞检测

**Windows：**
```python
import msvcrt
def _kbhit():
    return msvcrt.kbhit()
def _readkey():
    return msvcrt.getch().decode("utf-8", errors="replace")
```

**Unix：**
```python
import select
def _kbhit():
    return select.select([sys.stdin], [], [], 0)[0]
def _readkey():
    return sys.stdin.read(1)
```

## 路径处理

- `os.environ.get("PATH", "")` 在 Windows 下包含 `;` 分隔的路径
- 使用 `pathlib.Path` 处理路径，避免手动字符串拼接
- Windows 路径在 git-bash 中可以用 Unix 风格（`/c/Users/...`）或原生风格（`C:\Users\...`）
- `asyncio` 的子进程 `command` 参数支持 Windows 路径，建议用 `Path` 对象转字符串

## 包管理

- `pyproject.toml` 的 `build-backend` 用 `setuptools.build_meta`，不要用 `setuptools.backends._legacy`（该后端不存在）
- Python 3.12+ 的 venv 在 Windows 上需要 `.venv\Scripts\activate`（不是 `source`），git-bash 下可以用 `source`
- https:// 请求可能走系统代理，确保子进程环境变量中包含 `HTTP_PROXY`

## 环境变量冲突：PYTHONHOME / UV_INTERNAL__PYTHONHOME

当系统环境变量 `PYTHONHOME` 或 `UV_INTERNAL__PYTHONHOME` 被设为某个 Python 版本时，**任何 Python 解释器都会优先加载 PYTHONHOME 下的 stdlib**，忽略自身二进制文件所在路径的 stdlib。

典型场景：Hermes 的运行环境设置了 `PYTHONHOME=C:\...\cpython-3.11`（uv 的 Python），此时直接调用 miniconda 的 Python 3.13 会报：
```
AssertionError: SRE module mismatch
```
原因：miniconda 的 python.exe 本身是 3.13，但 `re` 模块是从 PYTHONHOME 的 3.11 加载的，MAGIC number 不匹配。

**诊断方法：**
```python
import os
for k, v in os.environ.items():
    if 'python' in k.lower() or 'uv' in k.lower():
        print(f"{k}={v}")
```

**修复：在调用前清除这两个变量**
```python
import subprocess, os

env = os.environ.copy()
for k in ['PYTHONHOME', 'UV_INTERNAL__PYTHONHOME']:
    env.pop(k, None)

result = subprocess.run(
    [r"C:\Users\77\miniconda3\python.exe", "script.py"],
    capture_output=True, text=True, timeout=120,
    env=env
)
```

**适用于：** 调用非 uv 管理的 Python（conda、pyenv、系统 Python）、运行独立 cron 脚本、或任何 PYTHONHOME 与目标 Python 版本不匹配的场景。

## References

- [references/asyncio-subprocess-pattern.md](references/asyncio-subprocess-pattern.md) — 完整的 asyncio 子进程实现参考（MCPClient 模式）
