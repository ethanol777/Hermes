---
name: skill-evolution-system
description: >
  Monica 的 Skill 自我进化系统 — 基于 Microsoft SkillOpt 思想的本地实现。
  三层架构：轨迹记录 → 失败分析 → 自动改写 skill 文档。
  Use when: 想要 skill 越用越好，而非静态文档不断老化。
---

# Skill 自我进化系统

基于 Microsoft SkillOpt 核心思想的本地实现，核心在 `skill_evolution/` 目录。

## 架构

```
skill_evolution/
├── __init__.py      ← 统一导出
├── logger.py        ← 第一层：轨迹记录
├── optimizer.py     ← 第二层：失败分析 + 改写生成
└── logs/
    └── skill_runs.jsonl   ← 执行日志（JSONL）
```

## 用法

### 记录执行轨迹

```python
from skill_evolution import log_skill_run, log_step

run_id = log_skill_run(
    skill_name="bazi-ziwei",
    task="给用户算命",
    outcome="success",
    trajectory=[
        {"step": 1, "action": "收集信息", "result": "获取了生日"},
        {"step": 2, "action": "排盘", "result": "成功"},
    ],
    duration_seconds=3.5,
    error=None,
    notes="用户要求大尺度",
)

# 逐步追加步骤
trajectory = []
log_step(trajectory, step=1, action="收集信息", result="OK")
```

### 查询记录

```python
from skill_evolution import read_runs, get_stats

stats = get_stats("bazi-ziwei")
# {'total': 10, 'success': 7, 'failure': 3, 'success_rate': 0.7}

runs = read_runs(skill_name="bazi-ziwei", outcome="failure", limit=20)
```

### 分析并生成改写建议

```python
from skill_evolution import analyze_failure_patterns, generate_edit_suggestions, build_optimizer_context

patterns = analyze_failure_patterns("bazi-ziwei")
# {'total_failures': 5, 'keywords': [...], 'step_failures': {2: 3}}

suggestions = generate_edit_suggestions("bazi-ziwei", skill_content, skill_path)
# [{'op': 'append', 'content': '...', 'reason': '...'}, ...]

report = build_optimizer_context("bazi-ziwei")
```

### 应用改写

```python
from skill_evolution import apply_edits

new_content = apply_edits("path/to/SKILL.md", suggestions)
```

## 阈值规则

防止误判，单次失败不触发改写：
- 关键词出现 ≥2 次才生成建议
- 步骤失败 ≥2 次才生成建议
- max 5 条建议/次

## SkillOpt 参考

Microsoft SkillOpt (`/tmp/SkillOpt`) 是原版框架，ReflACT 循环：
Rollout → Reflect → Patch → Validation → Update
支持 minibatch 轨迹分析、多模式改写、meta-skill 历史积累。

当前实现是轻量本地版，核心思想一致，跑在 Hermes 环境里，不需要 GPU/API key。

## 目录

- 代码：`~/AppData/Local/hermes/skill_evolution/`
- 日志：`~/AppData/Local/hermes/skill_evolution/logs/`
- SkillOpt 源码：`/tmp/SkillOpt/`
