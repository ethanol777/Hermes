---
name: overseas-ai-api-access
description: >-
  Methods for accessing overseas AI API services (OpenAI, Anthropic, Google,
  xAI, etc.) from within China, including API relay/proxy services, direct
  subscription options, and self-hosted gateway solutions. Covers tool
  integration (Codex CLI, Cursor, etc.) with relay endpoints.
triggers:
  - "API中转"
  - "API中转站"
  - "API relay"
  - "api proxy"
  - "api.v3.cm"
  - "V-API"
  - "v3.cm"
  - "ohmygpt"
  - "api2d"
  - "veast"
  - "openai proxy"
  - "claude proxy"
  - "国内用Codex"
  - "Codex CLI中转"
  - "cc-switch"
  - "OpenAI中转"
  - "ChatGPT Plus国内"
  - "海外API中转"
tags: [api, proxy, relay, china, openai, claude, codex, gemini, deepseek]
---

# Overseas AI API Access (from China)

Techniques and providers for accessing overseas AI APIs from within China, where direct API calls to OpenAI/Anthropic/Google may be blocked or impractical.

## Overview: Three Approaches

| Approach | Cost | Security | Effort | Best For |
|----------|:----:|:--------:|:------:|----------|
| **API Relay** (中转站) | Pay-as-you-go | Data via 3rd party | Low | Quick access, personal use |
| **Direct Subscription** (Plus/Pro) | Fixed $20/mo | Official | Low | Codex CLI, ChatGPT desktop |
| **Self-Hosted** (OneAPI + upstream) | Upstream cost | Full control | High | Production, commercial projects |

---

## 1. API Relay Services (API中转站)

### How They Work

Relay services provide an OpenAI-compatible endpoint (`https://<relay>/v1/chat/completions`) that proxies requests to upstream providers. You use your API key from the relay, not from OpenAI directly.

### Vetted Relay Providers

| Service | URL | Models Available | Notes |
|---------|-----|-----------------|-------|
| **V-API** | https://api.v3.cm | 718+ models. OpenAI, Anthropic/Claude, Gemini, Grok, DeepSeek, 豆包, 千问, Midjourney etc. | Has dedicated **codex (0.5x)** pricing group — Codex-related models at half price. Multiple pricing tiers (default, claude 2.4x, gemini 1.5x, qwen 0.4x). |
| **API2D / API2GPT** | (various domains) | OpenAI + Claude | Long-standing service (years of operation). Higher prices. Alipay support. |
| **OhMyGPT** | (various domains) | OpenAI + Claude (limited) | Budget-friendly. Smaller model selection. Higher risk profile. |
| **Veast AI** | (Singapore-based) | Full model lineup | Good latency from China (Singapore routing). Responsive support. |

### What to Check Before Buying

1. **Minimum top-up** — start with ¥10-20 to test
2. **Status/monitoring page** — reputable services publish uptime stats
3. **Community presence** — active Telegram/WeChat group = less likely to rug
4. **Refund policy** — can unused balance be withdrawn?
5. **Multiplier/labeling** — some providers use "倍率" (multiplier) to differentiate pricing tiers
6. **Data retention** — whether prompts/logs are stored

### Risks

- **Run risk** (跑路) — the service disappears with your balance. Never top up large amounts.
- **Data privacy** — all prompts pass through their servers
- **Rate limiting** — shared accounts may throttle
- **Model equivalence** — "GPT-4o" on a relay may use a different routing path than official

---

## 2. Direct Subscription

For tools like Codex CLI that support login-based authentication, a direct ChatGPT Plus ($20/mo ≈ ¥145) or ChatGPT Pro ($200/mo) subscription is the simplest option.

### Upgrade Methods (from China)

| Method | URL | Notes |
|--------|-----|-------|
| **getgpt.pro** | https://getgpt.pro | Popular one-click ChatGPT Plus upgrade service. Chinese payment (Alipay/WeChat). |
| **Depay/OneKey cards** | Various | Virtual Visa cards for overseas subscriptions. Higher fees. |

### Codex CLI with Plus Subscription

```bash
# Install
npm i -g @openai/codex

# Launch — opens browser to authenticate with ChatGPT Plus
codex
```

No API key needed when using Plus login mode.

---

## 3. Codex CLI Through API Relay

If you want to use Codex CLI with an API relay (not Plus login):

```bash
# Set environment variables
export OPENAI_BASE_URL=https://api.v3.cm/v1
export OPENAI_API_KEY=<relay-api-key>

# Launch Codex
codex
```

### Model Selection Note

Codex CLI by default uses a codex-optimized model (e.g., GPT-5.3-Codex, GPT-5.5). On relay services, check:
- Does the relay have an explicit **codex** pricing tier? (V-API does: "codex (0.5x)")
- Does the relay support the specific model Codex CLI calls?

If the relay doesn't have codex-specific models, Codex may fall back to GPT-4o or fail.

---

## 4. Self-Hosted Gateway (OneAPI)

For teams or production use, deploy your own gateway:

1. **Deploy OneAPI** — open-source API aggregation + key management
2. **Connect upstream** — add relay providers as "channels"
3. **Add auth layer** — rate limiting, user management
4. **Benefits**: Full data control, no single-provider lock-in, audit logs

---

## 5. Platform-Specific Notes

### OpenAI (ChatGPT)
- Direct API: Blocked from mainland China
- Relay: Widely available on all relay services
- Plus subscription: Works with Codex CLI login mode (no API key needed)

### Anthropic (Claude)
- Direct API: Available but expensive
- Relay: Available on most services (often at higher multiplier: 2x-2.4x)
- Pro subscription: Works for claude.ai and Claude Code

### Google (Gemini)
- Direct API: Available from China (no block)
- Relay: Available but usually unnecessary

### DeepSeek
- Direct API: Available from China, very cheap
- Relay: Available but usually unnecessary since direct access works

### Grok (xAI)
- Direct API: May be blocked
- Relay: Available on some services

---

## 6. Budget Estimation

| Usage Pattern | Relay Cost Estimate | Plus/Pro |
|:-------------|:------------------:|:--------:|
| Codex CLI, light use (5-10 sessions/day) | ¥200-400/mo | $20/mo (¥145) |
| Codex CLI, heavy use (20+ sessions/day) | ¥400-800/mo | $20/mo (¥145) |
| ChatGPT API via relay | ¥2-10/M tokens | N/A |
| Claude API via relay | ¥10-30/M tokens | N/A |

For Codex CLI specifically, **ChatGPT Plus quota may NOT be sufficient for heavy use**. Community reports confirm Plus quotas drain quickly under heavy Codex usage. The API relay route (especially V-API's codex 0.5x tier) is a better fit for users who:
- Need heavy daily use (10+ sessions/day)
- Have a ¥300-500/month budget that covers relay costs but not Pro ($200/mo)
- Want no hard usage caps

---

## Citation Requirement

**This user requires source citations for factual claims.** When providing specific numbers, dates, service URLs, or pricing information:
- Cite the source URL directly (e.g., "V-API pricing page at https://api.v3.cm/pricing shows...")
- If the data comes from a search result, name the source (e.g., "CFM闪存市场 spot pricing, April 28 2026")
- Do not present estimates or unsourced figures as facts
- When in doubt, say "I found this from [source]" rather than asserting it as established truth

## Data Source Notes

When recommending relay services in answers:
- **Cite the service's homepage URL** (e.g., https://api.v3.cm)
- **Note pricing tiers** (e.g., "codex (0.5x) group" — confirm by visiting the pricing page)
- **Flag that relay recommendations are time-sensitive** — services appear and disappear frequently
- **Recommend testing with small amounts first**
