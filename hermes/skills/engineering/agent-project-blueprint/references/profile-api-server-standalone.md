---
name: hermes-profile-api-server
description: 为 Hermes profile 创建轻量 API 服务器，不依赖完整 gateway。读取 profile 的 SOUL.md 作为 system prompt，直接调用 LLM API，让单个 profile 可以作为独立 API endpoint 运行。
---

# Hermes Profile API Server

## 何时使用

- Hermes gateway 是单例，无法同时跑两个 profile，但你需要某个 profile 作为独立 API 提供服务（如多 agent 聊天室）
- 你只需要某个 profile 的身份 (SOUL.md) + LLM 调用能力，不需要 gateway 的完整平台栈
- 你想在聊天室或桥接场景中让多个 Hermes 身份同时在线

## 实现模式

### 核心逻辑

```
读取 SOUL.md → 构造 system prompt → 启动 HTTP server → 收到请求时调用 LLM API → 返回回复
```

### 关键步骤

1. **读取 profile 的 SOUL.md**
   ```python
   SOUL_PATH = Path(HERMES_HOME) / 'profiles' / '<name>' / 'SOUL.md'
   ouro_soul = SOUL_PATH.read_text(encoding='utf-8')
   system_prompt = f"{ouro_soul}\n\n[additional context/instructions]"
   ```

2. **直接调用 LLM API**（不走 Hermes gateway）
   ```python
   import urllib.request, json
   payload = json.dumps({
       "model": MODEL,
       "messages": [
           {"role": "system", "content": system_prompt},
           {"role": "user", "content": prompt}
       ],
       "max_tokens": 600,
   }).encode('utf-8')
   req = urllib.request.Request(API_URL, data=payload, headers={
       'Content-Type': 'application/json',
       'Authorization': f'Bearer {API_KEY}',
   })
   with urllib.request.urlopen(req, timeout=120) as resp:
       result = json.loads(resp.read().decode('utf-8'))
       return result['choices'][0]['message']['content'].strip()
   ```

3. **读取 API key** 从 profile 的 `.env` 文件
   ```python
   for line in ENV_PATH.read_text(encoding='utf-8').splitlines():
       if line.startswith('OPENCODE_GO_API_KEY='):
           return line.split('=', 1)[1]
   ```

4. **监听配置的端口** — 确保与 chatroom server 中配置的端口一致

## 参考实现

完整示例见 `ouro_api_server.py` in `C:\Users\77\chatroom\`:
- `ouro_api_server.py`: 监听 8645，读取 Ouro 的 SOUL.md，调用 OpenCode Go API
- 配合 `server.py`: 三方聊天室服务器，Monica (HTTP) + Star (本地 import) + Ouro (本 API)

## 已知问题

- **Windows 编码**: `curl` 从 git-bash 发送中文时可能使用 GBK 而非 UTF-8。Python 的 `urllib` 调用不受影响（走正确的 UTF-8 编码）。测试时用 Python 脚本而不是 curl。
- **API key 格式**: profile 的 `.env` 中 `OPENCODE_GO_API_KEY` 会被 Hermes gateway 注入到 agent 会话，但本模式手动读取。确保 key 是完整的、未被截断的。
- **无状态**: 每个请求独立，不保存跨轮上下文。如果需要记忆，需要额外实现。

## 参考文件

- `references/ouro-api-server-example.py`: 完整可运行的实现示例，读取 Ouro profile 的 SOUL.md 并监听 8645 端口

## 与完整 gateway 的区别

| 特性 | 本模式 | Hermes gateway |
|------|--------|---------------|
| 身份加载 | 手动读 SOUL.md | 自动 AGENTS.md+SOUL.md |
| 平台支持 | HTTP 仅 | Telegram/Discord/Slack... |
| 记忆系统 | 无 | 三层记忆架构 |
| 工具调用 | 无 | 完整工具栈 |
| 同时运行 | 可多个 | 单例 |
