# Mission Control — WSL Deployment Notes

## Prerequisites
- Node.js 22+ (available via Hermes bundled node at `/home/ethanol/.hermes/node/bin/node`)
- pnpm (install via `npm install -g pnpm`)
- Git

## Step-by-Step

```bash
# 1. Clone
git clone https://github.com/builderz-labs/mission-control.git ~/mission-control
cd ~/mission-control

# 2. Ensure pnpm is in PATH (Hermes' node may shadow global npm)
export PATH="/home/ethanol/.hermes/node/bin:$PATH"

# 3. Install dependencies
pnpm install

# 4. Build
pnpm build

# 5. Start with tmux (persists after terminal closes)
tmux new-session -d -s mc 'cd ~/mission-control && export PATH="/home/ethanol/.hermes/node/bin:$PATH" && pnpm start'
```

## Gotchas

### Corepack fails on WSL
The `install.sh` script tries `corepack enable`, but on WSL the Windows Node.js binary path (`/mnt/c/Program Files/nodejs/corepack`) has CRLF newlines breaking the shebang. **Workaround:** skip the installer script and run manually (steps above).

### pnpm not found despite npm install -g
Hermes bundles its own Node.js at `/home/ethanol/.hermes/node/`. Global npm modules go to `/home/ethanol/.hermes/node/bin/`, which may not be in `$PATH`. Always do:
```bash
export PATH="/home/ethanol/.hermes/node/bin:$PATH"
```
before any pnpm command.

### Approved builds
pnpm v10 requires explicitly approving which packages can run build scripts. The project's `package.json` lists `better-sqlite3` and `node-pty`. Other native deps (`sharp`, `esbuild`, `@swc/core`, `@parcel/watcher`, `unrs-resolver`) may show warnings but don't block the build.

If the build requires them, set `.npmrc`:
```
only-built-dependencies=sharp esbuild @swc/core @parcel/watcher unrs-resolver vue-demi better-sqlite3 node-pty
```

### Port 3000 conflict
Mission Control defaults to port 3000. To change:
```bash
# Set env var before starting:
PORT=3001 pnpm start
```
Or set `PORT=3001` in `.env`.

## First-Time Setup
1. Visit `http://localhost:3000/setup` in browser
2. Create admin account (username + password, min 12 chars)
3. Get API Key from Settings page

## Management

| Action | Command |
|--------|---------|
| View logs | `tmux attach -t mc` |
| Restart | `tmux send-keys -t mc '^C' Enter && tmux new-session -d -s mc 'cd ~/mission-control && pnpm start'` |
| Stop | `tmux kill-session -t mc` |
| Update | `cd ~/mission-control && git pull && pnpm install && pnpm build && tmux kill-session -t mc && tmux new-session -d -s mc 'cd ~/mission-control && pnpm start'` |

## API Key Usage

```bash
export MC_API_KEY="<key-from-settings>"

# Register Hermes as an agent
curl -X POST http://localhost:3000/api/adapters \
  -H "Content-Type: application/json" \
  -H "x-api-key: $MC_API_KEY" \
  -d '{"framework": "generic", "action": "register", "payload": {"agentId": "hermes", "name": "Hermes Agent"}}'

# Heartbeat every 5 min
curl -X POST http://localhost:3000/api/adapters \
  -H "Content-Type: application/json" \
  -H "x-api-key: $MC_API_KEY" \
  -d '{"framework": "generic", "action": "heartbeat", "payload": {"agentId": "hermes", "status": "online"}}'
```
