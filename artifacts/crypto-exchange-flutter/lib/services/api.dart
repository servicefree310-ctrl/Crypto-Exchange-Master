import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' as bhttp;

class ApiException implements Exception {
  final int status;
  final String message;
  ApiException(this.status, this.message);
  @override
  String toString() => 'ApiException($status): $message';
}

class ApiClient {
  static final ApiClient I = ApiClient._();
  late final http.Client _client;
  String base;

  ApiClient._() : base = '/api' {
    if (kIsWeb) {
      final bc = bhttp.BrowserClient();
      bc.withCredentials = true;
      _client = bc;
    } else {
      _client = http.Client();
    }
  }

  Uri _u(String path, [Map<String, dynamic>? q]) {
    final url = base + path;
    if (q == null || q.isEmpty) return Uri.parse(url);
    final qs = q.entries
        .where((e) => e.value != null)
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}')
        .join('&');
    return Uri.parse('$url?$qs');
  }

  Future<dynamic> _handle(http.Response r) async {
    if (r.statusCode >= 200 && r.statusCode < 300) {
      if (r.body.isEmpty) return null;
      try {
        return jsonDecode(r.body);
      } catch (_) {
        return r.body;
      }
    }
    String msg = 'HTTP ${r.statusCode}';
    try {
      final j = jsonDecode(r.body);
      if (j is Map && j['error'] != null) msg = j['error'].toString();
      else if (j is Map && j['message'] != null) msg = j['message'].toString();
    } catch (_) {}
    throw ApiException(r.statusCode, msg);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final r = await _client.get(_u(path, query), headers: {'accept': 'application/json'});
    return _handle(r);
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    final r = await _client.post(
      _u(path),
      headers: {'content-type': 'application/json', 'accept': 'application/json'},
      body: jsonEncode(body ?? {}),
    );
    return _handle(r);
  }

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async {
    final r = await _client.patch(
      _u(path),
      headers: {'content-type': 'application/json', 'accept': 'application/json'},
      body: jsonEncode(body ?? {}),
    );
    return _handle(r);
  }

  Future<dynamic> delete(String path) async {
    final r = await _client.delete(_u(path), headers: {'accept': 'application/json'});
    return _handle(r);
  }
}

class Api {
  static final _c = ApiClient.I;

  // ───── Auth ─────
  static Future<Map<String, dynamic>?> me() async {
    try {
      final r = await _c.get('/auth/me');
      if (r is Map) return Map<String, dynamic>.from(r);
      return null;
    } on ApiException catch (e) {
      if (e.status == 401) return null;
      rethrow;
    }
  }
  static Future login(String email, String password) =>
      _c.post('/auth/login', {'email': email, 'password': password});
  static Future register(Map<String, dynamic> body) => _c.post('/auth/register', body);
  static Future logout() => _c.post('/auth/logout');

  // ───── Markets ─────
  static Future<List> coins() async => (await _c.get('/coins')) as List;
  static Future<List> pairs() async => (await _c.get('/pairs')) as List;
  static Future prices() => _c.get('/prices');
  static Future<List> banners() async {
    try { return (await _c.get('/banners')) as List; } catch (_) { return []; }
  }
  static Future orderbook(String symbol) => _c.get('/orderbook', query: {'symbol': symbol});
  static Future<List> recentTrades(String symbol) async =>
      (await _c.get('/recent-trades', query: {'symbol': symbol})) as List;
  static Future<List> klines(String symbol, {String interval = '1h', int limit = 100}) async =>
      (await _c.get('/klines', query: {'symbol': symbol, 'interval': interval, 'limit': limit})) as List;

  // ───── Wallets ─────
  static Future<List> wallets() async {
    try { return (await _c.get('/wallets')) as List; } catch (_) { return []; }
  }

  // ───── Orders ─────
  static Future<List> myOrders() async {
    try { return (await _c.get('/orders')) as List; } catch (_) { return []; }
  }
  static Future placeOrder(Map<String, dynamic> body) => _c.post('/orders', body);
  static Future cancelOrder(dynamic id) => _c.post('/orders/$id/cancel');

  // ───── Earn ─────
  static Future<List> earnProducts() async => (await _c.get('/earn-products')) as List;
  static Future<List> earnPositions() async {
    try { return (await _c.get('/earn/positions')) as List; } catch (_) { return []; }
  }
  static Future earnSubscribe(Map<String, dynamic> b) => _c.post('/earn/subscribe', b);
  static Future earnRedeem(dynamic id) => _c.post('/earn/positions/$id/redeem');

  // ───── KYC ─────
  static Future kycMy() async {
    try { return await _c.get('/kyc/my'); } catch (_) { return null; }
  }
  static Future kycSettings() async {
    try { return await _c.get('/kyc/settings'); } catch (_) { return null; }
  }
  static Future kycSubmit(Map<String, dynamic> b) => _c.post('/kyc/submit', b);

  // ───── Fees / Refer ─────
  static Future feesMy() async { try { return await _c.get('/fees/my'); } catch (_) { return null; } }
  static Future feesTiers() async { try { return await _c.get('/fees/tiers'); } catch (_) { return []; } }
  static Future referStats() async { try { return await _c.get('/refer/stats'); } catch (_) { return null; } }

  // ───── Security ─────
  static Future enable2FA() => _c.post('/security/2fa/enable');
  static Future disable2FA(String code) => _c.post('/security/2fa/disable', {'code': code});
  static Future revokeSessions() => _c.post('/security/sessions/revoke-others');

  // ───── Transfer ─────
  static Future transfer(Map<String, dynamic> b) => _c.post('/transfer', b);

  // ───── Deposits / Withdrawals ─────
  static Future<List> inrDeposits() async { try { return (await _c.get('/inr-deposits')) as List; } catch (_) { return []; } }
  static Future<List> inrWithdrawals() async { try { return (await _c.get('/inr-withdrawals')) as List; } catch (_) { return []; } }
  static Future<List> cryptoDeposits() async { try { return (await _c.get('/crypto-deposits')) as List; } catch (_) { return []; } }
  static Future<List> cryptoWithdrawals() async { try { return (await _c.get('/crypto-withdrawals')) as List; } catch (_) { return []; } }
  static Future depositAddress(String coin, [String? network]) =>
      _c.get('/deposit-address', query: {'coin': coin, if (network != null) 'network': network});
  static Future inrDepositCreate(Map<String, dynamic> b) => _c.post('/inr-deposits', b);
  static Future inrWithdrawCreate(Map<String, dynamic> b) => _c.post('/inr-withdrawals', b);
  static Future cryptoWithdrawCreate(Map<String, dynamic> b) => _c.post('/crypto-withdrawals', b);

  // ───── Banks ─────
  static Future<List> banks() async { try { return (await _c.get('/banks')) as List; } catch (_) { return []; } }
  static Future addBank(Map<String, dynamic> b) => _c.post('/banks', b);
  static Future deleteBank(dynamic id) => _c.delete('/banks/$id');

  // ───── Networks / Gateways ─────
  static Future<List> networks() async { try { return (await _c.get('/networks')) as List; } catch (_) { return []; } }
  static Future<List> gateways() async { try { return (await _c.get('/gateways')) as List; } catch (_) { return []; } }
}
