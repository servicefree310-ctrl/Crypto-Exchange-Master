#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
PORT="${PORT:-8082}"
BASE="${BASE_PATH:-/flutter/}"

NEED_BUILD=1
if [ -f "build/web/index.html" ] && [ -f "build/web/main.dart.js" ]; then
  if [ -z "$(find lib -newer build/web/index.html -print -quit 2>/dev/null)" ]; then
    NEED_BUILD=0
  fi
fi

if [ "$NEED_BUILD" = "1" ]; then
  echo "[dev.sh] Building Flutter web release (base=$BASE)..."
  flutter build web --release --base-href "$BASE" --no-tree-shake-icons
fi

echo "[dev.sh] Starting Node static server on 0.0.0.0:$PORT under $BASE"
exec node scripts/serve.cjs
