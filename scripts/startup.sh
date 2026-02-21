#!/usr/bin/env bash
set -e

SKILL_DIR="${OPENCLAW_WORKSPACE_DIR:-/data/workspace}/skills/polymarket-arb-bot"
BUILD_DIR="/opt/polymarket-arb-bot"

echo "[startup] Syncing polymarket-arb-bot skill..."

if [ -d "$SKILL_DIR/.git" ]; then
  cd "$SKILL_DIR"
  if git fetch origin main --depth 1 2>&1; then
    git reset --hard origin/main 2>&1
    echo "[startup] Pulled latest into $SKILL_DIR"
  else
    echo "[startup] Git fetch failed (network may not be ready) — using existing copy"
  fi
elif [ -d "$BUILD_DIR" ]; then
  mkdir -p "$(dirname "$SKILL_DIR")"
  if cp -r "$BUILD_DIR" "$SKILL_DIR"; then
    echo "[startup] Copied build-time skill to $SKILL_DIR"
  else
    echo "[startup] ERROR: Failed to copy skill from $BUILD_DIR"
  fi
else
  echo "[startup] WARNING: No skill source found at $BUILD_DIR or $SKILL_DIR"
fi

# Install/update Python dependencies
if [ -f "$SKILL_DIR/requirements.txt" ]; then
  if pip3 install --no-cache-dir -q -r "$SKILL_DIR/requirements.txt" 2>&1; then
    echo "[startup] Python dependencies up to date"
  else
    echo "[startup] WARNING: pip install failed — some features may not work"
  fi
fi

# Set PYTHONPATH to the actual runtime skill location (not the build-time /opt copy)
export PYTHONPATH="$SKILL_DIR:${PYTHONPATH:-}"

echo "[startup] Skill sync complete — starting server"
exec node src/server.js
