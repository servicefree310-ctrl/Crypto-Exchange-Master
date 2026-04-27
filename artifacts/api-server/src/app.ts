import express, { type Express, type Request, type Response, type NextFunction } from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import pinoHttp from "pino-http";
import router from "./routes";
import webhooksRouter from "./routes/webhooks";
import { logger } from "./lib/logger";

const app: Express = express();

// ─── Trust proxy ─────────────────────────────────────────────────────────
// Replit puts a single proxy in front of every artifact. Without this
// `trust proxy` setting, express-rate-limit would key every visitor by the
// proxy's IP (locking down the whole app on the first burst) and the
// `x-forwarded-for` chain we log on login would be unverified.
app.set("trust proxy", 1);

// ─── CORS allow-list ─────────────────────────────────────────────────────
// In dev we trust the REPLIT_DEV_DOMAIN. In production CORS_ORIGINS
// (comma-separated) is REQUIRED — we refuse to boot without it so a
// misconfigured deploy can't accidentally fall back to "allow anyone".
function getAllowedOrigins(): string[] {
  const explicit = (process.env["CORS_ORIGINS"] || "")
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
  if (explicit.length > 0) return explicit;
  if (process.env["NODE_ENV"] === "production") {
    throw new Error(
      "CORS_ORIGINS env required in production (comma-separated list of allowed origins)",
    );
  }
  const dev = process.env["REPLIT_DEV_DOMAIN"];
  const out: string[] = [];
  if (dev) out.push(`https://${dev}`);
  // Local dev fallbacks
  out.push("http://localhost:3000", "http://localhost:5000", "http://localhost:5173");
  return out;
}
const allowedOrigins = new Set(getAllowedOrigins());
logger.info({ allowedOrigins: [...allowedOrigins] }, "CORS allow-list configured");

const corsMiddleware = cors({
  origin: (origin, cb) => {
    // Allow requests with no Origin header — covers mobile native HTTP
    // clients (Expo), curl, server-to-server, and same-origin requests
    // from older Safari versions. They are still subject to the CSRF
    // origin guard below for any cookie-bearing write.
    if (!origin) return cb(null, true);
    if (allowedOrigins.has(origin)) return cb(null, true);
    return cb(new Error(`CORS: origin not allowed: ${origin}`));
  },
  credentials: true,
  methods: ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization", "X-CSRF-Token", "X-Requested-With"],
});

// ─── CSRF / Origin guard ─────────────────────────────────────────────────
// Defense-in-depth on top of SameSite=strict cookies. Any cookie-authed
// state-changing write (POST/PUT/PATCH/DELETE) must originate from an
// allow-listed Origin (or Referer, as a fallback). Bearer-token requests
// are CSRF-immune because the Authorization header cannot be set by an
// HTML form / cross-site script — so they bypass this check. Webhooks are
// already mounted before this middleware and HMAC-validated separately.
function originGuard(req: Request, res: Response, next: NextFunction): void {
  const method = req.method.toUpperCase();
  if (method === "GET" || method === "HEAD" || method === "OPTIONS") {
    next();
    return;
  }
  const auth = req.headers.authorization || "";
  // Bearer-only requests are CSRF-immune (Authorization header can't be set
  // by an HTML form / cross-site script). BUT if a session cookie is also
  // present, an attacker could auto-attach the victim's cookie via CSRF and
  // tack on a junk Bearer to bypass this check; the route's auth middleware
  // would then fall back to the cookie. So we only skip when the request is
  // PURELY token-authenticated.
  const cookies = (req as unknown as { cookies?: Record<string, string> }).cookies || {};
  const hasSessionCookie =
    !!cookies["cx_session"] || !!cookies["accessToken"] || !!cookies["sessionId"];
  if (auth.toLowerCase().startsWith("bearer ") && !hasSessionCookie) {
    next();
    return;
  }
  const origin = req.headers.origin;
  if (origin) {
    if (allowedOrigins.has(origin)) {
      next();
      return;
    }
    res.status(403).json({ error: "Origin not allowed" });
    return;
  }
  const referer = req.headers.referer || "";
  if (referer) {
    try {
      const refOrigin = new URL(referer).origin;
      if (allowedOrigins.has(refOrigin)) {
        next();
        return;
      }
    } catch {
      /* malformed referer falls through */
    }
    res.status(403).json({ error: "Referer not allowed" });
    return;
  }
  res
    .status(403)
    .json({ error: "Missing Origin/Referer header for cookie-authenticated request" });
}

