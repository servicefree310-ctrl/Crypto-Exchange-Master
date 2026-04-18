import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, put } from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { useEffect, useState } from "react";
import { useAuth } from "@/lib/auth";

type Page = { slug: string; title: string; content: string; updatedAt: string };

const SLUGS = ["privacy", "terms", "aml", "contact"];

export default function LegalPage() {
  const { user: me } = useAuth();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const qc = useQueryClient();
  const { data = [] } = useQuery<Page[]>({ queryKey: ["/admin/legal"], queryFn: () => get<Page[]>("/admin/legal") });
  const save = useMutation({ mutationFn: ({ slug, body }: { slug: string; body: Partial<Page> }) => put(`/admin/legal/${slug}`, body), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/legal"] }) });

  return (
    <Tabs defaultValue={SLUGS[0]} className="space-y-4">
      <TabsList>{SLUGS.map((s) => <TabsTrigger key={s} value={s}>{s.toUpperCase()}</TabsTrigger>)}</TabsList>
      {SLUGS.map((slug) => {
        const p = data.find((x) => x.slug === slug) || { slug, title: "", content: "", updatedAt: "" };
        return (
          <TabsContent key={slug} value={slug}>
            <PageEditor page={p} disabled={!isAdmin} onSave={(body) => save.mutate({ slug, body })} />
          </TabsContent>
        );
      })}
    </Tabs>
  );
}

function PageEditor({ page, disabled, onSave }: { page: Page; disabled: boolean; onSave: (b: Partial<Page>) => void }) {
  const [title, setTitle] = useState(page.title);
  const [content, setContent] = useState(page.content);
  useEffect(() => { setTitle(page.title); setContent(page.content); }, [page.slug, page.title, page.content]);
  return (
    <Card>
      <CardHeader>
        <CardTitle>Edit /{page.slug}</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="space-y-2"><Label>Title</Label><Input value={title} onChange={(e) => setTitle(e.target.value)} disabled={disabled} /></div>
        <div className="space-y-2"><Label>Content (Markdown)</Label><Textarea rows={20} value={content} onChange={(e) => setContent(e.target.value)} disabled={disabled} className="font-mono text-sm" /></div>
        {!disabled && <Button onClick={() => onSave({ title, content })}>Save changes</Button>}
        {page.updatedAt && <div className="text-xs text-muted-foreground">Last updated: {new Date(page.updatedAt).toLocaleString("en-IN")}</div>}
      </CardContent>
    </Card>
  );
}
