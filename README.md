# Hermes 🤖

雨晨的 Hermes Agent 统一配置与技能仓库。

所有文件直接存储于此仓库，不包含子模块或符号链接。

## 目录结构

```
Hermes/
├── config/           ← Hermes Agent 运行时配置（config.yaml、SOUL.md、scripts）
├── skills/           ← Hermes Skills（211+ AI 专家角色）
├── learnings/        ← 自我进化学习记录
├── agentic-stack/    ← 跨 Agent 记忆与技能共享层
├── .gitignore        ← 排除密钥/运行时数据
└── README.md
```

## 初始化

```bash
git clone https://github.com/ethanol777/Hermes.git
```

## 从子模块迁移说明

此仓库原使用 Git 子模块管理各组件。现已将所有子模块文件直接纳入主仓库。
如需更新内容，直接修改并提交即可，不再需要分别推送多个子仓库。

原子模块来源：
- `skills` → ethanol777/hermes-skills
- `config` → ethanol777/hermes-config
- `learnings` → ethanol777/hermes-learnings
- `agentic-stack` → ethanol777/agentic-stack
