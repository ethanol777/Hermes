# Conversation Scout — 对话扫描检测模式

## 检测原理

从 Hermes `state.db` 读取最近对话，匹配用户消息中的 skill 执行模式。

**数据库路径**：`C:/Users/77/AppData/Local/hermes/state.db`
**表**：`messages` + `sessions`
**时间戳格式**：Unix epoch（float，如 `1780071163.635`），不是 ISO 字符串

## 检测模式（优先级从高到低）

### 1. 关键词直接映射（最快）

```python
keyword_skills = {
    "算命": "creation/bazi-ziwei",
    "八字": "creation/bazi-ziwei",
    "紫微": "creation/bazi-ziwei",
    "命理": "creation/bazi-ziwei",
    "skillopt": "autonomous-ai-agents/skillopt",
    "skill-opt": "autonomous-ai-agents/skillopt",
}
```

### 2. 命令模式匹配

```python
command_patterns = [
    (r"用(.+?)做", 1),                    # 用xxx做
    (r"帮我用(.+?)做", 1),
    (r"执行(.+?)做", 1),
    (r"跑一下(.+?)(?:\s|$)", 1),         # 跑一下xxx
    (r"用(.+?)skill", 1),
    (r"查一下\s*(.+?)(?:\s*$)", 0),     # 查一下xxx
    (r"分析一下\s*(.+?)(?:\s*$)", 0),     # 分析一下xxx
    (r"看看\s*(.+?)(?:\s*$)", 0),        # 看看xxx
]
```

### 3. Skill 简称匹配

按名称长度倒序（优先匹配长名）：
- `creation/bazi-ziwei` 优先于 `bazi-ziwei`
- 去掉连字符后匹配：`bazi` 匹配 `bazi-ziwei`

## Skill 名称扫描

扫描 `skills/` 目录获取所有已知 skill（415个），用于模式匹配。

```python
def get_known_skills():
    skills = set()
    for item in SKILLS_DIR.iterdir():
        if item.is_dir():
            skills.add(item.name)
            for sub in item.iterdir():
                if sub.is_dir():
                    skills.add(f"{item.name}/{sub.name}")
    return skills
```

## Outcome 判断

根据执行后的消息判断：
- `"不对"/"错了"/"重新"` → `partial`
- `"失败"/"错误"` → `failure`
- `"好的"/"谢谢"/"可以"` → `success`（默认）

## 注意事项

- 只检测 `role=user` 的消息
- 需要从最近的 session 过滤，避免跨会话误匹配
- SkillOpt 等未安装到 skills 目录的仓库，关键词映射检测不到

## Cron Job

`skill-conversation-scout`（job_id: acbcc0861da1）每30分钟运行一次，检测到新执行后自动写入 `skill_runs.jsonl`。

## 执行环境（重要）

⚠️ **不能用 `python` 直接调用**：cron job 的 PATH 里 `python` 解析到 Hermes uv Python（3.11），存在 SRE module mismatch，import re/json 会炸。

**正确方式**：
```bash
env -i PATH="/c/Users/77/miniconda3:/c/Windows/system32:/c/Windows" \
    /c/Users/77/miniconda3/python.exe \
    C:/Users/77/AppData/Local/hermes/skill_evolution/conversation_scout.py
```

miniconda Python 路径：`/c/Users/77/miniconda3/python.exe`（不要用 `which python` 查，它会返回损坏的 uv Python）。
