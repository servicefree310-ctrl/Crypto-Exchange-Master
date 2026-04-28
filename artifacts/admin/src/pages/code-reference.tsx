import { useState } from "react";
import { PageHeader } from "@/components/premium/PageHeader";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { useToast } from "@/hooks/use-toast";
import {
  Code2, Copy, Check, Server, LayoutDashboard, Globe, Database,
  FileCode2, Sparkles,
} from "lucide-react";

type Snippet = {
  id: "api" | "admin" | "user" | "sql";
  label: string;
  icon: typeof Server;
  filePath: string;
  language: "typescript" | "tsx" | "sql";
  description: string;
  code: string;
};

const API_CODE = String.raw`// artifacts/api-server/src/routes/announcements.ts
//
// Full Express + Drizzle API for "announcements".
// - Public GET (cached 30s)
// - Admin CRUD (cookie-session, requireRole)
// Mount in routes/index.ts:
//   app.use("/api/content/announcements", announcementsPublic);
//   app.use("/api/admin/announcements", announcementsAdmin);

import { Router, type Request, type Response } from "express";
import { eq, and, desc } from "drizzle-orm";
import { z } from "zod";
import { db } from "../db";
import { announcementsTable } from "@workspace/db/schema";
import { requireRole } from "../middlewares/auth";
import { cachePublic, invalidate } from "../lib/cache";

// ---------- Validation ----------
const upsertSchema = z.object({
  title: z.string().min(1).max(200),
  body: z.string().min(1),
  kind: z.enum(["info", "success", "warning", "danger"]).default("info"),
  isPinned: z.boolean().default(false),
  isActive: z.boolean().default(true),
  ctaLabel: z.string().max(60).optional().nullable(),
  ctaUrl: z.string().url().optional().nullable(),
  publishedAt: z.coerce.date().optional().nullable(),
  expiresAt: z.coerce.date().optional().nullable(),
});

// ---------- Public router (read-only, cached) ----------
export const announcementsPublic = Router();

announcementsPublic.get("/", cachePublic(30), async (_req, res) => {
  const now = new Date();
  const rows = await db
    .select()
    .from(announcementsTable)
    .where(eq(announcementsTable.isActive, true))
    .orderBy(desc(announcementsTable.isPinned), desc(announcementsTable.publishedAt));

  // Filter out expired/scheduled in JS to keep the SQL simple.
  const visible = rows.filter((r) => {
    if (r.publishedAt && r.publishedAt > now) return false;
    if (r.expiresAt && r.expiresAt < now) return false;
    return true;
  });

  res.json({ items: visible });
});

// ---------- Admin router (CRUD, role-gated) ----------
export const announcementsAdmin = Router();
announcementsAdmin.use(requireRole("admin", "superadmin"));

announcementsAdmin.get("/", async (_req, res) => {
  const rows = await db
    .select()
    .from(announcementsTable)
    .orderBy(desc(announcementsTable.createdAt));
  res.json({ items: rows });
});

announcementsAdmin.post("/", async (req: Request, res: Response) => {
  const data = upsertSchema.parse(req.body);
  const [row] = await db.insert(announcementsTable).values(data).returning();
  await invalidate("content:announcements");
  res.status(201).json(row);
});

announcementsAdmin.patch("/:id", async (req, res) => {
  const id = Number(req.params.id);
  const data = upsertSchema.partial().parse(req.body);
  const [row] = await db
    .update(announcementsTable)
    .set({ ...data, updatedAt: new Date() })
    .where(eq(announcementsTable.id, id))
    .returning();
  if (!row) return res.status(404).json({ error: "not_found" });
  await invalidate("content:announcements");
  res.json(row);
});

announcementsAdmin.delete("/:id", async (req, res) => {
  const id = Number(req.params.id);
  await db.delete(announcementsTable).where(eq(announcementsTable.id, id));
  await invalidate("content:announcements");
  res.json({ ok: true });
});
`;

