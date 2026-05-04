---
name: wsl-networking
description: WSL 网络配置与端口转发——从局域网访问 WSL 服务的完整指南，涵盖 IP 探测、绑定检查、netsh portproxy、替代方案和常见陷阱
trigger:
  - User needs to access a WSL service from another computer on the LAN
  - User asks about port forwarding or SSH tunneling from WSL
  - Service on WSL is not reachable from Windows or other machines
  - User needs to find Windows/LAN IPs from within WSL
  - User tries SSH forwarding and gets "Connection refused"
  - netsh portproxy isn't working as expected
---

# WSL 网络配置与端口转发

## 核心概念

WSL 运行在轻量级虚拟机中，拥有独立的网络接口。WSL 内部的服务会自动映射到 **Windows 的 localhost**（通过 Windows 浏览器 `http://localhost:<port>` 可直接访问），但**不会自动暴露给局域网**。

要从局域网的另一台电脑访问 WSL 里的服务，需要额外的转发步骤。

## 常用命令速查

### 查 WSL 的 eth0 IP
```bash
ip a | grep inet | grep -v 127.0.0.1
```

### 查 Windows 宿主机的 LAN IP（从 WSL 内）
```bash
cmd.exe /c "ipconfig | findstr IPv4"
```

### 查服务监听的地址和端口
```bash
ss -tlnp | grep <port>
```

关键看输出：
- `127.0.0.1:<port>` — 仅 WSL 本机可访问 ❌
- `0.0.0.0:<port>` — 可从外部访问 ✅
- `*:<port>` — 同上 ✅

## 方案一：Windows 端口转发（netsh portproxy）

不需要 SSH 服务端，一次设置永久生效（除非 WSL IP 变了）。

### 设置转发
```powershell
# 在 WSL 终端或 Windows 终端（管理员权限）执行：
netsh interface portproxy add v4tov4 \
  listenport=<你要暴露的端口> \
  listenaddress=0.0.0.0 \
  connectport=<WSL 服务端口> \
  connectaddress=<WSL eth0 IP>
```

### 查看已有转发规则
```powershell
netsh interface portproxy show all
```

### 删除转发规则
```powershell
netsh interface portproxy delete v4tov4 listenport=<端口> listenaddress=0.0.0.0
```

## 方案二：SSH 隧道（需要目标机器上有 SSH 服务）

有两种 SSH 服务端可选：

### 选项 A：Windows 自带的 OpenSSH Server（推荐）
Windows 10/11 自带 OpenSSH Server，**不依赖 WSL 的 sudo**。

**检查是否已安装：**
```powershell
# 在 Windows PowerShell（管理员）执行
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
```

**启动服务：**
```powershell
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
```

**WSL 内验证端口已开始监听：**
```bash
cmd.exe /c "netstat -an | findstr :22"
```

**防火墙**：安装时会自动创建入站规则 `OpenSSH SSH Server (sshd)`，默认已启用放行 22 端口。

**从局域网其他机器 SSH 进入 WSL：**
```bash
ssh <wsl-用户名>@<Windows LAN IP>
```
连接进入后就是 WSL 环境。

### 选项 B：WSL 内的 SSH 服务端（需要 sudo）
```bash
sudo apt install openssh-server -y
sudo service ssh start
```
注意 WSL 默认可能禁用 sudo，需在 Windows 设置 → 开发者选项中启用。若 sudo 被禁用，推荐使用选项 A。

### 端口转发示例（从另一台电脑访问 WSL 的 8787 端口）
```bash
ssh -N -L 8787:127.0.0.1:8787 <wsl-用户名>@<Windows LAN IP>
```

## 方案三：公网隧道（绕过局域网限制）

当两台设备不在同一局域网或无法直接互通时，使用公网隧道创建可公开访问的 URL。

### Cloudflare Tunnel（推荐，无需账号，国内可用）

[Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/) 通过 Cloudflare 边缘网络创建到本地服务的加密隧道，**免费、无需 Cloudflare 账号**，在 WSL 上**不需要 sudo**。

