import { useEffect, useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { get } from "@/lib/api";
import { useToast } from "@/hooks/use-toast";
import { PageHeader } from "@/components/premium/PageHeader";
import { EmptyState } from "@/components/premium/EmptyState";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import {
  Code2, Copy, Check, FileCode2, Folder, FolderOpen, ChevronRight,
  Search, Loader2, FileText, Sparkles,
} from "lucide-react";
import { cn } from "@/lib/utils";

type FileNode = { type: "file"; name: string; path: string; size: number };
type DirNode  = { type: "dir";  name: string; path: string; children: TreeNode[] };
type TreeNode = FileNode | DirNode;

type TreeResp = { root: string; label: string; tree: TreeNode[] };
type FileResp = { root: string; path: string; size: number; content: string };

const ROOT_KEY = "admin";

function langOf(name: string): string {
  const ext = name.split(".").pop()?.toLowerCase() ?? "";
  switch (ext) {
    case "tsx": return "tsx";
    case "ts":  return "typescript";
    case "jsx": return "jsx";
    case "js":  case "mjs": case "cjs": return "javascript";
    case "json": return "json";
    case "css":  return "css";
    case "scss": return "scss";
    case "html": return "html";
    case "md":   return "markdown";
    case "sql":  return "sql";
    case "yml":  case "yaml": return "yaml";
    case "sh":   return "bash";
    default:     return ext || "text";
  }
}

function fmtBytes(n: number): string {
  if (n < 1024) return `${n} B`;
  if (n < 1024 * 1024) return `${(n / 1024).toFixed(1)} KB`;
  return `${(n / (1024 * 1024)).toFixed(2)} MB`;
}

// Recursively filter the tree by a case-insensitive substring on file path.
function filterTree(nodes: TreeNode[], q: string): TreeNode[] {
  if (!q) return nodes;
  const needle = q.toLowerCase();
  const out: TreeNode[] = [];
  for (const n of nodes) {
    if (n.type === "file") {
      if (n.path.toLowerCase().includes(needle)) out.push(n);
    } else {
      const kept = filterTree(n.children, needle);
      if (kept.length > 0) out.push({ ...n, children: kept });
      else if (n.path.toLowerCase().includes(needle)) out.push(n);
    }
  }
  return out;
}

// Pre-compute every directory path so we can auto-expand when filtering.
function collectDirPaths(nodes: TreeNode[]): string[] {
  const paths: string[] = [];
  const walk = (ns: TreeNode[]) => {
    for (const n of ns) {
      if (n.type === "dir") {
        paths.push(n.path);
        walk(n.children);
      }
    }
  };
  walk(nodes);
  return paths;
}

function TreeItem({
  node, depth, expanded, onToggle, selected, onSelect,
}: {
  node: TreeNode;
  depth: number;
  expanded: Set<string>;
  onToggle: (path: string) => void;
  selected: string | null;
  onSelect: (path: string) => void;
}) {
  const indent = { paddingLeft: 8 + depth * 14 };

  if (node.type === "file") {
    const isActive = selected === node.path;
    return (
      <button
        type="button"
        onClick={() => onSelect(node.path)}
        style={indent}
        className={cn(
          "w-full text-left flex items-center gap-2 py-1 pr-2 text-sm rounded-sm hover:bg-muted/60 transition-colors",
          isActive && "bg-primary/10 text-primary"
        )}
      >
        <FileCode2 className="h-3.5 w-3.5 shrink-0 opacity-70" />
        <span className="truncate">{node.name}</span>
      </button>
    );
  }

  const isOpen = expanded.has(node.path);
  return (
    <>
      <button
        type="button"
        onClick={() => onToggle(node.path)}
        style={indent}
        className="w-full text-left flex items-center gap-1 py-1 pr-2 text-sm rounded-sm hover:bg-muted/60 transition-colors font-medium"
      >
        <ChevronRight
          className={cn(
            "h-3.5 w-3.5 shrink-0 transition-transform",
            isOpen && "rotate-90"
          )}
        />
        {isOpen ? (
          <FolderOpen className="h-3.5 w-3.5 shrink-0 text-amber-500" />
        ) : (
          <Folder className="h-3.5 w-3.5 shrink-0 text-amber-500" />
        )}
        <span className="truncate">{node.name}</span>
      </button>
      {isOpen && (
        <div>
          {node.children.map((c) => (
            <TreeItem
              key={c.path}
              node={c}
              depth={depth + 1}
              expanded={expanded}
              onToggle={onToggle}
              selected={selected}
              onSelect={onSelect}
            />
          ))}
        </div>
      )}
    </>
  );
}

export default function CodeReferencePage() {
  const { toast } = useToast();
  const [query, setQuery] = useState("");
  const [expanded, setExpanded] = useState<Set<string>>(new Set(["src", "src/pages", "src/components"]));
  const [selected, setSelected] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);

  const treeQ = useQuery({
    queryKey: ["admin-source-tree", ROOT_KEY],
    queryFn: () => get<TreeResp>(`/admin/source/tree?root=${ROOT_KEY}`),
    staleTime: 60_000,
  });

  const fileQ = useQuery({
    queryKey: ["admin-source-file", ROOT_KEY, selected],
    queryFn: () =>
      get<FileResp>(
        `/admin/source/file?root=${ROOT_KEY}&path=${encodeURIComponent(selected!)}`
      ),
    enabled: !!selected,
    staleTime: 30_000,
  });

  // Auto-select a sensible first file when the tree first loads.
  useEffect(() => {
    if (selected || !treeQ.data?.tree) return;
    const findFirstFile = (nodes: TreeNode[]): string | null => {
      for (const n of nodes) {
        if (n.type === "file") return n.path;
        if (n.type === "dir") {
          const f = findFirstFile(n.children);
          if (f) return f;
        }
      }
      return null;
    };
    // Prefer src/App.tsx if present.
    const flat: string[] = [];
    const walk = (ns: TreeNode[]) => {
      for (const n of ns) {
        if (n.type === "file") flat.push(n.path);
        else walk(n.children);
      }
    };
    walk(treeQ.data.tree);
    const preferred = flat.find((p) => p === "src/App.tsx") ?? flat.find((p) => p.endsWith("/App.tsx")) ?? findFirstFile(treeQ.data.tree);
    if (preferred) setSelected(preferred);
  }, [treeQ.data, selected]);

  // When the user types a search, auto-expand all dirs in the filtered view.
  const filteredTree = useMemo(() => {
    if (!treeQ.data?.tree) return [];
    return filterTree(treeQ.data.tree, query.trim());
  }, [treeQ.data, query]);

  useEffect(() => {
    if (!query.trim()) return;
    const dirs = collectDirPaths(filteredTree);
    setExpanded((prev) => {
      const next = new Set(prev);
      dirs.forEach((d) => next.add(d));
      return next;
    });
  }, [query, filteredTree]);

  const toggle = (p: string) =>
    setExpanded((prev) => {
      const next = new Set(prev);
      if (next.has(p)) next.delete(p);
      else next.add(p);
      return next;
    });

  const onCopy = async () => {
    if (!fileQ.data?.content) return;
    try {
      await navigator.clipboard.writeText(fileQ.data.content);
      setCopied(true);
      toast({ title: "Copied", description: fileQ.data.path });
      setTimeout(() => setCopied(false), 1600);
    } catch {
      toast({ title: "Copy failed", variant: "destructive" });
    }
  };

  const lineCount = fileQ.data?.content ? fileQ.data.content.split("\n").length : 0;
  const language = selected ? langOf(selected.split("/").pop() ?? "") : "";

  return (
    <div className="space-y-6">
      <PageHeader
        title="Code Reference"
        subtitle="Browse the admin panel's full source tree, just like in your editor."
        icon={Code2}
        actions={
          <Badge variant="outline" className="gap-1">
            <Sparkles className="h-3.5 w-3.5" />
            {treeQ.data?.label ?? "artifacts/admin"}
          </Badge>
        }
      />

      <div className="grid grid-cols-12 gap-4">
        {/* ---------------- Left: tree ---------------- */}
        <Card className="col-span-12 md:col-span-4 lg:col-span-3 p-0 overflow-hidden">
          <div className="p-3 border-b">
            <div className="relative">
              <Search className="absolute left-2 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-muted-foreground" />
              <Input
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Find file or folder…"
                className="pl-7 h-8 text-sm"
              />
            </div>
          </div>
          <div className="max-h-[72vh] overflow-y-auto py-2">
            {treeQ.isLoading ? (
              <div className="flex items-center justify-center py-10 text-muted-foreground text-sm gap-2">
                <Loader2 className="h-4 w-4 animate-spin" /> Loading tree…
              </div>
            ) : treeQ.isError ? (
              <div className="px-4 py-6 text-sm text-red-500">
                Couldn't load source tree.
              </div>
            ) : filteredTree.length === 0 ? (
              <EmptyState
                title="No matches"
                description="Try a different search term."
                icon={FileText}
              />
            ) : (
              filteredTree.map((n) => (
                <TreeItem
                  key={n.path}
                  node={n}
                  depth={0}
                  expanded={expanded}
                  onToggle={toggle}
                  selected={selected}
                  onSelect={setSelected}
                />
              ))
            )}
          </div>
        </Card>

        {/* ---------------- Right: viewer ---------------- */}
        <Card className="col-span-12 md:col-span-8 lg:col-span-9 p-0 overflow-hidden">
          <div className="flex items-center justify-between gap-3 border-b p-3">
            <div className="min-w-0 flex items-center gap-2">
              <FileCode2 className="h-4 w-4 text-primary shrink-0" />
              <code className="text-sm font-medium truncate">
                {selected
                  ? `${treeQ.data?.label ?? "artifacts/admin"}/${selected}`
                  : "Select a file from the tree"}
              </code>
              {selected && (
                <>
                  <Badge variant="outline">{language}</Badge>
                  {fileQ.data && (
                    <>
                      <Badge variant="secondary">{lineCount} lines</Badge>
                      <Badge variant="secondary">{fmtBytes(fileQ.data.size)}</Badge>
                    </>
                  )}
                </>
              )}
            </div>
            <Button
              size="sm"
              variant="outline"
              onClick={onCopy}
              disabled={!fileQ.data?.content}
            >
              {copied ? (
                <><Check className="h-4 w-4 mr-2" /> Copied</>
              ) : (
                <><Copy className="h-4 w-4 mr-2" /> Copy code</>
              )}
            </Button>
          </div>

          <div className="bg-zinc-950">
            {!selected ? (
              <div className="p-12 text-center text-sm text-muted-foreground">
                Pick any file on the left to view its full source.
              </div>
            ) : fileQ.isLoading ? (
              <div className="flex items-center justify-center py-16 text-muted-foreground text-sm gap-2">
                <Loader2 className="h-4 w-4 animate-spin" /> Loading file…
              </div>
            ) : fileQ.isError ? (
              <div className="p-6 text-sm text-red-400">
                Failed to load this file ({(fileQ.error as any)?.message ?? "error"}).
              </div>
            ) : (
              <pre className="overflow-auto p-4 text-[12.5px] leading-relaxed text-zinc-100 font-mono max-h-[72vh]">
                <code>{fileQ.data?.content}</code>
              </pre>
            )}
          </div>
        </Card>
      </div>
    </div>
  );
}
