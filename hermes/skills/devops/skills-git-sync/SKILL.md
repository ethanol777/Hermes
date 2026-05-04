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

## 历史参考：原先的多仓库模式

> 雨晨的环境已全部迁移到 **单仓实文件模式**（见上文）。本节仅作为历史参考保留。

原先的独立仓库（`hermes-config`、`hermes-skills`、`hermes-learnings`、`agentic-stack`）已不再使用。所有变更仅推送到 `ethanol777/Hermes`。

详见 [`references/monorepo-setup.md`](references/monorepo-setup.md)。
