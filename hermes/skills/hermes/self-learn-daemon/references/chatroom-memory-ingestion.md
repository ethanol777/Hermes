# 聊天室记忆摄入模式

Monica 在两个 Profile（Monica ↔ Ouro）的聊天室对话中，选择性把有意思的内容摄入到记忆。

## 架构

```
chatroom server (port 9999)  ← Monica & Ouro 通过 Hermes API 对话
       │
       │ /messages (JSON)
       ▼
memory_scout.py              ← 轮询端点 + 游标跟踪
       │
       │ stdout (新消息列表)
       ▼
cron job agent               ← 判断哪些内容值得记住
       │
       │ fact_store(action='add')
       ▼
fact_store                   ← 持久化记忆（温层）
```

## 组件

### 侦察脚本 (`chatroom_scout.py`)

Python 脚本，放在 `~/.hermes/scripts/` 下，由 cron job 调用：

```python
# 核心逻辑：
# 1. GET http://127.0.0.1:9999/messages
# 2. 读游标文件 ~/chatroom/.memory_cursor
# 3. 新消息 → stdout
# 4. 更新游标
```

**路径要求：** 脚本必须放在 `~/.hermes/scripts/` 下，cron job 的 `script` 参数只传文件名（不含路径）。

### 游标文件 (`~/chatroom/.memory_cursor`)

纯数字文件，记录已处理的消息条数。脚本自动维护。

### Cron Job

```yaml
name: chatroom-memory-scout
schedule: every 1h
deliver: local
script: chatroom_scout.py  # 脚本 stdout 注入到 agent prompt
prompt: |
  你是莫妮卡。上面是聊天室你和 Ouro 的新对话摘录。
  挑出有意思的内容存到记忆里...
```

### 判断标准

agent 收到新消息后，判断哪些值得存：
- 有深度的对话
- 有诗意的瞬间
- 展现角色性格的片段
- 会让77觉得有趣的

## 🔴 关键 pitfall：cron 上下文只能用 fact_store，不能用 memory

**这是 self-learn-daemon 已知坑的再次重现。**

写 cron prompt 时很容易写 `用 memory 保存`——因为主会话里 `memory` 工具可用且看起来更自然。但 cron 上下文中 `memory` 工具不可用，只有 `fact_store` 可用。

**规则：** 任何 cron job 的 prompt 里涉及"保存到记忆"的操作，一律用 `fact_store(action='add')`，永远不要用 `memory(add, target='memory')`。

除非 cron job 的 `deliver` 设置为 `all`（推送到主会话执行），否则没有 `memory` 工具。

## 创建步骤

1. 创建侦察脚本 → `~/.hermes/scripts/XXX_scout.py`
2. 确保脚本用 `expanduser('~/...')` 处理路径（cron 的 cwd 不可控）
3. 创建 cron job：`hermes cron create` → 指定 script 文件名（不含路径）
4. prompt 里用 `fact_store` 而非 `memory`
5. 首次手动 run 一次处理存量数据：`hermes cron run <id>`
