# stdlib 损坏诊断与修复

## 诊断决策树

```
脚本/命令执行报错：
├── AssertionError: SRE module mismatch
│   └── → stdlib 损坏（最常见）
│
├── Fatal Python error: init_sys_streams ... SyntaxError
│   └── → stdlib 损坏（Python 版本不兼容）
│
├── import 报错但文件存在
│   └── → stdlib 损坏或版本冲突
│
└── 正常但输出乱码
    └── → 编码问题（见主 SKILL.md 编码章节）
```

## 第一步：识别损坏的版本

**快速测试脚本（一次性检查所有 uv Python）：**
```bash
for ver in /c/Users/77/AppData/Roaming/uv/python/cpython-*-windows-x86_64-none; do
    name=$(basename $ver)
    result=$($ver/python.exe -c "import re; print('OK')" 2>&1)
    echo "$name: $result"
done
```

**预期结果：** 能 import re 的版本会输出 `OK`，损坏的会报 `AssertionError` 或其他 stdlib 错误。

## 第二步：找到健康版本

已知健康路径（截至 2026-05）：
- `/c/Users/77/AppData/Roaming/uv/python/cpython-3.12.13-windows-x86_64-none/python.exe` ✅
- `/d/Code/environment/Python37/python.exe` ✅（但版本太老，某些新语法不支持）

## 第三步：修复调用方

### 场景 A：Python subprocess 调用

```python
import subprocess, os

env = os.environ.copy()
env.pop('PYTHONHOME', None)
env.pop('UV_INTERNAL__PYTHONHOME', None)
env.pop('UV_PYTHON', None)  # 有时 uv 还会设置这个

healthy_python = r"C:\Users\77\AppData\Roaming\uv\python\cpython-3.12.13-windows-x86_64-none\python.exe"

result = subprocess.run(
    [healthy_python, "script.py"],
    capture_output=True, text=True, errors='replace',
    env=env,
    timeout=60
)
print(result.stdout)
```

### 场景 B：shell 脚本调用

```bash
PYTHONPATH="" PYTHONHOME="" UV_INTERNAL__PYTHONHOME="" \
env -i \
    PATH="/c/Users/77/AppData/Roaming/uv/python/cpython-3.12.13-windows-x86_64-none:/c/Windows/system32:/c/Windows" \
    USERPROFILE="/c/Users/77" \
    HOME="/c/Users/77" \
    TEMP="/c/Users/77/AppData/Local/Temp" \
    "/c/Users/77/AppData/Roaming/uv/python/cpython-3.12.13-windows-x86_64-none/python.exe" \
    "C:/Users/77/AppData/Local/hermes/skill_evolution/conversation_scout.py"
```

注意：PATH 里面要包含 python.exe 的父目录，否则找不到依赖。

### 场景 C：Hermes cron job 脚本

cron job 如果用 `script` 字段调用 shell 脚本，用场景 B 的 `env -i` 包装。

如果 cron job 用 `prompt` 字段直接运行 Python，需要在 prompt 里用 subprocess 调用健康 Python。

## 根本原因分析

uv 的 `cpython-*-windows-x86_64-none` 是在 MSYS2 环境下编译的，它依赖特定的 MSYS2 运行时。如果：
1. 运行时文件被部分覆盖
2. 系统更新破坏了 MSYS2 ABI 兼容性
3. 磁盘写入错误

则 `_sre.pyd` 的 MAGIC number 与 `python.exe` 期望的不一致，导致 `AssertionError`。

**预兆：** 在损坏前可能出现 `Fatal Python error: init_sys_streams` 或奇怪的 import 错误。

## 预防措施

1. 定期测试：`uv python list` 查看所有已安装版本
2. 多版本共存：总是保留一个已知健康的版本（如 3.12）作为备用
3. cron job 脚本化：用 shell 脚本包装 Python 调用，方便调试
