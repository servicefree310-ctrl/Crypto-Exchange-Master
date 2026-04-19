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
      if (ticks is Map) {
        // Merge: prices map keyed by symbol like 'BTC' → {price, change, ...} OR {usd, inr}
        ticks.forEach((k, v) {
          if (v is Map) {
            prices[k.toString()] = Map<String, dynamic>.from(v);
          } else if (v is num) {
            prices[k.toString()] = v;
          }
        });
        // Also patch coins[].currentPrice & change24h so home recomputes priceMap
        for (var i = 0; i < coins.length; i++) {
          final c = coins[i];
          if (c is Map) {
            final sym = (c['symbol'] ?? '').toString();
            final t = ticks[sym];
            if (t is Map) {
              if (t['price'] is num) c['currentPrice'] = (t['price'] as num).toString();
              if (t['usd'] is num) c['currentPrice'] = (t['usd'] as num).toString();
              if (t['inr'] is num) c['priceInr'] = (t['inr'] as num).toString();
              if (t['change'] is num) c['change24h'] = (t['change'] as num).toString();
              if (t['change24h'] is num) c['change24h'] = (t['change24h'] as num).toString();
            }
          }
        }
        notifyListeners();
      }
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
