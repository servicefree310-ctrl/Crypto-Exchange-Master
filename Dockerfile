# ── CryptoX Production Dockerfile ─────────────────────────────────────────
# Multi-stage build: Go engine + Node API + static frontends
# Usage: docker build -t cryptox:latest .
#         docker run -p 8080:8080 --env-file .env.production cryptox:latest

# ────────────────────────────────────────────────────────────────────────────
# Stage 1: Build Go service
# ────────────────────────────────────────────────────────────────────────────
FROM golang:1.22-alpine AS go-builder
WORKDIR /src/go-service
COPY artifacts/go-service/go.mod artifacts/go-service/go.sum ./
RUN go mod download
COPY artifacts/go-service/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /bin/cryptox-go .

# ────────────────────────────────────────────────────────────────────────────
# Stage 2: Build Node API server
# ────────────────────────────────────────────────────────────────────────────
FROM node:24-alpine AS node-builder
WORKDIR /workspace
RUN npm install -g pnpm@10

# Copy workspace manifests
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY lib/db/package.json lib/db/
COPY artifacts/api-server/package.json artifacts/api-server/
RUN pnpm install --frozen-lockfile

# Copy source
COPY lib/db/ lib/db/
COPY artifacts/api-server/ artifacts/api-server/

# Build DB package
RUN pnpm --filter @workspace/db build 2>/dev/null || true

# Build API server
WORKDIR /workspace/artifacts/api-server
RUN node build.mjs

# ────────────────────────────────────────────────────────────────────────────
# Stage 3: Build admin panel
# ────────────────────────────────────────────────────────────────────────────
FROM node:24-alpine AS admin-builder
WORKDIR /workspace
RUN npm install -g pnpm@10
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY artifacts/admin/package.json artifacts/admin/
RUN pnpm install --frozen-lockfile
COPY artifacts/admin/ artifacts/admin/
WORKDIR /workspace/artifacts/admin
RUN pnpm run build

# ────────────────────────────────────────────────────────────────────────────
# Stage 4: Build user portal
# ────────────────────────────────────────────────────────────────────────────
FROM node:24-alpine AS portal-builder
WORKDIR /workspace
RUN npm install -g pnpm@10
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY artifacts/user-portal/package.json artifacts/user-portal/
RUN pnpm install --frozen-lockfile
COPY artifacts/user-portal/ artifacts/user-portal/
WORKDIR /workspace/artifacts/user-portal
RUN pnpm run build

# ────────────────────────────────────────────────────────────────────────────
# Stage 5: Production image
# ────────────────────────────────────────────────────────────────────────────
FROM node:24-alpine AS production
WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache nginx curl tzdata && \
    mkdir -p /var/log/nginx /var/cache/nginx /run/nginx logs

# Go binary
COPY --from=go-builder /bin/cryptox-go /usr/local/bin/cryptox-go

# Node API server (built bundle + production node_modules)
COPY --from=node-builder /workspace/artifacts/api-server/dist/ ./api-server/dist/
COPY --from=node-builder /workspace/node_modules/ ./node_modules/

# Static frontends
COPY --from=admin-builder /workspace/artifacts/admin/dist/ /usr/share/nginx/html/admin/
COPY --from=portal-builder /workspace/artifacts/user-portal/dist/ /usr/share/nginx/html/user/

# Nginx config
COPY docker/nginx.conf /etc/nginx/nginx.conf

# PM2 for process management
RUN npm install -g pm2

COPY ecosystem.config.cjs ./

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/api/healthz || exit 1

EXPOSE 80 8080 8090

ENV NODE_ENV=production

CMD ["sh", "-c", "nginx && cryptox-go & pm2-runtime ecosystem.config.cjs --env production"]
