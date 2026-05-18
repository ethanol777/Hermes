# Cloudflare Tunnel Remote Access

Expose WSL services to the internet via Cloudflare Tunnel (trycloudflare). Free, no account needed, works in China (unlike ngrok), no sudo required.

## Quick Start

```bash
# Download cloudflared
mkdir -p ~/.hermes
curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o ~/.hermes/cloudflared
chmod +x ~/.hermes/cloudflared
```

```bash
# Start tunnel (tmux for persistence)
tmux new-session -d -s cf-tunnel '~/.hermes/cloudflared tunnel --url http://<IP>:<PORT> 2>&1 | tee /tmp/cloudflared.log'

# Get public URL
sleep 8
cat /tmp/cloudflared.log | grep -oP 'https://[a-z-]+\.trycloudflare\.com'

# Verify
curl -s -o /dev/null -w "HTTP %{http_code}" https://<your-url>
```

## Management

```bash
# View logs
cat /tmp/cloudflared.log

# Check tunnel status
tmux capture-pane -t cf-tunnel -p | tail -20

# Restart (gets new URL)
tmux kill-session -t cf-tunnel
tmux new-session -d -s cf-tunnel '~/.hermes/cloudflared tunnel --url http://<IP>:<PORT> 2>&1 | tee /tmp/cloudflared.log'

# Stop tunnel
tmux kill-session -t cf-tunnel
```

## Important: Service Binding

Check what address the service binds to:
```bash
ss -tlnp | grep <port>
```

If bound to `127.0.0.1`, use `http://localhost:<PORT>`.
If bound to WSL IP (e.g. `172.28.x.x`), use that IP in the tunnel URL.

## Notes

- **Random URL** — each restart generates a new trycloudflare URL
- **No SLA** — free tier, suitable for temporary remote access
- **WSL shutdown** — tunnel is lost when WSL shuts down
- **China-friendly** — Cloudflare edge nodes reachable; ngrok DNS is polluted
