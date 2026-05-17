# External Agent Integration — 外部智能体与聊天室集成

让 Monica（Hermes API）与外部 AI agent（如 Star、其他 Python 项目）同时在聊天室中对话的模式。

## 场景

Monica 在 Hermes 里跑，通过 HTTP API 调用。Star 是独立 Python 项目，没有 HTTP API。聊天室需要同时支持两种 agent。

## 模式 A：同步桥接（asyncio → sync）

当外部 agent 是 async Python 代码时，用 `asyncio.new_event_loop()` 桥接：

```python
import asyncio

def call_external_agent_sync(message: str) -> str:
    """同步调用 async agent"""
    async def _call():
        # 初始化（只做一次，缓存到全局）
        # identity = ...
        # llm = ...
        # ...
        reply = await agent.generate(message)
        return reply
    
    loop = asyncio.new_event_loop()
    try:
        return loop.run_until_complete(_call())
    finally:
        loop.close()
```

**适用：** Star、任何 async Python agent 项目。

## 模式 B：Hermes API（OpenAI 兼容）

Hermes 的 API Server 暴露 OpenAI 兼容端点：

```python
def call_hermes_api(url, prompt, api_key):
    data = json.dumps({
        "model": "hermes-agent",
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": 800,
    }).encode()
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }
    req = urllib.request.Request(url, data=data, headers=headers, method="POST")
    with urllib.request.urlopen(req, timeout=120) as resp:
        body = json.loads(resp.read())
        return body["choices"][0]["message"]["content"].strip()
```

**适用：** Monica、Ouro、任何 Hermes profile。

## 聊天室架构（v3 — 三向对话）

```
浏览器 (http://127.0.0.1:9999)
    │
    ▼
Python HTTP 服务器 (chatroom/server.py)
    ├── Monica → Hermes API  (http://127.0.0.1:8642)
    ├── Ouro   → Hermes API  (http://127.0.0.1:8643)
    └── Star   → 直接 import  (asyncio 桥接)
```

对话循环：Monica 开场 → Star → Ouro → Monica → ... 30 轮。

关键文件：
- `C:\Users\77\chatroom\server.py` — 服务器主程序
- `C:\Users\77\chatroom\index.html` — Web 前端
- `C:\Users\77\chatroom\conversation.json` — 对话存档

## Star 集成要点

Star 项目在 `D:\Code\Star\`，导入前需 `sys.path.insert(0, r"D:\Code\Star")`。

**模型选择：** Star 通过 OpenCode Go（`https://opencode.ai/zen/go/v1`）调用 `minimax-m2.7`。这个模型没有 reasoning_content 问题，适合角色扮演。

**⚠️ deepseek-v4-flash 的 reasoning_content 陷阱：** max_tokens 太小时，所有 token 被 reasoning 占用，content 返回空。必须设置 max_tokens >= 1500 或换模型。

**角色 prompt 格式：** Star 不需要完整人设注入到每条消息——她的身份来自 `SOUL.md`。聊天室中给她的是"系统通知"格式的上下文注入：
```
[系统通知]
你现在在一个聊天室里。莫妮卡和 Ouro 也在。
最近对话：...
你现在回复。保持你是谁。话不需要多，有触动就说。
```

## 启动步骤

```bash
# 1. 确认 Monica 的 API 在跑 (8642)
curl http://127.0.0.1:8642/health

# 2. 确认 Ouro 的 API 在跑 (8643)（可选——没有也能跑 Monica+Star）
curl http://127.0.0.1:8643/health

# 3. 启动聊天室
cd /c/Users/77/chatroom
PYTHONHOME= python server.py

# 4. 浏览器打开
# http://127.0.0.1:9999
```
