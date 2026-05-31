#!/bin/bash
# auto_sync_v2.sh — 莫妮卡核心文件同步脚本
# v2: 跳过 .curator_backups, .hub, __pycache__ 避免超时

set -euo pipefail
shopt -s nullglob

HERMES_SRC="${HERMES_HOME:-C:\Users\77\AppData\Local\hermes}"
HERMES_REPO="$HOME/Hermes"
DEST="$HERMES_REPO/hermes"

# MSYS 路径转换
if [[ "$HERMES_SRC" == C:\* ]]; then
    HERMES_SRC="/c/Users/77/AppData/Local/hermes"
fi

echo "=== 莫妮卡同步 v2 ==="
echo "源: $HERMES_SRC"
echo "目标: $DEST"
echo ""

echo "[1/5] 同步 SOUL.md ..."
cp -u "$HERMES_SRC/SOUL.md" "$DEST/SOUL.md" 2>/dev/null || echo "  ⚠️ SOUL.md 不存在，跳过"

echo "[2/5] 同步 config.yaml ..."
cp -u "$HERMES_SRC/config.yaml" "$DEST/config.yaml" 2>/dev/null || echo "  ⚠️ config.yaml 不存在，跳过"

echo "[3/5] 同步 memories/ ..."
mkdir -p "$DEST/memories"
cp -u "$HERMES_SRC/memories/"*.md "$DEST/memories/" 2>/dev/null || echo "  memories/ 无 .md 文件"
for subdir in "$HERMES_SRC/memories/"*/; do
    [ -d "$subdir" ] || continue
    subname=$(basename "$subdir")
    mkdir -p "$DEST/memories/$subname"
    cp -u "$subdir"*.md "$DEST/memories/$subname/" 2>/dev/null || true
done

echo "[4/5] 同步 skills/ (跳过备份/缓存) ..."
mkdir -p "$DEST/skills"
for d in "$HERMES_SRC/skills/"*/; do
    [ -d "$d" ] || continue
    subname=$(basename "$d")
    # 跳过不需要同步的目录
    [[ "$subname" == ".curator_backups" ]] && continue
    [[ "$subname" == ".hub" ]] && continue
    [[ "$subname" == "__pycache__" ]] && continue
    [[ "$subname" == ".usage"* ]] && continue
    mkdir -p "$DEST/skills/$subname"
    cp -ru "$d"* "$DEST/skills/$subname/" 2>/dev/null || true
done

echo "[5/5] 同步 cron/ ..."
mkdir -p "$DEST/cron"
cp -u "$HERMES_SRC/cron/"*.yaml "$DEST/cron/" 2>/dev/null || true
cp -u "$HERMES_SRC/cron/"*.sh "$DEST/cron/" 2>/dev/null || true
cp -u "$HERMES_SRC/cron/"*.json "$DEST/cron/" 2>/dev/null || true

echo ""
echo "同步完成，检查 Git 状态..."

cd "$HERMES_REPO"

if git diff --quiet && git diff --cached --quiet && [[ -z "$(git status --porcelain)" ]]; then
    echo "没有变更，无需提交。"
    exit 0
fi

echo ""
echo "变更:"
git status --short

git add -A
git commit -m "auto sync $(date '+%Y-%m-%d %H:%M')"

echo ""
echo "推送到 GitHub ..."
git push origin master 2>&1 || {
    echo "⚠️  推送失败（本地已提交）"
    echo "   commit: $(git rev-parse HEAD)"
    exit 1
}

echo ""
echo "✅ 同步完成，已推送。"
