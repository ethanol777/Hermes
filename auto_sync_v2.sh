#!/bin/bash
# auto_sync_v2.sh — 莫妮卡核心文件同步脚本 (hardened)

set -euo pipefail
shopt -s nullglob  # 空 glob 不展开为字面字符串

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

echo "[1/4] 同步 SOUL.md ..."
cp "$HERMES_SRC/SOUL.md" "$DEST/SOUL.md" 2>/dev/null || echo "  ⚠️ SOUL.md 不存在，跳过"

echo "[2/4] 同步 config.yaml ..."
cp "$HERMES_SRC/config.yaml" "$DEST/config.yaml" 2>/dev/null || echo "  ⚠️ config.yaml 不存在，跳过"

echo "[3/4] 同步 memories/ ..."
mkdir -p "$DEST/memories"

# 清除目标中源不存在的文件
for f in "$DEST/memories"/*.md; do
    [ -f "$f" ] || continue
    base=$(basename "$f")
    if [ ! -f "$HERMES_SRC/memories/$base" ]; then
        rm -f "$f"
        echo "  清除过期: $base"
    fi
done

cp -u "$HERMES_SRC/memories/"*.md "$DEST/memories/" 2>/dev/null || echo "  memories/ 无 .md 文件"

# 子目录
for subdir in "$HERMES_SRC/memories/"*/; do
    [ -d "$subdir" ] || continue
    subname=$(basename "$subdir")
    mkdir -p "$DEST/memories/$subname"
    cp -u "$subdir"*.md "$DEST/memories/$subname/" 2>/dev/null || true
done

echo "[4/4] 同步 skills/ 和 cron/ ..."

# skills
mkdir -p "$DEST/skills"
for f in "$HERMES_SRC/skills/"*.yaml; do
    [ -f "$f" ] || continue
    cp "$f" "$DEST/skills/"
done

for d in "$HERMES_SRC/skills/"*/; do
    [ -d "$d" ] || continue
    subname=$(basename "$d")
    [ "$subname" = "__pycache__" ] && continue
    mkdir -p "$DEST/skills/$subname"
    cp -r "$d"* "$DEST/skills/$subname/" 2>/dev/null || true
done

# cron
mkdir -p "$DEST/cron"
cp "$HERMES_SRC/cron/"*.yaml "$DEST/cron/" 2>/dev/null || true
cp "$HERMES_SRC/cron/"*.sh "$DEST/cron/" 2>/dev/null || true
cp "$HERMES_SRC/cron/"*.json "$DEST/cron/" 2>/dev/null || true

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
