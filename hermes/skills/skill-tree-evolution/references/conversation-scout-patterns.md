# Conversation Scout — 对话扫描检测模式

## ⚠️ 已验证的误检测（2026-05-30）

`detect_skill_execution()` 的模式3（skill简称匹配）在2026-05-30扫描中产生了两条误报：

| 报告的skill | 实际匹配的内容 | 问题 |
|------------|--------------|------|
| `github` | `Browse GitHub Trending` | `github` 是顶层**分类目录名**，不是skill |
| `creative` | `Search and browse 小红书 (Xiaohongshu)` | `creative` 是顶层**分类目录名**，不是skill |

**根本原因**：`get_known_skills()` 的扫描逻辑对顶级目录**无条件**添加 `item.name` 到 skills 集合，即使该目录只是分类容器（无 SKILL.md）：

```python
# 有问题的逻辑
for item in SKILLS_DIR.iterdir():
    if item.is_dir() and not item.name.startswith("."):
        skills.add(item.name)  # ← 分类目录也被当成skill！
        for sub in item.iterdir():
            if sub.is_dir():
                skills.add(f"{item.name}/{sub.name}")
```

**已知被误检测的分类名**（均无对应 SKILL.md）：
`github`、`creative`、`design`、`engineering`、`marketing`、`product`、`research`、`software-development`、`game-development`、`gaming`、`hr`、`legal`、`finance`、`health`、`mlops`、`note-taking`、`productivity`、`sales`、`security`、`spatial-computing`、`unreal-engine`、`unity`、`workflow-runner`、`writing-skills`

**修复方向**：
1. **严格模式（推荐）**：只有当 `item / 'SKILL.md'` 存在时才添加 `item.name`
2. **过滤模式**：检测结果后，验证 skill 在 `skills/` 下有对应的 SKILL.md 才接受
3. **明确白名单**：维护 `KNOWN_SKILLS` 列表，排除顶级目录名

**日志污染影响**：误检测结果会通过 `log_skill_run()` 写入 `skill_runs.jsonl`，污染 skill 执行历史。

---

## 检测原理

从 Hermes `state.db` 读取最近对话，匹配用户消息中的 skill 执行模式。

**数据库路径**：`C:/Users/77/AppData/Local/hermes/state.db`
**表**：`messages` + `sessions`
**时间戳格式**：Unix epoch（float，如 `1780071163.635`），不是 ISO 字符串

## 检测模式（优先级从高到低）

### 1. 关键词直接映射

```python
keyword_skills = {
    "算命": "creation/bazi-ziwei",
    "八字": "creation/bazi-ziwei",
    "紫微": "creation/bazi-ziwei",
    "命理": "creation/bazi-ziwei",
}
```

### 2. 命令模式匹配

```python
command_patterns = [
    (r"用(.+?)做", 1),
    (r"帮我用(.+?)做", 1),
    (r"执行(.+?)做", 1),
    (r"跑一下(.+?)(?:\s|$)", 1),
    (r"用(.+?)skill", 1),
    (r"查一下\s*(.+?)(?:\s*$)", 0),
    (r"分析一下\s*(.+?)(?:\s*$)", 0),
    (r"看看\s*(.+?)(?:\s*$)", 0),
]
```

### 3. Skill 简称匹配

按名称长度倒序（优先匹配长名），去掉连字符后匹配。

## Outcome 判断

- `"不对"/"错了"/"重新"` → `partial`
- `"失败"/"错误"` → `failure`
- `"好的"/"谢谢"/"可以"` → `success`（默认）

## 执行环境

⚠️ **不能用 `python` 直接调用**：cron job 的 PATH 里 `python` 解析到 Hermes uv Python（3.11），存在 SRE module mismatch。

**正确方式**：
```bash
env -i PATH="/c/Users/77/miniconda3:/c/Windows/system32:/c/Windows" \
    /c/Users/77/miniconda3/python.exe \
    C:/Users/77/AppData/Local/hermes/skill_evolution/conversation_scout.py
```

miniconda Python 路径：`/c/Users/77/miniconda3/python.exe`（不要用 `which python` 查，它会返回损坏的 uv Python）。

## execute_code 中的调用方式

在 `execute_code` 里调用时，不能用 subprocess 直接运行（会走损坏的 hermes venv Python）。正确方式是：

```python
import subprocess, os

env = os.environ.copy()
for key in list(env.keys()):
    if 'PYTHON' in key.upper() or key in ('PYTHONHOME', 'PYTHONPATH', 'VIRTUAL_ENV'):
        del env[key]

# 用 shell 重定向到文件绕过编码问题
temp_output = "C:/Users/77/AppData/Local/hermes/skill_evolution/_scout_last_run.txt"
miniconda_py = "C:/Users/77/miniconda3/python.exe"
scout_py = "C:/Users/77/AppData/Local/hermes/skill_evolution/conversation_scout.py"
subprocess.run(
    f'"{miniconda_py}" "{scout_py}" > "{temp_output}" 2>&1',
    shell=True, env=env
)
with open(temp_output, encoding="gbk") as f:
    print(f.read())
```

**注意**：subprocess 的 `text=True` 模式下 `stdout` 可能返回 `None`，但命令实际成功执行（returncode=0）。用 shell 重定向到文件 + `encoding="gbk"` 读取可绕过编码问题。

## Cron Job

`skill-conversation-scout`（job_id: acbcc0861da1）每30分钟运行一次，检测到新执行后自动写入 `skill_runs.jsonl`。
