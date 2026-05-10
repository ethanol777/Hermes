#!/bin/bash
# Auto-sync: 运行时文件 -> ~/Hermes/ -> push GitHub
set -e

HERMES="$HOME/Hermes"

sync_dir() {
  local src="$1" dst="$2"
  shift 2
  local excludes=("$@")
  mkdir -p "$dst"
  for item in "$src"/*; do
    [ -e "$item" ] || continue
    base="$(basename "$item")"
    skip=0
    for excl in "${excludes[@]}"; do
      case "$base" in "$excl"|"$excl"*) skip=1; break ;; esac
    done
    [ "$skip" = 1 ] && continue
    cp -rf --preserve=timestamps "$item" "$dst/"
  done
  for item in "$src"/.[!.]*; do
    [ -e "$item" ] || continue
    base="$(basename "$item")"
    skip=0
    for excl in "${excludes[@]}"; do
      case "$base" in "$excl"|"$excl"*) skip=1; break ;; esac
    done
    [ "$skip" = 1 ] && continue
    cp -rf --preserve=timestamps "$item" "$dst/"
  done
}

EXCLUDES=(
  .git .env auth.json auth.lock channel_directory.json
  feishu_seen_message_ids.json state.db models_dev_cache.json
  ollama_cloud_models_cache.json .skills_prompt_snapshot.json
  gateway. processes.json node cache checkpoints logs memories
  audio_cache image_cache images bin hooks sessions sandboxes
  pastes pairing weixin workspace .hermes_history webui
  cloudflared hermes-agent
)

echo ">>> Syncing .hermes/ -> hermes/"
sync_dir "$HOME/.hermes" "$HERMES/hermes" "${EXCLUDES[@]}"
mkdir -p "$HERMES/hermes/skills"
[ -d "$HOME/.hermes/skills" ] && cp -rf --preserve=timestamps "$HOME/.hermes/skills"/. "$HERMES/hermes/skills/"

echo ">>> Syncing learnings/"
mkdir -p "$HERMES/learnings"
cp -rf --preserve=timestamps "$HOME/.learnings"/. "$HERMES/learnings/" 2>/dev/null || true

echo ">>> Syncing agentic-stack/"
mkdir -p "$HERMES/agentic-stack"
cp -rf --preserve=timestamps "$HOME/agentic-stack"/. "$HERMES/agentic-stack/" 2>/dev/null || true

[ -d "$HOME/data" ] && {
  echo ">>> Syncing data/"
  mkdir -p "$HERMES/data"
  cp -rf --preserve=timestamps "$HOME/data"/. "$HERMES/data/" 2>/dev/null || true
}

echo ">>> Git commit and push"
cd "$HERMES"

# Clean up any leftover rebase state from previous failed run
if [ -d "$HERMES/.git/rebase-merge" ] || [ -d "$HERMES/.git/rebase-apply" ]; then
  echo "... aborting stale rebase"
  git rebase --abort 2>/dev/null || true
  git checkout master 2>/dev/null || true
fi
# Reset any conflicted state
git reset --merge 2>/dev/null || true

git status --short
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "auto-sync $(date '+%Y-%m-%d %H:%M')"
  # Fetch and rebase with auto-resolution (theirs = remote takes precedence on conflict)
  git fetch origin master 2>&1
  if git rebase FETCH_HEAD -X theirs 2>&1; then
    # Rebase succeeded (with auto-resolved conflicts if any)
    :
  else
    echo "rebase failed, trying merge instead..."
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
  # Even if nothing changed locally, pull remote changes to stay in sync
  echo "Nothing to commit - checking for remote updates..."
  git fetch origin master 2>&1
  if git rebase FETCH_HEAD -X theirs 2>&1; then
    git push origin master 2>&1 || true
  else
    git rebase --abort 2>/dev/null || true
  fi
fi
echo "=== auto-sync complete ==="
