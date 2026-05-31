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

**关键概念：`VAR=value` vs `env -u VAR`**

| 写法 | 效果 | 适用场景 |
|------|------|---------|
| `VAR=value command` | 在子进程环境**设置**变量（覆盖父进程的值） | 想让变量有特定值 |
| `VAR= command` | 在子进程环境设置变量为**空字符串**（变量仍存在） | 通常不够用 |
| `env -u VAR command` | **彻底移除**变量，子进程看不到它 | 清除冲突变量 |
| `env -i command` | 从空环境开始，需手动重建所有变量 | 完整隔离 |

> **注意**：`VAR=value` 在父进程已有同名变量时仍会**覆盖**为新值。但若目标 Python 本身就是通过 PYTHONHOME 定位的，直接覆盖会导致它找不到自己。

**修复方式一（Python subprocess 中清理）：**
```python
import subprocess, os

env = os.environ.copy()
for k in ['PYTHONHOME', 'UV_INTERNAL__PYTHONHOME']:
    env.pop(k, None)  # pop 比赋值空字符串更干净

result = subprocess.run(
    [r"C:\Users\77\miniconda3\python.exe", "script.py"],
    capture_output=True, text=True, timeout=120,
    env=env
)
```

**修复方式二（shell 层精准卸载）：**

只去掉特定冲突变量，保留其余环境变量完整：
```bash
env -u PYTHONHOME -u UV_INTERNAL__PYTHONHOME \
    /c/Users/77/miniconda3/python.exe script.py
```

**修复方式三（env -i 裸环境，最干净）：**

从完全干净的环境启动，需要手动重建必要变量（PATH、TEMP、USERPROFILE）：
```bash
env -i \
    PATH="/c/Users/77/miniconda3:/c/Windows/system32:/c/Windows" \
    USERPROFILE="/c/Users/77" \
    HOME="/c/Users/77" \
    TEMP="/c/Users/77/AppData/Local/Temp" \
    /c/Users/77/miniconda3/python.exe script.py
```

**适用于：** 调用非 uv 管理的 Python（conda、pyenv、系统 Python）、运行独立 cron 脚本、或任何 PYTHONHOME 与目标 Python 版本不匹配的场景。

**完整可执行的 cron 模板（Windows git-bash 环境）：**
```bash
CRON_PYTHON="/c/Users/77/miniconda3/python.exe"
CRON_SCRIPT="C:/Users/77/AppData/Local/hermes/skill_evolution/evolution_cron.py"

PYTHONPATH="" PYTHONHOME="" UV_INTERNAL__PYTHONHOME="" \
env -i \
    PATH="/c/Users/77/miniconda3:/c/Windows/system32:/c/Windows" \
    USERPROFILE="/c/Users/77" \
    HOME="/c/Users/77" \
    TEMP="/c/Users/77/AppData/Local/Temp" \
    "$CRON_PYTHON" "$CRON_SCRIPT"
```
前置清除 `PYTHONPATH`/`PYTHONHOME`/`UV_INTERNAL__PYTHONHOME` 再 `env -i`，双重保险。
PYTHONPATH="" PYTHONHOME="" UV_INTERNAL__PYTHONHOME="" \
env -i \
    PATH="/c/Users/77/miniconda3:/c/Windows/system32:/c/Windows" \
    USERPROFILE="/c/Users/77" \
    HOME="/c/Users/77" \
    TEMP="/c/Users/77/AppData/Local/Temp" \
    "$CRON_PYTHON" "$CRON_SCRIPT"
```

关键点：必须显式继承 `PATH`（否则找不到 python.exe）、`TEMP`（否则临时文件无处可写）、`USERPROFILE`/`HOME`（某些 stdlib 依赖 home 路径）。

这种方式完全绕开任何环境变量干扰，最可靠。

**适用于：** 调用非 uv 管理的 Python（conda、pyenv、系统 Python）、运行独立 cron 脚本、或任何 PYTHONHOME 与目标 Python 版本不匹配的场景。

## `py -3` 启动器在 Hermes 环境下不可靠

在 Hermes cron/sandbox 环境中，`py -3` 会继承父进程的 `PYTHONHOME`，导致加载错误的 stdlib。症状是 `AssertionError: SRE module mismatch`（uv 的 3.11 stdlib 被强加给另一个 Python 版本）。

**两种可靠方案：**

### 方案 A：用 execute_code 的 subprocess（最简洁）
```python
import subprocess, os

