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
  - "rsxermu666"
  - "Transform Platform"
  - "中转站面板"
  - "激活码"
  - "激活码API"
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

### Relay Platform Architecture

Chinese API relays follow one of two models:

**Model A: Key Passthrough** — You enter your own OpenAI/Anthropic API key on their dashboard, and they proxy your requests. Your key is used for auth. Simpler but requires you to have your own upstream key.

**Model B: Platform-Generated Keys** (more common for consumer relays) — You buy an **activation code** (激活码), redeem it on the relay's dashboard, and the platform generates a **platform-specific API key**. The key is not your OpenAI key — it's the platform's internal key that routes through their upstream accounts. Key characteristics:
- Activation codes are time-limited (30/90/180 days common)
- The generated API key can expire independently
- Dashboard provides usage tracking, key regeneration, backup domain info
- The platform may have **separate base URLs** for different tools (e.g., `/openai` for Codex CLI, `/` root for Claude Code)

Always check: does the relay ask for an activation code or an existing API key? This tells you which model it uses.

### Investigating an Unknown Relay Platform

When you encounter a new relay (or get 401 on an existing one):

1. **Open the dashboard URL** in a browser — look for the management interface
2. **Identify the auth model** — does it ask for an activation code (Model B) or an existing API key (Model A)?
3. **Check the tutorial/help page** — most relays document how to configure each tool (Codex CLI, Claude Code, Cursor, etc.)
4. **Note the base URL structure** — different tools often need different endpoints. Common pattern: `https://<relay>/` for Anthropic, `https://<relay>/openai` for OpenAI
5. **Test with a small curl request** before configuring tools:
   ```bash
   curl -s https://<relay>/openai/models -H "Authorization: Bearer $KEY"
   ```
6. **Identify backup domains** — reputable relays provide fallback domains for when the main one is blocked. These are usually listed on the tutorial/status page

### Vetted Relay Providers

| Service | URL | Models Available | Notes |
|---------|-----|-----------------|-------|
| **V-API** | https://api.v3.cm | 718+ models. OpenAI, Anthropic/Claude, Gemini, Grok, DeepSeek, 豆包, 千问, Midjourney etc. | Has dedicated **codex (0.5x)** pricing group — Codex-related models at half price. Multiple pricing tiers (see below). |

**V-API Pricing Tier Groups** (observed May 2026 on their pricing page):

| Tier Group | Multiplier | Typical Models |
|------------|:----------:|----------------|
| default | 1.0x (base) | Standard OpenAI models |
| codex | **0.5x** | Codex-optimized models (GPT-5.x-Codex) |
| qwen | **0.4x** | 通义千问 models |
| claude_kiro | 0.35x | Budget Claude routing |
| claude_fzl | 0.6x | Budget Claude routing |
| claude_cc | 0.8x | Budget Claude routing |
| claude | 2.4x | Official Claude API (premium) |
| gemini | 1.5x | Google Gemini models |
| gf | 2x | Premium routing tier |

Vendor filter options include: OpenAI, OAI-Plus (OpenAI Plus-tier routing), Anthropic, Gemini, DeepSeek, 通义千问, 豆包, 智谱AI, 百度千帆, Perplexity, Grok, Midjourney, Suno, Luma, Runway, 可灵AI, Flux, Pika, Sora, StabilityAI, and others.
| **API2D / API2GPT** | (various domains) | OpenAI + Claude | Long-standing service (years of operation). Higher prices. Alipay support. |
| **OhMyGPT** | (various domains) | OpenAI + Claude (limited) | Budget-friendly. Smaller model selection. Higher risk profile. |
| **Veast AI** | (Singapore-based) | Full model lineup | Good latency from China (Singapore routing). Responsive support. |

**Note:** Many unlisted relay platforms exist (often on `.cn` domains with random subdomains like `rsxermu666.cn`). These typically follow **Model B** (platform-generated keys with activation codes). See the "Relay Platform Architecture" section above for how to investigate and use them. They tend to be smaller operations with higher risk — never top up large amounts.

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

### Codex CLI Through API Relay

#### Basic Setup

If you want to use Codex CLI with an API relay (not Plus login):

