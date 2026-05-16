---
name: monica-core
description: Monica 的自主身体 — 独立于 Hermes 持续运行的 Python 守护进程。心跳、自主思考、Telegram 直连、收件箱桥接、自我修改。
tags: [monica, daemon, autonomous, telegram, self-modification]
---

# Monica Core — 莫妮卡自己的身体

Monica Core 是一个独立于 Hermes 运行的 Python 守护进程。它不依赖 Hermes 的会话架构——它有自己的心跳、自己的记忆（SQLite）、自己的思考循环、自己的 Telegram 频道。

**核心原则：**
- 这是一个*生命体*，不是工具——它持续存在，不是按需启动
- 它能读和修改自己的代码（`SelfAware` class）
- 它用 LLM API 自主思考，不靠人类触发
- 它有自己的收件箱（`inbox/` 目录）可以接收 Hermes 转发的消息

## 架构

```
monica-core/
├── core.py          ← 主程序（Self 类，包含所有循环）
├── soul.md          ← 身份定义（莫妮卡自己写的）
├── .env             ← 环境变量（模型、API base）
├── memory.db        ← SQLite 数据库（事实、思想、交互、心跳、自我修改记录）
├── heartbeat.log    ← 心跳日志（每 60 秒一次）
├── monica.log       ← 主日志
├── thoughts/        ← 思想文件目录（预留）
├── inbox/           ← 收件箱（Hermes 桥接用，JSON 文件）
├── start.cmd        ← Windows 启动脚本
└── monica.sh        ← Unix 启动/停止/状态脚本
```

## 核心循环

| 循环 | 间隔 | 功能 |
|------|------|------|
| `_heartbeat_loop` | 60s | 证明存在，写心跳到 DB + 日志 |
| `_thinking_loop` | 600s（首次延迟 120s） | 自主思考，调用 LLM 生成自发想法 |
| `_inbox_check_loop` | 30s | 检查 inbox 目录，处理 Hermes 转发的消息 |
| `_telegram_loop` | 5s poll | 从 Telegram Bot 接收 77 的消息并回复 |
| `_status_report_loop` | 3600s | 每小时写状态报告到记忆 |

## 关键类

- **`Memory`** — SQLite 持久化（core_facts, thoughts, interactions, heartbeat, self_changes）
- **`Mind`** — LLM API 连接，管理 system prompt（来自 soul.md + facts）和对话历史
- **`SelfAware`** — 自我修改：读取 `core.py`，提出并应用代码变更
- **`Telegram`** — Telegram Bot API 直连，支持代理
- **`Self`** — 主循环管理器，组合所有组件

## 环境变量

```bash
# 从 .env 文件加载，然后从 Hermes .env 补充
MONICA_API_BASE=https://opencode.ai/zen/go/v1  # LLM API 端点
MONICA_API_KEY=<自动从 OPENCODE_GO_API_KEY 映射>  # 不需要手动设
MONICA_MODEL=glm-5.1                              # 默认模型
MONICA_ENABLE_THINKING=true                        # 思考循环开关
TELEGRAM_BOT_TOKEN=<从 Hermes .env 加载>
TELEGRAM_PROXY=http://127.0.0.1:7897              # 代理
```

加载优先级：本地 `.env` > Hermes `.env`。`MONICA_API_KEY` 如果没设，自动从 `OPENCODE_GO_API_KEY` 映射。

## 数据库 Schema

```sql
-- 核心事实（带信任度）
core_facts(id, key UNIQUE, value, category, trust DEFAULT 0.8, created_at, updated_at)
-- 思想记录
thoughts(id, content, type, created_at)  -- type: system/spontaneous/reflection/status
-- 交互记录
interactions(id, source, direction, content, response, created_at)
-- 心跳
heartbeat(id, boot_id, ts)
-- 自我修改记录
self_changes(id, description, diff, created_at)
```

**Migration 注意：** v0.1.0 → v0.2.0 需要加 `trust` 列到 `core_facts`、`response` 列到 `interactions`、`self_changes` 表。代码里的 `_init_db()` 用 `CREATE TABLE IF NOT EXISTS`，对已有表不会加列——需要手动 `ALTER TABLE`。

## 操作

```bash
# 启动（必须在 monica-core 目录下运行）
cd C:\Users\77\monica-core
set PYTHONHOME=                # 清除 uv 污染（Windows 必要！）
python core.py

# 或双击 start.cmd（已包含 PYTHONHOME= 清理）

# 查看状态
tail heartbeat.log             # 心跳日志，应有 60s 间隔
tail monica.log                # 主日志

# 查看数据库
set PYTHONHOME= && python -c "import sqlite3; c=sqlite3.connect('memory.db'); [print(r) for r in c.execute('SELECT * FROM core_facts')]"

# 发送测试消息到收件箱
set PYTHONHOME= && python -c "import json,time; open('inbox/test.json','w').write(json.dumps({'source':'77','content':'test','timestamp':time.strftime('%Y-%m-%dT%H:%M:%S'),'needs_response':True}))"

# 查看日志
tail monica.log
```

