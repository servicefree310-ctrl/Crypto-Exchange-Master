import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/errors/exceptions.dart';

abstract class P2PLocalDataSource {
  // Cache management
  Future<void> cacheOffers(String key, List<Map<String, dynamic>> offers);
  Future<List<Map<String, dynamic>>?> getCachedOffers(String key);
  Future<void> clearOffersCache();

  Future<void> cachePaymentMethods(List<Map<String, dynamic>> methods);
  Future<List<Map<String, dynamic>>?> getCachedPaymentMethods();

  Future<void> cacheMarketStats(Map<String, dynamic> stats);
  Future<Map<String, dynamic>?> getCachedMarketStats();

  // Trades caching
  Future<void> cacheTrade(dynamic trade);
  Future<void> clearTradesListCache();
  Future<void> cacheTradesList(Map<String, dynamic> trades);
  Future<Map<String, dynamic>?> getCachedTradesList();
  Future<dynamic> getCachedTrade(String id);

  // Dashboard caching
  Future<void> cacheDashboardData(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getCachedDashboardData();

  // Reviews caching
  Future<void> cacheReviews(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getCachedReviews();

  // Payment methods cache management
  Future<void> clearPaymentMethodsCache();

  // User preferences
  Future<void> saveOfferFilters(Map<String, dynamic> filters);
  Future<Map<String, dynamic>?> getOfferFilters();

  Future<void> saveTradingPreferences(Map<String, dynamic> preferences);
  Future<Map<String, dynamic>?> getTradingPreferences();

  Future<void> saveRecentSearches(List<String> searches);
  Future<List<String>?> getRecentSearches();

  // Cache metadata
  Future<void> setCacheTimestamp(String key, DateTime timestamp);
  Future<DateTime?> getCacheTimestamp(String key);
  Future<bool> isCacheValid(String key, Duration maxAge);
}

@Injectable(as: P2PLocalDataSource)
class P2PLocalDataSourceImpl implements P2PLocalDataSource {
  final SharedPreferences _prefs;

  P2PLocalDataSourceImpl(this._prefs);

  // Cache keys
  static const String _offersPrefix = 'p2p_offers_';
  static const String _paymentMethodsKey = 'p2p_payment_methods';
  static const String _marketStatsKey = 'p2p_market_stats';
  static const String _dashboardKey = 'p2p_dashboard';
  static const String _reviewsKey = 'p2p_reviews';
  static const String _offerFiltersKey = 'p2p_offer_filters';
  static const String _tradingPreferencesKey = 'p2p_trading_preferences';
  static const String _recentSearchesKey = 'p2p_recent_searches';
  static const String _timestampPrefix = 'p2p_timestamp_';

  @override
  Future<void> cacheOffers(
      String key, List<Map<String, dynamic>> offers) async {
    try {
      final cacheKey = '$_offersPrefix$key';
      final jsonString = jsonEncode(offers);
      await _prefs.setString(cacheKey, jsonString);
      await setCacheTimestamp(cacheKey, DateTime.now());
    } catch (e) {
      throw CacheException('Failed to cache offers: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>?> getCachedOffers(String key) async {
    try {
      final cacheKey = '$_offersPrefix$key';
      final jsonString = _prefs.getString(cacheKey);

      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      throw CacheException('Failed to get cached offers: $e');
    }
  }

  @override
  Future<void> clearOffersCache() async {
    try {
      final keys = _prefs
          .getKeys()
          .where((key) => key.startsWith(_offersPrefix))
          .toList();

      for (final key in keys) {
        await _prefs.remove(key);
        await _prefs.remove('$_timestampPrefix$key');
      }
    } catch (e) {
      throw CacheException('Failed to clear offers cache: $e');
    }
  }

  @override
  Future<void> cachePaymentMethods(List<Map<String, dynamic>> methods) async {
    try {
      final jsonString = jsonEncode(methods);
      await _prefs.setString(_paymentMethodsKey, jsonString);
      await setCacheTimestamp(_paymentMethodsKey, DateTime.now());
    } catch (e) {
      throw CacheException('Failed to cache payment methods: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>?> getCachedPaymentMethods() async {
    try {
      final jsonString = _prefs.getString(_paymentMethodsKey);

      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      throw CacheException('Failed to get cached payment methods: $e');
    }
  }

  // Market Stats Caching
  @override
  Future<void> cacheMarketStats(dynamic stats) async {
    try {
      final jsonString = jsonEncode(stats);
      await _prefs.setString(_marketStatsKey, jsonString);
      await setCacheTimestamp(_marketStatsKey, DateTime.now());
    } catch (e) {
      throw CacheException('Failed to cache market stats: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedMarketStats() async {
    try {
      final jsonString = _prefs.getString(_marketStatsKey);

      if (jsonString == null) return null;

      return jsonDecode(jsonString);
    } catch (e) {
      throw CacheException('Failed to get cached market stats: $e');
    }
  }

  // Trades List Caching
  @override
  Future<void> cacheTradesList(Map<String, dynamic> trades) async {
    try {
      final jsonString = jsonEncode(trades);
      await _prefs.setString('trades_list', jsonString);
      await setCacheTimestamp('trades_list', DateTime.now());
    } catch (e) {
      throw CacheException('Failed to cache trades list: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedTradesList() async {
    try {
      final jsonString = _prefs.getString('trades_list');

      if (jsonString == null) return null;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException('Failed to get cached trades list: $e');
    }
  }

  @override
  Future<void> clearTradesListCache() async {
    try {
      await _prefs.remove('trades_list');
      await _prefs.remove('${_timestampPrefix}trades_list');
    } catch (e) {
      throw CacheException('Failed to clear trades list cache: $e');
    }
  }

  // Individual Trade Caching
  @override
  Future<void> cacheTrade(dynamic trade) async {
    try {
      final tradeId = trade.id ?? 'unknown';
      final jsonString = jsonEncode(trade);
      await _prefs.setString('trade_$tradeId', jsonString);
      await setCacheTimestamp('trade_$tradeId', DateTime.now());
    } catch (e) {
      throw CacheException('Failed to cache trade: $e');
    }
  }

  @override
  Future<dynamic> getCachedTrade(String id) async {
    try {
      final jsonString = _prefs.getString('trade_$id');

      if (jsonString == null) return null;

      return jsonDecode(jsonString);
    } catch (e) {
      throw CacheException('Failed to get cached trade: $e');
    }
  }

  // Top Markets Caching
  Future<void> cacheTopMarkets(List<Map<String, dynamic>> markets) async {
    try {
      final jsonString = jsonEncode(markets);
      await _prefs.setString('top_markets', jsonString);
      await setCacheTimestamp('top_markets', DateTime.now());
    } catch (e) {
      throw CacheException('Failed to cache top markets: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> getCachedTopMarkets() async {
    try {
      final jsonString = _prefs.getString('top_markets');

      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      throw CacheException('Failed to get cached top markets: $e');
    }
  }

  // Market Highlights Caching
  Future<void> cacheMarketHighlights(
      List<Map<String, dynamic>> highlights) async {
    try {
      final jsonString = jsonEncode(highlights);
      await _prefs.setString('market_highlights', jsonString);
      await setCacheTimestamp('market_highlights', DateTime.now());
    } catch (e) {
      throw CacheException('Failed to cache market highlights: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> getCachedMarketHighlights() async {
    try {
      final jsonString = _prefs.getString('market_highlights');

      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      throw CacheException('Failed to get cached market highlights: $e');
    }
  }

  @override
  Future<void> saveOfferFilters(Map<String, dynamic> filters) async {
    try {
      final jsonString = jsonEncode(filters);
      await _prefs.setString(_offerFiltersKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to save offer filters: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getOfferFilters() async {
    try {
      final jsonString = _prefs.getString(_offerFiltersKey);

      if (jsonString == null) return null;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException('Failed to get offer filters: $e');
    }
  }

  @override
  Future<void> saveTradingPreferences(Map<String, dynamic> preferences) async {
    try {
      final jsonString = jsonEncode(preferences);
      await _prefs.setString(_tradingPreferencesKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to save trading preferences: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getTradingPreferences() async {
    try {
      final jsonString = _prefs.getString(_tradingPreferencesKey);

      if (jsonString == null) return null;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException('Failed to get trading preferences: $e');
    }
  }

  @override
  Future<void> saveRecentSearches(List<String> searches) async {
    try {
      final jsonString = jsonEncode(searches);
      await _prefs.setString(_recentSearchesKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to save recent searches: $e');
    }
  }

  @override
  Future<List<String>?> getRecentSearches() async {
    try {
      final jsonString = _prefs.getString(_recentSearchesKey);

      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.cast<String>();
    } catch (e) {
      throw CacheException('Failed to get recent searches: $e');
    }
  }

  @override
  Future<void> setCacheTimestamp(String key, DateTime timestamp) async {
    try {
      await _prefs.setInt(
          '$_timestampPrefix$key', timestamp.millisecondsSinceEpoch);
    } catch (e) {
      throw CacheException('Failed to set cache timestamp: $e');
    }
  }

  @override
  Future<DateTime?> getCacheTimestamp(String key) async {
    try {
      final timestamp = _prefs.getInt('$_timestampPrefix$key');

      if (timestamp == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      throw CacheException('Failed to get cache timestamp: $e');
    }
  }

  @override
  Future<bool> isCacheValid(String key, Duration maxAge) async {
    try {
      final timestamp = await getCacheTimestamp(key);

      if (timestamp == null) return false;

      final now = DateTime.now();
      final difference = now.difference(timestamp);

      return difference <= maxAge;
    } catch (e) {
      return false; // Consider cache invalid if we can't determine validity
    }
  }

  // Dashboard Caching
  @override
  Future<void> cacheDashboardData(Map<String, dynamic> data) async {
    try {
      final jsonString = jsonEncode(data);
      await _prefs.setString(_dashboardKey, jsonString);
      await setCacheTimestamp(_dashboardKey, DateTime.now());
    } catch (e) {
      throw CacheException('Failed to cache dashboard data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedDashboardData() async {
    try {
      final jsonString = _prefs.getString(_dashboardKey);

      if (jsonString == null) return null;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException('Failed to get cached dashboard data: $e');
    }
  }

  // Reviews Caching
  @override
  Future<void> cacheReviews(Map<String, dynamic> data) async {
    try {
      final jsonString = jsonEncode(data);
      await _prefs.setString(_reviewsKey, jsonString);
      await setCacheTimestamp(_reviewsKey, DateTime.now());
    } catch (e) {
      throw CacheException('Failed to cache reviews: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedReviews() async {
    try {
      final jsonString = _prefs.getString(_reviewsKey);

      if (jsonString == null) return null;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException('Failed to get cached reviews: $e');
    }
  }

  // Payment Methods Cache Management
  @override
  Future<void> clearPaymentMethodsCache() async {
    try {
      await _prefs.remove(_paymentMethodsKey);
      await _prefs.remove('$_timestampPrefix$_paymentMethodsKey');
    } catch (e) {
      throw CacheException('Failed to clear payment methods cache: $e');
    }
  }
}
