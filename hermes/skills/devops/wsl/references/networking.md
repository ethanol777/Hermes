# WSL Networking Reference

## Core Concepts

WSL runs in a lightweight VM with its own network interface. WSL services auto-map to **Windows localhost** (http://localhost:<port> works from Windows browser), but do NOT auto-expose to LAN.

## Commands

```bash
# Find WSL eth0 IP
ip addr show eth0 | grep inet

# Find Windows LAN IP from within WSL
cmd.exe /c "ipconfig | findstr IPv4"

# Check what address a service is bound to
ss -tlnp | grep <port>
```

- `127.0.0.1:<port>` — WSL-local only ❌
- `0.0.0.0:<port>` — externally accessible ✅
- `*:<port>` — externally accessible ✅

## Method 1: Windows Port Forwarding (netsh portproxy)

No SSH needed. Run on Windows PowerShell (Admin):

```powershell
# Add rule
netsh interface portproxy add v4tov4 listenport=<PORT> listenaddress=0.0.0.0 connectport=<PORT> connectaddress=<WSL_ETH0_IP>

# List rules
netsh interface portproxy show all

# Remove rule
netsh interface portproxy delete v4tov4 listenport=<PORT>
```

**Pitfall:** WSL IP changes on restart — recreate the rule.

## Method 2: SSH Tunnel

### Windows OpenSSH Server (recommended, no WSL sudo)
```powershell
# In Windows PowerShell (Admin)
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
```

```bash
# From LAN machine
ssh -N -L 8787:127.0.0.1:8787 <wsl-user>@<Windows-LAN-IP>
```

### WSL SSH Server (needs sudo)
```bash
sudo apt install openssh-server -y
sudo service ssh start
```

## Method 3: Tailscale (for cross-subnet access)

Creates a WireGuard mesh network between all devices. Use when machines are on different subnets.

```bash
# WSL install
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

# See all devices
tailscale status
```

Connect via `100.x.x.x` IP instead of physical LAN IP.

## Common Pitfalls

1. **Service bound to 127.0.0.1** — Fix: start with `--host 0.0.0.0` or use socat/SSH forwarding
2. **WSL no sudo** — Use netsh portproxy or Cloudflare Tunnel instead
3. **WSL IP changes on restart** — Re-run portproxy after restart
4. **Windows firewall blocks** — Check Windows Defender Firewall inbound rules
5. **Cross-subnet: "No route to host"** — Use Tailscale
6. **Hermes WebUI default 127.0.0.1** — Set `HERMES_WEBUI_HOST=0.0.0.0`
