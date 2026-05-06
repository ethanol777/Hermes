# Monorepo Auto-Sync Setup

雨晨的 Hermes 配置使用**单仓实文件**模式，所有配置归入 `~/Hermes/`，每30分钟自动同步到 GitHub。

## 仓库结构

```
~/Hermes/                          ← GitHub: ethanol777/Hermes
├── hermes/                        ← 运行时配置
│   ├── config.yaml                ← Hermes 主配置
│   ├── SOUL.md                    ← 身份定义
│   ├── scripts/                   ← 工具脚本（auto_sync.sh, feishu_push_ai_news.py）
│   ├── profiles/                  ← 自定义 profile（coder/researcher/reviewer/writer）
│   ├── cron/                      ← 定时任务（AI资讯推送等）
│   ├── output/                    ← 历史输出文件（如八字排盘结果）
│   ├── skills/                    ← 67+ AI 专家角色 skill
│   └── .gitignore                 ← 排除密钥/缓存
├── learnings/                     ← 自我进化记录
│   ├── LEARNINGS.md               ← 修正/最佳实践
│   ├── ERRORS.md                  ← 命令失败记录
│   └── FEATURE_REQUESTS.md        ← 用户需求
├── agentic-stack/                 ← 跨 Agent 记忆层
│   ├── .agent/                    ← 便携大脑（记忆+技能+协议）
│   ├── harness_manager/           ← 钩子管理器
│   └── ...
├── .gitignore                     ← 全局排除规则
└── README.md
```

## 自动同步机制

### 脚本内容（当前版本 - rsync 模式）

```bash
#!/bin/bash
# Auto-sync: 运行时文件 → ~/Hermes/ → push GitHub
set -e

HERMES="$HOME/Hermes"

# Sync ~/.hermes/ (排除不需要的)
rsync -a --delete \
  --exclude='.git' \
  --exclude='.env' \
  --exclude='auth.json' --exclude='auth.lock' \
  --exclude='channel_directory.json' \
  --exclude='feishu_seen_message_ids.json' \
  --exclude='state.db*' \
  --exclude='models_dev_cache.json' \
  --exclude='ollama_cloud_models_cache.json' \
  --exclude='.skills_prompt_snapshot.json' \
  --exclude='gateway.*' \
  --exclude='processes.json' \
  --exclude='node/' \
  --exclude='cache/' --exclude='checkpoints/' \
  --exclude='logs/' --exclude='memories/' \
  --exclude='audio_cache/' \
  --exclude='image_cache/' --exclude='images/' \
  --exclude='bin/' --exclude='hooks/' \
  --exclude='sessions/' --exclude='sandboxes/' \
  --exclude='pastes/' --exclude='pairing/' \
  --exclude='weixin/' --exclude='workspace/' \
  --exclude='.hermes_history' --exclude='webui/' \
  --exclude='cloudflared' \
  --exclude='hermes-agent/' \
  # 注意：cron/、profiles/、output/、scripts/ 故意不排除——跨设备恢复需要它们
  "$HOME/.hermes/" "$HERMES/hermes/"

# Sync skills
rsync -a --delete --exclude='.git' \
  "$HOME/.hermes/skills/" "$HERMES/hermes/skills/"

# Sync learnings
rsync -a --delete --exclude='.git' \
  "$HOME/.learnings/" "$HERMES/learnings/"

# Sync agentic-stack
rsync -a --delete --exclude='.git' \
  "$HOME/agentic-stack/" "$HERMES/agentic-stack/"

# Commit & push
cd "$HERMES"
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "auto-sync $(date '+%Y-%m-%d %H:%M')"
  git push 2>&1 || echo "push failed"
fi

echo "auto-sync complete"
```

> 关键点: `--delete` 确保 Hermes 仓库中已删除的运行时文件会被清理。`--exclude` 排除密钥、缓存、二进制、源码子模块。

### 工作流程

```
运行时目录有变更
       ↓
auto_sync.sh 检测到 git 变动
       ↓
从运行目录复制文件到 ~/Hermes/
       ↓
git add → commit → push
       ↓
仅推送 ethanol777/Hermes（不推子目录独立仓库）
```

### 覆盖的运行时目录

| 运行时路径 | Hermes 中路径 | 说明 |
|-----------|---------------|------|
| `~/.hermes/` | `hermes/` | 配置、脚本（不含密钥/缓存，由 .gitignore 排除） |
| `~/.hermes/skills/` | `hermes/skills/` | 所有 skill |
| `~/.learnings/` | `learnings/` | 学习记录 |
| `~/agentic-stack/` | `agentic-stack/` | 跨 Agent 记忆层 |

