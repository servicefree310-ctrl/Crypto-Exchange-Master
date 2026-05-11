/**
 * PM2 Ecosystem Config — CryptoX Production
 * Usage: pm2 start ecosystem.config.cjs --env production
 */
module.exports = {
  apps: [
    // ── Node API Server ──────────────────────────────────────────────────────
    {
      name: "cryptox-api",
      cwd: "artifacts/api-server",
      script: "dist/index.mjs",
      interpreter: "node",
      interpreter_args: "--enable-source-maps",
      instances: process.env.API_INSTANCES || 2,
      exec_mode: "cluster",
      env: {
        NODE_ENV: "development",
        PORT: 8080,
        BASE_PATH: "/api/",
      },
      env_production: {
        NODE_ENV: "production",
        PORT: 8080,
        BASE_PATH: "/api/",
      },
      max_memory_restart: "1G",
      watch: false,
      autorestart: true,
      restart_delay: 2000,
      max_restarts: 10,
      exp_backoff_restart_delay: 100,
      error_file: "logs/api-error.log",
      out_file: "logs/api-out.log",
      log_date_format: "YYYY-MM-DD HH:mm:ss",
      // Graceful shutdown: allow in-flight requests to finish
      kill_timeout: 10000,
      listen_timeout: 10000,
    },

    // ── Go Futures Matching Engine ────────────────────────────────────────────
    {
      name: "cryptox-go",
      cwd: "artifacts/go-service",
      script: "bin/cryptox-go",
      interpreter: "none",
      env: {
        PORT: 8090,
        BASE_PATH: "/go-service/",
        BIND_ADDR: "127.0.0.1",
      },
      env_production: {
        PORT: 8090,
        BASE_PATH: "/go-service/",
        BIND_ADDR: "127.0.0.1",
      },
      watch: false,
      autorestart: true,
      max_restarts: 20,
      error_file: "logs/go-error.log",
      out_file: "logs/go-out.log",
      log_date_format: "YYYY-MM-DD HH:mm:ss",
    },

    // ── Admin Panel (served as static build by nginx in production) ───────────
    // In production: build once with `pnpm --filter @workspace/admin build`
    // then serve via nginx. This entry is only for dev reference.
    // {
    //   name: "cryptox-admin",
    //   cwd: "artifacts/admin",
    //   script: "pnpm",
    //   args: "run preview --port 23744",
    //   env_production: { PORT: 23744, BASE_URL: "/admin/" },
    // },

    // ── User Portal (served as static build by nginx in production) ───────────
    // {
    //   name: "cryptox-user-portal",
    //   cwd: "artifacts/user-portal",
    //   script: "pnpm",
    //   args: "run preview --port 5000",
    //   env_production: { PORT: 5000, BASE_URL: "/user/" },
    // },
  ],
};
