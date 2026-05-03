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

详细设置见 [`references/monorepo-setup.md`](references/monorepo-setup.md)（含脚本内容、cron配置、gitignore规则、初始化新机器步骤）。

## 历史参考：原先的多仓库模式

> 雨晨的环境已全部迁移到 **单仓实文件模式**（见上文）。本节仅作为历史参考保留。

原先的独立仓库（`hermes-config`、`hermes-skills`、`hermes-learnings`、`agentic-stack`）已不再使用。所有变更仅推送到 `ethanol777/Hermes`。

详见 [`references/monorepo-setup.md`](references/monorepo-setup.md)。
