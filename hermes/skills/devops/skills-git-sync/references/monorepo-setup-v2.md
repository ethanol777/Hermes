# Monorepo Auto-Sync Setup v2

雨晨的 Hermes 配置使用**单仓实文件**模式，所有配置归入 `~/Hermes/`，每30分钟自动同步到 GitHub。

## v2 关键变更（vs v1）

| 项目 | v1 (auto_sync.sh) | v2 (auto_sync_v2.sh) |
|------|-------------------|----------------------|
| 数据源路径 | 硬编码 `~/.hermes` | 读取 `$HERMES_HOME` 环境变量 |
| memories/ | rsync `--exclude='memories/'` | 逐文件选择性包含（MEMORY.md, USER.md, hot_candidates.txt, archive_index.md, fact_store.jsonl, archive/） |
| skills 处理 | rsync 整目录 | 逐目录 cp，处理 symlink（蒸馏技能从 `~/skills/`） |
| 用户技能 | 不包含 | `~/skills/` → `~/Hermes/user-skills/` |
| fact_store | 不包含 | `memories/fact_store.jsonl` 进入版本控制 |
| 脚本位置 | `~/auto_sync.sh` | `~/auto_sync_v2.sh` + `$HERMES_HOME/scripts/auto_sync_v2.sh` |

## Windows HERMES_HOME 路径

**Windows 上 Hermes 运行时数据目录是 `C:\Users\<用户>\AppData\Local\hermes`，不是 `~/.hermes`。**

`HERMES_HOME` 环境变量决定实际路径。v1 脚本硬编码 `~/.hermes` 导致同步了旧数据。

**验证：** `echo $HERMES_HOME`

## 仓库结构

```
~/Hermes/                          ← GitHub: ethanol777/Hermes
├── hermes/                        ← 运行时配置（来自 $HERMES_HOME）
│   ├── config.yaml                ← Hermes 主配置
│   ├── SOUL.md                    ← 身份定义（莫妮卡人格）
│   ├── memories/                  ← 记忆系统核心文件（v2 新增同步）
│   │   ├── MEMORY.md              ← 冷层笔记
│   │   ├── USER.md                ← 用户档案
│   │   ├── hot_candidates.txt     ← 热层候选
│   │   ├── archive_index.md       ← 归档索引
│   │   ├── archive/               ← 归档记忆（按月）
│   │   └── fact_store.jsonl       ← 温层 JSON 备份
│   ├── scripts/                   ← 工具脚本
│   ├── cron/                      ← 定时任务配置
│   ├── skills/                    ← 75+ 技能定义
│   └── .gitignore                 ← 排除 DB/缓存/密钥
├── user-skills/                   ← 蒸馏技能（费曼/Karpathy/鲁迅/王阳明/王小波）
├── agentic-stack/                 ← 跨 Agent 记忆层
├── .gitignore                     ← 全局排除规则
└── README.md                      ← 恢复指南
```

## 记忆数据双重存储

| 存储 | 路径 | 用途 | Git 同步？ |
|------|------|------|-----------|
| SQLite 源 | `$HERMES_HOME/state.db` | 运行时 fact_store | ❌ 不同步（60MB+） |
| JSON 备份 | `$HERMES_HOME/memories/fact_store.jsonl` | Git 同步 + 新设备恢复 | ✅ 同步 |
| 冷层笔记 | `$HERMES_HOME/memories/MEMORY.md` | 原始学习记录 | ✅ 同步 |
| 热层候选 | `$HERMES_HOME/memories/hot_candidates.txt` | 维护 cron 生成 | ✅ 同步 |

维护 cron（每日 3am）负责将 fact_store 导出为 `.jsonl`。新设备恢复时学习 cron 会自动重建温层。

## .gitignore 关键规则

**根 `.gitignore`（~/Hermes/.gitignore）：** 排除 `.env`、`auth.json`、大型二进制、敏感数据

**内层 `.gitignore`（~/Hermes/hermes/.gitignore）：** 
- 排除：`.db*`、`.lock`、`cache/`、`logs/`、`sessions/`、`bin/` 等
- **不排除** `memories/`（v1 排除了，v2 修复）
- **不排除** `cron/`（已修复）

**⚠️ 两层 .gitignore 陷阱：** 修改忽略规则时两个文件都要改，否则内层规则会覆盖外层的 `!` 取消指令。

## Cron 配置

```bash
# 同步 cron（v2）
hermes cron update 1d871b4e4b88 \
  --name "莫妮卡完整同步到 GitHub" \
  --script auto_sync_v2.sh \
  --schedule "every 30m" \
  --deliver local \
  --enabled_toolsets '["terminal"]'
```

## 新设备恢复步骤

```bash
# 1. 克隆
git clone https://github.com/ethanol777/Hermes.git ~/Hermes

# 2. 确定运行时目录
# Windows: ~/AppData/Local/hermes
# macOS/Linux: ~/.hermes
HERMES_HOME="$HOME/.hermes"  # 根据系统调整

# 3. 复制核心文件
cp ~/Hermes/hermes/SOUL.md "$HERMES_HOME/"
cp ~/Hermes/hermes/config.yaml "$HERMES_HOME/"
mkdir -p "$HERMES_HOME/memories/archive"
cp ~/Hermes/hermes/memories/MEMORY.md "$HERMES_HOME/memories/"
cp ~/Hermes/hermes/memories/USER.md "$HERMES_HOME/memories/"
cp ~/Hermes/hermes/memories/hot_candidates.txt "$HERMES_HOME/memories/"
cp ~/Hermes/hermes/memories/archive_index.md "$HERMES_HOME/memories/"
cp -r ~/Hermes/hermes/memories/archive/* "$HERMES_HOME/memories/archive/" 2>/dev/null || true
cp ~/Hermes/hermes/memories/fact_store.jsonl "$HERMES_HOME/memories/" 2>/dev/null || true
mkdir -p "$HERMES_HOME/skills"
cp -r ~/Hermes/hermes/skills/* "$HERMES_HOME/skills/"

# 4. 用户蒸馏技能
mkdir -p "$HOME/skills"
cp -r ~/Hermes/user-skills/* "$HOME/skills/"

# 5. API 密钥（手动配置）
# 编辑 $HERMES_HOME/.env

# 6. 启动
hermes start
```

## Pitfalls

- **⚠️ HERMES_HOME 必须设对** — Windows 默认是 `C:\Users\<用户>\AppData\Local\hermes`，不是 `~/.hermes`。auto_sync_v2.sh 从环境变量读取。
- **⚠️ memories/ 曾被 gitignore** — v1 时 `hermes/.gitignore` 排除了整个 `memories/` 目录，导致冷层记忆不同步。v2 修复为仅排除 `.db*` 和 `.lock`。
- **符号链接技能** — `~/skills/` 下的蒸馏技能是 symlink，cp 时需要 `readlink -f` 解析真实路径。auto_sync_v2.sh 已处理。
- **state.db 有 60MB+** — 绝对不同步到 Git。`.gitignore` 必须包含 `state.db*`。
- **两层 gitignore** — 总是检查 `~/Hermes/.gitignore` 和 `~/Hermes/hermes/.gitignore` 两个文件。