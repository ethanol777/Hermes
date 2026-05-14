#!/bin/bash
# auto_sync_v2.sh — Sync from HERMES_HOME (AppData/Local/hermes) → ~/Hermes/ → GitHub
set -e

HERMES_HOME="/c/Users/77/AppData/Local/hermes"
HERMES="$HOME/Hermes"
TARGET="$HERMES/hermes"

echo "=== auto_sync_v2 ==="
echo "Source: $HERMES_HOME"
echo "Target: $TARGET"
echo "Time:   $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Resolve source
if [ ! -d "$HERMES_HOME" ]; then
  # Try cygpath if available
  if command -v cygpath &>/dev/null; then
    HERMES_HOME=$(cygpath -u "C:\Users\77\AppData\Local\hermes" 2>/dev/null)
  fi
fi

echo "Resolved HERMES_HOME: $HERMES_HOME"

if [ ! -d "$HERMES_HOME" ]; then
  echo "ERROR: HERMES_HOME ($HERMES_HOME) not found!"
  exit 1
fi

mkdir -p "$TARGET"

# Sync core files
sync_file() {
  local src="$1" dst="$2"
  if [ -f "$src" ]; then
    cp -f --preserve=timestamps "$src" "$dst"
    echo "  OK  $src -> $dst"
  else
    echo "  MISS $src"
  fi
}

sync_dir() {
  local src="$1" dst="$2"
  if [ -d "$src" ]; then
    mkdir -p "$dst"
    cp -rf --preserve=timestamps "$src"/. "$dst/"
    echo "  OK  $src/ -> $dst/"
  else
    echo "  MISS $src/"
  fi
}

echo ""
echo ">>> Syncing SOUL.md"
sync_file "$HERMES_HOME/SOUL.md" "$TARGET/SOUL.md"

echo ">>> Syncing config.yaml"
sync_file "$HERMES_HOME/config.yaml" "$TARGET/config.yaml"

echo ">>> Syncing memories/"
sync_dir "$HERMES_HOME/memories" "$TARGET/memories"

echo ">>> Syncing skills/"
sync_dir "$HERMES_HOME/skills" "$TARGET/skills"

echo ">>> Syncing cron/"
sync_dir "$HERMES_HOME/cron" "$TARGET/cron"

# Also sync any other top-level important files
for f in "$HERMES_HOME"/.gitignore; do
  [ -f "$f" ] && sync_file "$f" "$TARGET/$(basename "$f")"
done

echo ""
echo ">>> Git status and push"
cd "$HERMES"

# Clean stale rebase state
if [ -d "$HERMES/.git/rebase-merge" ] || [ -d "$HERMES/.git/rebase-apply" ]; then
  echo "... aborting stale rebase"
  git rebase --abort 2>/dev/null || true
  git checkout master 2>/dev/null || true
fi
git reset --merge 2>/dev/null || true

git status --short
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "auto-sync-v2 $(date '+%Y-%m-%d %H:%M')"
  echo ">>> Pushing to GitHub..."
  git fetch origin master 2>&1
  if git rebase FETCH_HEAD -X theirs 2>&1; then
    :
  else
    echo "rebase failed, trying merge..."
    git rebase --abort 2>/dev/null || true
    git merge origin/master --no-edit -X theirs 2>/dev/null || true
  fi
  git push origin master 2>&1 || {
    echo "push failed, retrying..."
    sleep 2
    git pull origin master --no-edit -X theirs 2>/dev/null || true
    git push origin master 2>&1
  }
else
  echo "Nothing to commit - checking remote..."
  git fetch origin master 2>&1
  if git rebase FETCH_HEAD -X theirs 2>&1; then
    git push origin master 2>&1 || true
  else
    git rebase --abort 2>/dev/null || true
  fi
fi

echo "=== auto_sync_v2 complete ==="
