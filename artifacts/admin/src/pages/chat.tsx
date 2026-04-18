import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, patch } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { useState } from "react";

type Thread = { id: number; userId: number; subject: string; status: string; assigneeId: number | null; lastMessageAt: string };
type Message = { id: number; threadId: number; senderId: number; senderRole: string; message: string; createdAt: string };

export default function ChatPage() {
  const qc = useQueryClient();
  const { data: threads = [] } = useQuery<Thread[]>({ queryKey: ["/admin/chat-threads"], queryFn: () => get<Thread[]>("/admin/chat-threads"), refetchInterval: 5000 });
  const [active, setActive] = useState<number | null>(null);
  const { data: msgs = [] } = useQuery<Message[]>({
    queryKey: ["/admin/chat-threads", active, "messages"],
    queryFn: () => active ? get<Message[]>(`/admin/chat-threads/${active}/messages`) : Promise.resolve([]),
    enabled: !!active, refetchInterval: 3000,
  });
  const send = useMutation({ mutationFn: ({ id, message }: { id: number; message: string }) => post(`/admin/chat-threads/${id}/messages`, { message }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/chat-threads", active, "messages"] }) });
  const closeThread = useMutation({ mutationFn: (id: number) => patch(`/admin/chat-threads/${id}`, { status: "closed" }), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/chat-threads"] }) });
  const [text, setText] = useState("");

  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 h-[calc(100vh-8rem)]">
      <Card className="overflow-y-auto p-2 space-y-1">
        {threads.length === 0 && <div className="p-4 text-center text-sm text-muted-foreground">No threads</div>}
        {threads.map((t) => (
          <button key={t.id} onClick={() => setActive(t.id)}
            className={`w-full text-left p-3 rounded-md hover-elevate ${active === t.id ? "bg-accent text-accent-foreground" : ""}`}>
            <div className="flex justify-between items-center">
              <span className="font-medium text-sm">User #{t.userId}</span>
              <Badge variant={t.status === "open" ? "default" : "secondary"}>{t.status}</Badge>
            </div>
            <div className="text-xs text-muted-foreground truncate">{t.subject}</div>
            <div className="text-xs text-muted-foreground">{new Date(t.lastMessageAt).toLocaleString("en-IN")}</div>
          </button>
        ))}
      </Card>
      <Card className="lg:col-span-2 flex flex-col">
        {active ? (
          <>
            <div className="flex items-center justify-between p-3 border-b border-border">
              <div className="font-medium">Thread #{active}</div>
              <Button variant="outline" size="sm" onClick={() => closeThread.mutate(active)}>Close thread</Button>
            </div>
            <div className="flex-1 overflow-y-auto p-3 space-y-2">
              {msgs.map((m) => (
                <div key={m.id} className={`max-w-[75%] rounded-lg px-3 py-2 ${m.senderRole === "support" ? "ml-auto bg-primary text-primary-foreground" : "bg-muted"}`}>
                  <div className="text-xs opacity-70 mb-0.5">{m.senderRole} • {new Date(m.createdAt).toLocaleTimeString("en-IN")}</div>
                  <div className="text-sm whitespace-pre-wrap">{m.message}</div>
                </div>
              ))}
            </div>
            <form className="flex gap-2 p-3 border-t border-border" onSubmit={(e) => { e.preventDefault(); if (text.trim()) { send.mutate({ id: active, message: text }); setText(""); } }}>
              <Input value={text} onChange={(e) => setText(e.target.value)} placeholder="Type a reply…" />
              <Button type="submit">Send</Button>
            </form>
          </>
        ) : (
          <div className="flex-1 flex items-center justify-center text-muted-foreground">Select a thread</div>
        )}
      </Card>
    </div>
  );
}
