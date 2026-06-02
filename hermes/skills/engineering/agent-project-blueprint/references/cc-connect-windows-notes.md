# cc-connect Windows notes

Session-derived notes for setup and verification.

## Working sequence observed

1. Read upstream INSTALL.md first.
2. Install with npm: `npm install -g cc-connect`.
3. Verify: `cc-connect --version`.
4. Initialize once with `cc-connect` to create `~/.cc-connect/config.toml`.
5. Enable/open management UI with `cc-connect web`.
6. Start the bridge service with `cc-connect` in the background.
7. Open `http://localhost:9820` and log in with the management token from `config.toml`.

## Windows/Git Bash specifics

- `cc-connect` may resolve through Scoop-installed Node paths under `/c/Users/<user>/scoop/apps/nodejs-lts/current/bin/cc-connect`.
- Config path on Windows user profile: `C:\Users\77\.cc-connect\config.toml`.
- Default template config may still contain placeholder project/platform values after initialization.

## Important distinction

- `cc-connect web` configures and opens the admin UI.
- It does **not** start the bridge process itself.

## Telegram BotFather token handoff

When the user pastes a BotFather token:

1. Write it into the Telegram platform block in `~/.cc-connect/config.toml`.
2. Remove unused generated placeholder platform blocks (for example Feishu placeholder credentials) to reduce noisy recovery logs.
3. Set `work_dir` to a real project path instead of `/path/to/your/project`.
4. If project agent is Codex, verify the CLI separately with `codex --version`; install with `npm install -g @openai/codex` if it is genuinely absent.
5. Restart `cc-connect` after config edits.
6. Verify the Telegram token independently via Bot API `getMe` and report only non-secret identity fields such as username/id.
7. Tell the user about BotFather `/setprivacy` only when group-message visibility matters.

Security note: never echo the full Telegram token in final output; say it was written or where it is stored.
