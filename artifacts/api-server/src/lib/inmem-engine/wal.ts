import { promises as fsp, createReadStream, createWriteStream, type WriteStream } from "node:fs";
import path from "node:path";
import readline from "node:readline";
import type { WalEntry } from "./types";

// Write-Ahead Log: every accepted command and emitted trade is appended,
// in receive order, as a single JSON object per line (JSONL). The engine
// can rebuild the entire book by replaying this file.
//
// Why JSONL on the local filesystem rather than e.g. a real durable WAL
// (RocksDB / sqlite / Kafka)?
//
//   - Local fs is ~µs to append; the engine stays single-threaded with no
//     network dependency on the hot path.
//   - For real production durability you'd swap the writer for an
//     fsync-after-batch loop or stream the same entries to Kafka. The
//     `WalWriter` interface below is small enough that swapping is a
//     localised change.
//   - JSONL replays in O(file_size) and is human-debuggable — you can
//     `tail -f` the WAL during a benchmark and watch every match scroll by.
//
// We keep ONE writer instance (one fd, append mode) per engine instance.
// Concurrent writes from different processes are NOT supported — the
// engine is intentionally single-process / single-threaded.

export class WalWriter {
  private stream: WriteStream | null = null;
  private readonly path: string;
  private opening: Promise<void> | null = null;

  constructor(filePath: string) {
    this.path = filePath;
  }

  private async ensureOpen(): Promise<void> {
    if (this.stream) return;
    if (this.opening) return this.opening;
    this.opening = (async () => {
      await fsp.mkdir(path.dirname(this.path), { recursive: true });
      // 'a' = append. flags must be a string for createWriteStream.
      this.stream = createWriteStream(this.path, { flags: "a" });
    })();
    await this.opening;
    this.opening = null;
  }

  /** Append one entry. Resolves once the line is in the OS write buffer.
   *  We don't fsync per write — that would add a syscall + disk-flush per
   *  trade and crater latency. The snapshot writer fsyncs the snapshot
   *  on rotate, which is the durability boundary we care about. */
  async append(entry: WalEntry): Promise<void> {
    await this.ensureOpen();
    const line = JSON.stringify(entry) + "\n";
    return new Promise((resolve, reject) => {
      this.stream!.write(line, (err) => (err ? reject(err) : resolve()));
    });
  }

  /** Truncate the WAL — called after a snapshot rotation so disk usage
   *  doesn't grow unbounded. The snapshot now contains everything the
   *  truncated WAL prefix did, so replays are still complete. */
  async rotate(): Promise<void> {
    if (this.stream) {
      await new Promise<void>((res) => this.stream!.end(() => res()));
      this.stream = null;
    }
    await fsp.writeFile(this.path, "");
  }

  async close(): Promise<void> {
    if (!this.stream) return;
    await new Promise<void>((res) => this.stream!.end(() => res()));
    this.stream = null;
  }

  /** Streaming replay — yields one entry per line, never loads the whole
   *  file into memory so multi-GB WALs replay safely. */
  static async *read(filePath: string): AsyncIterable<WalEntry> {
    try {
      await fsp.access(filePath);
    } catch {
      return; // no WAL yet — nothing to replay
    }
    const rl = readline.createInterface({
      input: createReadStream(filePath, { encoding: "utf8" }),
      crlfDelay: Infinity,
    });
    for await (const raw of rl) {
      if (!raw) continue;
      try {
        yield JSON.parse(raw) as WalEntry;
      } catch {
        // Corrupt trailing line (typically the very last entry of a
        // crashed write). Stop replay here — anything after a bad line is
        // unsafe to apply since we can't be sure of ordering.
        return;
      }
    }
  }
}
