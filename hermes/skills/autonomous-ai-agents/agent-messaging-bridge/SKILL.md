---
name: agent-messaging-bridge
description: Install and configure bridges that expose local AI coding agents through chat platforms (Telegram, Feishu/Lark, Discord, Slack, WeChat, etc.); covers cc-connect-style setup, Web UI initialization, and platform credential handoff.
---

# Agent Messaging Bridge

Use this skill when the user wants to install, configure, or troubleshoot a tool that lets them talk to a **local coding agent** from a messaging platform, such as Telegram, Feishu/Lark, DingTalk, Slack, Discord, personal WeChat, QQ, or similar.

This is a class-level workflow. Current concrete implementation covered: `cc-connect`.

Support file: `references/cc-connect-windows-notes.md` for Windows/Git Bash session notes and verification sequence.

## Core workflow

1. **Read the upstream install guide first**
   - For `cc-connect`: `https://raw.githubusercontent.com/chenhg5/cc-connect/refs/heads/main/INSTALL.md`
   - Prefer upstream docs over guessing command flags.

2. **Check prerequisites before installing**
   - Node/npm path: `node -v && npm -v`
   - Existing bridge binary: `command -v cc-connect || true`
   - Existing config path: `~/.cc-connect/config.toml`

3. **Install the bridge**
   - Most users: `npm install -g cc-connect`
   - Verify: `cc-connect --version`

4. **Initialize config before Web UI**
   - If `cc-connect web` says config is missing, run `cc-connect` once.
   - First run creates `~/.cc-connect/config.toml` and exits with a message asking for config edits.

5. **Enable/open Web Admin UI**
   - Run `cc-connect web`.
   - This configures `[management]` and opens the dashboard URL, commonly `http://localhost:9820`.
   - Important: `cc-connect web` configures/opens the admin UI; it does **not** start the bridge service.

6. **Start the bridge service separately**
   - Run `cc-connect` in a separate terminal/background process.
   - Then open the Web UI and log in using `[management].token` from `~/.cc-connect/config.toml`.

7. **Configure agent and platform**
   - Default generated config is only a template. Replace placeholder values such as:
     - `work_dir = "/path/to/your/project"`
     - Feishu placeholder `app_id` / `app_secret`
   - Choose agent: Claude Code, Codex, Cursor, Gemini CLI, OpenCode, iFlow, Qoder, etc.
   - Choose platform: Telegram is often the lowest-friction first setup because it uses BotFather token and no public IP.

## cc-connect notes

- `cc-connect web --help` may trigger Web UI setup rather than showing help if management is not enabled yet.
- Config file location on Windows user machine is usually `C:\Users\<user>\.cc-connect\config.toml`.
- On Git Bash/MSYS, the binary may appear under a POSIX-style path such as `/c/Users/<user>/scoop/apps/nodejs-lts/current/bin/cc-connect`.
- The Web UI login secret is the `[management].token` value, not the `[bridge].token`.
- Keep tokens out of final messages unless the user explicitly needs them; describe where to find them instead.
- If the project agent is `type = "codex"`, verify `codex --version`; if missing, install with `npm install -g @openai/codex`. If the user uses an OpenAI-compatible custom provider, make sure Codex CLI is also configured to see that provider/API key, not just cc-connect's provider block.
- When replacing the generated template, remove unused placeholder platform blocks such as Feishu `your-feishu-app-id`/`your-feishu-app-secret`; otherwise recovery loops may produce noisy misleading logs.
- For Telegram bots, verify the token with Bot API `getMe` before declaring the bridge ready. In groups, BotFather privacy mode controls what the bot can see: use `/setprivacy` → bot → `Disable` if the bot must read all group messages.

## Platform choice heuristic

- **Telegram**: easiest personal test path, no public IP, needs BotFather token.
- **Feishu/Lark**: good for work/chatops, WebSocket mode can avoid public IP, needs app credentials and permissions.
- **Discord/Slack**: good for communities/servers, needs bot/app setup.
- **Personal WeChat / QQ**: possible but often more moving parts; use upstream docs and expect QR login/bridge constraints.
- **LINE / webhook-only modes**: usually require public URL via server, ngrok, or cloudflared.

## Verification checklist

- `cc-connect --version` returns a version.
- `~/.cc-connect/config.toml` exists.
- `[management] enabled = true` and has a port/token.
- `cc-connect` service is running.
- Web UI opens and logs in with the management token.
- At least one project has a real `work_dir`, an installed agent type, and a platform with real credentials.
- For Telegram, Bot API `getMe` returns `ok: true` for the supplied bot token.
- If the platform is a group chat, BotFather privacy mode matches the expected behavior.

## Pitfalls

- Do not treat successful install as a working chat bridge. Install + Web UI is only the base; platform credentials and agent config are still required.
- Do not tell the user `cc-connect web` starts the service. It only configures/opens Web Admin.
- Do not leave placeholder project settings and claim the setup is usable.
- Do not guess platform credentials. Ask for or guide the user to create the token/app secret.
- If running under another agent environment, start the bridge from a separate terminal when subprocess restrictions or environment variables interfere.
