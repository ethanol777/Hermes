# Windows Python 环境路径故障 — SRE module mismatch

## 问题

在 Windows（MSYS/git-bash）环境中，直接调用 `python` 或其绝对路径时，遇到：

```
AssertionError: SRE module mismatch
```

堆栈：
```
File "...\Lib\re\__init__.py", line 125
    from . import _compiler, _parser
  File "...\Lib\re\_compiler.py", line 18
    assert _sre.MAGIC == MAGIC, "SRE module mismatch"
```

**根因 A（原始）：** Windows 商店版 Python Launcher（PythonManager）的 shim 层在 MSYS bash 中解析 PATH 时，错误地将 `/c/Users/77/AppData/Roaming/uv/python/cpython-3.11-windows-x86_64-none/` 的 stdlib 链接到另一个 Python 可执行文件，导致 `_sre.MAGIC` 与当前解释器的 `MAGIC` 不匹配。

**根因 B（2026-05 更新）：** `cpython-3.11-windows-x86_64-none` 的 stdlib 本身损坏——`_sre.pyd` 的二进制文件损坏或与 python.exe 不匹配。即使 `uv run` 也可能被父进程 `PYTHONHOME` 污染而失败。

受影响的 Python 可执行文件：
- `C:\Users\77\AppData\Local\Microsoft\WindowsApps\python.exe`（PythonManager shim）
- `C:\Users\77\AppData\Local\Microsoft\WindowsApps\python3.exe`
- `C:\Users\77\AppData\Roaming\uv\...` 下的 uv managed Python（当被 PYTHONHOME 污染时）
- **任何**指向损坏 stdlib 的 Python 调用

不受影响：
- `C:\Users\77\AppData\Roaming\uv\python\cpython-3.12.13-windows-x86_64-none\python.exe`（截至 2026-05 健康）
- `/d/Code/environment/Python37/python.exe`（但版本太老，不支持新语法）
- MSYS 路径下的 `/usr/bin/python3`

## 症状

- 几乎所有 stdlib 模块（`json`, `re`, `tokenize` 等）加载时都会触发
- 与 PYTHONPATH / PYTHONDONTWRITEBYTECODE 环境变量无关
- `uv run` 也失败，错误与直接调用相同（说明根因 B）
- 或 `Fatal Python error: init_sys_streams` + SyntaxError（根因 B 的变体）

## 解决方案（优先级从高到低）

### 方案 0：诊断（先确认损坏程度）

```bash
for ver in /c/Users/77/AppData/Roaming/uv/python/cpython-*-windows-x86_64-none; do
    name=$(basename $ver)
    result=$($ver/python.exe -c "import re; print('OK')" 2>&1)
    echo "$name: $result"
done
```

能 import re 的版本输出 `OK`，损坏的报 `AssertionError`。

### 方案 1：Python subprocess 中清理环境（推荐用于脚本）

```python
import subprocess, os

env = os.environ.copy()
env.pop('PYTHONHOME', None)
env.pop('UV_INTERNAL__PYTHONHOME', None)

healthy = r"C:\Users\77\AppData\Roaming\uv\python\cpython-3.12.13-windows-x86_64-none\python.exe"
result = subprocess.run([healthy, "script.py"], capture_output=True, text=True, env=env)
```

### 方案 2：env -i 裸环境（适用于 shell 脚本）

```bash
env -u PYTHONHOME -u UV_INTERNAL__PYTHONHOME \
    PATH="/c/Users/77/AppData/Roaming/uv/python/cpython-3.12.13-windows-x86_64-none:/c/Windows/system32" \
    USERPROFILE="/c/Users/77" HOME="/c/Users/77" TEMP="/c/Users/77/AppData/Local/Temp" \
    "/c/Users/77/AppData/Roaming/uv/python/cpython-3.12.13-windows-x86_64-none/python.exe" \
    "C:/Users/77/AppData/Local/hermes/skill_evolution/conversation_scout.py"
```

### 方案 3：uv run（仅在根因 A 且无 PYTHONHOME 时有效）

```bash
uv run --python 3.11 python script.py
```

**注意：** 如果父进程设置了 `PYTHONHOME=.../cpython-3.11`，此方案也会失败，因为 uv 仍会加载父进程的 stdlib。

### 方案 4：重装损坏的 Python

```bash
rm -rf /c/Users/77/AppData/Roaming/uv/python/cpython-3.11-windows-x86_64-none
uv python install 3.11
```

适用于 stdlib 文件损坏无法修复的情况。

## 适用场景

- 运行 cron 脚本（如 `evolution_cron.py`）
- 调用 `execute_code` 时 Python stdlib 出错
- 任何通过 bash 调用 Python 且遇到 `SRE module mismatch` 的场景

## 参考

- PythonManager (Windows Python Launcher) 将 `/c/Users/77/AppData/Roaming/uv/` 的 Python 3.11 stdlib 注册为 shim 后的全局 Python，导致 PATH 顺序中的冲突
- uv managed Python (`uv run`) 内部设置了隔离的 stdlib 查找路径，但无法绕过父进程 PYTHONHOME 污染
- 2026-05 更新：已知 `cpython-3.11-windows-x86_64-none` stdlib 损坏，`cpython-3.12.13-windows-x86_64-none` 健康
