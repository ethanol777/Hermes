#!/bin/bash
# Auto-sync all Hermes config to ~/Hermes/ and push to GitHub

set -e

HERMES_REPO="$HOME/Hermes"

# Sync ~/.hermes/ safe files → hermes/
cd "$HOME/.hermes"
git ls-files | grep -v 'node/' | while IFS= read -r f; do
  mkdir -p "$HERMES_REPO/hermes/$(dirname "$f")"
  cp "$f" "$HERMES_REPO/hermes/$f"
done

# Skills (submodule in ~/.hermes/skills/)
cd "$HOME/.hermes/skills"
git ls-files | while IFS= read -r f; do
  mkdir -p "$HERMES_REPO/hermes/skills/$(dirname "$f")"
  cp "$f" "$HERMES_REPO/hermes/skills/$f"
done

# Copy extra safe files from ~/.hermes/
cp "$HOME/.hermes/SOUL.md" "$HERMES_REPO/hermes/" 2>/dev/null || true

# Copy scripts 
cp -r "$HOME/.hermes/scripts"/* "$HERMES_REPO/hermes/scripts/" 2>/dev/null || true

# Sync learnings
cp "$HOME"/.learnings/*.md "$HERMES_REPO/learnings/" 2>/dev/null || true

# Sync agentic-stack
cd "$HOME/agentic-stack"
git ls-files | while IFS= read -r f; do
  mkdir -p "$HERMES_REPO/agentic-stack/$(dirname "$f")"
  cp "$f" "$HERMES_REPO/agentic-stack/$f"
done

# Commit and push Hermes repo
cd "$HERMES_REPO"
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "auto-sync $(date '+%Y-%m-%d %H:%M')"
  git push 2>&1 || echo "push failed"
fi

echo "auto-sync complete"