### .gitignore 排除内容（跨设备注意事项）

**当前排除：**
- 密钥文件: `.env`, `auth.json`, `channel_directory.json`, `feishu_seen_message_ids.json`
- 运行时数据: `state.db`, `models_dev_cache.json`, `gateway.*`, `processes.json`
- 缓存/日志: `cache/`, `checkpoints/`, `logs/`, `memories/`, `audio_cache/`, `image_cache/`, `images/`
- 第三方工具: `bin/`, `hooks/`, `sessions/`, `sandboxes/`, `node/`
- 历史/状态: `.hermes_history`, `webui/`

**⚠️ 不排除但需确认：**
- `cron/` — 之前在 rsync 排除列表中，已移除。确认同样不在 `.gitignore` 中
- `profiles/` — 当前未被排除，跨设备恢复需要保留
- `scripts/` — 当前未被排除，保留
- `output/` — 当前未被排除，保留

**跨设备恢复提示：** clone 下来后需要手动配置的是 `~/.hermes/.env`（API 密钥），其余 cron/profiles/scripts 等均由 git 覆盖。

## Cron Job 配置

使用 Hermes 内置 cron 系统:

```bash
# 创建时（已完成）
cron action=create name="自动同步 Hermes 配置到 GitHub" \
  schedule="every 30m" \
  script=auto_sync.sh \
  deliver=local \
  enabled_toolsets=["terminal"]

# 查看状态
cron action=list
```

Job ID: `1d871b4e4b88`

## 初始化新机器

```bash
git clone https://github.com/ethanol777/Hermes.git ~/Hermes

# 创建符号链接（或手动复制文件到运行时路径）
ln -sf ~/Hermes/hermes ~/.hermes
ln -sf ~/Hermes/learnings ~/.learnings
ln -sf ~/Hermes/agentic-stack ~/agentic-stack
```

> **注意**: 当前运行时目录和 Hermes 仓库是**独立**的，通过 auto_sync.sh 同步复制。符号链接方式尚未启用，但可作为未来优化方向。

## Pitfalls ⚠️

- **不要直接编辑 `~/Hermes/` 中的文件** — 变更在运行时目录发生，auto_sync.sh 负责同步。直接修改 Hermes 中文件会被下次同步覆盖。
- **查看当前是否有未推送变更**: `cd ~/Hermes && git status`
- **auto_sync.sh 不处理删除** — 如果运行时目录删除了文件，Hermes 仓库中仍保留旧版本。如需清理，手动 git rm。
- **各运行时目录的 .git 已删除** — 不再有冲突的独立 git 仓库。
- **⚠️ `hermes/.gitignore` 中的 `skills/` 陷阱**: `~/.hermes/.gitignore` 里如果写了 `skills/`（原用于排除 skills 子模块），被 auto_sync.sh 同步到 `~/Hermes/hermes/.gitignore` 后，会导致整个 skills 目录被 git 忽略，957+ 个 skill 文件推不上 GitHub。如果有人问"为什么 GitHub 上看不到 skills"，第一步检查 `hermes/.gitignore` 里是否有 `skills/`。
  - **修复**: 删除 `hermes/.gitignore` 中的 `skills/` 和 `hermes-agent/` 行。
  - **根因**: `~/.hermes/.gitignore` 原本是为了独立 git 仓库排除子模块而写的，迁移到单仓后这些规则不再适用。
  - **防止复发**: 同步源 `~/.hermes/.gitignore` 也必须同时修，否则 auto_sync.sh 每次 rsync 会覆盖修复。
- **⚠️ `hermes-agent/` 不该进仓库**: `~/.hermes/hermes-agent/` 是 Hermes Agent 源码目录（一个 git 子模块），不应进入配置仓库。在 `~/Hermes/.gitignore` 中添加 `hermes/hermes-agent/`，同时在 `auto_sync.sh` 的 rsync 中 `--exclude='hermes-agent/'`。
- **⚠️ cloudflared 二进制文件**: `~/.hermes/cloudflared` 是 Cloudflare Tunnel 二进制，不应进仓库。在 `.gitignore` 和 rsync 中排除。
- **auto_sync.sh 演化路径**: 脚本从"git submodule add" → "git ls-files 逐文件复制"（但子目录 .git 已删除后失败）→ "rsync 完整目录同步"。如果你需要重建 auto_sync.sh，使用 `rsync -a --delete` 模式配合 `--exclude` 排除列表。
