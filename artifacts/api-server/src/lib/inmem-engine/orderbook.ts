import { PriceLevel, type OrderNode } from "./pricelevel";
import type { Order, Side, Trade, Depth, DepthLevel } from "./types";

// Per-symbol order book.
//
// Data structures (see types.ts comments for the spec):
//
//   bids: Map<price, PriceLevel>   +  bidPrices: number[] sorted ascending
//   asks: Map<price, PriceLevel>   +  askPrices: number[] sorted ascending
//
// Why a sorted array instead of a balanced BST (BTreeMap)?
//   - JS has no built-in BTreeMap. A typical order book has O(100-1000)
//     active price levels; binary search + array splice is O(log n) lookup
//     and O(n) splice — for a 1k-level book that's ~1µs in V8.
//   - This is the same trade-off LMAX Disruptor and most JVM engines make
//     — they use sorted arrays + ring buffers, NOT trees.
//   - If you ever need to support 10k+ price levels per symbol (e.g. a
//     fragmented MM market), swap this for a skiplist or std::map FFI
//     binding without touching the matching loop — the public surface
//     `bestBid()`, `bestAsk()`, `addLevel()`, `dropLevel()` is the only
//     thing the matching loop knows about.
//
// We keep `bidPrices` ascending (NOT descending) and use the LAST element
// as the best bid. Reason: array.pop() is O(1) but array.shift() is O(n),
// so by storing bids ascending we get O(1) best-bid removal too.

export class OrderBook {
  readonly symbol: string;

  private readonly bids = new Map<number, PriceLevel>();
  private readonly asks = new Map<number, PriceLevel>();

  /** Sorted ascending. bestBid = bidPrices[bidPrices.length-1]. */
  private readonly bidPrices: number[] = [];
  /** Sorted ascending. bestAsk = askPrices[0]. */
  private readonly askPrices: number[] = [];

  /** order id → (level, node) so cancels are O(log n) lookup + O(1) unlink. */
  private readonly orderIndex = new Map<number, { level: PriceLevel; node: OrderNode; side: Side }>();

  constructor(symbol: string) {
    this.symbol = symbol;
  }

  /** Apply an aggressive (taker) limit order. Returns the trades it
   *  generated (possibly empty) and whether any quantity is left to rest
   *  in the book.
   *
   *  This is the HOT PATH — every line is benchmarked. Avoid:
   *    - object allocation in the inner loop except for trades
   *    - Map.delete inside the loop (use the dropLevel helper which the
   *      engine calls AFTER the loop drains a level)
   *    - try/catch inside the loop (deopts the function in V8)
   */
  match(taker: Order, nextTradeId: () => number): { trades: Trade[]; resting: boolean } {
    const trades: Trade[] = [];
    const isBuyer = taker.side === "buy";
    // Buyers eat the asks (lowest first); sellers eat the bids (highest first).
    const bookPrices = isBuyer ? this.askPrices : this.bidPrices;
    const bookLevels = isBuyer ? this.asks : this.bids;

    while (taker.remaining > 0 && bookPrices.length > 0) {
      // Best price = first ask (ascending) or last bid (ascending).
      const bestPrice = isBuyer ? bookPrices[0]! : bookPrices[bookPrices.length - 1]!;

      // Cross check — limit orders only match when the prices cross.
      if (isBuyer ? taker.price < bestPrice : taker.price > bestPrice) break;

      const level = bookLevels.get(bestPrice)!;
      // Drain the FIFO at this level. Each iteration peels one maker.
      while (taker.remaining > 0 && level.head) {
        const makerNode = level.head;
        const maker = makerNode.order;
        const fillQty = taker.remaining < maker.remaining ? taker.remaining : maker.remaining;

        trades.push({
          id: nextTradeId(),
          symbol: this.symbol,
          price: maker.price, // maker sets the price (price-time priority)
          quantity: fillQty,
          takerSide: taker.side,
          makerOrderId: maker.id,
          takerOrderId: taker.id,
          ...(maker.ref !== undefined ? { makerRef: maker.ref } : {}),
          ...(taker.ref !== undefined ? { takerRef: taker.ref } : {}),
          timestamp: Date.now(),
        });

        taker.remaining -= fillQty;
        maker.remaining -= fillQty;
        level.decreaseTotal(fillQty);

        if (maker.remaining === 0) {
          level.unlink(makerNode);
          this.orderIndex.delete(maker.id);
        }
      }

      if (level.isEmpty()) this.dropLevel(bestPrice, isBuyer ? "ask" : "bid");
    }

    let resting = false;
    if (taker.remaining > 0) {
      this.rest(taker);
      resting = true;
    }
    return { trades, resting };
  }