const ADMIN_CODE = String.raw`// artifacts/admin/src/pages/announcements-cms.tsx
//
// Full admin CMS page: list + create/edit dialog + delete confirm.
// Uses tanstack-query, the project "premium" UI kit, and the API above.

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { get, post, patch, del } from "@/lib/api";
import { useToast } from "@/hooks/use-toast";
import { PageHeader } from "@/components/premium/PageHeader";
import { EmptyState } from "@/components/premium/EmptyState";
import { StatusPill } from "@/components/premium/StatusPill";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import { Badge } from "@/components/ui/badge";
import {
  Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle,
} from "@/components/ui/dialog";
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from "@/components/ui/table";
import { Bell, Plus, Pencil, Trash2 } from "lucide-react";

type Announcement = {
  id: number;
  title: string;
  body: string;
  kind: "info" | "success" | "warning" | "danger";
  isPinned: boolean;
  isActive: boolean;
  ctaLabel?: string | null;
  ctaUrl?: string | null;
  publishedAt?: string | null;
  expiresAt?: string | null;
};

type FormState = Partial<Announcement>;

const EMPTY: FormState = {
  title: "",
  body: "",
  kind: "info",
  isPinned: false,
  isActive: true,
};

export default function AnnouncementsCmsPage() {
  const qc = useQueryClient();
  const { toast } = useToast();
  const [open, setOpen] = useState(false);
  const [form, setForm] = useState<FormState>(EMPTY);
  const editing = typeof form.id === "number";

  const { data, isLoading } = useQuery({
    queryKey: ["admin", "announcements"],
    queryFn: () => get<{ items: Announcement[] }>("/admin/announcements"),
  });

  const save = useMutation({
    mutationFn: (payload: FormState) =>
      editing
        ? patch<Announcement>(\`/admin/announcements/\${form.id}\`, payload)
        : post<Announcement>("/admin/announcements", payload),
    onSuccess: () => {
      toast({ title: editing ? "Updated" : "Created", description: form.title });
      setOpen(false);
      setForm(EMPTY);
      qc.invalidateQueries({ queryKey: ["admin", "announcements"] });
    },
    onError: (e: any) =>
      toast({ title: "Save failed", description: e?.message ?? "—", variant: "destructive" }),
  });

  const remove = useMutation({
    mutationFn: (id: number) => del(\`/admin/announcements/\${id}\`),
    onSuccess: () => {
      toast({ title: "Deleted" });
      qc.invalidateQueries({ queryKey: ["admin", "announcements"] });
    },
  });

  const startNew = () => { setForm(EMPTY); setOpen(true); };
  const startEdit = (row: Announcement) => { setForm(row); setOpen(true); };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Announcements"
        subtitle="Pinned banners and platform-wide notices for users."
        icon={Bell}
        actions={
          <Button onClick={startNew}><Plus className="h-4 w-4 mr-2" /> New announcement</Button>
        }
      />

      <Card className="p-0 overflow-hidden">
        {isLoading ? (
          <div className="p-10 text-center text-sm text-muted-foreground">Loading…</div>
        ) : !data?.items?.length ? (
          <EmptyState title="No announcements yet" description="Create the first one." />
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Title</TableHead>
                <TableHead>Kind</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data.items.map((row) => (
                <TableRow key={row.id}>
                  <TableCell className="font-medium">
                    {row.isPinned && <Badge className="mr-2">Pinned</Badge>}
                    {row.title}
                  </TableCell>
                  <TableCell><Badge variant="outline">{row.kind}</Badge></TableCell>
                  <TableCell>
                    <StatusPill status={row.isActive ? "success" : "muted"}>
                      {row.isActive ? "Live" : "Draft"}
                    </StatusPill>
                  </TableCell>
                  <TableCell className="text-right space-x-2">
                    <Button size="sm" variant="ghost" onClick={() => startEdit(row)}>
                      <Pencil className="h-4 w-4" />
                    </Button>
                    <Button
                      size="sm" variant="ghost"
                      onClick={() => confirm("Delete?") && remove.mutate(row.id)}
                    >
                      <Trash2 className="h-4 w-4 text-red-500" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </Card>

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="max-w-xl">
          <DialogHeader>
            <DialogTitle>{editing ? "Edit announcement" : "New announcement"}</DialogTitle>
          </DialogHeader>

          <div className="space-y-4">
            <div className="space-y-2">
              <Label>Title</Label>
              <Input
                value={form.title ?? ""}
                onChange={(e) => setForm({ ...form, title: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <Label>Body</Label>
              <Textarea
                rows={5}
                value={form.body ?? ""}
                onChange={(e) => setForm({ ...form, body: e.target.value })}
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <label className="flex items-center justify-between rounded-md border p-3">
                <span className="text-sm">Pinned</span>
                <Switch
                  checked={!!form.isPinned}
                  onCheckedChange={(v) => setForm({ ...form, isPinned: v })}
                />
              </label>
              <label className="flex items-center justify-between rounded-md border p-3">
                <span className="text-sm">Active</span>
                <Switch
                  checked={!!form.isActive}
                  onCheckedChange={(v) => setForm({ ...form, isActive: v })}
                />
              </label>
            </div>
          </div>

          <DialogFooter>
            <Button variant="ghost" onClick={() => setOpen(false)}>Cancel</Button>
            <Button onClick={() => save.mutate(form)} disabled={save.isPending}>
              {save.isPending ? "Saving…" : editing ? "Save changes" : "Publish"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
`;