// ─── Rate limiters ───────────────────────────────────────────────────────
// IP-keyed (trust proxy:1 above unwraps the real client IP). The global
// limiter is generous because the app polls tickers/orderbook frequently;
// hot endpoints (auth, OTP) get much tighter caps mounted before it.
const globalLimiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 600, // 10/sec sustained
  standardHeaders: "draft-7",
  legacyHeaders: false,
  message: { error: "Too many requests, please slow down" },
  // Skip true-public / high-volume endpoints from the cap
  skip: (req) => {
    const p = req.path;
    return (
      p === "/health" ||
      p === "/healthz" ||
      p.startsWith("/ws/") ||
      p === "/exchange/ticker" ||
      p === "/exchange/ws" ||
      p === "/exchange/market" ||
      p.startsWith("/webhooks/")
    );
  },
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 10, // 10 auth attempts per IP per 15 min
  standardHeaders: "draft-7",
  legacyHeaders: false,
  message: { error: "Too many auth attempts, try again in 15 minutes" },
});

const otpSendLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  limit: 5, // 5 OTP sends per IP per hour (stops free SMS flooding)
  standardHeaders: "draft-7",
  legacyHeaders: false,
  message: { error: "Too many OTP requests, try again in 1 hour" },
});

// ─── Middleware stack ────────────────────────────────────────────────────
app.use(
  pinoHttp({
    logger,
    serializers: {
      req(req) {
        return { id: req.id, method: req.method, url: req.url?.split("?")[0] };
      },
      res(res) {
        return { statusCode: res.statusCode };
      },
    },
  }),
);

// helmet defaults plus a few app-specific overrides:
//  - CSP off: would break Vite HMR + Flutter inline assets without a
//    carefully tuned policy. Re-enable in a follow-up with explicit
//    script-src / connect-src lists.
//  - COEP off: we need cross-origin iframes (canvas, mockup sandbox).
//  - CORP cross-origin: artifacts on different paths still need to fetch
//    each other's static assets through the Replit proxy.
app.use(
  helmet({
    contentSecurityPolicy: false,
    crossOriginEmbedderPolicy: false,
    crossOriginResourcePolicy: { policy: "cross-origin" },
  }),
);

app.use(corsMiddleware);
app.use(cookieParser());

// Webhooks BEFORE express.json — they need raw body for HMAC verification.
// Also mounted BEFORE the origin guard / rate limiter so legitimate
// gateway callbacks aren't throttled or blocked.
app.use("/api", webhooksRouter);

app.use(express.json({ limit: "2mb" }));
app.use(express.urlencoded({ extended: true }));

// CSRF/origin guard on every /api write.
app.use("/api", originGuard);

// Tighter caps on hot auth surfaces. Paths cover both the legacy cookie
// auth (auth.ts) and the Bicrypto JWT adapter (bicrypto.ts).
app.use(
  [
    "/api/auth/login",
    "/api/auth/register",
    "/api/auth/change-password",
    "/api/auth/forgot-password-request",
    "/api/auth/forgot-password-confirm",
    "/api/auth/login/flutter",
    "/api/auth/refresh",
  ],
  authLimiter,
);
app.use("/api/otp/send", otpSendLimiter);

// Global cap last — runs only if a request slipped past the specific limiters.
app.use("/api", globalLimiter);

app.use("/api", router);

// Global error handler — last in the chain. Logs everything, never
// leaks stack traces back to clients.
app.use((err: Error, req: Request, res: Response, _next: NextFunction): void => {
  if (err?.message?.startsWith("CORS:")) {
    res.status(403).json({ error: err.message });
    return;
  }
  logger.error(
    { err: err?.message, stack: err?.stack, path: req.path, method: req.method },
    "Unhandled error",
  );
  if (res.headersSent) return;
  res.status(500).json({ error: "Internal server error" });
});

export default app;
