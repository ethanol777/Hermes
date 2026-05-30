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

**根因**：Windows 商店版 Python Launcher（PythonManager）的 shim 层在 MSYS bash 中解析 PATH 时，错误地将 `/c/Users/77/AppData/Roaming/uv/python/cpython-3.11-windows-x86_64-none/` 的 stdlib 链接到另一个 Python 可执行文件，导致 `_sre.MAGIC` 与当前解释器的 `MAGIC` 不匹配。

受影响的 Python 可执行文件：
- `C:\Users\77\AppData\Local\Microsoft\WindowsApps\python.exe`（PythonManager shim）
- `C:\Users\77\AppData\Local\Microsoft\WindowsApps\python3.exe`
- `C:\Users\77\AppData\Roaming\uv\...` 下的 uv managed Python

不受影响：
- `C:\Users\77\miniconda3\python.exe`（但它的 stdlib 路径被上面的 shim 污染）
- MSYS 路径下的 `/usr/bin/python3`

## 症状

- 几乎所有 stdlib 模块（`json`, `re`, `tokenize` 等）加载时都会触发
- 与 PYTHONPATH / PYTHONDONTWRITEBYTECODE 环境变量无关
- 即使显式用 miniconda 的绝对路径调用也失败（因为 linecache 等 stdlib 仍走 PATH 解析）

## 解决方案

**首选**：使用 `uv run --python <version>` 代替直接调用 Python：

```bash
# 不 Work（PATH 被 Windows Python shim 污染）
python script.py

# Work
uv run --python 3.11 python script.py
```

**备选**：使用 MSYS 自己的 Python：

```bash
/usr/bin/python3  # 来自 MSYS2 环境
```

## 适用场景

- 运行 cron 脚本（如 `evolution_cron.py`）
- 调用 `execute_code` 时 Python stdlib 出错
- 任何通过 bash 调用 Python 且遇到 `SRE module mismatch` 的场景

## 参考

- PythonManager (Windows Python Launcher) 将 `/c/Users/77/AppData/Roaming/uv/` 的 Python 3.11 stdlib 注册为 shim 后的全局 Python，导致 PATH 顺序中的冲突
- uv managed Python (`uv run`) 内部设置了隔离的 stdlib 查找路径，绕过了这个问题
