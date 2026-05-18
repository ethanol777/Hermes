# OpenCode + DeepSeek Integration (No OAuth Required)

## The Discovery

`opencode auth login` is interactive (requires device code flow + browser). It times out in non-interactive environments. But there's a simpler path: **pass the API key directly as an environment variable**.

## Verified Working Pattern

```bash
# One-shot task with DeepSeek API key
DEEPSEEK_API_KEY=sk-d319d11ac9d541609f50f9ad0766fd62 opencode run 'Respond with exactly: OK'

# Interactive session
DEEPSEEK_API_KEY=sk-xxx opencode

# With explicit provider flag
DEEPSEEK_API_KEY=sk-xxx OPENCODE_PROVIDER=deepseek opencode run '...'
```

**Result:** `deepseek-v4-pro` model responds correctly.

## What Doesn't Work (Pitfall)

```bash
# Interactive auth flow - times out in non-interactive/PTY environments
opencode auth login --provider deepseek
# → hangs waiting for device code browser flow

# --api-key flag doesn't exist on auth login
opencode auth login --api-key sk-xxx
# → error: auth login expects a URL, not an API key

# In tmux/background shells: always use env var pattern
opencode auth login
# → hangs even with PTY if no real browser is attached
```

**Session failure observed:** `opencode auth login` inside a tmux session with PTY — device code flow couldn't reach a browser, process hung indefinitely. Root cause: no browser attached in that environment. Fix: use env var inline, never the interactive login flow.

## OpenCode Binary Location

```bash
which opencode              # /usr/local/bin/opencode (npm global)
npm list -g opencode-ai    # check installed version
opencode --version         # 1.14.31
```

## Credentials Storage

OpenCode stores credentials at: `~/.local/share/opencode/auth.json`

To see current auth state:
```bash
opencode auth list
```

## Hermes Integration

For delegating to OpenCode from Hermes:

```bash
# One-shot (non-interactive)
terminal(command="DEEPSEEK_API_KEY=sk-xxx opencode run 'Your task here'", timeout=300)

# Background interactive session
terminal(command="opencode", workdir="~/project", background=true, pty=true)
```

## Other Provider API Keys (Same Pattern)

| Provider | Env Var |
|----------|---------|
| DeepSeek | `DEEPSEEK_API_KEY` |
| OpenRouter | `OPENROUTER_API_KEY` |
| Google Gemini | `GOOGLE_API_KEY` or `GEMINI_API_KEY` |
| OpenAI | `OPENAI_API_KEY` |

Pattern: `PROVIDER_API_KEY=xxx opencode run '...'`