  /** Place a non-aggressive (post-only style) order directly into the book
   *  without attempting to match. Used by the WAL replayer to rebuild state
   *  exactly as it was — replays must NOT re-execute trades. */
  insertResting(order: Order): void {
    this.rest(order);
  }

  /** Cancel a resting order by engine-local id. Returns the now-cancelled
   *  order (or null if not found / already filled). */
  cancel(orderId: number): Order | null {
    const idx = this.orderIndex.get(orderId);
    if (!idx) return null;
    const { level, node, side } = idx;
    level.unlink(node);
    this.orderIndex.delete(orderId);
    if (level.isEmpty()) this.dropLevel(level.price, side === "buy" ? "bid" : "ask");
    return node.order;
  }

  /** Snapshot the top-N levels — used both by the public depth API and by
   *  the snapshot persistence layer (which passes Infinity to dump it all).
   */
  depth(maxLevels: number, seq: number): Depth {
    const bids: DepthLevel[] = [];
    const asks: DepthLevel[] = [];
    // Bids: walk from the END of the ascending array → descending output.
    for (let i = this.bidPrices.length - 1, n = 0; i >= 0 && n < maxLevels; i--, n++) {
      const p = this.bidPrices[i]!;
      const lvl = this.bids.get(p)!;
      bids.push({ price: p, quantity: lvl.totalQty, orders: lvl.count });
    }
    for (let i = 0, n = 0; i < this.askPrices.length && n < maxLevels; i++, n++) {
      const p = this.askPrices[i]!;
      const lvl = this.asks.get(p)!;
      asks.push({ price: p, quantity: lvl.totalQty, orders: lvl.count });
    }
    return { symbol: this.symbol, bids, asks, seq };
  }

  /** Walk every resting order — used by the snapshot writer. Returns a
   *  fresh array so callers can serialize without holding the engine. */
  allRestingOrders(): Order[] {
    const out: Order[] = [];
    for (const lvl of this.bids.values()) {
      for (let n = lvl.head; n; n = n.next) out.push(n.order);
    }
    for (const lvl of this.asks.values()) {
      for (let n = lvl.head; n; n = n.next) out.push(n.order);
    }
    return out;
  }

  bestBid(): number | null {
    return this.bidPrices.length ? this.bidPrices[this.bidPrices.length - 1]! : null;
  }

  bestAsk(): number | null {
    return this.askPrices.length ? this.askPrices[0]! : null;
  }

  // ─── private helpers ───────────────────────────────────────────────────

  private rest(order: Order): void {
    const isBuyer = order.side === "buy";
    const map = isBuyer ? this.bids : this.asks;
    const prices = isBuyer ? this.bidPrices : this.askPrices;
    let level = map.get(order.price);
    if (!level) {
      level = new PriceLevel(order.price);
      map.set(order.price, level);
      // Binary insert — keeps the array sorted ascending so best-price
      // lookup is O(1) and depth snapshots are a single linear walk.
      const ix = lowerBound(prices, order.price);
      prices.splice(ix, 0, order.price);
    }
    const node = level.push(order);
    this.orderIndex.set(order.id, { level, node, side: order.side });
  }

  private dropLevel(price: number, side: "bid" | "ask"): void {
    const map = side === "bid" ? this.bids : this.asks;
    const prices = side === "bid" ? this.bidPrices : this.askPrices;
    map.delete(price);
    const ix = lowerBound(prices, price);
    if (ix < prices.length && prices[ix] === price) prices.splice(ix, 1);
  }
}

/** Standard lower-bound binary search — returns the FIRST index where
 *  arr[i] >= target. Used for both insert position and removal lookup. */
function lowerBound(arr: number[], target: number): number {
  let lo = 0;
  let hi = arr.length;
  while (lo < hi) {
    const mid = (lo + hi) >>> 1;
    if (arr[mid]! < target) lo = mid + 1;
    else hi = mid;
  }
  return lo;
}
