#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
PORT="${PORT:-8082}"
BASE="${BASE_PATH:-/flutter/}"
exec flutter run -d web-server \
  --web-port="$PORT" \
  --web-hostname=0.0.0.0
