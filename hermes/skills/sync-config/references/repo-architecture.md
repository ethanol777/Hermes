# Hermes 配置仓库结构

仓库: `github.com/ethanol777/Hermes`

```
Hermes/
├── hermes/                  ← 主配置（symlink 目标 ~/.hermes）
│   ├── config.yaml          ← Hermes 完整配置（v22，385 skills）
│   ├── SOUL.md              ← 人格设定文件（莫妮卡/简约版）
│   ├── cron/
│   │   ├── jobs.json        ← 3 个定时任务定义
│   │   └── output/          ← cron 执行输出日志
│   ├── scripts/             ← 辅助脚本
│   ├── skills/              ← 67 个 skill（按类别分目录）
│   └── profiles/            ← 配置文件
├── learnings/
│   ├── LEARNINGS.md         ← 10 条经验教训
│   ├── ERRORS.md            ← 3 个已解决错误
│   └── FEATURE_REQUESTS.md  ← 功能请求
├── agentic-stack/           ← 跨 Agent 记忆层（含 .agent/ 便携大脑）
└── data/                    ← 运行时数据（vectordb、viking）
```

# 3 个 Cron 任务

| 任务 | 调度 | 目标 | 说明 |
|------|------|------|------|
| 每日AI资讯推送 | 每天 9:00 (cron) | 飞书 | 搜索最新 AI 资讯，写入飞书表格并发送消息卡片 |
| 自动同步配置到GitHub | 每 30 分钟 (interval) | GitHub | 执行 `auto_sync.sh`，已执行 312+ 次 |
| 记忆自动维护 | 每天 3:00 (cron) | 本地 | 清理低信任度事实、检查 memory 容量 |

# Windows 路径要点

- **HERMES_HOME**: `~/AppData/Local/hermes/`（Hermes 实际读的目录）
- **~/.hermes**: 意图是 `~/Hermes/hermes` 的符号链接，但 Windows git-bash 不支持（ln -s 和 mklink 需管理员权限），现在是独立目录
- **同步方向**: GitHub → `~/Hermes/hermes/` (git pull) → `~/AppData/Local/hermes/` (cp -ru)
