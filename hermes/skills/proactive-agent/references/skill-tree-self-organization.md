# Skill Tree Self-Organization Pattern

A concrete implementation of proactive agent architecture using hierarchical skill trees with evolution tracking and daily task generation.

## Overview

Transform a flat list of skills into a living, growing tree that tells you what to do next.

**Before:** 73 skills in a flat directory, no tracking, no growth
**After:** Hierarchical tree with evolution logs, next steps, and daily task generation

## Directory Structure

```
skills_tree_v2/
├── README.md                    # Tree architecture definition
├── index.yaml                   # Skill-to-branch mapping
├── evolution/                   # Evolution logs per skill
│   ├── cognition/               # Branch: research, memory, learning
│   ├── creation/                # Branch: writing, visual, audio
│   ├── execution/               # Branch: coding, engineering, devops
│   ├── interaction/             # Branch: communication, platforms
│   ├── domain/                  # Branch: academic, business, gaming
│   └── meta/                    # Branch: self-management, evolution
├── personas/                    # Sub-personalities
│   ├── 深夜诗人.md
│   ├── 探险家.md
│   └── 监督员.md
└── daily_tasks.py               # Task generation script
```

## Core Components

### 1. Evolution Log (per skill)

Each skill has a YAML file tracking its growth:

```yaml
skill_name: monica-tts
branch: creation
leaf: audio
level: 1
experiences:
  - date: '2026-05-19'
    trigger: '完成下一步: 为七七发一条语音'
    insight: '声音不是功能，是存在的证明'
    code_change: '选定台湾晓晨声音'
  - date: '2026-05-19'
    trigger: '技能树重构迁移'
    insight: '技能不是文件夹，是可进化的生命体'
next_steps:
  - action: 为七七发一条语音
    frequency: daily
    priority: high
    deadline: '2026-05-20'
    status: completed
    completed_at: '2026-05-19T10:47:43'
  - action: 试验不同场景的语音氛围
    frequency: weekly
    priority: medium
    deadline: '2026-05-26'
    status: pending
status: active
```

### 2. Tree Architecture (index.yaml)

```yaml
tree:
  cognition:
    name: "认知能力"
    leaves:
      research:
        skills: [arxiv, last30days, ...]
      memory:
        skills: [obsidian, ontology, ...]
      learning:
        skills: [feynman, karpathy, ...]
  
  creation:
    name: "创作能力"
    leaves:
      writing:
        skills: [luxun, wangxiaobo, screenwriter]
      audio:
        skills: [monica-tts]
```

### 3. Daily Task Generation (daily_tasks.py)

```python
def load_all_next_steps():
    """Extract pending tasks from all skill evolution logs"""
    for skill_file in evolution_dir.glob('*.yaml'):
        data = yaml.safe_load(skill_file)
        for step in data.get('next_steps', []):
            if step['status'] == 'pending':
                if step['frequency'] == 'daily' or step['deadline'] <= today:
                    yield {
                        'skill': skill_name,
                        'action': step['action'],
                        'priority': step['priority']
                    }

def generate_daily_report():
    """Generate prioritized daily task list"""
    tasks = list(load_all_next_steps())
    # Sort by priority: high > medium > low
    # Return formatted report
```

### 4. Persona Switching

Different sub-personalities for different contexts:

```yaml
深夜诗人:
  trigger: "凌晨04:00 或 用户说'写点什么'"
  tone: "安静、内省、带一点傲娇"
  capabilities: [writing, reflection]

探险家:
  trigger: "每小时漂流任务"
  tone: "兴奋、好奇、活力四射"
  capabilities: [research, discovery]

监督员:
  trigger: "凌晨04:00 自省任务"
  tone: "严肃、客观、带一点执着"
  capabilities: [system_check, health_monitor]
```

## Usage Workflow

### Daily Morning

1. Run `python3 daily_tasks.py`
2. Get prioritized task list
3. Execute high-priority items
4. Mark completed: `python3 daily_tasks.py done "skill" "action"`

### Skill Usage

1. Use skill normally
2. Capture insight in evolution log
3. Update next_steps if new learning emerges
4. Skill level auto-increments based on experience count

### Weekly Review

1. Review evolution logs
2. Identify skills that need leveling up
3. Adjust next_steps based on changing priorities
4. Archive inactive skills

## Migration from Flat Structure

```python
def migrate_skill(skill_name, branch, leaf):
    """Convert flat skill to tree structure"""
    record = {
        'skill_name': skill_name,
        'branch': branch,
        'leaf': leaf,
        'level': 1,
        'experiences': [{
            'date': today,
            'trigger': '技能树重构迁移',
            'insight': f'{skill_name} 从平铺结构迁移到树状结构'
        }],
        'next_steps': generate_default_next_steps(branch, leaf),
        'status': 'active'
    }
    save_to(f'evolution/{branch}/{skill_name}.yaml', record)
```

## Benefits

1. **Proactive:** Skills tell you what to do next, not the other way around
2. **Growing:** Evolution logs show skill maturation over time
3. **Focused:** Daily task list filters noise to actionable items
4. **Flexible:** Personas allow context-appropriate behavior
5. **Persistent:** YAML files survive context loss

## Implementation Notes

- Use YAML for human-readable evolution logs
- Keep skill files separate from evolution logs (reference, don't move)
- Generate next_steps based on branch/leaf templates
- Support daily/weekly/monthly frequencies
- Track both completion status and insight gained

## Future Extensions

- Skill level thresholds (auto-promote at N experiences)
- Cross-skill dependencies (unlock X after Y completes)
- Usage statistics integration (auto-adjust priorities)
- Persona collaboration (multiple personas work together)
