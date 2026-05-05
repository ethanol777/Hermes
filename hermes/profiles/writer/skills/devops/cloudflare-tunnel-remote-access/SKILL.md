---
name: cloudflare-tunnel-remote-access
description: 用 Cloudflare Tunnel（trycloudflare）将 Hermes Web UI 暴露到公网，替代被墙的 ngrok
version: 1.0.0
author: Monica
---

# Cloudflare Tunnel 远程访问 Hermes Web UI

在中国大陆环境下，ngrok 的 DNS 被污染（`connect.ngrok-agent.com` 解析失败），Cloudflare Tunnel 是免费、可靠的替代方案。

## 适用场景

- Hermes Web UI（或其他本地 Web 服务）需要从另一台电脑远程访问
- 两台电脑不在同一局域网 / 跨子网
- WSL 环境，sudo 被禁用（Cloudflare Tunnel 无需管理员权限）
- ngrok 连不上服务器

## 前置条件

- Hermes Web UI 已在本地运行，确认端口
- 出站网络正常（能访问 Cloudflare 边缘节点）

## 操作步骤

### 1. 查看 Web UI 监听的地址和端口

```bash
ss -tlnp | grep python
```

典型输出：
```
LISTEN 0  50  172.28.108.182:8788  0.0.0.0:*  users:(("python3",pid=xxx,fd=3))
LISTEN 0  64  127.0.0.1:8787       0.0.0.0:*  users:(("python",pid=xxx,fd=5))
```

注意 cloudflared 需要能访问到的地址 — 如果是 `127.0.0.1` 绑定就用 `http://localhost:<PORT>`，如果是 WSL 局域网 IP 就用 `http://<IP>:<PORT>`。

### 2. 下载 cloudflared（如果没有）

```bash
curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o ~/.hermes/cloudflared
chmod +x ~/.hermes/cloudflared
```

### 3. 创建隧道（用 tmux 持久化后台运行）

```bash
tmux new-session -d -s cf-tunnel '~/.hermes/cloudflared tunnel --url http://172.28.108.182:8788 2>&1 | tee /tmp/cloudflared.log'
```

### 4. 等待几秒后获取公网 URL

```bash
sleep 8 && cat /tmp/cloudflared.log | grep -oP 'https://[a-z-]+\.trycloudflare\.com'
```

会得到类似 `https://placed-instructor-recent-lone.trycloudflare.com` 的 URL。

### 5. 验证

```bash
curl -s -o /dev/null -w "HTTP %{http_code}" https://<你的url>
```

返回 `HTTP 200` 即成功。

### 6. 其他电脑访问

直接打开上一步的 URL 即可。

## 隧道管理命令

```bash
# 查看输出 / 日志
tmux capture-pane -t cf-tunnel -p | tail -20
cat /tmp/cloudflared.log

# 重启隧道（会获得新 URL）
tmux kill-session -t cf-tunnel
tmux new-session -d -s cf-tunnel '~/.hermes/cloudflared tunnel --url http://<你的地址>:<端口> 2>&1 | tee /tmp/cloudflared.log'

# 停止隧道
tmux kill-session -t cf-tunnel
```

## 已知问题 / 注意事项

- **trycloudflare 随机 URL**：每次重启隧道 URL 都会变。如果需要固定域名，配置 Cloudflare 账号下的命名隧道。
- **免费版无 SLA**：trycloudflare 免费隧道没有可用性保证，用于临时远程访问足够了。
- **WSL 关机后隧道消失**：WSL 关闭后 tmux 进程被终止，需要重新创建。
- **绑定的地址要对**：如果 cloudflared 连 `localhost` 但服务绑定在 WSL 局域网 IP 上，会连接失败。用 `ss -tlnp` 确认实际绑定地址。

## 为什么不用 ngrok

在中国大陆，ngrok 的 `connect.ngrok-agent.com` 被 DNS 污染（返回 NXDOMAIN），导致无法连接 ngrok 服务器。Cloudflare Tunnel 的 `trycloudflare.com` 能被正常解析，且有边缘节点覆盖。
