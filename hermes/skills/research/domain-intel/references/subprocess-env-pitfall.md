# Subprocess Environment Pitfall — Windows + MSYS

## The Problem

On Windows hosts running bash via MSYS (git-bash, Git Bash, MSYS2), `subprocess.run(['python3', '-c', '...'])` or `terminal` with inline Python scripts can fail with:

```
AssertionError: SRE module mismatch
  File "...\re\_compiler.py", line 18, in <module>
    assert _sre.MAGIC == MAGIC, "SRE module mismatch"
```

**Root cause**: When Hermes spawns a subprocess via `terminal` (which runs through MSYS bash on this Windows setup), the subprocess's Python interpreter picks up a stdlib `re` module compiled against a different Python build than the one Hermes itself uses. The mismatch is at the C extension level and cannot be patched at the Python layer.

**Scope**: Affects any `terminal` invocation that pipes Python code via `| python3 -c "..."` or `python3 -c "..."`. The MSYS Python is the culprit — it uses MSYS-style path translation and a different Python build than the Windows-native Python.

## The Fix

Use `execute_code` (the inline Python runner) instead of `terminal` for any Python stdlib networking code. `execute_code` runs in-process inside the active Hermes Python environment, bypassing the subprocess entirely.

## Correct Pattern

```python
# ✅ CORRECT — run in-process, no subprocess
import urllib.request, json
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
data = json.loads(urllib.request.urlopen(req).read().decode())
```

## Incorrect Patterns

```bash
# ❌ BROKEN on Windows+MSYS — subprocess Python stdlib mismatch
curl -s "https://api.example.com" | python3 -c "import sys,json; print(json.load(sys.stdin))"

# ❌ BROKEN on Windows+MSYS
python3 -c "import urllib.request,json; print(json.loads(urllib.request.urlopen('https://api.example.com').read().decode()))"

# ❌ BROKEN if script is long
cat script.py | python3
```

## When subprocess IS Fine

Subprocess calls work for:
- Shell-native commands: `curl`, `grep`, `find`, `ls`, `git`, `awk`
- Commands with no Python involved
- When `execute_code` cannot do what you need (e.g., you need a full interactive REPL)

## Testing the Environment

To confirm you're on a Windows+MSYS setup where this applies:

```bash
uname -s  # → MSYS_NT-* on this host
python3 --version  # → shows MSYS Python, different build from hermes-agent's venv Python
```

The `execute_code` tool uses the Hermes agent's own Python (from `hermes-agent/venv/`) which is the Windows-native build and avoids the stdlib conflict.
