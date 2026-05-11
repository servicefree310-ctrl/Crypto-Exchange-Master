/**
 * Email sending service — reads active config from email_configs table.
 * Supports: SMTP (nodemailer), SendGrid, Mailgun, Postmark, AWS SES (SMTP relay).
 */
import nodemailer from "nodemailer";
import { db, emailConfigsTable } from "@workspace/db";
import { eq, and } from "drizzle-orm";
import { logger } from "./logger";

export type EmailPayload = {
  to: string;
  subject: string;
  html: string;
  text?: string;
};

type SendResult = { ok: true; provider: string; messageId?: string } | { ok: false; error: string; provider: string };

async function getActiveConfig() {
  const [cfg] = await db
    .select()
    .from(emailConfigsTable)
    .where(and(eq(emailConfigsTable.isActive, true)))
    .orderBy(emailConfigsTable.createdAt)
    .limit(1);
  return cfg ?? null;
}

async function sendViaSMTP(cfg: typeof emailConfigsTable.$inferSelect, payload: EmailPayload): Promise<SendResult> {
  if (!cfg.smtpHost || !cfg.username || !cfg.password) {
    return { ok: false, provider: "smtp", error: "SMTP host/username/password not configured" };
  }
  try {
    const transporter = nodemailer.createTransport({
      host: cfg.smtpHost,
      port: cfg.smtpPort ?? 587,
      secure: cfg.smtpSecure ?? false,
      auth: { user: cfg.username, pass: cfg.password },
      tls: { rejectUnauthorized: process.env.NODE_ENV === "production" },
      connectionTimeout: 8000,
      greetingTimeout: 5000,
    });
    const info = await transporter.sendMail({
      from: cfg.fromEmail ? `"${cfg.fromName || "CryptoX"}" <${cfg.fromEmail}>` : cfg.username,
      to: payload.to,
      subject: payload.subject,
      html: payload.html,
      text: payload.text ?? payload.html.replace(/<[^>]+>/g, ""),
    });
    logger.info({ messageId: info.messageId, to: payload.to }, "Email sent via SMTP");
    return { ok: true, provider: "smtp", messageId: info.messageId };
  } catch (e: any) {
    logger.error({ err: e.message, provider: "smtp" }, "SMTP send failed");
    return { ok: false, provider: "smtp", error: e.message };
  }
}

async function sendViaSendGrid(cfg: typeof emailConfigsTable.$inferSelect, payload: EmailPayload): Promise<SendResult> {
  if (!cfg.apiKey) return { ok: false, provider: "sendgrid", error: "API key not configured" };
  try {
    const r = await fetch("https://api.sendgrid.com/v3/mail/send", {
      method: "POST",
      headers: { "Authorization": `Bearer ${cfg.apiKey}`, "Content-Type": "application/json" },
      body: JSON.stringify({
        personalizations: [{ to: [{ email: payload.to }], subject: payload.subject }],
        from: { email: cfg.fromEmail || "no-reply@cryptox.in", name: cfg.fromName || "CryptoX" },
        content: [
          { type: "text/plain", value: payload.text ?? payload.html.replace(/<[^>]+>/g, "") },
          { type: "text/html", value: payload.html },
        ],
      }),
      signal: AbortSignal.timeout(10000),
    });
    if (!r.ok) {
      const errText = await r.text();
      return { ok: false, provider: "sendgrid", error: `SendGrid ${r.status}: ${errText.slice(0, 200)}` };
    }
    const msgId = r.headers.get("x-message-id") ?? undefined;
    logger.info({ to: payload.to, msgId }, "Email sent via SendGrid");
    return { ok: true, provider: "sendgrid", messageId: msgId };
  } catch (e: any) {
    return { ok: false, provider: "sendgrid", error: e.message };
  }
}

