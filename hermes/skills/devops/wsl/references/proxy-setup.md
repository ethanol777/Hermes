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

**IMPORTANT: Add catch-all rules at the end of your rules list.** Without them, sites not explicitly listed (e.g., news.ycombinator.com) will go DIRECT and fail:

```yaml
rules:
  # ... all your specific rules ...
  - 'GEOIP,CN,DIRECT'           # Chinese IPs go direct
  - 'MATCH,YourProxyGroupName'  # Everything else through proxy
```

The `GEOIP,CN,DIRECT` ensures domestic traffic stays direct (fast), while `MATCH` catches everything else and routes it through the proxy. This eliminates the need to list every foreign domain explicitly.

**How to get the node config:**
- From subscription API: `curl -sL "https://example.com/subscribe?token=xxx" -o ~/.config/clash/config.yaml`
- From direct paste: write the YAML config directly from the user's document — the primary fallback when the subscription API is down
- From Clash Verge Rev GUI: export from the app on Windows, then copy to WSL

### 3. Start Mihomo Daemon

```bash
# Start in background (USE background=true flag, not &)
# terminal(background=true, command="~/.local/bin/verge-mihomo -d ~/.config/clash -f ~/.config/clash/config.yaml > /tmp/mihomo.log 2>&1")

# Wait for initialization
sleep 6

# Check startup logs
tail -20 /tmp/mihomo.log

# Expected log lines:
#   "Mixed(http+socks) proxy listening at: [::]:7890"
#   "RESTful API listening at: 127.0.0.1:9090"
#   "Initial configuration complete, total time: ...ms"
```

### 4. Test the Proxy

```bash
# Test with a site in the proxy rules
curl -sI --proxy "http://127.0.0.1:7890" "https://www.google.com" --max-time 10
# Expected: HTTP/1.1 200 Connection established

# Check which node is being used
tail /tmp/mihomo.log
# Look for: "match DomainKeyword(google) using ProxyGroup[NodeName]"

# Check your external IP through the proxy
curl -s --proxy "http://127.0.0.1:7890" "https://ifconfig.co" --max-time 15
# Should return a non-Chinese IP

# Check current proxy status via API
unset http_proxy https_proxy  # CRITICAL — see pitfall below
curl -s "http://127.0.0.1:9090/proxies" | python3 -m json.tool
```

### 5. Switch Proxy Nodes via API

Use the mihomo REST API to switch between nodes without editing config:

```bash
# List proxy groups and find available nodes
unset http_proxy https_proxy  # CRITICAL — see pitfall below

curl -s "http://127.0.0.1:9090/proxies" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for name, proxy in data.get('proxies', {}).items():
    if proxy.get('type') == 'Selector':
        print(f'Group: {name}  Now: {proxy.get(\"now\")}')
        for n in proxy.get('all', []):
            print(f'  Available: {n}')
"

# Switch to a specific node
curl -s "http://127.0.0.1:9090/proxies/YourGroupName" \
  -X PUT -H "Content-Type: application/json" \
  -d '{"name":"YourNodeName"}' --max-time 5
# Status 204 (no content) = success

# Verify switch
curl -s "http://127.0.0.1:9090/proxies/YourGroupName" | python3 -c "import sys,json; print(json.load(sys.stdin).get('now'))"
```

### 6. Set Environment Variables

```bash
# Export these to route terminal traffic through the proxy
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890

# Or add to ~/.bashrc for persistence
echo 'export http_proxy=http://127.0.0.1:7890' >> ~/.bashrc
echo 'export https_proxy=http://127.0.0.1:7890' >> ~/.bashrc
```

### 7. Accessing External Content Through Proxy

Once the proxy is running, you can fetch trending content from various sources:

```bash
# Hacker News trends (JSON API — works reliably, no CAPTCHA)
curl -sL --proxy "http://127.0.0.1:7890" \
  "https://hn.algolia.com/api/v1/search?tags=front_page&hitsPerPage=15"

# Reddit hot posts (use .json API)
# NOTE: CloudFront nodes get 403 from Reddit. Switch to anytls node first.
curl -sL --proxy "http://127.0.0.1:7890" \
  "https://www.reddit.com/r/all/hot/.json?limit=10"

# Specific subreddits
curl -sL --proxy "http://127.0.0.1:7890" \
  "https://www.reddit.com/r/technology/.json?limit=8"

# RSS feeds (work with both CloudFront and anytls nodes)
curl -sL --proxy "http://127.0.0.1:7890" \
  "https://techcrunch.com/category/artificial-intelligence/feed/"

# BBC News — reliable text content via proxy (but JS-heavy pages fail)
curl -sL --proxy "http://127.0.0.1:7890" \
  "https://www.bbc.com/news/world/us_and_canada"

# NPR News RSS
curl -sL --proxy "http://127.0.0.1:7890" \
  "https://feeds.npr.org/1001/rss.xml"

# Politico RSS
curl -sL --proxy "http://127.0.0.1:7890" \
  "https://rss.politico.com/politics-news.xml"

# Check external IP through proxy
curl -s --proxy "http://127.0.0.1:7890" "https://ifconfig.co"
```

