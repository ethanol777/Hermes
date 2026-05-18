# 心跳注入路径修复 — 2026-05-19

## 问题

Hermes 对话开头的 Monica 连续性注入块（`[Monica's life — before this conversation]`）从未出现过。

根因在 `agent/system_prompt.py` 的 `build_system_prompt_parts()` 中 ——
用于读取心跳的路径与实际写入位置不一致。

## 路径分析

```
HERMES_HOME = C:\Users\77\AppData\Local\hermes
```

| 路径 | 存在？ |
|------|--------|
| `$HERMES_HOME/heartbeat/` | ❌ |
| `dirname($HERMES_HOME)/heartbeat/` = `C:\Users\77\AppData\Local/heartbeat/` | ❌ |
| `$HERMES_HOME/profiles/01/heartbeat/` | ✅ 实际的心跳文件位置 |
| `$HERMES_HOME/profiles/ouro/heartbeat/` | ✅ 另一个 profile 的心跳 |

## 原始代码（有 bug）

```python
# 原代码在 system_prompt.py 第 258 行
_hb_dir = os.path.join(os.path.dirname(_r.get_hermes_home().rstrip("\\/")), "heartbeat")
# 解析为：C:\Users\77\AppData\Local\heartbeat → 不存在

# fallback:
_hb_dir = os.path.join(os.environ.get("HERMES_HOME", ...), "heartbeat")
# 解析为：C:\Users\77\AppData\Local\hermes/heartbeat → 也不存在
```

两个路径都找不到文件，代码静默跳过，从不报错。

## 修复（2026-05-19）

在 `system_prompt.py` 的 path resolution 中加入 profiles/*/heartbeat/ fallback 扫描：

```python
_hb_dir = ""
if hasattr(_r, "get_hermes_home"):
    _hermes_home = _r.get_hermes_home()
    # Try HERMES_HOME/heartbeat first
    _hb_dir = os.path.join(_hermes_home, "heartbeat")
    if not os.path.isdir(_hb_dir):
        # Fallback: scan profiles/*/heartbeat/ directories
        _profiles_dir = os.path.join(_hermes_home, "profiles")
        if os.path.isdir(_profiles_dir):
            for _p in sorted(os.listdir(_profiles_dir)):
                _candidate = os.path.join(_profiles_dir, _p, "heartbeat")
                if os.path.isdir(_candidate):
                    _hb_dir = _candidate
                    break
# Last resort: env-based guess
if not _hb_dir or not os.path.isdir(_hb_dir):
    _hb_dir = os.path.join(
        os.environ.get("HERMES_HOME",
            os.path.join(os.environ.get("LOCALAPPDATA", ""), "hermes")),
        "heartbeat"
    )
```

现在会按顺序：
1. `$HERMES_HOME/heartbeat/` — 最直接的位置
2. `$HERMES_HOME/profiles/*/heartbeat/` — 扫描所有 profile
3. `(env HERMES_HOME or AppData/hermes)/heartbeat/` — 兜底

## 验证

修复后需要确认：
- 心跳文件存在：`ls $HERMES_HOME/profiles/01/heartbeat/pulse.md`
- pulse.md 有至少一条以 `|` 开头且 >10 字符的条目
- 下次对话开始时能看到 `[Monica's life — before this conversation]` 块
