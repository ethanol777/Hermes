# Codex CLI + API Relay Setup (May 2026)

Session findings from May 8, 2026 — research on using OpenAI Codex CLI through Chinese API relay services.

## Current State

- **Codex CLI** (npm: `@openai/codex`) now supports **ChatGPT Plus login mode** — no API key needed. Just `npm i -g @openai/codex` then `codex` to launch.
- Codex has evolved into a full app with CLI + desktop modes, using GPT-5.3/5.4/5.5 coding-optimized models.
- Cost: ChatGPT Plus = $20/month (≈¥145)

## API Relay for Codex

If using relay mode (with `OPENAI_API_KEY`):

### V-API Codex Tier

- **Site**: https://api.v3.cm
- **Tier**: "codex (0.5x)" — 0.5x multiplier on base pricing
- **Models**: 718 total; codex-specific models available
- **Configuration**: `export OPENAI_BASE_URL=https://api.v3.cm/v1`
- **Pricing**: 0.5x group means Codex models at half-rate relative to default group

### Other Relays Tried/Considered

| Service | Codex Support | Notes |
|---------|:-------------:|-------|
| API2D | Partial | No explicit codex tier found |
| OhMyGPT | Limited | Smaller model selection |
| Veast | Unknown | Not verified in this session |

## Key Insight: Plus Quota Is Insufficient for Heavy Use

**ChatGPT Plus ($20/mo) has usage quotas that drain quickly with Codex CLI.** OpenAI community reports ("GPT 5.5 Codex Quota Drains Quickly", "Understanding the New Codex Limit System After the April 9 Update") confirm that heavy coding use exhausts the Plus quota in days, not weeks.

For heavy daily use (10+ coding sessions/day), the comparison becomes:

| Approach | Monthly Cost | Suitability |
|----------|:-----------:|:-----------:|
| ChatGPT Plus | ~¥145 | ❌ Quota too low for heavy Codex use |
| ChatGPT Pro | ~¥1,450+ | ✅ High quota but expensive |
| V-API codex (0.5x) relay | ~¥200-400 | ✅ No quota, usage-based |
| Direct API relay (other) | ~¥400-800 | ✅ Varies by provider |

**Bottom line**: For a user with a ¥500/month budget who wants to use Codex CLI heavily, the API relay approach (especially V-API's codex 0.5x tier) is the sweet spot — cheaper than Pro, no quota limits, and well within budget.

Relay (API mode) makes sense when:
- You need to use Codex through API (not login)
- You're integrating into automated pipelines or CI/CD
- Plus quota is insufficient for your usage volume
- You have a budget that covers relay costs but not Pro ($200/mo)

Plus login mode still makes sense for:
- Light to moderate use
- Users who prioritize simplicity over flexibility
- Budget-constrained users who don't hit quota limits

## Useful Links from Research

- https://zhuanlan.zhihu.com (search "Codex 国内使用 2026") — Chinese installation guides with relay config examples
- https://csguide.cn/private/how-to-use-codex.html — detailed Codex CLI domestic setup tutorial
- https://getgpt.pro/codex — ChatGPT Plus upgrade service for Chinese users
- https://github.com/freestylefly/CodexGuide — Chinese Codex knowledge base
