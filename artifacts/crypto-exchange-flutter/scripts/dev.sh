#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
# Pin these values unconditionally so global env vars (e.g. PORT=8081 from
# Replit's userenv.shared) cannot override the Flutter static server config.
export PORT=8082
export BASE_PATH="/flutter/"
BASE="/flutter/"

NEED_BUILD=1
if [ -f "build/web/index.html" ] && [ -f "build/web/main.dart.js" ]; then
  STALE="$(find lib assets pubspec.yaml -newer build/web/index.html -print -quit 2>/dev/null)"
  if [ -z "$STALE" ]; then
    NEED_BUILD=0
  fi
fi

if [ "$NEED_BUILD" = "1" ]; then
  echo "[dev.sh] Installing Flutter dependencies..."
  flutter pub get
  echo "[dev.sh] Building Flutter web release (base=$BASE)..."
  flutter build web --release --base-href "$BASE" --no-tree-shake-icons
fi

# After build (or on every restart), overlay the latest runtime config so
# baseUrl edits in assets/config/app_config.json take effect immediately.
if [ -f "assets/config/app_config.json" ]; then
  mkdir -p build/web/assets/assets/config
  cp assets/config/app_config.json build/web/assets/assets/config/app_config.json
  echo "[dev.sh] Refreshed runtime app_config.json from source"
fi

# Disable the Flutter service worker. In the Replit preview iframe the SW
# aggressively caches the previous bundle and continues serving it even
# after a fresh rebuild — leading to stuck stale code (e.g. old baseUrl
# baked into main.dart.js). We patch flutter_bootstrap.js to skip SW
# registration AND inject an unregister snippet into index.html so any SW
# the user installed during prior visits is evicted on next load.
BOOTSTRAP="build/web/flutter_bootstrap.js"
if [ -f "$BOOTSTRAP" ] && ! grep -q "REPLIT_SW_DISABLED" "$BOOTSTRAP"; then
  node -e "
    const fs = require('fs');
    const p = 'build/web/flutter_bootstrap.js';
    let s = fs.readFileSync(p, 'utf8');
    s = s.replace(
      /_flutter\.loader\.load\(\s*\{[^}]*serviceWorkerSettings[\s\S]*?\}\s*\)\s*;?/,
      '/* REPLIT_SW_DISABLED */ _flutter.loader.load({});'
    );
    fs.writeFileSync(p, s);
  "
  echo "[dev.sh] Patched flutter_bootstrap.js to skip service worker registration"
fi

INDEX="build/web/index.html"
if [ -f "$INDEX" ] && ! grep -q "REPLIT_SW_UNREGISTER" "$INDEX"; then
  node -e "
    const fs = require('fs');
    const p = 'build/web/index.html';
    let s = fs.readFileSync(p, 'utf8');
    const snippet = \"<script>/* REPLIT_SW_UNREGISTER */if ('serviceWorker' in navigator) { navigator.serviceWorker.getRegistrations().then(rs => rs.forEach(r => r.unregister())); if (window.caches) caches.keys().then(ks => ks.forEach(k => caches.delete(k))); }</script>\\n  \";
    s = s.replace('<script src=\"flutter_bootstrap.js\"', snippet + '<script src=\"flutter_bootstrap.js\"');
    fs.writeFileSync(p, s);
  "
  echo "[dev.sh] Injected SW unregister snippet into index.html"
fi

echo "[dev.sh] Starting Node static server on 0.0.0.0:$PORT under $BASE"
exec node scripts/serve.cjs