env = os.environ.copy()
env.pop('PYTHONHOME', None)
env.pop('UV_INTERNAL__PYTHONHOME', None)

result = subprocess.run(
    ['C:/Users/77/AppData/Roaming/uv/python/cpython-3.12.13-windows-x86_64-none/python.exe',
     'C:/Users/77/AppData/Local/hermes/skill_evolution/conversation_scout.py'],
    capture_output=True, text=True, errors='replace',
    env=env
)
```
适用于脚本需要调用其他 Python 解释器的场景（对话自动扫描、skill 执行检测等）。

### 方案 B：env -i 裸环境（最彻底）
```bash
PYTHONPATH="" PYTHONHOME="" UV_INTERNAL__PYTHONHOME="" \
env -i \
    PATH="/c/Users/77/miniconda3:/c/Windows/system32:/c/Windows" \
    USERPROFILE="/c/Users/77" HOME="/c/Users/77" \
    TEMP="/c/Users/77/AppData/Local/Temp" \
    "$PYTHON_EXE" script.py
```
适用于 shell 层调用，特别是 crontab 和 Windows 任务计划程序。

## stdlib 损坏 / SRE module mismatch

**典型错误：**
```
AssertionError: SRE module mismatch
```
或：
```
Fatal Python error: init_sys_streams: can't initialize sys standard streams
```
紧接着是 `SyntaxError` 或其他来自错误版本 stdlib 的错误。

**原因：** uv 安装的 Python 解释器的 stdlib 损坏（通常是 `_sre` 模块的 MAGIC 不匹配）。这不是环境变量问题，而是 Python 二进制本身的文件损坏。

**诊断：**
```bash
# 1. 确认是哪几个 uv Python 安装
ls /c/Users/77/AppData/Roaming/uv/python/

# 2. 逐个测试是否损坏
for ver in cpython-*-windows-x86_64-none; do
    echo "Testing $ver..."
    /c/Users/77/AppData/Roaming/uv/python/$ver/python.exe -c "import re; print('OK')" 2>&1
done
```

**修复方案：**

1. **优先尝试方案 A（最快）：** 找另一个可用的 Python 版本
   ```bash
   # 检查 3.12 是否完好
   /c/Users/77/AppData/Roaming/uv/python/cpython-3.12.13-windows-x86_64-none/python.exe -c "import re; print('3.12 OK')"
   ```

2. **方案 B（修复调用方）：** 在 subprocess 调用中清理环境后指向健康的 Python
   ```python
   import subprocess, os

   env = os.environ.copy()
   env.pop('PYTHONHOME', None)
   env.pop('UV_INTERNAL__PYTHONHOME', None)

   # 用健康的 Python（3.12 或其他）
   result = subprocess.run(
       ['C:/Users/77/AppData/Roaming/uv/python/cpython-3.12.13-windows-x86_64-none/python.exe',
        'script.py'],
       capture_output=True, text=True,
       env=env
   )
   ```

3. **方案 C（彻底重装损坏的 Python）：**
   ```bash
   # 删除损坏的版本
   rm -rf /c/Users/77/AppData/Roaming/uv/python/cpython-3.11-windows-x86_64-none

   # 让 uv 重新安装
   uv python install 3.11
   ```

**注意：** `uv run` 会自动选用父进程环境中的 Python，**不会**自动绕过损坏的版本。如果 Hermes 的运行环境设置了 `PYTHONHOME=.../cpython-3.11`，`uv run` 也会加载损坏的 stdlib。方案 B/C 是唯一出路。

---

## References

- [references/asyncio-subprocess-pattern.md](references/asyncio-subprocess-pattern.md) — 完整的 asyncio 子进程实现参考（MCPClient 模式）
- [references/stdlib-corruption.md](references/stdlib-corruption.md) — stdlib 损坏的完整诊断树和修复流程
