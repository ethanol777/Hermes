# Python Debugging (pdb + debugpy)

## Quick Reference: pdb Commands

| Command | Action |
|---------|--------|
| `n` | next line |
| `s` | step into |
| `r` | return from function |
| `c` | continue |
| `l` / `ll` | list source |
| `w` | where (stack trace) |
| `u` / `d` | move up/down stack |
| `p expr` / `pp expr` | print expression |
| `b file:line` | set breakpoint |
| `cl N` | clear breakpoint |
| `!stmt` | execute statement |
| `interact` | full Python REPL |
| `q` | quit |

## Recipe 1: Local breakpoint

```python
breakpoint()  # drop into pdb here
```

## Recipe 2: Launch under pdb

```bash
python -m pdb path/to/script.py arg1
```

## Recipe 3: Debug pytest

```bash
pytest tests/test_file.py::test_name --pdb -p no:xdist
```

## Recipe 4: Post-mortem

```python
import pdb, sys
try: run_the_thing()
except Exception: pdb.post_mortem(sys.exc_info()[2])
```

## Recipe 5: Remote debug (debugpy)

```bash
pip install debugpy
python -m debugpy --listen 127.0.0.1:5678 --wait-for-client your_script.py
```

## Better alternative: remote-pdb (agent-friendly)

```bash
pip install remote-pdb
```

In code: `from remote_pdb import set_trace; set_trace(host="127.0.0.1", port=4444)`
From terminal: `nc 127.0.0.1 4444` → full (Pdb) prompt.

## Common Pitfalls

1. **pdb under pytest-xdist**: silently does nothing. Use `-p no:xdist` or `-n 0`
2. **breakpoint() in CI**: hangs the process. Pre-commit grep to catch
3. **PYTHONBREAKPOINT=0**: disables all breakpoint() calls
4. **ptrace_scope**: debugpy attach-to-PID requires `sudo sh -c 'echo 0 > /proc/sys/kernel/yama/ptrace_scope'`
5. **Threads**: pdb debugs only current thread. Use debugpy for multi-threaded
6. **asyncio**: pdb works in coroutines, `await` needs Python 3.13+
