# Mihomo (Clash Meta) Proxy Setup on Headless WSL

Setting up a Clash-compatible proxy on WSL without a desktop environment, no sudo, no Docker.

## Overview

Used when you need WSL to access blocked external websites (Google, YouTube, etc.) through a proxy service (机场/airport). The approach uses **mihomo** (Clash Meta kernel), which runs as a headless daemon and provides a local HTTP/SOCKS proxy on `127.0.0.1:7890`.

## Workflow

### 1. Get the Mihomo Binary

**Option A: Download Clash Verge Rev .deb and extract (preferred)**

```bash
# Download the .deb from GitHub Releases (GitHub is accessible from China)
curl -sL -o /tmp/clash-verge.deb \
  "https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v2.4.7/Clash.Verge_2.4.7_amd64.deb" \
  -H "Accept: application/octet-stream" \
  --connect-timeout 15 --max-time 300

# Extract without installing (no sudo needed)
mkdir -p /tmp/clash-verge-extract
dpkg-deb -x /tmp/clash-verge.deb /tmp/clash-verge-extract/

# Copy the mihomo binary
mkdir -p ~/.local/bin
cp /tmp/clash-verge-extract/usr/bin/verge-mihomo ~/.local/bin/
chmod +x ~/.local/bin/verge-mihomo

# Verify version
~/.local/bin/verge-mihomo -v
# Expected: Mihomo Meta v1.19.xx linux amd64
```

**Option B: Download mihomo standalone binary directly**

```bash
# From GitHub releases (mihomo project)
curl -sL -o /tmp/mihomo.gz \
  "https://github.com/MetaCubeX/mihomo/releases/download/v1.19.21/mihomo-linux-amd64-v1.19.21.gz"
gunzip /tmp/mihomo.gz
chmod +x /tmp/mihomo
mv /tmp/mihomo ~/.local/bin/
```

### 2. Create Configuration

Config file goes at `~/.config/clash/config.yaml`:

```yaml
mixed-port: 7890
allow-lan: true
bind-address: '*'
mode: rule
log-level: info
external-controller: '127.0.0.1:9090'
dns:
    enable: false
    ipv6: false
proxies:
  # ... your node configurations here ...
proxy-groups:
  - { name: Proxy, type: select, proxies: [...] }
rules:
  - 'DOMAIN-KEYWORD,google,Proxy'
  # ... more rules ...
```

**How to get the config:**
- From subscription API: `curl -sL "https://example.com/subscribe?token=xxx" -o ~/.config/clash/config.yaml`
- From direct paste: write the YAML config directly from the user
- From Clash Verge Rev GUI: export from the app on Windows, then copy to WSL

### 3. Start Mihomo Daemon

```bash
# Start in background
mkdir -p ~/.config/clash
~/.local/bin/verge-mihomo -d ~/.config/clash -f ~/.config/clash/config.yaml > /tmp/mihomo.log 2>&1 &

# Check startup logs
tail -20 /tmp/mihomo.log

# Expected log lines:
#   "Mixed(http+socks) proxy listening at: [::]:7890"
#   "RESTful API listening at: 127.0.0.1:9090"
#   "Initial configuration complete, total time: ...ms"
```

### 4. Test the Proxy

```bash
# Test with a site definitely in the proxy rules
curl -sI --proxy "http://127.0.0.1:7890" "https://www.google.com" --max-time 10
# Expected: HTTP/1.1 200 Connection established

# Check which node is being used
tail /tmp/mihomo.log
# Look for: "match DomainKeyword(google) using ProxyGroup[NodeName]"

# Check current proxy status via API
curl -s "http://127.0.0.1:9090/proxies" | python3 -m json.tool
```

### 5. Switch Proxy Nodes via API

Use the mihomo REST API to switch between nodes without editing config:

```bash
# List all proxy groups and find the one you want to switch
curl -s "http://127.0.0.1:9090/proxies" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for name, proxy in data.get('proxies', {}).items():
    if proxy.get('type') == 'Selector':
        print(f'Group: {name}  Now: {proxy.get(\"now\")}')
"

# Switch to a specific node
python3 -c "
import urllib.request, json, urllib.parse
group = 'ProxyGroupName'  # e.g. 'RioLU.443 精靈學院'
node = 'NodeName'          # e.g. '🇭🇰 香港01 CloudFront'
req = urllib.request.Request(
    f'http://127.0.0.1:9090/proxies/{urllib.parse.quote(group)}',
    data=json.dumps({'name': node}).encode(),
    headers={'Content-Type': 'application/json'},
    method='PUT'
)
resp = urllib.request.urlopen(req, timeout=5)
print(f'Status: {resp.status}')  # 204 = success
"
```

### 6. Set Environment Variables

```bash
# Export these to route traffic through the proxy
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890

# Or add to ~/.bashrc for persistence
echo 'export http_proxy=http://127.0.0.1:7890' >> ~/.bashrc
echo 'export https_proxy=http://127.0.0.1:7890' >> ~/.bashrc
```

## Common Pitfalls

### DNS Resolution Failure
**Error:** `dns resolve failed: couldn't find ip` for the proxy server domain
**Cause:** The DNS for `moe233.org` or similar proxy server domains is blocked/resolvable only through the tunnel
**Fix:** Switch to a different node type (CloudFront-based nodes often work better from China)

### Empty Responses / TLS Errors
**Error:** `exit code 35` (SSL/TLS handshake) or `Status: 000`
**Cause:** Some node types (anytls with relay) may not connect properly from certain networks
**Fix:** Try CloudFront-based VMess nodes (via CDN) — they use standard HTTPS over CloudFront and work more reliably

### All Search Engines Give Captcha
Even with working proxy, curl requests to Google/DuckDuckGo/Bing often trigger bot detection.
**Workaround:** Use the proxy for accessing specific sites (GitHub, HuggingFace, API endpoints) rather than search engines. For search, use 360搜索 (so.com) directly without proxy — it's accessible from China.

### Node Types — Reliability Ranking (from China)
| Rank | Node Type | Reliability |
|------|-----------|-------------|
| 1 | VMess + CloudFront (CDN) | Best — standard HTTPS, uses Cloudflare |
| 2 | Anytls (direct to relay) | Moderate — depends on relay availability |
| 3 | VMess direct (moe233.org:8000) | Worst — DNS/port often blocked |

## Stopping the Proxy

```bash
pkill -f verge-mihomo
# Verify stopped
ps aux | grep verge-mihomo | grep -v grep
```