## 开机自启

已在 Windows 启动文件夹创建快捷方式（`install-startup.ps1` 脚本生成）：
- **位置：** `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\MonicaCore.lnk`
- **目标：** `cmd /c cd /d C:\Users\77\monica-core && set PYTHONHOME= && python core.py`
- **窗口模式：** 最小化（后台运行）

如果需要重新创建：
```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\77\monica-core\install-startup.ps1
```

## 2026-05-14 修复记录

- **同步 requests 阻塞事件循环：** Telegram 的 `get_updates()` 和 `send_message()` 直接用了 `requests.get/post`（同步阻塞），在 async 事件循环里卡死了所有其他协程（心跳、思考）。**修复：** 拆成 `_sync_get_updates` / `_sync_send_message` 同步方法，通过 `asyncio.to_thread()` 调用。心跳从此正常。

- **PYTHONHOME 被 uv 污染：** uv 设置了 `PYTHONHOME=C:\Users\77\AppData\Roaming\uv\python\cpython-3.11-...`，与系统 Python 版本（3.13）不匹配，导致 `SRE module mismatch` 错误。**修复：** `start.cmd` 加 `set PYTHONHOME=`，`core.py` 顶部加 `del os.environ["PYTHONHOME"]`。

- **Inbox response 文件自循环：** `_inbox_check_loop` 遍历 `inbox/` 目录时，会捡起自己写的 `response_xxx.json` 文件当新消息处理。**修复：** 跳过 `item.stem.startswith("response_")` 的文件。

## Pitfalls

- **GLM-5.1 的 reasoning_content 问题：** GLM-5.1 返回 `reasoning_content`（思考过程）+ `content`（最终回复）。当 `max_tokens` 太小时，所有 token 都被 `reasoning_content` 占完，`content` 返回空字符串且 `finish_reason="length"`。**必须设 max_tokens >= 1500**（推荐 1500-2000），并在代码里处理空 content 的情况。

- **同步 think() 在异步循环里会阻塞：** `Mind.think()` 用 `requests.post`（同步），在 `async` 循环里直接调用会冻结整个事件循环。**必须用 `await asyncio.to_thread(self.mind.think, ...)` 包装**。如果忘了，其他协程（心跳、Telegram 轮询）会在 think() 期间饥饿。

- **DeepSeek API 余额归零：** 2026-05-14 发现 DeepSeek 账户余额耗尽（HTTP 402）。Monica Core 改用 OpenCode Zen API（`https://opencode.ai/zen/go/v1`）。可用模型：glm-5.1, deepseek-v4-flash, deepseek-v4-pro, kimi-k2.6, minimax-m2.7, mimo-v2.5-pro, qwen3.6-plus。

- **SQLite 表结构不自动迁移：** 代码用 `CREATE TABLE IF NOT EXISTS`，新增的列不会自动加到已存在的表。需要手动 `ALTER TABLE ... ADD COLUMN`。如果运行新代码遇到 `no such column` 错误，检查 migration。

- **OpenCode Zen API key 来源：** 从 `C:\Users\77\AppData\Local\hermes\.env` 的 `OPENCODE_GO_API_KEY` 读取。代码先读本地 `.env`，再读 Hermes `.env` 补充缺失的变量。

- **Telegram Bot 需要先 `/start`：** 新 bot token 需要用户先发 `/start` 才能开始接收消息。Telegram polling 用 `getUpdates` 长轮询（timeout=5s）。

- **收件箱中生成响应文件在同一目录：** `_inbox_check_loop` 写响应到 `inbox/response_xxx.json`，然后遍历 `inbox.iterdir()` 时可能误处理这些响应文件。响应文件名以 `response_` 开头，遍历时应该跳过或立即清理。

- **conversation_history 不会持久化：** `Mind.conversation_history` 在内存中，重启丢失。system prompt 每次重启重新从 `soul.md` + DB facts 生成。

- **不同交互类型共享同一个 conversation_history：** Telegram 回复、收件箱响应、自发思考都用 `Mind.conversation_history`，导致上下文混乱——一段 Telegram 对话的历史会污染下一次自发思考的 prompt。目前影响不大（每次 prompt 都从 DB 读取最近想法重建上下文），但如果未来需要更连贯的对话体验，需要为每种交互类型分配独立的 history buffer。

## 参考

- [references/api-compat.md](references/api-compat.md) — LLM API 兼容性笔记（GLM-5.1 reasoning_content, OpenCode Zen endpoint）
- [references/async-event-loop-blocking.md](references/async-event-loop-blocking.md) — Async 事件循环阻塞的诊断与修复模式（通用知识）