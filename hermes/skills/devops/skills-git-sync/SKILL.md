---
name: skills-git-sync
description: "Sync Hermes config, skills, and backups to GitHub — single repo, submodules, cron-driven auto-push."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [git, github, skills, sync, backup]
    related_skills: [github-auth, github-repo-management]
---

# Skills Git Sync

**注: 雨晨的环境已迁移为单仓实文件模式（见下文）。旧的子模块/多仓库模式仅作为历史参考保留。**

## 当前模式：单仓实文件 + 自动同步

所有 Hermes 配置（config + skills + learnings + agentic-stack）归入 **`~/Hermes/`**（`github.com/ethanol777/Hermes`），每30分钟自动同步。

**核心特征：**
- **实文件** — 不是 git submodule，每个文件真实存在于 `~/Hermes/` 中
- **单一远程** — 只推送到 `ethanol777/Hermes`，不推送子目录的独立仓库
- **从运行时目录同步** — `auto_sync.sh` 检测运行时目录变更并复制到 `~/Hermes/`
- **子目录无独立 .git** — 已删除 `~/.hermes/.git`、`~/.learnings/.git` 等

**⚠️ Gitignore 陷阱：运行时数据库文件必须排除**
- SQLite 数据库（`memory_store.db`、`memory_store.db-shm`、`memory_store.db-wal`）属于 **二进制运行时数据**，不应提交到 git
- 同步到 `~/Hermes/` 目录后，如果 `.gitignore` 没有排除这些文件，它们会被误提交
- 首次提交后，需要用 `git rm --cached` 从跟踪中移除，再添加到 `.gitignore`
- 检查清单：`state.db*`、`memory_store.db*`、`*.db-wal`、`*.db-shm` 都应列入 `.gitignore`
- `auto_sync.sh` 的 `--exclude` 列表也需要同步更新，防止 rsync 把不需要的文件拷贝过去

详见 [`references/monorepo-setup.md`](references/monorepo-setup.md)（含脚本内容、cron配置、gitignore规则、初始化新机器步骤）。
外部独立仓库依赖关系见 [`references/external-repo-deps.md`](references/external-repo-deps.md)。

## Windows HERMES_HOME 路径问题（关键）

**问题：** Windows 上 Hermes 的运行时数据目录由 `HERMES_HOME` 环境变量决定。默认是 `C:\Users\<用户>\AppData\Local\hermes`，**不是** `~/.hermes`。

旧版 auto_sync.sh 硬编码 `~/.hermes`，导致同步的是旧数据。新版 auto_sync_v2.sh 改为读取 `$HERMES_HOME` 环境变量。

**验证方法：** `echo $HERMES_HOME` — 应输出类似 `/c/Users/77/AppData/Local/hermes`。

**跨设备恢复时：** 新设备的 HERMES_HOME 可能不同。拷贝文件时以环境变量为准，不要硬编码路径。

## 当前模式：单仓实文件 + 自动同步 v2

所有 Hermes 配置归入 **`~/Hermes/`**（`github.com/ethanol777/Hermes`），每30分钟自动同步。

**v2 同步脚本：`auto_sync_v2.sh`**（替代旧版 auto_sync.sh）

核心改进：
- 从 `$HERMES_HOME`（而非固定 `~/.hermes`）同步，适配 Windows/macOS/Linux
- `memories/` 目录不再整体 gitignore，核心文件进入版本控制
- 仅同步必要的核心文件，不同步 state.db（60MB）、sessions/、cache/、logs/ 等运行时数据
- 运行脚本放在 `$HERMES_HOME/scripts/` 而非 `$HOME/`

**同步范围（v2）：**

