import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api.dart';

class AuthState extends ChangeNotifier {
  Map<String, dynamic>? user;
  bool loading = true;
  bool get isLoggedIn => user != null;

  Future<void> bootstrap() async {
    loading = true;
    notifyListeners();
    user = await Api.me();
    loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final r = await Api.login(email, password);
    user = (r is Map && r['user'] != null) ? Map<String, dynamic>.from(r['user']) : await Api.me();
    notifyListeners();
  }

  Future<void> register(Map<String, dynamic> body) async {
    await Api.register(body);
    user = await Api.me();
    notifyListeners();
  }

  Future<void> logout() async {
    try { await Api.logout(); } catch (_) {}
    user = null;
    notifyListeners();
  }
}

class MarketsState extends ChangeNotifier {
  List<dynamic> coins = [];
  List<dynamic> pairs = [];
  Map<String, dynamic> prices = {};
  List<dynamic> banners = [];
  bool loading = true;
  String? error;
  Timer? _timer;
  bool _inFlight = false;
  WebSocketChannel? _ws;
  StreamSubscription? _wsSub;
  Timer? _wsRetry;
  double inrRate = 1.0;
  bool wsConnected = false;

  Future<void> start() async {
    await refresh();
    _timer ??= Timer.periodic(const Duration(seconds: 15), (_) => refresh(silent: true));
    _connectWs();
  }

  void stop() {
    _timer?.cancel(); _timer = null;
    _wsRetry?.cancel(); _wsRetry = null;
    _wsSub?.cancel(); _wsSub = null;
    try { _ws?.sink.close(); } catch (_) {}
    _ws = null;
    wsConnected = false;
  }

  void _connectWs() {
    try {
      String wsUrl;
      if (kIsWeb) {
        // Build wss/ws URL relative to current origin
        final origin = Uri.base;
        final scheme = origin.scheme == 'https' ? 'wss' : 'ws';
        wsUrl = '$scheme://${origin.authority}/api/ws/prices';
      } else {
        wsUrl = 'wss://${Uri.base.authority}/api/ws/prices';
      }
      _ws = WebSocketChannel.connect(Uri.parse(wsUrl));
      _wsSub = _ws!.stream.listen(
        _onWsMessage,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
      wsConnected = true;
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    wsConnected = false;
    _wsSub?.cancel(); _wsSub = null;
    try { _ws?.sink.close(); } catch (_) {}
    _ws = null;
    _wsRetry?.cancel();
    _wsRetry = Timer(const Duration(seconds: 3), _connectWs);
  }

  void _onWsMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw is String ? raw : raw.toString());
      if (data is! Map) return;
      final ir = data['inrRate'];
      if (ir is num) inrRate = ir.toDouble();
      final ticks = data['ticks'];
      if (ticks is! List) return;

      // Build symbol -> tick map from array
      final tickBySym = <String, Map>{};
      for (final t in ticks) {
        if (t is Map) {
          final sym = (t['symbol'] ?? '').toString();
          if (sym.isNotEmpty) {
            tickBySym[sym] = t;
            // Also store in prices for symbol-level lookup
            prices[sym] = {
              'price': (t['usdt'] is num) ? (t['usdt'] as num).toDouble() : 0.0,
              'inr': (t['inr'] is num) ? (t['inr'] as num).toDouble() : 0.0,
              'usdt': (t['usdt'] is num) ? (t['usdt'] as num).toDouble() : 0.0,
              'change': (t['change24h'] is num) ? (t['change24h'] as num).toDouble() : 0.0,
              'change24h': (t['change24h'] is num) ? (t['change24h'] as num).toDouble() : 0.0,
              'volume24h': (t['volume24h'] is num) ? (t['volume24h'] as num).toDouble() : 0.0,
            };
          }
        }
      }

      // Patch coins[] in-place so dashboard's priceMap recomputes with live data
      for (var i = 0; i < coins.length; i++) {
        final c = coins[i];
        if (c is Map) {
          final sym = (c['symbol'] ?? '').toString();
          final t = tickBySym[sym];
          if (t != null) {
            if (t['usdt'] is num) c['currentPrice'] = (t['usdt'] as num).toString();
            if (t['inr'] is num) c['priceInr'] = (t['inr'] as num).toString();
            if (t['change24h'] is num) c['change24h'] = (t['change24h'] as num).toString();
          }
        }
      }
      // Patch pairs[] lastPrice for symbols like BTCINR / BTCUSDT
      for (var i = 0; i < pairs.length; i++) {
        final p = pairs[i];
        if (p is Map) {
          final sym = (p['symbol'] ?? '').toString();
          // Resolve base by stripping known quote suffix
          String? base;
          String? quote;
          for (final q in const ['USDT', 'INR', 'USDC', 'USD', 'BTC', 'ETH']) {
            if (sym.endsWith(q) && sym.length > q.length) {
              base = sym.substring(0, sym.length - q.length);
              quote = q;
              break;
            }
          }
          if (base != null) {
            final t = tickBySym[base];
            if (t != null) {
              final price = quote == 'INR'
                  ? (t['inr'] is num ? (t['inr'] as num).toDouble() : 0.0)
                  : (t['usdt'] is num ? (t['usdt'] as num).toDouble() : 0.0);
              if (price > 0) p['lastPrice'] = price.toString();
              if (t['change24h'] is num) p['change24h'] = (t['change24h'] as num).toString();
            }
          }
        }
      }
      notifyListeners();
    } catch (_) {/* ignore malformed */}
  }

  Future<void> refresh({bool silent = false}) async {
    if (_inFlight) return;
    _inFlight = true;
    try {
      final results = await Future.wait([
        Api.coins(),
        Api.pairs(),
        Api.prices(),
        Api.banners(),
      ]);
      final newCoins = results[0] as List;
      final newPairs = results[1] as List;
      final p = results[2];
      final newPrices = (p is Map) ? Map<String, dynamic>.from(p) : <String, dynamic>{};
      final newBanners = results[3] as List;

      bool changed = !silent ||
          newCoins.length != coins.length ||
          newPairs.length != pairs.length ||
          newBanners.length != banners.length ||
          newPrices.toString() != prices.toString();

      coins = newCoins;
      pairs = newPairs;
      prices = newPrices;
      banners = newBanners;
      error = null;
      loading = false;
      if (changed) notifyListeners();
    } catch (e) {
      error = e.toString();
      loading = false;
      if (!silent) notifyListeners();
    } finally {
      _inFlight = false;
    }
  }

  double priceFor(String symbol) {
    final p = prices[symbol];
    if (p is num) return p.toDouble();
    if (p is Map && p['price'] is num) return (p['price'] as num).toDouble();
    return 0;
  }

  @override
  void dispose() { stop(); super.dispose(); }
}

class WalletsState extends ChangeNotifier {
  List<dynamic> wallets = [];
  bool loading = false;

  Future<void> refresh() async {
    loading = true;
    notifyListeners();
    wallets = await Api.wallets();
    loading = false;
    notifyListeners();
  }

  double balanceOf(String coin, {String type = 'spot'}) {
    for (final w in wallets) {
      if ((w['coin'] ?? w['symbol']) == coin && (w['type'] ?? 'spot') == type) {
        final v = w['balance'] ?? w['available'] ?? 0;
        return v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0;
      }
    }
    return 0;
  }
}
