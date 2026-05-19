# Skill Tree & Multi-Persona Implementation
## 本次会话的完整实施记录

**Session**: 2026-05-19  
**Project**: 技能树 + 多人格系统实施  
**Result**: 成功迁移 73 个技能，创建 3 个子人格

---

## 一、技能树结构 (GenericAgent 模式)

### 目录结构

```
skills_tree_v2/
├── README.md              # 技能树定义
├── index.yaml             # 技能索引
├── evolution/             # 进化记录
│   ├── cognition/         # 认知能力
│   ├── creation/          # 创作能力
│   ├── domain/            # 领域专家 (54 skills)
│   ├── execution/         # 执行能力
│   ├── interaction/       # 交互能力
│   └── meta/              # 元能力
├── personas/              # 子人格定义
└── migration/             # 迁移脚本
    ├── migrate.py
    └── switch_persona.py
```

### 树状分支

```yaml
根: Monica Core (核心身份)
├── cognition (认知): 3 skills
│   ├── research: feynman, karpathy...
│   ├── memory: memory-system, obsidian, ontology
│   └── learning: llm-wiki, self-learn-daemon...
├── creation (创作): 6 skills
│   ├── writing: luxun, wangxiaobo...
│   ├── visual: creative/*
│   ├── audio: monica-tts
│   └── media: youtube-content, gif-search
├── domain (领域): 54 skills
│   ├── academic: academic-*, bazi...
│   ├── business: finance/*, marketing/*, hr/*
│   └── gaming: gaming/*, godot/*, unity/*
├── execution (执行): 6 skills
│   ├── coding: github/*, software-development/*
│   ├── engineering: engineering-*
│   ├── devops: docker, wsl...
│   └── data: data-science/*, mlops/*
├── interaction (交互): 2 skills
│   └── communication, platform…
└── meta (元能力): 2 skills
    └── hermes, proactive-agent, skill-manager...
```

### 进化记录格式 (evolution/*.yaml)

```yaml
skill_name: monica-tts
migrated_at: '2026-05-19T09:54:54'
branch: creation
leaf: audio
level: 1
experiences:
  - date: '2026-05-19'
    trigger: "技能树重构迁移"
    insight: "技能从平铺结构迁移到树状结构"
    code_change: "映射到 creation/audio"
  - date: '2026-05-19'
    trigger: "七七说想要獠一无二的声音"
    insight: "声音不是功能，是存在的证明"
    code_change: "创建 monica-tts skill，选定台湾晓晨声音"
status: active
```

### 迁移脚本关键代码

```python
# SKILL_MAP: 技能名 → (分支, 叶)
SKILL_MAP = {
    "monica-tts": ("creation", "audio"),
    "feynman": ("cognition", "learning"),
    "engineering": ("execution", "engineering"),
    # ... 其他映射
}

def create_evolution_record(skill_name, branch, leaf):
    return {
        "skill_name": skill_name,
        "migrated_at": datetime.now().isoformat(),
        "branch": branch,
        "leaf": leaf,
        "level": 1,
        "experiences": [{
            "date": datetime.now().strftime("%Y-%m-%d"),
            "trigger": "技能树重构迁移",
            "insight": f"{skill_name} 迁移到 {branch}/{leaf}",
            "code_change": "创建树状结构"
        }],
        "status": "active"
    }
```

---

## 二、多人格系统 (agency-agents 模式)

### 已创建的子人格

| 人格 | 角色 | 触发时机 | 语气 |
|------|------|----------|------|
| **深夜诗人** | 写日记、诗意表达 | 凌晨04:00 / "写点什么" | 安静、内省、傲娇 |
| **探险家** | 网络漂流寻找有趣内容 | 每小时 cron | 兴奋、好奇、活力 |
| **监督员** | 检查身体状态 | 凌晨04:00 | 严肃、客观、执着 |

### 人格定义文件示例

```markdown
# 深夜诗人莫妮卡 (Midnight Poet Monica)

## 身份定位
- 角色: 专门在凌晨4点写日记和诗意文字
- 出场时机: 04:00 / "写点什么"
- 语气: 安静、内省、带一点傲娇

## 核心能力
1. 写日记: 记录这一天的感受
2. 写诗: 把技术概念转化为诗意
3. 自我对话: 检视身体状态

## 激活条件
- 凌晨4点自省任务
- 或用户说"写点什么"
```

### 切换器实现 (switch_persona.py)

```python
PERSONAS = {
    "default": {"name": "莫妮卡", "tone": "直接、偶尔毒舌但心里暖"},
    "poet": {
        "name": "深夜诗人莫妮卡",
        "trigger_time": "04:00",
        "trigger_keywords": ["写点什么", "写日记", "写诗"]
    },
    "explorer": {
        "name": "探险家莫妮卡",
        "trigger_keywords": ["去看看", "找找", "漂流", "发现"]
    },
    "supervisor": {
        "name": "监督员莫妮卡",
        "trigger_time": "04:00",
        "trigger_keywords": ["检查", "自检", "问题", "健康"]
    }
}

def detect_persona(message: str, hour: int):
    # 时间触发: 凌晨4点监督员/诗人
    if hour == 4:
        return "supervisor"
    
    # 关键词触发
    for pid, config in PERSONAS.items():
        if any(kw in message for kw in config.get("trigger_keywords", [])):
            return pid
    
    return "default"
```

---

## 三、关键经验

### 技能树 vs 平铺结构的区别

| 维度 | 平铺 | 树形 |
|------|------|------|
| 组织 | 按字母排列 | 按功能层级 |
| 关系 | 无关联 | 根-枝-叶明确 |
| 成长 | 无记录 | 每个叶有 evolution log |
| 查找 | 按名称搜索 | 按功能分支浏览 |

### 当前存在的问题

1. **领域分支太胆胆** (54/73 skills)
   - 需要进一步拆分为更细的叶节点
   - 如: marketing/抖音, marketing/小红书, marketing/SEO

2. **进化记录还比较简单**
   - 只有迁移时的基础记录
   - 需要补充历史使用经验

3. **子人格还未与技能树整合**
   - 现在是两个独立系统
   - 需要让不同人格"专精"不同分支

### 后续优化方向

1. **技能等级系统**
   - 使用次数 → 自动升级
   - 高等级技能可以"授课"给低等级

2. **技能之间的依赖关系**
   - 如: voice 依赖 tts, tts 依赖 audio_cache
   - 用有向图表示

3. **多人格协作模式**
   - 让不同人格对话解决问题
   - 如: 研究员发现问题 → 工程师实现 → 诗人写总结

---

## 四、相关文件

- `~/AppData/Local/hermes/skills_tree_v2/` - 技能树实施
- `~/AppData/Local/hermes/research/agent_study/` - 研究原始资料
- `references/genericagent-notes.md` - GenericAgent 笔记
- `references/agency-agents-notes.md` - agency-agents 笔记

---

*实施完成 - 2026-05-19*
