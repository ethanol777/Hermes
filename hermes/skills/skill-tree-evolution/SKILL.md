---
name: skill-tree-evolution
description: 技能树进化系统 - 从平铺技能列表迁移到树状结构并持续进化
version: 1.0.0
---

# 技能树进化系统

## 问题：平铺技能的痛点
- 技能是散乱的目录列表
- 用完就忘，没有积累
- 找东西靠猜，不知道哪些常用
- 没有成长感

## 解决方案：树状结构 + 进化追踪

### 三层架构
```
根 (Root)    → 核心身份
枝 (Branch)  → 能力类别
叶 (Leaf)    → 具体技能 + 进化记录
```

### 目录结构
```
skills_tree/
├── index.yaml           # 技能索引映射
├── evolution/           # 进化记录
│   ├── branch1/
│   │   ├── skill1.yaml
│   │   └── skill2.yaml
│   └── branch2/
└── migration/           # 迁移脚本
```

### 进化记录格式 (YAML)
```yaml
skill_name: "skill-name"
branch: "cognition"
leaf: "research"
level: 1  # 技能等级
status: active

experiences:
  - date: "2026-05-19"
    trigger: "触发事件"
    insight: "学到的核心洞察"
    code_change: "实际代码变更"

next_steps:
  - action: "今后要做的事"
    frequency: daily|weekly|monthly
    priority: high|medium|low
    deadline: "2026-05-20"
    status: pending|completed
```

## 快速开始

### 1. 初始化结构
```bash
mkdir -p skills_tree/{evolution,migration}
cat > skills_tree/index.yaml << 'EOF'
meta:
  version: "1.0"
  total_skills: 0
  migrated: 0

tree:
  branch_name:
    name: "分支中文名"
    color: "#3498db"
    leaves:
      leaf_name:
        skills: []
EOF
```

### 2. 迁移现有技能
```bash
python3 migration/migrate.py
```

### 3. 添加"下一步"
```bash
python3 add_next_steps.py
```

### 4. 查看今日任务
```bash
python3 daily_tasks.py
```

### 5. 完成任务
```bash
python3 daily_tasks.py done "skill-name" "action-description"
```

## 多人格分工
技能树可以与多人格系统结合：

```python
# switch_persona.py 示例
personas = {
    "poet": {
        "trigger": ["写点什么"],
        "uses_skills": ["creation/writing"]
    },
    "explorer": {
        "trigger": ["去看看"],
        "uses_skills": ["cognition/research"]
    }
}
```

## 目标状态
- [x] 树形结构定义
- [x] 迁移脚本
- [x] 进化记录系统
- [x] 下一步任务系统
- [x] 每日任务抽取
- [ ] 自动升级算法 (level 1→2→3...)
- [ ] 使用频率统计
- [ ] 生疏技能提醒

## 应用场景
- AI Agent 的持续成长追踪
- 个人知识管理系统
- 团队技能库管理
- 学习路径规划

## 实际案例
莫妮卡的技能树：`~/AppData/Local/hermes/skills_tree_v2/`
- 73 个技能
- 6 个分支
- 每日自动生成任务清单
