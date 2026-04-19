package main

import (
        "encoding/json"
        "log"
        "net/http"
        "os"
        "strings"
        "sync"
        "time"

        "github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
        CheckOrigin: func(r *http.Request) bool { return true },
}

type subSet struct {
        mu       sync.Mutex
        channels map[string]struct{}
}

func newSubSet() *subSet { return &subSet{channels: map[string]struct{}{}} }
func (s *subSet) add(ch string) {
        s.mu.Lock()
        defer s.mu.Unlock()
        s.channels[ch] = struct{}{}
}
func (s *subSet) snapshot() []string {
        s.mu.Lock()
        defer s.mu.Unlock()
        out := make([]string, 0, len(s.channels))
        for k := range s.channels {
                out = append(out, k)
        }
        return out
}

func handleHealth(w http.ResponseWriter, _ *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(map[string]any{
                "status":  "ok",
                "service": "cryptox-go",
                "ts":      time.Now().UnixMilli(),
        })
}

// Stub WebSocket: accepts {type:"subscribe", channel:"ticker:BTCUSDT"}
// frames and broadcasts mock ticker updates every second. Real matching
// engine + L2 book streams will replace this in Task #2.
func handleWS(w http.ResponseWriter, r *http.Request) {
        c, err := upgrader.Upgrade(w, r, nil)
        if err != nil {
                log.Println("upgrade:", err)
                return
        }
        defer c.Close()

        subs := newSubSet()

        // reader
        go func() {
                for {
                        _, msg, err := c.ReadMessage()
                        if err != nil {
                                return
                        }
                        var m map[string]any
                        if json.Unmarshal(msg, &m) == nil {
                                if t, _ := m["type"].(string); t == "subscribe" {
                                        if ch, _ := m["channel"].(string); ch != "" {
                                                subs.add(ch)
                                        }
                                }
                        }
                }
        }()

        tk := time.NewTicker(time.Second)
        defer tk.Stop()
        for range tk.C {
                for _, ch := range subs.snapshot() {
                        payload, _ := json.Marshal(map[string]any{
                                "channel": ch,
                                "ts":      time.Now().UnixMilli(),
                                "data":    map[string]any{"price": 50000.0, "qty": 0},
                        })
                        if err := c.WriteMessage(websocket.TextMessage, payload); err != nil {
                                return
                        }
                }
        }
}

func main() {
        port := os.Getenv("PORT")
        if port == "" {
                port = "8090"
        }
        prefix := os.Getenv("BASE_PATH")
        if prefix == "" {
                prefix = "/go-service/"
        }
        prefix = strings.TrimRight(prefix, "/")

        mux := http.NewServeMux()
        mux.HandleFunc("/healthz", handleHealth)
        mux.HandleFunc("/ws", handleWS)
        mux.HandleFunc(prefix+"/healthz", handleHealth)
        mux.HandleFunc(prefix+"/ws", handleWS)
        mux.HandleFunc(prefix+"/", handleHealth)

        log.Printf("cryptox-go listening on :%s", port)
        if err := http.ListenAndServe(":"+port, mux); err != nil {
                log.Fatal(err)
        }
}
