# 莫妮卡 — 完整备份

这是莫妮卡（Hermes Agent + Monica 人格）的完整备份仓库。

## 结构

```
Hermes/
├── .gitignore              # 排除密钥/DB/缓存
├── README.md               # 本文件
├── hermes/                  # Hermes 运行时数据（HERMES_HOME）
│   ├── config.yaml          # 核心配置
│   ├── SOUL.md             # 莫妮卡人格定义
│   ├── memories/           # 记忆系统
│   │   ├── MEMORY.md        # 冷层笔记（原始学习记录）
│   │   ├── USER.md          # 用户档案
│   │   ├── hot_candidates.txt  # 热层候选
│   │   ├── archive_index.md    # 归档索引
│   │   └── archive/         # 归档记忆（按月）
│   ├── skills/              # 75+ 技能定义
│   │   ├── hermes/          # 核心技能（memory-system, self-learn-daemon 等）
│   │   ├── monica/          # 莫妮卡人格技能
│   │   ├── feynman/         # 蒸馏技能
│   │   └── ...              # 其他技能
│   ├── cron/                # 定时任务配置
│   └── scripts/             # 脚本
├── user-skills/             # 用户蒸馏技能（费曼/Karpathy/鲁迅/王阳明/王小波）
├── learnings/               # 学习数据
└── agentic-stack/           # Agent 技术栈配置
```

## 在新设备上恢复

### 1. 克隆仓库

```bash
git clone https://github.com/ethanol777/Hermes.git ~/Hermes
```

### 2. 安装 Hermes Agent

```bash
# 参考 https://hermes-agent.nousresearch.com/docs 安装
pip install hermes-agent
```

### 3. 恢复运行时数据

```bash
# 确定你的 HERMES_HOME 路径
# Windows: ~/AppData/Local/hermes
# macOS/Linux: ~/.hermes

HERMES_HOME="$HOME/.hermes"  # 根据系统调整

# 复制核心文件
cp ~/Hermes/hermes/config.yaml "$HERMES_HOME/"
cp ~/Hermes/hermes/SOUL.md "$HERMES_HOME/"

# 恢复记忆系统
mkdir -p "$HERMES_HOME/memories/archive"
cp ~/Hermes/hermes/memories/MEMORY.md "$HERMES_HOME/memories/"
cp ~/Hermes/hermes/memories/USER.md "$HERMES_HOME/memories/"
cp ~/Hermes/hermes/memories/hot_candidates.txt "$HERMES_HOME/memories/"
cp ~/Hermes/hermes/memories/archive_index.md "$HERMES_HOME/memories/"
cp -r ~/Hermes/hermes/memories/archive/* "$HERMES_HOME/memories/archive/" 2>/dev/null

# 恢复技能
mkdir -p "$HERMES_HOME/skills"
cp -r ~/Hermes/hermes/skills/* "$HERMES_HOME/skills/"

# 恢复用户蒸馏技能（如有）
mkdir -p "$HOME/skills"
cp -r ~/Hermes/user-skills/* "$HOME/skills/" 2>/dev/null
```

### 4. 设置环境变量

```bash
# Windows (PowerShell 管理员)
setx HERMES_HOME "C:\Users\<用户名>\AppData\Local\hermes"

# macOS/Linux
export HERMES_HOME="$HOME/.hermes"
```

### 5. 记忆系统说明

莫妮卡使用三层记忆架构：
- **热层**（memory 工具）：2,200字，自动注入对话，仅存身份/关系/偏好
- **温层**（fact_store）：结构化事实，带信任评分和衰减，存在 state.db 中
- **冷层**（MEMORY.md）：无限笔记，完整学习记录

⚠️ **温层（fact_store）存在 state.db 数据库中，不通过 Git 同步。**
新设备上的 fact_store 需要莫妮卡自己重建——学习 cron 会在运行后自动填充。

### 6. 启动

```bash
hermes start
```

## 自动同步

当前设备每 30 分钟自动同步到 GitHub（`auto_sync_v2.sh` cron）。

手动同步：
```bash
export HERMES_HOME="$HOME/AppData/Local/hermes"  # Windows
bash ~/auto_sync_v2.sh
```

## 不同步的内容

出于安全和体积考虑，以下内容不同步：
- `.env` — API 密钥（需在新设备上重新配置）
- `auth.json` — 认证信息
- `state.db` — fact_store 数据库（温层记忆，自动重建）
- `logs/`, `cache/`, `sessions/` — 运行时临时数据
- `hermes-agent/` — 源码（通过 pip 安装）