const USER_CODE = String.raw`// artifacts/user-portal/src/pages/Announcements.tsx
//
// Public user-portal page that renders announcements from the API.
// - Hinglish copy, dark theme, uses the same API base ("/api/content/...").
// - Pinned items float to the top, show a CTA button when present.

import { useQuery } from "@tanstack/react-query";
import { get } from "@/lib/api";
import AppShell from "@/components/layout/AppShell";
import { Bell, Pin, ExternalLink } from "lucide-react";

type Announcement = {
  id: number;
  title: string;
  body: string;
  kind: "info" | "success" | "warning" | "danger";
  isPinned: boolean;
  ctaLabel?: string | null;
  ctaUrl?: string | null;
  publishedAt?: string | null;
};

const KIND_STYLES: Record<Announcement["kind"], string> = {
  info:    "border-sky-500/30 bg-sky-500/5",
  success: "border-emerald-500/30 bg-emerald-500/5",
  warning: "border-amber-500/30 bg-amber-500/5",
  danger:  "border-rose-500/30 bg-rose-500/5",
};

function fmtDate(s?: string | null) {
  if (!s) return "";
  return new Date(s).toLocaleDateString("en-IN", {
    day: "2-digit", month: "short", year: "numeric",
  });
}

export default function AnnouncementsPage() {
  const { data, isLoading } = useQuery({
    queryKey: ["public", "announcements"],
    queryFn: () => get<{ items: Announcement[] }>("/content/announcements"),
    staleTime: 30_000,
  });

  return (
    <AppShell>
      <div className="container mx-auto px-4 py-10 max-w-3xl">
        <header className="mb-8 flex items-center gap-3">
          <Bell className="h-6 w-6 text-primary" />
          <div>
            <h1 className="text-2xl font-semibold">Announcements</h1>
            <p className="text-sm text-muted-foreground">
              Latest updates from the Zebvix team.
            </p>
          </div>
        </header>

        {isLoading ? (
          <div className="text-sm text-muted-foreground">Loading…</div>
        ) : !data?.items?.length ? (
          <div className="rounded-xl border p-10 text-center text-muted-foreground">
            Abhi koi announcement nahi hai. Baad mein check karein.
          </div>
        ) : (
          <ul className="space-y-4">
            {data.items.map((a) => (
              <li
                key={a.id}
                className={\`rounded-xl border p-5 \${KIND_STYLES[a.kind]}\`}
              >
                <div className="flex items-start justify-between gap-3">
                  <h3 className="text-lg font-semibold">
                    {a.isPinned && (
                      <Pin className="inline h-4 w-4 mr-2 text-primary" />
                    )}
                    {a.title}
                  </h3>
                  {a.publishedAt && (
                    <span className="shrink-0 text-xs text-muted-foreground">
                      {fmtDate(a.publishedAt)}
                    </span>
                  )}
                </div>
                <p className="mt-2 whitespace-pre-line text-sm leading-relaxed">
                  {a.body}
                </p>
                {a.ctaUrl && (
                  <a
                    href={a.ctaUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="mt-3 inline-flex items-center gap-1 text-sm font-medium text-primary hover:underline"
                  >
                    {a.ctaLabel ?? "Learn more"}
                    <ExternalLink className="h-3.5 w-3.5" />
                  </a>
                )}
              </li>
            ))}
          </ul>
        )}
      </div>
    </AppShell>
  );
}
`;

const SQL_CODE = String.raw`-- lib/db/migrations/004_cms.sql
--
-- Full SQL definition for the "announcements" table used by the API and admin
-- shown in the other tabs. Idempotent (safe to re-run).
-- Apply via:  psql "$DATABASE_URL" -f lib/db/migrations/004_cms.sql

CREATE TABLE IF NOT EXISTS announcements (
  id            SERIAL PRIMARY KEY,
  title         VARCHAR(200) NOT NULL,
  body          TEXT         NOT NULL,
  kind          VARCHAR(16)  NOT NULL DEFAULT 'info'
                CHECK (kind IN ('info', 'success', 'warning', 'danger')),
  is_pinned     BOOLEAN      NOT NULL DEFAULT FALSE,
  is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
  cta_label     VARCHAR(60),
  cta_url       TEXT,
  published_at  TIMESTAMPTZ  DEFAULT NOW(),
  expires_at    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Public list query: WHERE is_active AND (expires_at IS NULL OR expires_at > NOW())
-- ORDER BY is_pinned DESC, published_at DESC
CREATE INDEX IF NOT EXISTS idx_announcements_active_published
  ON announcements (is_active, is_pinned DESC, published_at DESC);

CREATE INDEX IF NOT EXISTS idx_announcements_expires_at
  ON announcements (expires_at)
  WHERE expires_at IS NOT NULL;

-- Auto-bump updated_at on every row update.
CREATE OR REPLACE FUNCTION touch_announcements_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_announcements_updated_at ON announcements;
CREATE TRIGGER trg_announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW
  EXECUTE FUNCTION touch_announcements_updated_at();

-- Optional seed (one row, idempotent on title).
INSERT INTO announcements (title, body, kind, is_pinned, is_active, cta_label, cta_url)
VALUES (
  'Zebvix is live!',
  'Welcome to Zebvix. Spot, futures, earn — sab kuch ek jagah.',
  'success',
  TRUE,
  TRUE,
  'Start trading',
  'https://zebvix.example/trade'
)
ON CONFLICT DO NOTHING;
`;