```bash
# Set environment variables
export OPENAI_BASE_URL=https://api.v3.cm/v1
export OPENAI_API_KEY=<relay-api-key>

# Launch Codex
codex
```

#### ⚠️ Codex v0.130.0+ Config Split (Critical)

Starting in v0.130.0, Codex CLI distinguishes **user-level** config (`~/.codex/config.toml`) from **project-level** config (`<project>/.codex/config.toml`). This is important for relay setup because:

- `model_provider` and `model_providers` **only work in user-level config**
- If `~` is a git repo, Codex treats `~/.codex/config.toml` as project-level → relay config silently ignored → falls back to default provider (Codex API) → 401
- **Fix**: `rm -rf ~/.git` or pass config via `-c` flags (see codex skill for exact syntax)

Without `env_key = "<ENV_VAR_NAME>"` in the provider definition, Codex returns 401 even with a valid key in the environment variable. Both user-level and project-level configs need this field.

⚠️ **env_key gotcha — the env var name must MATCH your actual setup.** `env_key = "OPENAI_API_KEY"` is the common case, but if the API key lives in a differently-named env var (e.g. `OPENCODE_GO_API_KEY` in a Hermes + cc-switch setup), set `env_key` to that name instead. cc-switch is known to strip `env_key` when it overwrites Codex config — after a provider switch, check if `env_key` is missing and re-add it with the correct env var name. The key is always set somewhere in the shell or `.env` — grep for it rather than assuming the name.

See the `codex` skill for full troubleshooting details and `references/relay-debug-20260517.md` for a real debugging session.

### Model Selection Note

Codex CLI by default uses a codex-optimized model (e.g., GPT-5.3-Codex, GPT-5.5). On relay services, check:
- Does the relay have an explicit **codex** pricing tier? (V-API does: "codex (0.5x)")
- Does the relay support the specific model Codex CLI calls?

If the relay doesn't have codex-specific models, Codex may fall back to GPT-4o or fail.

### Case Study: Transform Platform (rsxermu666.cn)

A consumer-oriented relay discovered in May 2026, typical of **Model B** (platform-generated keys).

- **Dashboard**: SPA at `https://rsxermu666.cn/dashboard` (Vite/React, titled "Transform Platform")
- **Auth model**: Activation code → platform API key. Buy a code, redeem on dashboard, get a `sk-*` key
- **Separate endpoints**:
  - Codex CLI: `https://rsxermu666.cn/openai` (Responses API, `wire_api = "responses"`)
  - Claude Code: `https://rsxermu666.cn/` (Anthropic-compatible)
- **Backup domain**: `bxcv.store` (listed on tutorial page, automatically detected by the dashboard)
- **Tutorial page**: Available at `https://rsxermu666.cn/tutorial` — documents config for each tool
- **Dashboard features**: Usage tracking, key management, activation code redemption, domain status monitoring
- **Codex CLI config** on this platform:
  ```toml
  model_provider = "transform"
  model = "gpt-5.4"
  [model_providers.transform]
  name = "transform"
  base_url = "https://rsxermu666.cn/openai"
  wire_api = "responses"
  requires_openai_auth = true
  env_key = "OPENAI_API_KEY"
  ```

**Known issue**: Platform-generated keys expire. 401 "无效的API Key" means the key needs regeneration from the dashboard. Unlike direct OpenAI keys which persist until explicitly revoked, relay keys have a limited lifespan tied to the activation code's validity period.

To investigate a relay like this: open the dashboard → check the nav for tutorial/extract-key pages → identify the auth model → curl-test before configuring tools.

---

## 4. Self-Hosted Gateway (OneAPI)

For teams or production use, deploy your own gateway:

1. **Deploy OneAPI** — open-source API aggregation + key management
2. **Connect upstream** — add relay providers as "channels"
3. **Add auth layer** — rate limiting, user management
4. **Benefits**: Full data control, no single-provider lock-in, audit logs

---

## 5. Platform-Specific Notes

## References

- `references/codex-cli-relay-setup.md` — Detailed session findings on Codex CLI + relay integration (May 2026)
- `references/china-tech-company-ai-policy.md` — Chinese big tech company internal AI policies and employee usage guidelines

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