async function sendViaMailgun(cfg: typeof emailConfigsTable.$inferSelect, payload: EmailPayload): Promise<SendResult> {
  if (!cfg.apiKey || !cfg.domain) return { ok: false, provider: "mailgun", error: "API key and domain required" };
  try {
    const formData = new URLSearchParams({
      from: cfg.fromEmail ? `${cfg.fromName || "CryptoX"} <${cfg.fromEmail}>` : `CryptoX <no-reply@${cfg.domain}>`,
      to: payload.to,
      subject: payload.subject,
      html: payload.html,
      text: payload.text ?? payload.html.replace(/<[^>]+>/g, ""),
    });
    const baseUrl = cfg.region === "eu" ? "https://api.eu.mailgun.net" : "https://api.mailgun.net";
    const r = await fetch(`${baseUrl}/v3/${cfg.domain}/messages`, {
      method: "POST",
      headers: {
        "Authorization": "Basic " + Buffer.from(`api:${cfg.apiKey}`).toString("base64"),
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: formData.toString(),
      signal: AbortSignal.timeout(10000),
    });
    if (!r.ok) {
      const errText = await r.text();
      return { ok: false, provider: "mailgun", error: `Mailgun ${r.status}: ${errText.slice(0, 200)}` };
    }
    const json: any = await r.json();
    logger.info({ to: payload.to, id: json.id }, "Email sent via Mailgun");
    return { ok: true, provider: "mailgun", messageId: json.id };
  } catch (e: any) {
    return { ok: false, provider: "mailgun", error: e.message };
  }
}

async function sendViaPostmark(cfg: typeof emailConfigsTable.$inferSelect, payload: EmailPayload): Promise<SendResult> {
  if (!cfg.apiKey) return { ok: false, provider: "postmark", error: "Server token not configured" };
  try {
    const r = await fetch("https://api.postmarkapp.com/email", {
      method: "POST",
      headers: { "Accept": "application/json", "Content-Type": "application/json", "X-Postmark-Server-Token": cfg.apiKey },
      body: JSON.stringify({
        From: cfg.fromEmail ? `${cfg.fromName || "CryptoX"} <${cfg.fromEmail}>` : "no-reply@cryptox.in",
        To: payload.to,
        Subject: payload.subject,
        HtmlBody: payload.html,
        TextBody: payload.text ?? payload.html.replace(/<[^>]+>/g, ""),
      }),
      signal: AbortSignal.timeout(10000),
    });
    if (!r.ok) {
      const errText = await r.text();
      return { ok: false, provider: "postmark", error: `Postmark ${r.status}: ${errText.slice(0, 200)}` };
    }
    const json: any = await r.json();
    return { ok: true, provider: "postmark", messageId: json.MessageID };
  } catch (e: any) {
    return { ok: false, provider: "postmark", error: e.message };
  }
}

/** Main send function — reads config from DB and dispatches via correct provider. */
export async function sendEmail(payload: EmailPayload): Promise<SendResult> {
  const cfg = await getActiveConfig();
  if (!cfg) {
    logger.warn({ to: payload.to }, "No active email config — email not sent");
    return { ok: false, provider: "none", error: "No active email provider configured. Configure one in Admin → API Integrations → Email." };
  }
  switch (cfg.provider) {
    case "smtp":     return sendViaSMTP(cfg, payload);
    case "sendgrid": return sendViaSendGrid(cfg, payload);
    case "mailgun":  return sendViaMailgun(cfg, payload);
    case "postmark": return sendViaPostmark(cfg, payload);
    default:         return { ok: false, provider: cfg.provider, error: `Provider "${cfg.provider}" not implemented` };
  }
}

/** OTP-specific email template */
export async function sendOtpEmail(to: string, code: string, purpose: string): Promise<SendResult> {
  const purposeLabel: Record<string, string> = {
    signup: "Account Verification", login: "Login Verification", withdraw: "Withdrawal Verification",
    kyc: "KYC Verification", "2fa": "Two-Factor Authentication", reset: "Password Reset",
  };
  const label = purposeLabel[purpose] || "Verification";
  return sendEmail({
    to,
    subject: `Your CryptoX ${label} Code: ${code}`,
    html: `
      <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;background:#0d1117;color:#e6edf3;padding:32px;border-radius:12px;border:1px solid #30363d">
        <div style="text-align:center;margin-bottom:24px">
          <div style="font-size:28px;font-weight:700;color:#f0b429;letter-spacing:-0.5px">CryptoX</div>
          <div style="color:#7d8590;font-size:13px;margin-top:4px">India's Professional Crypto Exchange</div>
        </div>
        <h2 style="font-size:18px;font-weight:600;color:#e6edf3;margin:0 0 8px">${label}</h2>
        <p style="color:#7d8590;font-size:14px;margin:0 0 24px">Use the code below to verify your identity. It expires in <strong>10 minutes</strong>.</p>
        <div style="background:#161b22;border:1px solid #30363d;border-radius:8px;padding:20px;text-align:center;margin:0 0 24px">
          <div style="font-family:monospace;font-size:36px;font-weight:700;color:#f0b429;letter-spacing:12px">${code}</div>
        </div>
        <p style="color:#7d8590;font-size:12px;margin:0">If you didn't request this, please ignore this email. Never share this code with anyone.</p>
        <div style="border-top:1px solid #30363d;margin-top:24px;padding-top:16px;text-align:center;color:#484f58;font-size:11px">
          © ${new Date().getFullYear()} CryptoX · Secure Indian Crypto Exchange
        </div>
      </div>
    `,
    text: `Your CryptoX ${label} Code: ${code}\n\nThis code expires in 10 minutes. Never share it with anyone.`,
  });
}

/** Trade confirmation email */
export async function sendTradeConfirmEmail(to: string, opts: {
  symbol: string; side: string; qty: string; price: string; total: string; tds: string; fee: string;
}): Promise<SendResult> {
  const isSell = opts.side === "sell";
  return sendEmail({
    to,
    subject: `Trade ${isSell ? "Sold" : "Bought"} ${opts.qty} ${opts.symbol.split("/")[0]} on CryptoX`,
    html: `
      <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;background:#0d1117;color:#e6edf3;padding:32px;border-radius:12px;border:1px solid #30363d">
        <div style="text-align:center;margin-bottom:24px">
          <div style="font-size:24px;font-weight:700;color:#f0b429">CryptoX</div>
        </div>
        <h2 style="font-size:18px;font-weight:600;margin:0 0 16px">Trade Executed ✅</h2>
        <table style="width:100%;border-collapse:collapse;font-size:14px">
          <tr><td style="color:#7d8590;padding:6px 0">Pair</td><td style="text-align:right;font-weight:600">${opts.symbol}</td></tr>
          <tr><td style="color:#7d8590;padding:6px 0">Side</td><td style="text-align:right;color:${isSell?"#f85149":"#3fb950"};font-weight:700;text-transform:uppercase">${opts.side}</td></tr>
          <tr><td style="color:#7d8590;padding:6px 0">Quantity</td><td style="text-align:right;font-family:monospace">${opts.qty}</td></tr>
          <tr><td style="color:#7d8590;padding:6px 0">Price</td><td style="text-align:right;font-family:monospace">₹${opts.price}</td></tr>
          <tr><td style="color:#7d8590;padding:6px 0">Total</td><td style="text-align:right;font-family:monospace;font-weight:700">₹${opts.total}</td></tr>
          <tr><td style="color:#7d8590;padding:6px 0">Fee</td><td style="text-align:right;font-family:monospace">₹${opts.fee}</td></tr>
          ${isSell ? `<tr><td style="color:#7d8590;padding:6px 0">TDS (1%)</td><td style="text-align:right;font-family:monospace;color:#f0b429">₹${opts.tds}</td></tr>` : ""}
        </table>
        <p style="color:#484f58;font-size:11px;margin-top:24px;text-align:center">TDS is deducted as per Indian crypto regulations (Section 194S)</p>
      </div>
    `,
  });
}

/** Deposit credited email */
export async function sendDepositEmail(to: string, opts: { amount: string; currency: string; method: string }): Promise<SendResult> {
  return sendEmail({
    to,
    subject: `₹${opts.amount} Credited to Your CryptoX Wallet`,
    html: `
      <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;background:#0d1117;color:#e6edf3;padding:32px;border-radius:12px;border:1px solid #30363d">
        <div style="text-align:center;margin-bottom:24px"><div style="font-size:24px;font-weight:700;color:#f0b429">CryptoX</div></div>
        <h2 style="font-size:18px;font-weight:600;margin:0 0 16px">Deposit Credited ✅</h2>
        <div style="background:#161b22;border:1px solid #3fb950/40;border-radius:8px;padding:20px;text-align:center">
          <div style="font-size:32px;font-weight:700;color:#3fb950">+${opts.currency} ${opts.amount}</div>
          <div style="color:#7d8590;font-size:13px;margin-top:4px">via ${opts.method}</div>
        </div>
        <p style="color:#7d8590;font-size:14px;margin-top:20px">Your wallet has been credited. You can now start trading on CryptoX.</p>
      </div>
    `,
  });
}
