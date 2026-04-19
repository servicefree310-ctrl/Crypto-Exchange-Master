import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/p2p_recommendation_model.dart';

/// Local data source for P2P recommendations
@injectable
class P2PRecommendationLocalDataSource {
  const P2PRecommendationLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  // Storage keys
  static const String _recommendationsKey = 'p2p_recommendations';
  static const String _priceAlertsKey = 'p2p_price_alerts';
  static const String _offerSuggestionsKey = 'p2p_offer_suggestions';
  static const String _marketInsightsKey = 'p2p_market_insights';
  static const String _traderRecommendationsKey = 'p2p_trader_recommendations';
  static const String _preferencesKey = 'p2p_recommendation_preferences';
  static const String _unreadCountKey = 'p2p_unread_count';

  /// Cache recommendations
  Future<void> cacheRecommendations(
      List<P2PRecommendationModel> recommendations) async {
    final jsonList = recommendations.map((r) => r.toJson()).toList();
    await _preferences.setString(_recommendationsKey, jsonEncode(jsonList));
  }

  /// Get cached recommendations
  Future<List<P2PRecommendationModel>> getCachedRecommendations() async {
    final jsonString = _preferences.getString(_recommendationsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => P2PRecommendationModel.fromJson(json))
        .toList();
  }

  /// Cache price alerts
  Future<void> cachePriceAlerts(List<P2PRecommendationModel> alerts) async {
    final jsonList = alerts.map((a) => a.toJson()).toList();
    await _preferences.setString(_priceAlertsKey, jsonEncode(jsonList));
  }

  /// Get cached price alerts
  Future<List<P2PRecommendationModel>> getCachedPriceAlerts() async {
    final jsonString = _preferences.getString(_priceAlertsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => P2PRecommendationModel.fromJson(json))
        .toList();
  }

  /// Cache offer suggestions
  Future<void> cacheOfferSuggestions(
      List<P2PRecommendationModel> suggestions) async {
    final jsonList = suggestions.map((s) => s.toJson()).toList();
    await _preferences.setString(_offerSuggestionsKey, jsonEncode(jsonList));
  }

  /// Get cached offer suggestions
  Future<List<P2PRecommendationModel>> getCachedOfferSuggestions() async {
    final jsonString = _preferences.getString(_offerSuggestionsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => P2PRecommendationModel.fromJson(json))
        .toList();
  }

  /// Cache market insights
  Future<void> cacheMarketInsights(
      List<P2PRecommendationModel> insights) async {
    final jsonList = insights.map((i) => i.toJson()).toList();
    await _preferences.setString(_marketInsightsKey, jsonEncode(jsonList));
  }

  /// Get cached market insights
  Future<List<P2PRecommendationModel>> getCachedMarketInsights() async {
    final jsonString = _preferences.getString(_marketInsightsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => P2PRecommendationModel.fromJson(json))
        .toList();
  }

  /// Cache trader recommendations
  Future<void> cacheTraderRecommendations(
      List<P2PRecommendationModel> recommendations) async {
    final jsonList = recommendations.map((r) => r.toJson()).toList();
    await _preferences.setString(
        _traderRecommendationsKey, jsonEncode(jsonList));
  }

  /// Get cached trader recommendations
  Future<List<P2PRecommendationModel>> getCachedTraderRecommendations() async {
    final jsonString = _preferences.getString(_traderRecommendationsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => P2PRecommendationModel.fromJson(json))
        .toList();
  }

  /// Cache recommendation preferences
  Future<void> cachePreferences(Map<String, dynamic> preferences) async {
    await _preferences.setString(_preferencesKey, jsonEncode(preferences));
  }

  /// Get cached preferences
  Future<Map<String, dynamic>> getCachedPreferences() async {
    final jsonString = _preferences.getString(_preferencesKey);
    if (jsonString == null) return {};

    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Cache unread count
  Future<void> cacheUnreadCount(int count) async {
    await _preferences.setInt(_unreadCountKey, count);
  }

  /// Get cached unread count
  Future<int> getCachedUnreadCount() async {
    return _preferences.getInt(_unreadCountKey) ?? 0;
  }

  /// Mark recommendation as read locally
  Future<void> markAsRead(String recommendationId) async {
    final recommendations = await getCachedRecommendations();
    final updatedRecommendations = recommendations.map((r) {
      if (r.id == recommendationId) {
        return r.copyWith(isRead: true);
      }
      return r;
    }).toList();

    await cacheRecommendations(updatedRecommendations);
    await _updateUnreadCount();
  }

  /// Mark all recommendations as read locally
  Future<void> markAllAsRead() async {
    final recommendations = await getCachedRecommendations();
    final updatedRecommendations =
        recommendations.map((r) => r.copyWith(isRead: true)).toList();

    await cacheRecommendations(updatedRecommendations);
    await cacheUnreadCount(0);
  }

  /// Delete recommendation locally
  Future<void> deleteRecommendation(String recommendationId) async {
    final recommendations = await getCachedRecommendations();
    final updatedRecommendations =
        recommendations.where((r) => r.id != recommendationId).toList();

    await cacheRecommendations(updatedRecommendations);
    await _updateUnreadCount();
  }

  /// Update unread count based on cached recommendations
  Future<void> _updateUnreadCount() async {
    final recommendations = await getCachedRecommendations();
    final unreadCount = recommendations.where((r) => !r.isRead).length;
    await cacheUnreadCount(unreadCount);
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _preferences.remove(_recommendationsKey);
    await _preferences.remove(_priceAlertsKey);
    await _preferences.remove(_offerSuggestionsKey);
    await _preferences.remove(_marketInsightsKey);
    await _preferences.remove(_traderRecommendationsKey);
    await _preferences.remove(_unreadCountKey);
  }
}
