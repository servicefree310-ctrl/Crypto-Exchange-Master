#!/usr/bin/env bash
set -euo pipefail

echo "=== [1/4] Installing dependencies ==="
pnpm install --frozen-lockfile

echo "=== [2/4] Building API server ==="
(cd artifacts/api-server && node ./build.mjs)

echo "=== [3/4] Building User Portal ==="
(cd artifacts/user-portal && BASE_PATH=/user/ PORT=5000 pnpm run build)

echo "=== [4/4] Building Admin Panel ==="
(cd artifacts/admin && BASE_PATH=/admin/ PORT=3000 pnpm run build)

echo "=== Build complete ==="
