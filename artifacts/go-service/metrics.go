package main

import (
        "net/http"
        "os"
        "runtime"
        "sync/atomic"
        "time"
)

// ── Global counters (updated by handler wrappers) ──────────────────────────
var (
        reqTotal    atomic.Int64
        reqErrors   atomic.Int64
        startupTime = time.Now()
)

// ── /metrics ────────────────────────────────────────────────────────────────
// Prometheus-compatible plain-text exposition + JSON for admin panel.
func (s *Server) handleMetrics(w http.ResponseWriter, r *http.Request) {
        var memStats runtime.MemStats
        runtime.ReadMemStats(&memStats)

        uptimeSec := int64(time.Since(startupTime).Seconds())
        goroutines := runtime.NumGoroutine()
        gcCount := memStats.NumGC
        heapMB := float64(memStats.HeapAlloc) / (1024 * 1024)
        sysMB := float64(memStats.Sys) / (1024 * 1024)

        s.engine.mu.RLock()
        bookCount := len(s.engine.books)
        totalOrders := 0
        for _, b := range s.engine.books {
                totalOrders += len(b.Bids) + len(b.Asks)
        }
        s.engine.mu.RUnlock()

        s.wsMu.RLock()
        wsClients := len(s.wsSub)
        s.wsMu.RUnlock()

        accept := r.Header.Get("Accept")
        if accept == "application/json" || r.URL.Query().Get("format") == "json" {
                writeJSON(w, 200, map[string]any{
                        "service":          "cryptox-go",
                        "uptime_sec":       uptimeSec,
                        "goroutines":       goroutines,
                        "gc_runs":          gcCount,
                        "heap_alloc_mb":    heapMB,
                        "sys_mb":           sysMB,
                        "req_total":        reqTotal.Load(),
                        "req_errors":       reqErrors.Load(),
                        "ws_clients":       wsClients,
                        "book_count":       bookCount,
                        "resting_orders":   totalOrders,
                        "go_version":       runtime.Version(),
                        "hostname":         hostname(),
                        "ts":               time.Now().UnixMilli(),
                })
                return
        }

        // Prometheus exposition format
        w.Header().Set("Content-Type", "text/plain; version=0.0.4")
        fmt := func(name, help, typ, val string) string {
                return "# HELP " + name + " " + help + "\n" +
                        "# TYPE " + name + " " + typ + "\n" +
                        name + " " + val + "\n"
        }
        lines := fmt("cryptox_go_uptime_seconds", "Process uptime in seconds", "gauge", itoa(uptimeSec)) +
                fmt("cryptox_go_goroutines", "Number of goroutines", "gauge", itoa(int64(goroutines))) +
                fmt("cryptox_go_heap_alloc_bytes", "Heap memory allocated", "gauge", ftoa(float64(memStats.HeapAlloc))) +
                fmt("cryptox_go_gc_runs_total", "Total GC runs", "counter", itoa(int64(gcCount))) +
                fmt("cryptox_go_ws_clients", "Active WebSocket clients", "gauge", itoa(int64(wsClients))) +
                fmt("cryptox_go_orderbook_count", "Number of active orderbooks", "gauge", itoa(int64(bookCount))) +
                fmt("cryptox_go_resting_orders", "Total resting orders across all books", "gauge", itoa(int64(totalOrders))) +
                fmt("cryptox_go_http_requests_total", "Total HTTP requests handled", "counter", itoa(reqTotal.Load())) +
                fmt("cryptox_go_http_errors_total", "Total HTTP 5xx errors", "counter", itoa(reqErrors.Load()))
        w.Write([]byte(lines))
}

// ── /api/engine-status ──────────────────────────────────────────────────────
// Returns engine stats for the admin "Trading Engine" console.
func (s *Server) handleEngineStatus(w http.ResponseWriter, r *http.Request) {
        s.engine.mu.RLock()
        bookCount := len(s.engine.books)
        bookDetails := make([]map[string]any, 0, bookCount)
        for pairID, b := range s.engine.books {
                bids := len(b.Bids)
                asks := len(b.Asks)
                bestBid := 0.0
                bestAsk := 0.0
                if bids > 0 {
                        bestBid = b.Bids[len(b.Bids)-1].Price
                }
                if asks > 0 {
                        bestAsk = b.Asks[0].Price
                }
                bookDetails = append(bookDetails, map[string]any{
                        "pairId":  pairID,
                        "bids":    bids,
                        "asks":    asks,
                        "bestBid": bestBid,
                        "bestAsk": bestAsk,
                })
        }
        s.engine.mu.RUnlock()

        s.wsMu.RLock()
        wsClients := len(s.wsSub)
        s.wsMu.RUnlock()

        var memStats runtime.MemStats
        runtime.ReadMemStats(&memStats)

        writeJSON(w, 200, map[string]any{
                "service":        "futures-matching-engine",
                "uptime_sec":     int64(time.Since(startupTime).Seconds()),
                "goroutines":     runtime.NumGoroutine(),
                "heap_alloc_mb":  float64(memStats.HeapAlloc) / (1024 * 1024),
                "ws_clients":     wsClients,
                "books":          bookDetails,
                "book_count":     bookCount,
                "ts":             time.Now().UnixMilli(),
        })
}

func hostname() string {
        h, _ := os.Hostname()
        return h
}

func itoa(n int64) string {
        if n == 0 {
                return "0"
        }
        neg := n < 0
        if neg {
                n = -n
        }
        buf := make([]byte, 20)
        pos := len(buf)
        for n > 0 {
                pos--
                buf[pos] = byte(n%10) + '0'
                n /= 10
        }
        if neg {
                pos--
                buf[pos] = '-'
        }
        return string(buf[pos:])
}

func ftoa(f float64) string {
        return itoa(int64(f))
}

// countingHandler wraps a handler and increments global counters.
func countingHandler(h http.HandlerFunc) http.HandlerFunc {
        return func(w http.ResponseWriter, r *http.Request) {
                reqTotal.Add(1)
                rw := &responseWriter{ResponseWriter: w, code: 200}
                h(rw, r)
                if rw.code >= 500 {
                        reqErrors.Add(1)
                }
        }
}

type responseWriter struct {
        http.ResponseWriter
        code int
}

func (rw *responseWriter) WriteHeader(code int) {
        rw.code = code
        rw.ResponseWriter.WriteHeader(code)
}
