#!/bin/sh
# Update this linked herdr-mirror fork from upstream, keeping local patches.
# Rebases the current patch branch onto upstream, rebuilds, restarts the mirror.
# On a rebase conflict it stops for you to resolve (git status / rebase --continue),
# then re-run this script.
set -e
cd "$(dirname "$0")"

REMOTE=origin
if git remote get-url upstream >/dev/null 2>&1; then
  REMOTE=upstream
fi
git fetch "$REMOTE"
BASE=$(git rev-parse --abbrev-ref "$REMOTE/HEAD" 2>/dev/null || echo "$REMOTE/main")
BRANCH=$(git branch --show-current)
echo "rebasing $BRANCH onto $BASE ($(git rev-parse --short "$BASE"))"
git rebase "$BASE"

cargo build --release

BIN=target/release/herdr-mirror
"$BIN" pause || true
sleep 1
"$BIN" start
echo "updated: $(git log --oneline -1) — mirror restarted"
