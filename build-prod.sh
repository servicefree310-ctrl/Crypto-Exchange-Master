#!/usr/bin/env bash
set -euo pipefail

echo "=== [1/5] Installing Node dependencies ==="
pnpm install --frozen-lockfile

echo "=== [2/5] Building API server ==="
(cd artifacts/api-server && node ./build.mjs)

echo "=== [3/5] Building User Portal ==="
(cd artifacts/user-portal && BASE_PATH=/user/ PORT=5000 pnpm run build)

echo "=== [4/5] Building Admin Panel ==="
(cd artifacts/admin && BASE_PATH=/admin/ PORT=3000 pnpm run build)

echo "=== [5/5] Building Flutter Web ==="
(cd artifacts/crypto-exchange-flutter && BASE_PATH=/flutter/ bash scripts/build.sh)

echo "=== Build complete ==="
