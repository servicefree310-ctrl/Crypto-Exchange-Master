import 'dart:async';
import 'package:flutter/foundation.dart';
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

  Future<void> start() async {
    await refresh();
    _timer ??= Timer.periodic(const Duration(seconds: 4), (_) => refresh(silent: true));
  }

  void stop() { _timer?.cancel(); _timer = null; }

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
