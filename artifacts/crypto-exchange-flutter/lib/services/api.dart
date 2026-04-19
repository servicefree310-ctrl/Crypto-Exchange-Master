import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // In production, replace with your deployed API origin
  // For dev: same Replit dev domain hosts api at /api/*
  static String baseUrl = _detectBase();

  static String _detectBase() {
    // For Flutter web, use current origin (dev domain hosts /api proxy)
    return '/api';
  }

  static Future<List<dynamic>> getCoins() async {
    final r = await http.get(Uri.parse('$baseUrl/coins'));
    if (r.statusCode != 200) throw Exception('coins ${r.statusCode}');
    return jsonDecode(r.body) as List<dynamic>;
  }

  static Future<List<dynamic>> getPairs() async {
    final r = await http.get(Uri.parse('$baseUrl/pairs'));
    if (r.statusCode != 200) throw Exception('pairs ${r.statusCode}');
    return jsonDecode(r.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getPrices() async {
    final r = await http.get(Uri.parse('$baseUrl/prices'));
    if (r.statusCode != 200) throw Exception('prices ${r.statusCode}');
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
}