const SNIPPETS: Snippet[] = [
  {
    id: "api",
    label: "API endpoint",
    icon: Server,
    filePath: "artifacts/api-server/src/routes/announcements.ts",
    language: "typescript",
    description:
      "Express + Drizzle router with public read (cached) and admin CRUD (role-gated). Drop-in pattern used across the api-server.",
    code: API_CODE,
  },
  {
    id: "admin",
    label: "Admin page",
    icon: LayoutDashboard,
    filePath: "artifacts/admin/src/pages/announcements-cms.tsx",
    language: "tsx",
    description:
      "Full admin CMS page (list + create/edit dialog + delete) using tanstack-query and the project's premium UI kit.",
    code: ADMIN_CODE,
  },
  {
    id: "user",
    label: "User-portal page",
    icon: Globe,
    filePath: "artifacts/user-portal/src/pages/Announcements.tsx",
    language: "tsx",
    description:
      "Public user-portal page rendering the same data via the cached /content/* endpoint. Hinglish copy and dark theme.",
    code: USER_CODE,
  },
  {
    id: "sql",
    label: "SQL table",
    icon: Database,
    filePath: "lib/db/migrations/004_cms.sql",
    language: "sql",
    description:
      "Idempotent CREATE TABLE for `announcements`, indexes, and an updated_at trigger. Runs cleanly with `psql -f`.",
    code: SQL_CODE,
  },
];

function Snippet({ s }: { s: Snippet }) {
  const { toast } = useToast();
  const [copied, setCopied] = useState(false);

  const onCopy = async () => {
    try {
      await navigator.clipboard.writeText(s.code);
      setCopied(true);
      toast({ title: "Copied", description: s.filePath });
      setTimeout(() => setCopied(false), 1600);
    } catch {
      toast({ title: "Copy failed", variant: "destructive" });
    }
  };

  const lineCount = s.code.split("\n").length;

  return (
    <div className="space-y-3">
      <div className="flex items-start justify-between gap-3">
        <div className="space-y-1.5">
          <div className="flex items-center gap-2">
            <FileCode2 className="h-4 w-4 text-primary" />
            <code className="text-sm font-medium">{s.filePath}</code>
            <Badge variant="outline" className="ml-1">{s.language}</Badge>
            <Badge variant="secondary">{lineCount} lines</Badge>
          </div>
          <p className="text-sm text-muted-foreground">{s.description}</p>
        </div>
        <Button size="sm" variant="outline" onClick={onCopy}>
          {copied ? (
            <><Check className="h-4 w-4 mr-2" /> Copied</>
          ) : (
            <><Copy className="h-4 w-4 mr-2" /> Copy code</>
          )}
        </Button>
      </div>

      <Card className="p-0 overflow-hidden border bg-zinc-950">
        <pre className="overflow-x-auto p-4 text-[12.5px] leading-relaxed text-zinc-100 font-mono max-h-[640px]">
          <code>{s.code}</code>
        </pre>
      </Card>
    </div>
  );
}

export default function CodeReferencePage() {
  const [tab, setTab] = useState<Snippet["id"]>("api");

  return (
    <div className="space-y-6">
      <PageHeader
        title="Code Reference"
        subtitle="Copy-paste templates for an API endpoint, admin page, user-portal page, and SQL table."
        icon={Code2}
        actions={
          <Badge variant="outline" className="gap-1">
            <Sparkles className="h-3.5 w-3.5" /> Templates
          </Badge>
        }
      />

      <Tabs value={tab} onValueChange={(v) => setTab(v as Snippet["id"])}>
        <TabsList className="grid w-full grid-cols-2 md:grid-cols-4">
          {SNIPPETS.map((s) => {
            const Icon = s.icon;
            return (
              <TabsTrigger key={s.id} value={s.id} className="gap-2">
                <Icon className="h-4 w-4" />
                {s.label}
              </TabsTrigger>
            );
          })}
        </TabsList>

        {SNIPPETS.map((s) => (
          <TabsContent key={s.id} value={s.id} className="mt-6">
            <Snippet s={s} />
          </TabsContent>
        ))}
      </Tabs>
    </div>
  );
}
