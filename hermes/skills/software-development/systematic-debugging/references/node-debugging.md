# Node.js Debugging (--inspect + CDP)

## Quick Reference: `node inspect` REPL

Launch paused on first line:
```bash
node inspect path/to/script.js
node --inspect-brk $(which tsx) path/to/script.ts
```

## REPL Commands

| Command | Action |
|---------|--------|
| `c` / `cont` | continue |
| `n` / `next` | step over |
| `s` / `step` | step into |
| `o` / `out` | step out |
| `pause` | pause running code |
| `sb('file.js', 42)` | set breakpoint |
| `cb('file.js', 42)` | clear breakpoint |
| `bt` | backtrace |
| `list(5)` | show source lines |
| `repl` | JS REPL in current scope |
| `watch('expr')` | watch expression |

## Attach to Running Process

```bash
kill -SIGUSR1 <pid>                # enable inspector on running process
node inspect -p <pid>              # attach CLI debugger
node --inspect-brk script.js       # start and pause on first line
```

## CDP Automation (chrome-remote-interface)

```bash
npm i -g chrome-remote-interface
```

Script at `/tmp/cdp-debug.js`:
```javascript
const CDP = require('chrome-remote-interface');
(async () => {
  const client = await CDP({ port: 9229 });
  const { Debugger, Runtime } = client;
  Debugger.paused(async ({ callFrames, reason }) => {
    // inspect frames, scopes, locals...
    await Debugger.resume();
  });
  await Debugger.enable();
  await Debugger.setBreakpointByUrl({ urlRegex: '.*app\\.tsx$', lineNumber: 119 });
  await Runtime.runIfWaitingForDebugger();
})();
```

## Common Pitfalls

1. **Sourcemaps**: `node inspect` doesn't follow sourcemaps. Break in built JS, not TS.
2. **--inspect vs --inspect-brk**: Without -brk, code races past your breakpoints
3. **Port collisions**: Default 9229. Use `curl -s http://127.0.0.1:9229/json/list` to list targets
4. **Child processes**: `--inspect` on parent doesn't inspect children. Use `NODE_OPTIONS='--inspect-brk'`
5. **Security**: `--inspect=0.0.0.0` exposes arbitrary code execution. Always bind to 127.0.0.1