```bash
# 1. 下载单文件二进制（无需安装）
curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o ~/.hermes/cloudflared
chmod +x ~/.hermes/cloudflared

# 2. 创建隧道（获取随机 trycloudflare.com URL）
~/.hermes/cloudflared tunnel --url http://localhost:<port>
```

输出示例：
```
|  Your quick Tunnel has been created! Visit it at:  |
|  https://xxx-xxx-xxx.trycloudflare.com              |
```

**重要——服务绑定地址的坑：**

如果服务绑定在 `127.0.0.1`，cloudflared 连 `http://localhost:<port>` 即可。
如果服务绑定在 WSL 的 eth0 IP（如 `172.28.x.x:<port>`），cloudflared 必须连该 IP：

```bash
# 先查 WSL eth0 IP
ip a | grep "inet " | grep -v 127.0.0.1
# 输出示例：inet 172.28.108.182/20 ...

# 然后用实际 IP 而非 localhost
~/.hermes/cloudflared tunnel --url http://172.28.108.182:<port>
```

**后台持久运行（tmux，替代 systemd）：**

```bash
# 启动
tmux new-session -d -s cf-tunnel \
  '~/.hermes/cloudflared tunnel --url http://<IP>:<port> 2>&1 | tee /tmp/cloudflared.log'

# 查看隧道 URL
cat /tmp/cloudflared.log | grep -oP 'https://[a-z-]+\.trycloudflare\.com'

# 查看实时日志
tmux capture-pane -t cf-tunnel -p | tail -20

# 停止
tmux kill-session -t cf-tunnel
```

注意：每次重启隧道会生成新的随机 URL（trycloudflare 免费隧道的限制）。

### ngrok

```bash
ngrok http <port>
```

#### ⚠️ ngrok 在中国网络不可用（及诊断方法）

ngrok 的连接服务器 `connect.ngrok-agent.com` 在大陆网络环境下常被 DNS 污染。**诊断方法：**

```bash
# 如果 ngrok 显示 "reconnecting"，先检查 DNS
# ❌ 系统 DNS 被污染 → NXDOMAIN
host connect.ngrok-agent.com
# 输出：Host connect.ngrok-agent.com not found: 3(NXDOMAIN)

# ✅ 用 8.8.8.8 能正确解析 → 确认是 DNS 污染
nslookup connect.ngrok-agent.com 8.8.8.8
# 输出正常 IP（如 57.180.103.55 等 AWS IP）
```

**尝试修复：** 将解析到的 IP 添加至 `/etc/hosts`，但 WSL 的 hosts 文件归 root 管，且 Windows hosts 文件修改需管理员权限。通常直接改用 Cloudflare Tunnel 更省事。

推荐替代方案（按推荐优先级）：
- **Cloudflare Tunnel** ⭐ — 上方详细说明，最佳 ngrok 替代
- **Tailscale** — WireGuard 组网，无视网段/子网差异，详见下文「方案四」
- **cpolar**（极化）— 国产 ngrok 替代，国内网络友好
- **frp** — 自建隧道方案，需公网服务器

## 方案四：Tailscale（推荐，越过子网差异）

