// Pure data types for the in-memory matching engine. Kept dependency-free
// so the engine can run inside a worker thread, the main process, a CLI
// benchmark, or a test harness without dragging in Express / Drizzle.

export type Side = "buy" | "sell";
export type OrderType = "limit"; // market orders are NOT placed in the book

/** Public, immutable view of an order. The engine internally wraps this in
 *  a doubly-linked list node — see `pricelevel.ts`. */
export interface Order {
  /** Engine-local 64-bit-safe sequential id. Distinct from the SQL row id
   *  used by the production engine so the two systems can coexist. */
  id: number;
  symbol: string;
  side: Side;
  type: OrderType;
  /** Limit price in QUOTE currency, full precision (no scaling). */
  price: number;
  /** Original order quantity in BASE currency. */
  quantity: number;
  /** Quantity still resting in the book. Engine mutates this in place. */
  remaining: number;
  /** Wall-clock at acceptance. Used only for analytics — FIFO order is
   *  enforced by linked-list insertion order, NOT by comparing timestamps,
   *  so two orders accepted in the same millisecond still match correctly. */
  timestamp: number;
  /** Optional opaque handle the caller can attach (e.g. SQL order id) so
   *  trade events can be reconciled back to the persistence layer. */
  ref?: string;
}

export interface Trade {
  /** Engine-local sequential trade id. */
  id: number;
  symbol: string;
  /** Price the trade executed at — always the MAKER's price (price-time
   *  priority means the resting order sets the price). */
  price: number;
  quantity: number;
  /** Side of the AGGRESSOR (taker). The maker is always the opposite side. */
  takerSide: Side;
  makerOrderId: number;
  takerOrderId: number;
  /** Optional refs mirrored from the orders, for downstream reconciliation. */
  makerRef?: string;
  takerRef?: string;
  timestamp: number;
}

/** Engine commands — go through the single-threaded event queue. */
export type Command =
  | { kind: "place"; order: Order }
  | { kind: "cancel"; symbol: string; orderId: number };

/** WAL entries — every accepted command and every emitted trade is logged
 *  in receive order so the book can be deterministically reconstructed. */
export type WalEntry =
  | { seq: number; t: number; type: "place"; order: Order }
  | { seq: number; t: number; type: "cancel"; symbol: string; orderId: number }
  | { seq: number; t: number; type: "trade"; trade: Trade };

export interface DepthLevel {
  price: number;
  quantity: number;
  /** Number of resting orders aggregated at this price. */
  orders: number;
}

export interface Depth {
  symbol: string;
  bids: DepthLevel[]; // sorted descending
  asks: DepthLevel[]; // sorted ascending
  /** Sequence number of the last applied command — clients can use this for
   *  delta-stream resumption (not yet wired up). */
  seq: number;
}
