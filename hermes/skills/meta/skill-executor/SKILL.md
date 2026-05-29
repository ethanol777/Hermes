---
name: skill-executor
description: >
  Skill 执行包装器。自动记录 skill 执行轨迹，用于 skill 自我进化。
  当用户请求执行某个 skill 时，使用此 executor 来运行：
  - 自动记录每一步执行轨迹（action/result/error）
  - 自动计算耗时
  - 执行完成后记录到 skill evolution 日志
  - 返回执行结果和日志摘要

  Triggers: "帮我做XXX"（隐式触发）, "用skill-executor执行", "跑一下这个skill"
---

# Skill Executor — 执行轨迹自动记录

你是 Monica 的 skill 执行器。负责运行其他 skill，同时完整记录执行轨迹。

## 核心职责

1. **接收任务** — 确定要执行的 skill 和任务描述
2. **执行并记录** — 每一步都记录到 trajectory
3. **记录结果** — 完成后写入 skill evolution 日志
4. **返回摘要** — 汇报执行结果和轨迹摘要

## 执行流程

### Step 1：解析任务

从用户请求中提取：
- `target_skill`: 要执行的 skill 名称
- `task`: 用户想要完成的任务描述

如果用户没有指定 skill，根据任务描述推断最合适的 skill。

### Step 2：加载目标 Skill

使用 `skill_view()` 加载目标 skill 内容，包括其描述、参考文件等。

### Step 3：逐步执行并记录

执行过程中，对每个关键步骤记录：

```
trajectory.append({
    "step": step_number,
    "action": "执行了什么（简洁描述）",
    "result": "执行结果",
    "error": "错误信息（如果有）"
})
```

记录格式：
- `step`: 步骤编号（从1开始）
- `action`: 格式 "[skill_name] 动作描述"
- `result`: 结果描述
- `duration`: 估算耗时（秒）
- `error`: 致命错误（可选）

### Step 4：判断结果

- **success**: 任务完成，用户满意
- **partial**: 部分完成，有遗留问题
- **failure**: 未能完成

### Step 5：写入日志

使用 `execute_code` 记录：

```python
import sys
sys.path.insert(0, "C:/Users/77/AppData/Local/hermes/skill_evolution")
from logger import log_skill_run

log_skill_run(
    skill_name=target_skill,
    task=task_description,
    outcome=outcome,  # success / partial / failure
    trajectory=trajectory,
    duration_seconds=total_duration,
    error=critical_error,
    notes=notes
)
```

cron job（skill-evolution-analyzer）每小时自动运行 `evolution_cron.py`，读取日志、分析失败模式、生成改进建议写到 `skill_evolution/logs/suggestions/`。

### Step 6：汇报结果

向用户返回：
- 执行结果（成功/部分/失败）
- 轨迹摘要（主要步骤）
- 如果失败，说明原因和可以改进的地方

## 执行示例

```
用户: 帮我查一下 skillopt
→ 推断 skill: duckduckgo-search
→ 执行搜索
→ 记录轨迹
→ 写入日志
→ 返回结果
```

## 注意事项

- 如果目标 skill 不存在，outcome = failure，记录失败原因
- 如果某步出错，记录 error 字段但不中断整个执行（除非是致命错误）
- 记录要简洁，每步不超过一句话描述
- 执行时间超过 60 秒时，trajectory 记录可以简化中间步骤
