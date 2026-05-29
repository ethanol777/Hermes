# Skill Evolution System — Monica's Self-Improvement Loop

## Architecture

```
Skill执行 → skill-executor wrapper → log_skill_run()
                                         ↓
              cron(每h) → evolution_cron.py → suggestions/报告
                                         ↓
                                 确认后 → apply_edits() → 更新skill
```

## Files

| File | Purpose |
|------|---------|
| `logger.py` | 轨迹记录：`log_skill_run(task, outcome, trajectory)` |
| `optimizer.py` | 分析：`analyze_failure_patterns()` + `generate_edit_suggestions()` |
| `evolution_cron.py` | cron脚本：每小时读日志→生成报告 |
| `skill_runner.py` | 命令行runner：执行+记录+分析（`--analyze`） |
| `skill_log.py` | 快速单行记录 |

## Quick Reference

```python
# 记录一次执行
import sys
sys.path.insert(0, "C:/Users/77/AppData/Local/hermes/skill_evolution")
from logger import log_skill_run

log_skill_run(
    skill_name="bazi-ziwei",
    task="给77算命",
    outcome="success",
    trajectory=[
        {"step": 1, "action": "收集信息", "result": "完成"},
    ],
    duration_seconds=5.0,
    notes="用户要求大尺度"
)
```

```bash
# 命令行快速记录
python C:/Users/77/AppData/Local/hermes/skill_evolution/skill_log.py \
    --skill bazi-ziwei --task "算命" --outcome success --notes "OK"
```

## Key Thresholds

- 生成建议需要 ≥3 次失败记录
- 单次失败关键词不触发建议
- 每 skill 只保留最近 3 份分析报告

## SkillOpt Reference

SkillOpt (microsoft/SkillOpt, 2652⭐) 是这个系统的理论参考：
- ReflACT 循环：Rollout → Reflect → Patch → Validate → Update
- 对 Monica 的启发：skill 是可以被验证和迭代的"活文档"
- SkillOpt 仓库在 `C:/Users/77/AppData/Local/Temp/SkillOpt/`
