#!/usr/bin/env bash
set -e

SKILL_DIR="${OPENCLAW_WORKSPACE_DIR:-/data/workspace}/skills/polymarket-arb-bot"
BUILD_DIR="/opt/polymarket-arb-bot"

echo "[startup] Syncing polymarket-arb-bot skill..."

if [ -d "$SKILL_DIR/.git" ]; then
  # Runtime copy exists — pull latest
  cd "$SKILL_DIR"
  git fetch origin main --depth 1 2>/dev/null && git reset --hard origin/main 2>/dev/null || true
  echo "[startup] Pulled latest into $SKILL_DIR"
elif [ -d "$BUILD_DIR" ]; then
  # First boot or volume was wiped — copy from build-time clone
  mkdir -p "$(dirname "$SKILL_DIR")"
  cp -r "$BUILD_DIR" "$SKILL_DIR"
  echo "[startup] Copied build-time skill to $SKILL_DIR"
fi

# Install/update Python dependencies (fast no-op if already current)
if [ -f "$SKILL_DIR/requirements.txt" ]; then
  pip3 install --no-cache-dir -q -r "$SKILL_DIR/requirements.txt" 2>/dev/null || true
  echo "[startup] Python dependencies up to date"
fi

echo "[startup] Skill sync complete — starting server"
exec node src/server.js
