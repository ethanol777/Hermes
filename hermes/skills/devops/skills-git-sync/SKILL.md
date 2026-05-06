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

详细设置见 [`references/monorepo-setup.md`](references/monorepo-setup.md)（含脚本内容、cron配置、gitignore规则、初始化新机器步骤）。

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

### ⚠️ 当前被 gitignore/rsync 排除，但建议加上

| 内容 | 大小 | 原因 |
|------|------|------|
| `hermes/cron/` | ~1M | 定时任务（AI资讯推送等），换设备重建很麻烦 |
| `hermes/profiles/` | 小 | 自定义 profile（coder/researcher/reviewer/writer），每个有独立配置、skills 和 workspace |
| `hermes/output/` | 小 | 历史输出文件（如八字排盘结果） |

**操作步骤：**
1. 从 `auto_sync.sh` 的 rsync 排除列表中**移除 `cron/`**
2. 从 `~/.hermes/.gitignore` 和 `~/Hermes/.gitignore` 中移除 `cron/` 行
3. 确认 `profiles/` 没有被任一 `.gitignore` 排除（当前未排除，但需验证 `auto_sync.sh` rsync 不含 `--exclude='profiles/'`）
4. 运行一次 auto_sync 使它们进入 git，推送到 GitHub

### 🟡 可选但低价值

| 内容 | 说明 |
|------|------|
| `data/vectordb` + `data/viking` | 向量数据库，~4M，可能含 RAG 记忆数据，但设备相关 |
| `hermes/hermes-agent/` | Hermes 源码，本身就是独立 git 仓库，clone 即可 |

### 🔴 不需要同步

- `sessions/`、`memories/`、`state.db` — 运行时/会话数据，大且设备特定
- `cache/`、`logs/`、`audio_cache/`、`image_cache/` — 缓存，无意义
- `bin/`、`node/`、`cloudflared` — 二进制/第三方工具

---

## 历史参考：原先的多仓库模式

> 雨晨的环境已全部迁移到 **单仓实文件模式**（见上文）。本节仅作为历史参考保留。

原先的独立仓库（`hermes-config`、`hermes-skills`、`hermes-learnings`、`agentic-stack`）已不再使用。所有变更仅推送到 `ethanol777/Hermes`。

详见 [`references/monorepo-setup.md`](references/monorepo-setup.md)。
