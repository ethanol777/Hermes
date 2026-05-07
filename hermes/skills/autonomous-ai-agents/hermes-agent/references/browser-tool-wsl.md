# Browser Tool on WSL (No Sudo)

## Problem

The `browser_navigate` / `browser_snapshot` tools time out or fail silently on WSL. This happens because the Hermes browser tool requires a headless Chrome/Chromium instance, and WSL typically doesn't have one installed.

## Diagnosis

```bash
# Check if any browser is available
which google-chrome chromium chromium-browser 2>/dev/null || echo "no browser found"

# Check if the browser tool is configured
grep -A5 "browser:" ~/.hermes/config.yaml | grep "cdp_url\|camofox"

# Browser tool logs (if any)
grep -i "browser\|chrome\|cdp" ~/.hermes/logs/agent.log | tail -10
```

The config's `browser.cdp_url: ''` means the tool tries to launch a local browser. With none installed, it hangs until timeout.

## Solution: Install Headless Chromium (No Sudo)

### Option A: Playwright Chromium (Recommended)

Playwright ships its own Chromium binary — no system-wide install needed:

```bash
npx playwright install chromium 2>&1
```

This installs to `~/.cache/ms-playwright/`. After installation, `playwright launch` can be used, or configure the browser tool to use it.

If `npx` isn't available:
```bash
npm install -g playwright
playwright install chromium
```

### Option B: Static Chromium Binary

Download a standalone Chromium build:
```bash
mkdir -p ~/local/bin
curl -sL https://storage.googleapis.com/chromium-browser-snapshots/Linux_x64/LAST_CHANGE -o /tmp/last_change
# Get the latest build:
wget -O ~/local/bin/chromium.zip "https://storage.googleapis.com/chromium-browser-snapshots/Linux_x64/$(cat /tmp/last_change)/chrome-linux.zip"
unzip -q ~/local/bin/chromium.zip -d ~/local/bin/
chmod +x ~/local/bin/chrome-linux/chrome
```

### Option C: Connect to Windows Chrome via CDP

If Chrome is installed on Windows, start it with remote debugging and point Hermes at it:

**Windows PowerShell:**
```powershell
# Start Chrome with remote debugging
& "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222
```

**WSL config.yaml:**
```yaml
browser:
  cdp_url: http://host.docker.internal:9222
```

## Verification

After installing, test with:
```bash
# Quick test: can a headless browser launch?
node -e "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch({ headless: true });
  console.log('Browser launched successfully');
  await browser.close();
})();
"
```

Then start a new Hermes session and try `browser_navigate`.

## Key Insight

The network itself is usually fine on WSL (ping, curl, git all work). The browser tool failure is a missing **local browser binary**, not a network issue. Don't waste time on DNS/proxy troubleshooting if other network tools work.
