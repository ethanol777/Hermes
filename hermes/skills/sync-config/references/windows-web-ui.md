# Windows 上的 Web 聊天方案

Hermes dashboard 的 `/chat` 标签页（内嵌 TUI）需要 POSIX PTY，在 **原生 Windows Python 上不可用**。但有两种替代方案：

## 方案 A：OpenAI 兼容 API 服务器（推荐）

Hermes 自带 `api_server` 平台适配器，通过 gateway 暴露 OpenAI 兼容的 HTTP API。

### 配置

```yaml
# config.yaml
platforms:
  api_server:
    enabled: true
    port: 8642
    host: 127.0.0.1
```

或通过环境变量：
```
API_SERVER_ENABLED=true
API_SERVER_KEY=<your-key>        # 可选，绑定非 127.0.0.1 时需要
API_SERVER_PORT=8642             # 可选，默认 8642
API_SERVER_HOST=127.0.0.1        # 可选，默认 127.0.0.1
```

### 启动

```bash
hermes gateway run --replace
```

### 端点

| 端点 | 用途 |
|------|------|
| `GET /health` | 健康检查 |
| `GET /v1/models` | 列出可用模型 |
| `POST /v1/chat/completions` | OpenAI Chat Completions API |
| `POST /v1/responses` | OpenAI Responses API |

### Web UI 前端（任选其一）

任意 OpenAI 兼容的前端连接 `http://localhost:8642/v1` 即可：

- **Open WebUI** — 功能最全，支持对话历史、文件上传
- **LobeChat** — 现代 UI，插件丰富
- **NextChat** — 轻量，ChatGPT-Next-Web
- **ChatBox** — 桌面 App
- **LibreChat** — 开源，多模型
- **AnythingLLM** — 带 RAG

连接配置：API Base URL = `http://localhost:8642/v1`，Model = `hermes-agent`，Key = 留空或配置的 API_KEY。

### 注意事项

- 默认绑定 `127.0.0.1`，仅本机可访问。如需远程访问，设置 `API_SERVER_KEY` 并绑定 `0.0.0.0`，配合 Cloudflare Tunnel 更安全。
- API 服务器是 gateway 的一部分，启动 gateway 时也会加载其他平台（微信、飞书等）。
- 前端对话时，每条消息会创建独立的 agent 会话（默认无状态）。可以通过 `X-Hermes-Session-Id` header 维持连续性。
- 端口 8642 冲突时，`gateway.run` 会报错并跳过 api_server 平台——换端口即可。

## 方案 B：WSL2（完整 dashboard）

在 WSL2 中安装 Hermes，`hermes dashboard --tui` 的 `/chat` 标签页可以完整工作（POSIX PTY 在 Linux 内核中可用）。