```
$HERMES_HOME/SOUL.md                    → ~/Hermes/hermes/SOUL.md
$HERMES_HOME/config.yaml                → ~/Hermes/hermes/config.yaml
$HERMES_HOME/memories/MEMORY.md         → ~/Hermes/hermes/memories/MEMORY.md
$HERMES_HOME/memories/USER.md          → ~/Hermes/hermes/memories/USER.md
$HERMES_HOME/memories/hot_candidates.txt → ~/Hermes/hermes/memories/hot_candidates.txt
$HERMES_HOME/memories/archive_index.md  → ~/Hermes/hermes/memories/archive_index.md
$HERMES_HOME/memories/archive/*         → ~/Hermes/hermes/memories/archive/
$HERMES_HOME/memories/fact_store.jsonl  → ~/Hermes/hermes/memories/fact_store.jsonl
$HERMES_HOME/skills/**                  → ~/Hermes/hermes/skills/**
$HERMES_HOME/cron/**                    → ~/Hermes/hermes/cron/**
$HOME/skills/**                         → ~/Hermes/user-skills/**
```

**不同步（v2 明确排除）：**

| 排除项 | 原因 |
|--------|------|
| state.db / state.db-* | 运行时数据库，60MB+，含 fact_store SQLite |
| memory_store.db | 运行时数据库 |
| kanban.db / response_store.db | 运行时临时数据 |
| sessions/ | 会话历史，设备特定 |
| cache/ logs/ audio_cache/ image_cache/ | 缓存，无需备份 |
| .env auth.json channel_directory.json | 密钥/认证，安全风险 |
| bin/ hooks/ node/ | 二进制/第三方工具 |
| hermes-agent/ | 源码，通过 pip 安装 |
| profiles/ output/ gallery/ tmp/ | 运行时生成内容 |

**memories/ 目录的 Git 跟踪修复：** 旧版 `.gitignore` 曾排除整个 `memories/` 目录，导致冷层记忆和温层备份不同步到 GitHub。修复后 `memories/` 仅排除 `.lock`、`.db`、`.db-shm`、`.db-wal` 文件，保留 `.md`、`.txt`、`.jsonl`。

**两层 .gitignore 陷阱：** 根 `.gitignore` 和 `hermes/.gitignore` 同时存在。修改忽略规则时两层都要改，否则内层规则会覆盖外层的 `!` 取消指令。

## 记忆数据同步说明

**温层（fact_store）双重存储：**

| 存储 | 路径 | 用途 |
|------|------|------|
| SQLite 源 | `$HERMES_HOME/state.db` | 运行时，不同步 |
| JSON 备份 | `$HERMES_HOME/memories/fact_store.jsonl` | Git 同步，新设备恢复用 |

维护 cron（每日 3am）负责将 fact_store 导出为 `.jsonl` 格式供 Git 同步。新设备恢复时，学习 cron 会在运行后自动重建温层数据。

## 跨设备完整恢复清单

要把 Hermes 功能和记忆完整搬运到新设备，以下是在 `~/Hermes/` git 仓库之外需要注意的：

### 🔴 必须手动处理（不进 git）

| 内容 | 说明 |
|------|------|
| `~/.hermes/.env` | 所有 API 密钥，**绝不要进 git**，换设备手动拷或重新配置 |

### 🟢 仓库已覆盖（clone 即有）

| 路径 | 说明 |
|------|------|
| `hermes/config.yaml` | 主配置（模型、工具集、记忆设置等） |
| `hermes/SOUL.md` | 身份定义 |
| `hermes/skills/` | 全部 skill |
| `hermes/scripts/` | 自动同步脚本、飞书推送脚本 |

### ✅ 当前已加入 Git 备份

以下目录/文件已从 rsync 排除列表和 `.gitignore` 中移除，现已在仓库中跟踪：

| 内容 | 说明 |
|------|------|
| `hermes/cron/` | 定时任务（AI资讯推送等），通过去除 rsync `--exclude='cron/'` 及两处 `.gitignore` 中的 `cron/` 行加入 |
| `hermes/profiles/` | 自定义 profile（coder/researcher/reviewer/writer），已被跟踪 |
| `hermes/output/` | 历史输出文件，已被跟踪 |
| `data/` | vectordb + viking 数据（~4M），通过新增 rsync 行加入 |