**Content retrieval tips:**
- **Hacker News Algolia API** is the most reliable — no CAPTCHA, clean JSON, gets front-page stories
- **Reddit .json endpoints** are second-best — some subreddits may return 403 with certain node types
- **RSS/XML feeds** work well when the HTML page has CAPTCHA — NPR, Politico, TechCrunch all work
- **BBC News** HTML pages work for headline extraction but don't rely on complex DOM parsing (BBC has varied per-page structure)
- **Search engines (Google/DDG/Bing)** nearly always return CAPTCHA via curl, even through proxy — skip these in favor of direct source URLs
- **Truth Social / X (Twitter)** have no public scrape-friendly API — use news article summaries instead

## Troubleshooting: Airport Subscription Down

When the subscription API endpoint returns 502 (backend server down), but you still need proxy access:

1. **Find the airport's official website** — Use 360搜索 (so.com) via browser tool (no CAPTCHA in China). Search for the airport brand name + "机场":
   ```
   https://www.so.com/s?q=精灵学院+机场+官网
   ```
   The results typically include the official website + review sites with pricing info.

2. **Find the login panel** — Airport panels usually run V2Board or similar, behind Cloudflare. Common subdomains: `dome.*`, `panel.*`, `jump.*`, `v2board.*`. If the panel is Cloudflare-protected, you may not be able to scrape it — ask the user to log in via browser instead.

3. **Ask the user for their config directly** — If they can access the panel from their own machine, they can export/subscribe and paste the full YAML to you. This is the most reliable fallback:
   ```
   "订阅挂了，你能不能从面板导出完整配置文件发给我？我直接起代理。"
   ```

4. **Login with user credentials when the panel is accessible** — Some panels have Vue/React frontends that work through the browser tool:
   - Try navigating to `dome.*/auth/login` etc.
   - If Cloudflare blocks, ask the user to generate a new sub token from the panel

5. **Known airport subdomain patterns** (common V2Board panels):
   - `dome.<domain>` — dome.riolu.work
   - `www.<domain>`
   - `portal.<domain>`
   - `v2board.<domain>`
   - `jump.<domain>` (redirect) — jump.riolu.work
   - API subscription: `api2.<domain>`, `sub.<domain>`, or custom paths like `/RioLU/system/api/v1/client/subscribe`

### ⚠️ Proxy Env Var Traps Localhost API Calls

**Problem:** When `http_proxy=http://127.0.0.1:7890` is set, any curl to `127.0.0.1:9090` (mihomo control API) routes through the proxy itself, causing a 502 loop.

**Fix:** Always `unset http_proxy https_proxy` before making API calls to `127.0.0.1:9090`:

```bash
# WRONG — this goes through the proxy back to itself:
curl -s "http://127.0.0.1:9090/proxies"    # → 502 Bad Gateway

# RIGHT:
unset http_proxy https_proxy
curl -s "http://127.0.0.1:9090/proxies"    # → works

# Re-set after:
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
```

### DNS Resolution Failure
**Error:** `dns resolve failed: couldn't find ip` for the proxy server domain
**Cause:** The DNS for `moe233.org` or similar proxy server domains is blocked/resolvable only through the tunnel
**Fix:** Switch to a different node type (CloudFront-based nodes often work better from China)

### Empty Responses / TLS Errors
**Error:** `exit code 35` (SSL/TLS handshake) or `Status: 000`
**Cause:** Some node types (anytls with relay) may not connect properly from certain networks
**Fix:** Try CloudFront-based VMess nodes (via CDN) — they use standard HTTPS over CloudFront and work more reliably

### Reddit Blocks CloudFront IPs
**Problem:** Reddit returns 403 when accessed through CloudFront-based proxy nodes (datacenter IPs are blocked).
**Fix:** Switch to anytls or direct VMess nodes before Reddit access. These use residential/more diverse IP ranges.

### All Search Engines Give Captcha
Even with working proxy, curl requests to Google/DuckDuckGo/Bing often trigger bot detection.
**Workaround:** Use the proxy for accessing specific sites (GitHub, HuggingFace, API endpoints) rather than search engines. For search, use 360搜索 (so.com) directly without proxy — it's accessible from China.

### Node Types — Reliability Ranking (from China)
| Rank | Node Type | Reliability | Best For |
|------|-----------|-------------|----------|
| 1 | VMess + CloudFront (CDN) | Best — standard HTTPS, uses Cloudflare | General browsing, Google, HN |
| 2 | Anytls (direct to relay) | Moderate — depends on relay availability | Reddit (avoids CloudFront blocks), general |
| 3 | VMess direct (moe233.org:8000) | Worst — DNS/port often blocked | Fallback only |

### Starting Mihomo with `terminal(background=true)` versus `&`
Always use the `background=true` flag for mihomo (long-running daemon). The `&` shell backgrounding conflicts with the security scanner's foreground check.

### YAML Indentation in Patch
When adding rules to an existing config with `patch`, match the existing indentation exactly. Rules under `rules:` typically use 4-space indent. A 0-space indent will cause `yaml: line X: did not find expected key`.

## Stopping the Proxy

```bash
pkill -f verge-mihomo
# Verify stopped
ps aux | grep verge-mihomo | grep -v grep
```