[Tailscale](https://tailscale.com) 基于 WireGuard 协议，在所有安装它的设备间创建一个安全的虚拟局域网，**无视物理网络拓扑差异**（不同子网、不同 WiFi、甚至不同城市都能直连）。

### 适用场景

- 两台机器不在同一子网（如一台 `192.168.1.x`、另一台 `192.168.0.x`）→ "No route to host"
- 经常在不同网络间切换的笔记本电脑
- 需要穿透 NAT/防火墙

### 安装步骤

**每台设备**（Windows / macOS / Linux / 手机）都安装并登录**同一个账号**：

1. 去 https://tailscale.com/download 下载安装
2. 启动后登录（GitHub / Google / 微软账号均可）
3. 登录后每个设备自动获得一个 `100.x.x.x` 的 Tailscale IP

**WSL 里安装：**
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up  # 会弹出浏览器让登录
```

### 查看 Tailscale IP
```bash
tailscale status        # 列出所有设备及其 IP
tailscale ip            # 只看本机 IP
```

### 连接方式

从另一台电脑只需用 Tailscale IP 代替物理 IP：
```bash
ssh ethanol@100.x.x.x
```

或者浏览器访问 `http://100.x.x.x:8787`（需先配置服务监听 0.0.0.0）。

### 优点总结
- ✅ 免费（最多 100 台设备/3 个用户）
- ✅ 国内可用（WireGuard over HTTPS，未被封锁）
- ✅ 端到端加密
- ✅ 无需公网 IP、无需配置防火墙
- ✅ 无需管理员权限（Windows 安装一次即可）

## 常见陷阱

### 🚫 陷阱 1：服务绑定了 127.0.0.1
**现象**：`ss -tlnp | grep <port>` 显示 `127.0.0.1:<port>`
**后果**：即使配了 netsh portproxy，外部连接也会被拒绝
**原因**：portproxy 发往 WSL 的 eth0 IP（如 172.28.x.x），但服务只在 loopback 上监听
**修复**：
- 修改服务启动参数为 `--host 0.0.0.0` 或 `0.0.0.0:<port>`
- 或用 socat 做本地转发：`socat TCP-LISTEN:<port>,fork,reuseaddr TCP:127.0.0.1:<port>`
- 或用 SSH 本地端口转发绕一圈

### 🚫 陷阱 2：WSL 禁用 sudo
**现象**：`sudo: 已在此计算机上禁用 Sudo`
**修复**：
- **推荐做法：** 使用 `wsl-software-install` skill 的 deb 提取方案（无需启用 sudo）
- Windows 设置 → 开发者选项 → 启用 sudo（如果确实需要 sudo）
- 改用不需要 sudo 的方案（netsh portproxy、Cloudflare Tunnel 等）
- 详见 [`wsl-software-install`](/home/ethanol/.hermes/skills/devops/wsl-software-install/SKILL.md) — 覆盖 pip/apt/snap 等安装场景

### 🚫 陷阱 3：WSL 重启后 IP 变化
WSL 的 eth0 IP 每次重启可能变化，导致 portproxy 失效。
**修复**：重启后重新执行 `netsh interface portproxy ...` 命令

### 🚫 陷阱 4：Windows 防火墙拦截
**测试**：在另一台机器 `telnet <Windows IP> <port>` 或 `nc -zv <Windows IP> <port>`
**修复**：检查 Windows Defender 防火墙 → 入站规则

### 🚫 陷阱 5：两台机器不在同一子网 → "No route to host"
**现象**：`ssh` 返回 `No route to host`（而非 `Connection refused` 或 `timed out`）
**原因**：两台机器不在同一个子网（不同 WiFi、一个 2.4G 一个 5G 分属不同网段、一个连主路由一个连子路由、访客网络隔离等）
**诊断**：在两台机器上分别查 IP，确认 `192.168.x.x` 在同一网段
```bash
ip a | grep "inet " | grep -v 127.0.0.1
# 或 Windows：
ipconfig | findstr IPv4
```
**修复**：
1. 让两台电脑连同一个路由器 → IP 变为同一网段
2. 改用 **Tailscale** 组网 → 完全无视子网差异（详见「方案四：Tailscale」）
3. 改用 cpolar/frp 公网隧道（ngrok 在中国不可用）

### 🚫 陷阱 6：Hermes WebUI 默认绑定 127.0.0.1
Hermes Web UI 通过 `HERMES_WEBUI_HOST` 环境变量控制监听地址，默认 `127.0.0.1`。
开放到局域网需重启并设 `HERMES_WEBUI_HOST=0.0.0.0`，建议同时设 `HERMES_WEBUI_PASSWORD`。

## 工作流总结

```
1. 确认 WSL 服务在运行
   ss -tlnp | grep <port>

2. 检查绑定地址
   → 127.0.0.1 → 需要改成 0.0.0.0（陷阱1）
   → 0.0.0.0 或 * → 下一步

3. 查 WSL eth0 IP
   ip a | grep inet

4. 查 Windows LAN IP
   cmd.exe /c "ipconfig | findstr IPv4"

5. 设置 portproxy
   netsh interface portproxy add v4tov4 ...

6. 验证
   另一台机器浏览器访问 http://<Windows LAN IP>:<port>
```
