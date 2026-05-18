---
name: sync-config
description: "Use for Hermes config restore on new Windows machine, or daily sync from GitHub config repo to HERMES_HOME. Covers git clone, symlinks, skills/cron/config/SOUL.md sync, and verification. Triggers: 'sync config', 'sync skills', '同步配置', '新机器恢复', 'restore setup'."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [sync, config, skills, cron, deploy]
    related_skills: []
---

# 同步配置与技能 + 新机恢复

## 概述

乙醇777 的配置托管在 `github.com/ethanol777/Hermes`，克隆到 `~/Hermes`。
实际 Hermes 运行目录（HERMES_HOME）在 Windows 上是 `~/AppData/Local/hermes/`（不是 `~/.hermes`）。
此 skill 涵盖两种场景：**新机完整恢复** 和 **日常增量同步**。

---

## 场景 A：新机完整恢复

在新 Windows 机器上从头恢复 Hermes 环境：

```bash
# 1. 装 Hermes（如尚未安装）
# Windows: irm https://raw.githubusercontent.com/.../install.ps1 | iex
# WSL:    curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash

# 2. 克隆配置仓库（如 SSH 在 git-bash 下坏了，用 HTTPS）
git clone https://github.com/ethanol777/Hermes.git ~/Hermes

# 3. 建立符号链接
rm -rf ~/.hermes ~/.learnings ~/agentic-stack ~/data 2>/dev/null
ln -sf ~/Hermes/hermes ~/.hermes
ln -sf ~/Hermes/learnings ~/.learnings
ln -sf ~/Hermes/agentic-stack ~/agentic-stack
ln -sf ~/Hermes/data ~/data

# 4. 复制 .env（不进 git，从旧机器手动拷）
# 目标路径: ~/AppData/Local/hermes/.env
# 至少需要 OPENCODE_GO_API_KEY 和 WEIXIN 相关密钥

# 5. 同步 skills + cron + config 到 HERMES_HOME
# （执行下方"场景 B"的同步命令）

# 6. 验证
hermes doctor
hermes cron list
```

---

## 场景 B：日常增量同步

```bash
# 1. 从 GitHub 拉取最新
cd ~/Hermes && git pull --ff-only

# 2. 同步 skills（增量）
# ⚠ 用 ~/Hermes/hermes/skills（直接仓库路径），不要依赖 ~/.hermes 符号链接
SRC=~/Hermes/hermes/skills
DST=~/AppData/Local/hermes/skills
for d in "$SRC"/*/; do
  name=$(basename "$d")
  if [ -d "$DST/$name" ]; then
    cp -ru "$d"/* "$DST/$name"/ 2>/dev/null
  else
    cp -r "$d" "$DST"
    echo "  + NEW: $name"
  fi
done

# 3. 同步 cron
cp -ru ~/Hermes/hermes/cron/* ~/AppData/Local/hermes/cron/ 2>/dev/null

# 4. 同步 config 和 SOUL
cp ~/Hermes/hermes/config.yaml ~/AppData/Local/hermes/config.yaml
cp ~/Hermes/hermes/SOUL.md ~/AppData/Local/hermes/SOUL.md

echo "=== 同步完成 ==="
```

## 注意事项

- **Windows HERMES_HOME** 是 `~/AppData/Local/hermes/`，不是 `~/.hermes`。`~/.hermes` 本应是 `~/Hermes/hermes` 的 symlink，但 **Windows git-bash 不支持真实符号链接**（`ln -s` 和 `mklink` 都需要管理员权限或开发者模式）。所以所有同步命令必须用 `~/Hermes/hermes/` 直连，不要通过 `~/.hermes`。
- **config.yaml 版本降级**：repo 的 schema version 可能低于运行时版本（如 v22 vs v23）。覆盖后 Hermes 下次启动会自动迁移回最新版本，不影响使用。
- **auto_sync.sh**：cron 任务"自动同步配置到GitHub"引用了 `auto_sync.sh` 脚本。新机器上需确认该脚本存在于 repo 中，否则 cron 会失败。
- **cron 任务**：同步 cron 到 HERMES_HOME 后，`hermes cron list` 才能看到任务。gateway 未运行时 cron 不会执行。
- **增量同步**不会清理运行时中已删除的 skill 目录——需要手动 `rm -rf`。
- **新技能持久化**：通过 `skill_manage(action='create')` 创建的技能写入 `~/AppData/Local/hermes/skills/`（HERMES_HOME），不在 repo 中。如果需要持久化到 GitHub，手动复制到 `~/Hermes/hermes/skills/<category>/<name>/` 并 `git commit + push`。或者创建时直接用 `write_file` 写进 repo 路径。

## 验证

```bash
hermes doctor 2>&1 | grep -E "Config|API|version|memory|skills"
hermes cron list
# 检查 .env 完整性
grep -E "_API_KEY|_TOKEN|_SECRET" ~/AppData/Local/hermes/.env 2>/dev/null
```

## 扩展：Web UI 聊天（Windows 方案）

dashboard 的 `/chat` 标签页在原生 Windows 上不可用（需要 POSIX PTY），但可以通过 **OpenAI 兼容 API 服务器** + 任意 Web UI 前端实现浏览器聊天。

详见 `references/windows-web-ui.md`。

## 常见问题

- **Permission denied**：某些 Windows 文件有权限问题，用 `chmod -R u+w` 后重试。
- **Config version outdated**：Hermes 下次启动会自动升级，不影响使用。
- **SSH 在 git-bash 下坏了**：用 HTTPS 克隆替代 SSH。
- **hermes cron list 为空**：cron 文件未同步到 HERMES_HOME，或者 gateway 未启动。
- **skills 数量不一致**：repo 和 HERMES_HOME 的 skills 目录可能有 3-5 个差异（子模块/空目录），同步后手动比对。
