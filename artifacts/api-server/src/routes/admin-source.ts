import { Router, type IRouter, type Request, type Response } from "express";
import path from "node:path";
import { promises as fs } from "node:fs";
import { requireRole } from "../middlewares/auth";

// Security-locked source-code browser.
// - Admin/superadmin only.
// - Hard-coded root allowlist mapped to absolute paths under the monorepo.
// - Path traversal blocked (resolved path must stay inside its root).
// - Skips noisy / large directories (node_modules, dist, build, .git, etc).
// - Hard cap on individual file size sent over the wire.

const router: IRouter = Router();

const MAX_FILE_BYTES = 1_000_000; // 1 MB cap per file
const SKIP_DIRS = new Set([
  "node_modules",
  "dist",
  "build",
  ".git",
  ".next",
  ".turbo",
  ".cache",
  "coverage",
  ".vite",
]);
const BINARY_EXT = new Set([
  ".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico", ".bmp", ".tiff",
  ".woff", ".woff2", ".ttf", ".otf", ".eot",
  ".mp3", ".mp4", ".mov", ".webm", ".wav", ".ogg",
  ".zip", ".gz", ".tar", ".7z", ".rar",
  ".pdf", ".jar", ".class", ".so", ".dylib", ".dll", ".exe",
]);

// api-server runs with cwd = artifacts/api-server (per its dev script),
// so `../<x>` resolves to siblings under artifacts/.
function repoSibling(dir: string): string {
  return path.resolve(process.cwd(), "..", dir);
}

const ROOTS: Record<string, { absPath: string; label: string }> = {
  admin:        { absPath: repoSibling("admin"),        label: "artifacts/admin" },
  "user-portal": { absPath: repoSibling("user-portal"), label: "artifacts/user-portal" },
};

function resolveRoot(rootKey: string): string | null {
  const r = ROOTS[rootKey];
  return r ? r.absPath : null;
}

function isSafeChild(rootAbs: string, candidateAbs: string): boolean {
  const rel = path.relative(rootAbs, candidateAbs);
  return !!rel && !rel.startsWith("..") && !path.isAbsolute(rel);
}

type TreeNode =
  | { type: "dir"; name: string; path: string; children: TreeNode[] }
  | { type: "file"; name: string; path: string; size: number };

async function buildTree(rootAbs: string, rel = ""): Promise<TreeNode[]> {
  const dirAbs = path.join(rootAbs, rel);
  let entries: import("node:fs").Dirent[];
  try {
    entries = await fs.readdir(dirAbs, { withFileTypes: true });
  } catch {
    return [];
  }

  // Sort: directories first, then files; alphabetical.
  entries.sort((a, b) => {
    if (a.isDirectory() !== b.isDirectory()) return a.isDirectory() ? -1 : 1;
    return a.name.localeCompare(b.name);
  });

  const out: TreeNode[] = [];
  for (const e of entries) {
    if (e.name.startsWith(".") && e.name !== ".env.example") continue;
    if (e.isDirectory()) {
      if (SKIP_DIRS.has(e.name)) continue;
      const childRel = rel ? `${rel}/${e.name}` : e.name;
      const children = await buildTree(rootAbs, childRel);
      out.push({ type: "dir", name: e.name, path: childRel, children });
    } else if (e.isFile()) {
      const ext = path.extname(e.name).toLowerCase();
      if (BINARY_EXT.has(ext)) continue;
      const childRel = rel ? `${rel}/${e.name}` : e.name;
      let size = 0;
      try {
        const st = await fs.stat(path.join(dirAbs, e.name));
        size = st.size;
      } catch { /* ignore */ }
      out.push({ type: "file", name: e.name, path: childRel, size });
    }
  }
  return out;
}

// All endpoints under /admin/source/* require admin/superadmin.
router.use("/admin/source", requireRole("admin", "superadmin"));

router.get("/admin/source/roots", (_req: Request, res: Response) => {
  res.json({
    roots: Object.entries(ROOTS).map(([key, r]) => ({ key, label: r.label })),
  });
});

router.get("/admin/source/tree", async (req: Request, res: Response) => {
  const rootKey = String(req.query.root ?? "admin");
  const rootAbs = resolveRoot(rootKey);
  if (!rootAbs) {
    res.status(400).json({ error: "unknown_root" });
    return;
  }
  try {
    const tree = await buildTree(rootAbs);
    res.json({ root: rootKey, label: ROOTS[rootKey].label, tree });
  } catch (e: any) {
    res.status(500).json({ error: "tree_failed", message: e?.message ?? "" });
  }
});

router.get("/admin/source/file", async (req: Request, res: Response) => {
  const rootKey = String(req.query.root ?? "admin");
  const relPath = String(req.query.path ?? "");
  const rootAbs = resolveRoot(rootKey);

  if (!rootAbs) {
    res.status(400).json({ error: "unknown_root" });
    return;
  }
  if (!relPath) {
    res.status(400).json({ error: "path_required" });
    return;
  }
  if (relPath.includes("\0")) {
    res.status(400).json({ error: "invalid_path" });
    return;
  }

  // Reject any segment that tries to escape the root.
  const normalized = path.normalize(relPath).replace(/^[/\\]+/, "");
  const absCandidate = path.resolve(rootAbs, normalized);
  if (!isSafeChild(rootAbs, absCandidate)) {
    res.status(400).json({ error: "path_traversal" });
    return;
  }

  try {
    const st = await fs.stat(absCandidate);
    if (!st.isFile()) {
      res.status(400).json({ error: "not_a_file" });
      return;
    }
    if (st.size > MAX_FILE_BYTES) {
      res.status(413).json({
        error: "file_too_large",
        size: st.size,
        maxBytes: MAX_FILE_BYTES,
      });
      return;
    }
    const ext = path.extname(absCandidate).toLowerCase();
    if (BINARY_EXT.has(ext)) {
      res.status(415).json({ error: "binary_not_supported" });
      return;
    }
    const content = await fs.readFile(absCandidate, "utf8");
    res.json({
      root: rootKey,
      path: normalized.split(path.sep).join("/"),
      size: st.size,
      content,
    });
  } catch (e: any) {
    if (e?.code === "ENOENT") {
      res.status(404).json({ error: "not_found" });
      return;
    }
    res.status(500).json({ error: "read_failed", message: e?.message ?? "" });
  }
});

export default router;
