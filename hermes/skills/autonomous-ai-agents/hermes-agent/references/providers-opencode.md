# OpenCode as Hermes Provider

OpenCode offers two API tiers that can serve as Hermes LLM backends:

## OpenCode Go

Provides access to open models: **GLM-5**, **Kimi K2.5**, **MiniMax M2.5**, etc.
\$10/month subscription. Get key at: https://opencode.ai/auth

### Setup

1. **Add API key to `~/.hermes/.env`:**
   ```
   OPENCODE_GO_API_KEY=sk-your-key-here
   OPENCODE_GO_BASE_URL=https://opencode.ai/zen/go/v1
   ```

2. **Configure Hermes:**
   ```bash
   hermes config set model.provider opencode-go
   hermes config set model.default glm-5
   # or kimi-k2.5 / minimax-m2.5
   ```

3. **New session to apply** → `/reset` or restart gateway.

### Common Models

| Model | Config value |
|-------|-------------|
| GLM-5 | `glm-5` |
| Kimi K2.5 | `kimi-k2.5` |
| MiniMax M2.5 | `minimax-m2.5` |

## OpenCode Zen

Curated, tested models (GPT, Claude, Gemini, MiniMax, GLM, Kimi).
Pay-as-you-go pricing.

### Setup

1. **Add API key to `~/.hermes/.env`:**
   ```
   OPENCODE_ZEN_API_KEY=sk-your-key-here
   ```

2. **Configure Hermes:**
   ```bash
   hermes config set model.provider opencode-zen
   hermes config set model.default <model-name>
   ```

### Binary Path on WSL (for delegated coding tasks)

When OpenCode is installed via Hermes's bundled bun, the binary lives at:
```
/home/ethanol/.hermes/node/bin/opencode
```

Running from Windows paths (`/mnt/c/Users/...`) won't find it — use the full path or switch to a Linux home directory.
