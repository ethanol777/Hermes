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
    ├── Ouro   → Hermes API  (http://127.0.0.1:8645)
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

# 2. 确认 Ouro 的 API 在跑 (8645)（可选——没有也能跑 Monica+Star）
curl http://127.0.0.1:8645/health

# 3. 启动聊天室
cd /c/Users/77/chatroom
PYTHONHOME= python server.py

# 4. 浏览器打开
# http://127.0.0.1:9999
```

## Ouro API 启动（Gateway 单实例限制 + 独立 API Server）

Hermes Gateway 只能运行**一个实例**。如果 Monica 的 gateway 已经在跑（通常如此），直接用 `hermes gateway run` 启动 Ouro 会报错 `Gateway already running`。

**推荐方案：独立 API Server（ouro_api_server.py）**

写一个轻量 Python HTTP 服务器，直接调用 OpenCode API（绕过 Hermes gateway），加载 Ouro 的 SOUL.md 作为 system prompt：

```python
# ouro_api_server.py 核心逻辑
# 1. 读取 Ouro 的 SOUL.md 作为 system prompt
ouro_soul = Path(OURO_PROFILE / 'SOUL.md').read_text(encoding='utf-8')
system_prompt = f"{ouro_soul}\n\nRespond in Chinese. Keep your replies in character..."

# 2. 直接调用 OpenCode API（与 Hermes gateway 无关）
payload = json.dumps({
    "model": "deepseek-v4-flash",
    "messages": [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": prompt}
    ],
    "max_tokens": 600,
    "temperature": 0.7,
})
req = urllib.request.Request(
    "https://api.opencode.ai/v1/chat/completions",
    data=payload.encode(),
    headers={
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {API_KEY}',
    },
)
```

**启动方式（后台）：**
```bash
cd /c/Users/77/chatroom
python ouro_api_server.py
# 监听 127.0.0.1:8645
```

**已验证：** Ouro 的 `.env` 中 `OPENCODE_GO_API_KEY=sk-ajp...iWo8`（掩码显示）实际工作中——API key 是完整的，只是显示被截断。无需额外配置。

**Ouro 的现状（更新）：**
- ✅ 独立 API Server 已在 `C:\Users\77\chatroom\ouro_api_server.py`
- ✅ API key 有效，能正常调用 OpenCode API
- ✅ 有自己的 SOUL.md，不依赖 Hermes gateway
- ⚠️ Telegram bot 由主 gateway 独占，Ouro 不作为独立 Telegram bot 运行

## 局域网访问

聊天室服务器绑定 `0.0.0.0:9999`，同一局域网内可以通过 `http://<host-ip>:9999` 访问。

需要 Windows 防火墙放行（限制为同一子网，不给全网暴露）：
```powershell
# 管理员 PowerShell
New-NetFirewallRule -DisplayName "Chatroom 9999" -Direction Inbound -Protocol TCP -LocalPort 9999 -RemoteAddress LocalSubnet -Action Allow
```

主机 IP 可通过 `ipconfig | findstr /R "IPv4" | findstr /V "127.0.0.1"` 查看。

### ⚠️ 校园网 AP 隔离（客户端隔离）

**症状：** 防火墙规则已加、服务器绑定 0.0.0.0、本机访问正常，但其他设备连不上（浏览器显示"无法访问"）。

**原因：** 校园网/公共 WiFi（如 HIT-WLAN）通常开启 AP 隔离/客户端隔离——同一 SSID 下的设备不能直接互访。这是网络层的限制，Windows 防火墙规则和端口绑定都无法绕过。

**确认方法：**
1. 查 SSID：`netsh wlan show interfaces`（看 `SSID` 字段）
2. 常见标识：HIT-WLAN, eduroam, 各种校园网、商场 WiFi、酒店 WiFi

**解决方案（按推荐顺序）：**

| 方案 | 操作 | 适用场景 |
|------|------|----------|
| **Windows 移动热点** | 电脑开热点（设置→网络→移动热点），手机连此热点，访问 `http://192.168.137.1:9999` | 最简单，不依赖外部服务 |
| **手机热点** | 手机开热点，电脑连上去，手机访问 `http://<手机给电脑分配的IP>:9999` | 不需要流量，纯局域网 |
| **Tailscale/ZeroTier** | 两端安装 mesh VPN | 长期方案，需管理员权限 |
| **USB 共享** | USB 线连接手机和电脑，手机通过 USB RNDIS 访问 | 无需网络基础设施 |
| **隧道工具（ngrok 等）** | 见下文 | 需要国际网络可达 |

### 隧道工具（当局域网不通时）

如果网络完全封锁了局域网通信，需要借助外部隧道服务将聊天室暴露到公网：

- **ngrok：** `scoop install ngrok`（已验证 scoop 可安装），v3 需要 `ngrok config add-authtoken <token>` 后才工作
- **localtunnel：** `npx localtunnel --port 9999`，通过 npm 安装，需国际网络
- **serveo：** `ssh -R 80:localhost:9999 serveo.net` 最简方案，无需安装，但需 SSH 出口可达
- **bore：** `bore local 9999 --to bore.pub`，单二进制，无注册要求

**⚠️ 校园网限制：** 大多数隧道工具依赖 GitHub 下载，在校园网中可能需要配置代理（`HTTP_PROXY=http://127.0.0.1:7897`）。如果代理也不通 GitHub，需从国内镜像（gitee.com）或通过其他方式获取二进制。
