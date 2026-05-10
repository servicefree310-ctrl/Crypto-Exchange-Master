#!/usr/bin/env bash
set -euo pipefail

echo "[prod] Starting Go service..."
cd artifacts/go-service
PORT=23004 BASE_PATH=/go-service/ BIND_ADDR=0.0.0.0 ./bin/cryptox-go &
GO_PID=$!
cd /home/runner/workspace

echo "[prod] Starting API server..."
cd artifacts/api-server
PORT=8080 BASE_PATH=/api/ NODE_ENV=production node --enable-source-maps ./dist/index.mjs &
API_PID=$!
cd /home/runner/workspace

echo "[prod] All services started (go=$GO_PID api=$API_PID)"

wait -n
echo "[prod] A process exited — shutting down"
kill $GO_PID $API_PID 2>/dev/null || true
