# Gateway Model Mismatch — CLI vs config.yaml

## The Problem

When the user changes the model **interactively** (e.g. `/model deepseek-v4-flash` in CLI, or `hermes -m <model>` on startup), the change only applies to **that CLI session** — it does NOT persist to `~/.hermes/config.yaml`.

The **gateway** (which powers messaging platforms — Feishu, WeChat, Telegram, etc.) reads its model from `config.yaml` at startup. So the CLI and gateway can end up on **different models**, confusing the user:

```
CLI session:      deepseek-v4-flash  (via /model or -m flag)
config.yaml:      glm-5              (stale, unchanged)
  └─ gateway:     glm-5              (reads config.yaml)
     └─ WeChat:   glm-5              ← "why is my bot on a different model?"
```

## Diagnosis

1. Check the current CLI model from the conversation header (`Model: xxx` line at start).
2. Check `config.yaml` model:
   ```bash
   grep -A3 "^model:" ~/.hermes/config.yaml
   ```
3. If they differ, that's the root cause.

4. Confirm the gateway is using config.yaml:
   ```bash
   # Restart to pick up current config.yaml, then check logs
   systemctl --user restart hermes-gateway
   sleep 2
   grep "weixin\|feishu\|telegram\|discord" ~/.hermes/logs/gateway.log | grep "connected" | tail -4
   ```

## Fix

Synchronise the config.yaml model to match the CLI intention:

```bash
# Option A: Set via CLI (persistent)
hermes config set model.default deepseek-v4-flash

# Option B: Direct edit
grep -A3 "^model:" ~/.hermes/config.yaml
# Edit if needed via: nano ~/.hermes/config.yaml
```

Then **restart the gateway** for the change to take effect:

```bash
systemctl --user restart hermes-gateway
```

## Prevention

- When the user asks "why is my [platform] not using my current model", always check `config.yaml` model first.
- The `hermes model` interactive command updates `config.yaml` correctly — prefer it over `/model` slash command when the intent is a permanent change.
- If using `/model` for a quick test, note that the gateway reads config.yaml, not the session state.
