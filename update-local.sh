#!/bin/sh
# Update this linked herdr-mirror fork from upstream, keeping local patches.
# Rebases the local-patches branch onto upstream, rebuilds, restarts the mirror.
# On a rebase conflict it stops for you to resolve (git status / rebase --continue),
# then re-run this script.
set -e
cd "$(dirname "$0")"

git fetch origin
BASE=$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null || echo origin/main)
echo "rebasing local-patches onto $BASE ($(git rev-parse --short "$BASE"))"
git rebase "$BASE"

cargo build --release

BIN=target/release/herdr-mirror
"$BIN" pause || true
sleep 1
"$BIN" start
echo "updated: $(git log --oneline -1) — mirror restarted"
