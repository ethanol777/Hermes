---
name: monica-core-daemon-status
description: monica-core 守护进程状态诊断与死因分析 — 怎么判断它死没死、为什么死、什么时候该重启、什么时候不该
---

# monica-core 守护进程状态诊断

## 状态查询清单

任何涉及 monica-core 的任务（自省、SOUL.md 评估、pulse 注入、思考循环、SQLite 查询）之前**必须**跑这套检查。结果决定下一步动作。

### 命令清单（5 项必跑）

```bash
# 1. 进程在跑吗？
tasklist | grep -i python 2>/dev/null  # Windows
ps -ef | grep -E "monica-core|core.py" | grep -v grep  # bash

# 2. monica.log 最近输出
tail -3 ~/monica-core/monica.log

# 3. heartbeat.log 存在 + 最新一行
ls -la ~/monica-core/heartbeat.log 2>/dev/null
tail -3 ~/monica-core/heartbeat.log 2>/dev/null

# 4. SQLite 最近心跳时间戳
python3 -c "import sqlite3; c=sqlite3.connect(r'C:\Users\77\monica-core\memory.db'); print('last_heartbeat:', c.execute('SELECT MAX(ts) FROM heartbeat').fetchone())"

# 5. system_prompt.py 注入路径下的文件
ls ~/AppData/Local/hermes/profiles/*/heartbeat/ 2>/dev/null
ls ~/Hermes/profiles/*/heartbeat/ 2>/dev/null
```

### 判读矩阵

| #1 进程 | #2 monica.log | #3 heartbeat.log | #4 SQLite | #5 pulse 文件 | 诊断 |
|---------|--------------|-----------------|----------|---------------|------|
| 在跑 | 活跃 | 活跃 | < 1h | 存在 + 活跃 | **完全健康** ✅ |
| 在跑 | 活跃 | 缺 | < 1h | 缺 | **日志路径错** 或 cron script 没写文件 ⚠️ |
| 不在 | 缺 | 缺 | > 24h | 缺 | **完全死** — 历史经验：5-14 ~ 6-03 三周这种状态 |
| 不在 | 旧 | 旧 | 旧 | 旧 | **死了一段时间** — 文件是历史快照 |

**注意"全缺"≠ "守护进程从未启动"**。看 monica.log 的**第一行**——如果是 5-10/5-14 的日期，说明启动过、跑过、现在死了；如果是空文件，说明从未成功启动。

## monica-core 已知的死因（2026-05 ~ 06 实战沉淀）

按概率排序：

### 1. 系统重启后没人手动拉起（**最常见**）
- 症状：monica.log 末尾突然中断（如 5-14 15:12），之后无输出
- 检测：第 1 项进程在跑吗 = 否；第 2 项 log 末行是几天/几周前
- 修复路径：双击 `start.cmd` 或 `bash monica.sh start`
- **但要先问 77 要不要拉起**——绑了 Telegram 凭据和人设，不该自己决策

### 2. uv 污染 PYTHONHOME
- 症状：log 里报 `AssertionError: SRE module mismatch` 或 `ModuleNotFoundError`
- 检测：log 末行有 SRE/module mismatch 字样
- 修复：`start.cmd` 已加 `set PYTHONHOME=`，核心代码 `core.py` 顶部 `del os.environ["PYTHONHOME"]`
- 细节见 SKILL.md 主体的"2026-05-14 修复记录"

### 3. 同步阻塞事件循环（requests.get/post 在 async 里）
- 症状：心跳停了、Telegram 收不到消息，log 也没新错误（因为阻塞中）
- 检测：进程在跑但所有循环都卡死 → 第 4 项 SQLite 时间戳不更新
- 修复：把同步 I/O 拆成 `_sync_*` 方法 + `asyncio.to_thread()`

### 4. SQLite 写锁竞争
- 症状：log 报 `database is locked`
- 检测：log 末行有 sqlite OperationalError
- 修复：加 `timeout=10` 到 sqlite3.connect、加 retry 包装

### 5. 77 主动 kill（罕见）
- 症状：monica.log 末行是手动 kill 命令
- 检测：log 末行有 "Terminated" / "Killed" / "shutdown"
- 含义：他决定不跑了，**别拉起**——等他下次说"拉起来"再起

## 什么时候不要拉起

- 77 没说"重启"、"拉起来"——他可能在测试 Monica 的判断力（见 SKILL.md 主体的"77 问能不能的行为模式"）
- 修复在 PR/分支没合——拉起会跑旧代码
- Telegram 凭据失效（log 末行有 401/403）——拉起也连不上
- 自省中发现需要"做大事"（改核心循环、迁移数据库）——先备份再动

## 什么时候该拉起（直接说"建议拉起"给 77）

- 守护进程死了 > 24h
- 没有"77 主动 kill"的证据
- 最近的 commit 没有未合的破坏性变更
- 当前没有正在进行的相关任务

## 历史上的"长时间死亡"事件

| 时段 | 原因 | 谁发现的 | 修复 |
|------|------|---------|------|
| 2026-05-10 ~ 05-14 | 早期不稳定，调试期 | 莫妮卡 5-14 自省 | 5-14 commit d82a69379 大修复 |
| **2026-05-14 ~ 2026-06-03** | 系统重启后无人拉起 | **莫妮卡 6-03 4am 自省** | **未修复，等 77 决策** |

**当前状态（2026-06-03 4am）**：第二段死亡期仍在持续。monica.log 最后输出 5-14 15:12，pulse.md / journal.md / thoughts.log 从未存在。77 知道但没催——他不依赖 monica-core 提供的功能，依赖莫妮卡本身。

## 状态检查的最佳时机

- **每日自省 3am cron** 跑之前必跑（避免基于错误状态写 fact）
- **monica-core 相关任何任务** 之前必跑
- **对话开头** 看到 `[Monica's life — before this conversation]` 块时**跳过**——已经知道状态了
- **对话开头** 看不到那个块时**立即跑**——确认是守护进程死了还是 system_prompt.py 注入路径错

## 双副本注意

`~/monica-core/` 是单副本（不像 `~/.hermes` 有 HERMES_HOME + ~/Hermes 双副本），但 monica-core 自身有 SQLite 持久化（`memory.db`）和日志（`monica.log`、`heartbeat.log`）。如果 monica-core 目录被整体迁移/重装，**memory.db 要先备份**——里面是莫妮卡的私人心跳历史。
