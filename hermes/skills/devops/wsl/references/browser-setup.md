# Browser Tool Setup for Hermes Agent on WSL

Hermes Agent's browser tools (`browser_navigate`, `browser_snapshot`, etc.) require a headless Chromium installation. On WSL without sudo, use Playwright to install a browser bundle locally.

## Problem

`browser_navigate` times out with `CDP command timed out: Page.navigate`. Cause: no Chromium/Chrome binary available on PATH for the browser automation backend.

## Solution

```bash
# Option A: One-liner (preferred)
npx playwright install chromium

# Option B: Full install flow (if A warns about dependencies)
npm install @playwright/test
npx playwright install chromium
```

This downloads Chromium to `~/.cache/ms-playwright/chromium-*/` (visible with `ls ~/.cache/ms-playwright/`).

## Verification

Navigate to any accessible website:

```bash
# Via Hermes agent — test with a simple site
browser_navigate(url="https://www.baidu.com")
```

Expected result: page loads with snapshot content (elements, links, text). If you get a captcha, the browser is working — the captcha is a separate anti-bot issue.

## Notes

- **No sudo required** — Playwright installs Chromium to the user's home cache
- **No system dependencies needed** — the bundled Chromium includes its own deps
- **Baidu blocker** — some Chinese sites (Baidu, Zhihu) may present captchas. Use Bing (国内版) as an alternative
- **Cache location:** `~/.cache/ms-playwright/chromium-1217/` (version number may differ)

## Common Pitfalls

- `npx playwright install chromium` without `@playwright/test` works but prints a warning — that warning is harmless
- The browser tool uses CDP (Chrome DevTools Protocol) internally; if the site blocks automation, try a different search engine or add `stealth` features
- Network to foreign sites (Google, DuckDuckGo) may be slow or blocked from mainland China; use cn.bing.com for Chinese-language searches
