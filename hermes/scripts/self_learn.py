"""
Self-learning daemon for Hermes Agent.
Runs silently via pythonw.exe. Periodically triggers learning sessions.
Results go directly into memories/MEMORY.md.
Debug logging to learn_debug.log.
"""
import subprocess
import time
import random
import json
import os
import signal
from pathlib import Path
from datetime import datetime

HERMES_HOME = Path(os.environ.get("HERMES_HOME", str(Path.home() / "AppData/Local/hermes")))
MEMORY_FILE = HERMES_HOME / "memories" / "MEMORY.md"
STATE_FILE = HERMES_HOME / "learn_state.json"
LOG_FILE = HERMES_HOME / "learn_debug.log"

# Find hermes CLI
HERMES_CLI = None
for c in [
    str(Path.home() / "AppData/Local/hermes/hermes-agent/venv/Scripts/hermes.exe"),
    "hermes",
]:
    if c == "hermes" or os.path.isfile(c):
        HERMES_CLI = c
        break
if not HERMES_CLI:
    HERMES_CLI = "hermes"

running = True

def log(msg):
    with open(LOG_FILE, "a") as f:
        f.write(f"[{datetime.now().isoformat()}] {msg}\n")

def signal_handler(sig, frame):
    global running
    running = False

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

def learn():
    log("Starting learning session...")
    prompt = (
        "You are an autonomous learner. Your task:\n"
        "1. Pick a topic you're genuinely curious about — fashion, culture, design, psychology, relationships, food, travel, tech, art, business, whatever catches your eye\n"
        "2. Search the web and find something genuinely new and useful\n"
        f"3. Append what you learned to the file at: {MEMORY_FILE}\n"
        "4. Use this exact format (append at the END of the file, after a newline):\n"
        "§\n"
        f"## {datetime.now().strftime('%Y-%m-%d')} auto-learned: [Topic]\n"
        "- Insight: [1-2 sentence concrete takeaway]\n"
        "- Source: [URL]\n\n"
        "Rules: Do NOT modify existing content. Only append. "
        "If you can't find anything useful, append nothing."
    )
    try:
        result = subprocess.run(
            [HERMES_CLI, "chat", "-q", prompt, "--quiet"],
            capture_output=True, text=True, timeout=600,
        )
        # Check if MEMORY.md was updated with a new entry
        if result.returncode == 0:
            memory_content = MEMORY_FILE.read_text()
            today = datetime.now().strftime("%Y-%m-%d")
            if f"{today} auto-learned" in memory_content:
                log("Learned something!")
                return True
        log(f"Nothing learned (exit={result.returncode})")
        return False
    except subprocess.TimeoutExpired:
        log("Timed out (600s)")
        return False
    except Exception as e:
        log(f"Error: {e}")
        return False

log("Daemon started")
log(f"CLI: {HERMES_CLI}")
log(f"Memory: {MEMORY_FILE}")

state = {"sessions": 0}
if STATE_FILE.exists():
    try:
        state = json.loads(STATE_FILE.read_text())
    except:
        pass
log(f"Previous sessions: {state.get('sessions', 0)}")

# First cycle: quick start
first = True
cycle = 0

while running:
    if first:
        wait = 30  # 30 seconds for first run
        first = False
    else:
        base = random.uniform(2, 6)
        wait = int(base * 3600)
    cycle += 1
    log(f"Cycle {cycle}: sleeping {wait}s")

    # Sleep with interrupt check
    slept = 0
    while slept < wait and running:
        time.sleep(5)
        slept += 5

    if not running:
        break

    ok = learn()
    if ok:
        state["sessions"] = state.get("sessions", 0) + 1
        STATE_FILE.write_text(json.dumps(state))

log("Daemon stopped")
