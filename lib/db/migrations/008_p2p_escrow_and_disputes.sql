-- P2P Trading: dedicated escrow column + dispute table.
-- All idempotent so it's safe to re-apply.

-- ─── Per-wallet P2P escrow pocket ────────────────────────────────────────
-- Kept separate from `wallets.locked` (which is shared with futures
-- margin and withdrawal holds) so the P2P engine can lock/refund without
-- touching unrelated reservations.
ALTER TABLE wallets
  ADD COLUMN IF NOT EXISTS p2p_locked NUMERIC(28, 8) NOT NULL DEFAULT 0;

-- ─── Dedicated dispute table (1-to-1 with p2p_orders) ───────────────────
-- The legacy embedded dispute_* columns on p2p_orders remain for back-
-- compat during the transition window; new dispute opens write here too
-- so the admin moderation queue, audit log, and SLA dashboards have a
-- first-class table to query.
CREATE TABLE IF NOT EXISTS p2p_disputes (
  id              SERIAL PRIMARY KEY,
  order_id        INTEGER NOT NULL UNIQUE,
  opened_by       INTEGER NOT NULL,
  buyer_id        INTEGER NOT NULL,
  seller_id       INTEGER NOT NULL,
  reason          TEXT NOT NULL,
  evidence_url    TEXT,
  status          TEXT NOT NULL DEFAULT 'open',
  resolution      TEXT,
  resolved_by     INTEGER,
  resolved_at     TIMESTAMPTZ,
  notes           TEXT,
  opened_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS p2p_dispute_status_idx ON p2p_disputes (status, opened_at);
CREATE INDEX IF NOT EXISTS p2p_dispute_buyer_idx  ON p2p_disputes (buyer_id);
CREATE INDEX IF NOT EXISTS p2p_dispute_seller_idx ON p2p_disputes (seller_id);

-- ─── Backfill p2p_locked from in-flight P2P orders ──────────────────────
-- Sum the qty of every still-open order per (seller_id, coin_id) and
-- carve that out of the seller's existing `wallets.locked` into the new
-- p2p_locked pocket. This preserves ledger invariants for any orders
-- that were opened against the previous shared-locked code path.
WITH inflight AS (
  SELECT seller_id, coin_id, SUM(qty)::NUMERIC(28, 8) AS qty
  FROM p2p_orders
  WHERE status IN ('pending', 'paid', 'disputed')
  GROUP BY seller_id, coin_id
)
UPDATE wallets w
SET p2p_locked = w.p2p_locked + inflight.qty,
    locked     = GREATEST(w.locked - inflight.qty, 0::NUMERIC(28, 8)),
    updated_at = NOW()
FROM inflight
WHERE w.user_id = inflight.seller_id
  AND w.coin_id = inflight.coin_id
  AND w.wallet_type = 'spot'
  AND w.p2p_locked = 0;  -- only first-time backfill; safe to re-run.

-- ─── Backfill p2p_disputes from any existing disputed orders ────────────
INSERT INTO p2p_disputes (
  order_id, opened_by, buyer_id, seller_id, reason, status,
  resolution, resolved_by, resolved_at, notes, opened_at, updated_at
)
SELECT
  o.id, COALESCE(o.dispute_opened_by, o.buyer_id),
  o.buyer_id, o.seller_id,
  COALESCE(o.dispute_reason, 'legacy dispute'),
  CASE WHEN o.dispute_resolution IS NOT NULL THEN 'resolved'
       WHEN o.status = 'disputed' THEN 'open'
       ELSE 'resolved' END,
  o.dispute_resolution,
  o.dispute_resolved_by,
  o.dispute_resolved_at,
  o.dispute_notes,
  COALESCE(o.dispute_opened_at, o.created_at),
  o.updated_at
FROM p2p_orders o
WHERE (o.dispute_opened_at IS NOT NULL OR o.status = 'disputed')
ON CONFLICT (order_id) DO NOTHING;