### ⚠️ 操作注意事项：嵌套 .gitignore 陷阱

**问题：** `~/Hermes/` 仓库中有**两个** `.gitignore` 文件：
1. `~/Hermes/.gitignore`（根级别）
2. `~/Hermes/hermes/.gitignore`（内层，从 `~/.hermes/.gitignore` 同步而来）

要取消忽略某个目录（如 `cron/`），**两个 `.gitignore` 都要改**。根 `.gitignore` 的 `!hermes/cron/` 无法覆盖内层 `.gitignore` 的 `cron/` 规则。

**修复方法：**
- 修改源文件 `~/.hermes/.gitignore`，加入 `!cron/` 取消防御（或直接删除 `cron/` 行）
- 修改 `~/Hermes/.gitignore`，加入 `!hermes/cron/`
- 然后运行一次 `auto_sync.sh` 或手动 `cp` 同步两份 `.gitignore`

**为什么需要 `!dir/`：** 在 `.gitignore` 中，`cron/` 会匹配**任何位置**的 `cron/` 目录。使用 `!cron/`（同一文件内）或 `!hermes/cron/`（父目录文件内）才能重新包含。注意：`!` 规则在同一 `.gitignore` 文件中才生效——内层文件里的 `cron/` 需要用内层文件的 `!cron/` 取消。

### auto_sync.sh 变更记录

| 变更 | 说明 |
|------|------|
| 移除 `--exclude='cron/'` | 让 `cron/` 能被 rsync 同步到仓库目录 |
| 新增 data/ 同步行 | `rsync -a --delete --exclude='.git' "$HOME/data/" "$HERMES/data/"` |

修改后，下一次 cron 自动同步会把这些新目录推送到 GitHub。

### 🟡 可选但低价值

| 内容 | 说明 |
|------|------|
| `hermes/hermes-agent/` | Hermes 源码，本身就是独立 git 仓库，clone 即可 |

### 🔴 不需要同步

- `sessions/`、`memories/`、`state.db` — 运行时/会话数据，大且设备特定
- `cache/`、`logs/`、`audio_cache/`、`image_cache/` — 缓存，无意义
- `bin/`、`node/`、`cloudflared` — 二进制/第三方工具

---

## 🚀 新机器恢复步骤

在另一台电脑上恢复完整的 Hermes 环境：

```bash
# 1. 克隆主仓库
git clone https://github.com/ethanol777/Hermes.git ~/Hermes

# 2. 链接运行时目录（或 cp）
ln -s ~/Hermes/hermes ~/.hermes

# 3. 克隆 Hermes 源代码
git clone https://gitcode.com/GitHub_Trending/he/hermes-agent.git ~/.hermes/hermes-agent

# 4. 安装依赖
cd ~/.hermes/hermes-agent && pip install -e .

# 5. 手动复制 API 密钥（不在 git 中）
# 将原机器的 ~/.hermes/.env 拷贝过来

# 6. 检查配置
hermes doctor

# 7. 验证定时任务
hermes cron list

# 8. 恢复 mission-control（如需要）
git clone https://github.com/builderz-labs/mission-control.git ~/mission-control
cp ~/Hermes/hermes/.env.mc ~/mission-control/.env  # 若有备份
cd ~/mission-control && pnpm install && pnpm build
tmux new-session -d -s mc 'pnpm start'

# 大功告成 🚀
```

---

## 历史参考：原先的多仓库模式

> 雨晨的环境已全部迁移到 **单仓实文件模式**（见上文）。本节仅作为历史参考保留。

原先的独立仓库（`hermes-config`、`hermes-skills`、`hermes-learnings`、`agentic-stack`）已不再使用。所有变更仅推送到 `ethanol777/Hermes`。

详见 [`references/monorepo-setup.md`](references/monorepo-setup.md)。
