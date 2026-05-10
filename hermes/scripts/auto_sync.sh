#!/bin/bash
# Auto-sync: 运行时文件 → ~/Hermes/ → push GitHub
set -e

HERMES="$HOME/Hermes"

# Sync ~/.hermes/ (排除不需要的)
rsync -a --delete \
  --exclude='.git' \
  --exclude='.env' \
  --exclude='auth.json' --exclude='auth.lock' \
  --exclude='channel_directory.json' \
  --exclude='feishu_seen_message_ids.json' \
  --exclude='state.db*' \
  --exclude='models_dev_cache.json' \
  --exclude='ollama_cloud_models_cache.json' \
  --exclude='.skills_prompt_snapshot.json' \
  --exclude='gateway.*' \
  --exclude='processes.json' \
  --exclude='node/' \
  --exclude='cache/' --exclude='checkpoints/' \
  --exclude='logs/' --exclude='memories/' \
  --exclude='audio_cache/' \
  --exclude='image_cache/' --exclude='images/' \
  --exclude='bin/' --exclude='hooks/' \
  --exclude='sessions/' --exclude='sandboxes/' \
  --exclude='pastes/' --exclude='pairing/' \
  --exclude='weixin/' --exclude='workspace/' \
  --exclude='.hermes_history' --exclude='webui/' \
  --exclude='cloudflared' \
  --exclude='hermes-agent/' \
  "$HOME/.hermes/" "$HERMES/hermes/"

# Sync skills
rsync -a --delete --exclude='.git' \
  "$HOME/.hermes/skills/" "$HERMES/hermes/skills/"

# Sync learnings
rsync -a --delete --exclude='.git' \
  "$HOME/.learnings/" "$HERMES/learnings/"

# Sync agentic-stack
rsync -a --delete --exclude='.git' \
  "$HOME/agentic-stack/" "$HERMES/agentic-stack/"

# Sync data (vectordb + viking)
rsync -a --delete --exclude='.git' \
  "$HOME/data/" "$HERMES/data/"

# Commit & push
cd "$HERMES"
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "auto-sync $(date '+%Y-%m-%d %H:%M')"
  git push 2>&1 || echo "push failed"
fi

echo "auto-sync complete"
