# Chinese API Relay Providers (API中转站)

When users in China need access to OpenAI, Anthropic, Google, xAI, and other overseas LLM APIs, they often use **API中转站** (API relay/proxy services) instead of direct connections. These services:
- Accept Chinese payment methods (Alipay/WeChat)
- Bypass the Great Firewall
- Often offer lower prices than official API
- Provide OpenAI-compatible endpoints for easy integration

## Verified Options (as of May 2026)

### Tier 1: Established & Multi-Model

| Service | URL | Models | Pricing Notes |
|---------|-----|--------|---------------|
| **V-API** | https://api.v3.cm | 718 models — OpenAI, Claude 4/4.6, Gemini, DeepSeek, Grok, Qwen, Doubao, MJ, Suno | Multiple token groups with different multipliers (default, claude 2.4x, gf 2x, gemini 1.5x, qwen 0.4x, etc.) |
| **API2D / API2GPT** | (well-known) | OpenAI + Claude | Older, stable, Alipay support. Higher prices than newer competitors. |
| **OhMyGPT** | (well-known in community) | OpenAI + Claude | Budget-friendly. Limited Claude model selection. Smaller operation — higher risk. |
| **Veast AI** | (Singapore) | Full model lineup | Good China access speed. Responsive support. |

### Tier 2: Self-Hosted / Open Source

| Service | Description |
|---------|-------------|
| **OneAPI** | Open-source aggregation layer. Deploy your own, connect multiple upstream channels. Full data control but requires server maintenance. |

### What to Look For

| Feature | Why It Matters |
|---------|---------------|
| **Alipay/WeChat Pay** | Must-have for Chinese users without foreign credit cards |
| **OpenAI-compatible endpoint** | `https://api.service.com/v1/chat/completions` — works with any OpenAI SDK |
| **Status/monitoring page** | Shows uptime history — good sign of reliability |
| **Multiplier pricing groups** | Common model: base price × multiplier per model tier (cheaper for local CN models, more expensive for Claude). Look for a transparent pricing table. |
| **Active Telegram/community** | Ongoing support + outage alerts + user feedback |
| **Balance refund policy** | Some services refund unused balance; some don't. Ask before large deposits. |

## Integration with Hermes Agent

To use a relay service as a Hermes provider:

```yaml
# In config.yaml add a custom provider section or use model.base_url
model:
  default: "gpt-4o"  # or whatever model name the relay uses
  provider: openai  # most relays emulate the OpenAI protocol
  base_url: "https://api.v3.cm/v1"
  api_key: "your-api-key-from-relay-service"
```

Or set env vars:
```bash
export OPENAI_API_KEY="sk-your-relay-key"
export OPENAI_BASE_URL="https://api.v3.cm/v1"
```

## Pitfalls

- **Data privacy**: Your prompts pass through the relay's servers. Never send sensitive/proprietary data through an untrusted relay.
- **Model name differences**: Relays often rename models (e.g. `claude-sonnet-4-20250507` vs Claude's official name). Check their model list before configuring.
- **Rate limits**: Relay services have their own rate limits, often lower than official API.
- **Scam risk**: The industry has frequent scam/shutdown events. Start with the minimum top-up (¥10-20) and test for a few days before committing larger amounts.
- **Bing国内版 filter**: Searching for relay service reviews on Bing国内版 often returns poor results. Switch to 国际版 or use Chinese community platforms (V2EX, Zhihu, Telegram groups).
