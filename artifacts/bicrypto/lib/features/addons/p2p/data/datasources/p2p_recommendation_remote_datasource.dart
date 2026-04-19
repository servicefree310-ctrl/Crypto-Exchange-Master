import 'package:injectable/injectable.dart';
import '../../../../../../../core/network/dio_client.dart';
import '../../../../../../../core/constants/api_constants.dart';
import '../models/p2p_recommendation_model.dart';

/// Remote data source for P2P recommendations
@injectable
class P2PRecommendationRemoteDataSource {
  const P2PRecommendationRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// Get recommendations from API
  Future<List<P2PRecommendationModel>> getRecommendations({
    String? category,
    String? cryptocurrency,
    String? tradeType,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      if (category != null) 'category': category,
      if (cryptocurrency != null) 'cryptocurrency': cryptocurrency,
      if (tradeType != null) 'tradeType': tradeType,
      'limit': limit,
    };

    final response = await _dioClient.get(
      '${ApiConstants.p2pOffers}/recommendations',
      queryParameters: queryParams,
    );

    return (response.data['data'] as List)
        .map((json) => P2PRecommendationModel.fromJson(json))
        .toList();
  }

  /// Get price alerts
  Future<List<P2PRecommendationModel>> getPriceAlerts({
    String? cryptocurrency,
    int limit = 10,
  }) async {
    final queryParams = <String, dynamic>{
      if (cryptocurrency != null) 'cryptocurrency': cryptocurrency,
      'limit': limit,
    };

    final response = await _dioClient.get(
      '${ApiConstants.p2pOffers}/recommendations/price-alerts',
      queryParameters: queryParams,
    );

    return (response.data['data'] as List)
        .map((json) => P2PRecommendationModel.fromJson(json))
        .toList();
  }

  /// Get offer suggestions
  Future<List<P2PRecommendationModel>> getOfferSuggestions({
    String? cryptocurrency,
    String? tradeType,
    int limit = 10,
  }) async {
    final queryParams = <String, dynamic>{
      if (cryptocurrency != null) 'cryptocurrency': cryptocurrency,
      if (tradeType != null) 'tradeType': tradeType,
      'limit': limit,
    };

    final response = await _dioClient.get(
      '${ApiConstants.p2pOffers}/recommendations/offer-suggestions',
      queryParameters: queryParams,
    );

    return (response.data['data'] as List)
        .map((json) => P2PRecommendationModel.fromJson(json))
        .toList();
  }

  /// Get market insights
  Future<List<P2PRecommendationModel>> getMarketInsights({
    String? cryptocurrency,
    int limit = 5,
  }) async {
    final queryParams = <String, dynamic>{
      if (cryptocurrency != null) 'cryptocurrency': cryptocurrency,
      'limit': limit,
    };

    final response = await _dioClient.get(
      '${ApiConstants.p2pOffers}/recommendations/market-insights',
      queryParameters: queryParams,
    );

    return (response.data['data'] as List)
        .map((json) => P2PRecommendationModel.fromJson(json))
        .toList();
  }

  /// Get trader recommendations
  Future<List<P2PRecommendationModel>> getTraderRecommendations({
    String? cryptocurrency,
    int limit = 5,
  }) async {
    final queryParams = <String, dynamic>{
      if (cryptocurrency != null) 'cryptocurrency': cryptocurrency,
      'limit': limit,
    };

    final response = await _dioClient.get(
      '${ApiConstants.p2pOffers}/recommendations/trader-recommendations',
      queryParameters: queryParams,
    );

    return (response.data['data'] as List)
        .map((json) => P2PRecommendationModel.fromJson(json))
        .toList();
  }

  /// Mark recommendation as read
  Future<void> markAsRead(String recommendationId) async {
    await _dioClient.post(
      '${ApiConstants.p2pOffers}/recommendations/$recommendationId/read',
    );
  }

  /// Mark all recommendations as read
  Future<void> markAllAsRead() async {
    await _dioClient.post(
      '${ApiConstants.p2pOffers}/recommendations/read-all',
    );
  }

  /// Delete recommendation
  Future<void> deleteRecommendation(String recommendationId) async {
    await _dioClient.delete(
      '${ApiConstants.p2pOffers}/recommendations/$recommendationId',
    );
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    final response = await _dioClient.get(
      '${ApiConstants.p2pOffers}/recommendations/unread-count',
    );

    return response.data['count'] as int;
  }

  /// Create price alert
  Future<P2PRecommendationModel> createPriceAlert({
    required String cryptocurrency,
    required double targetPrice,
    required String alertType,
  }) async {
    final response = await _dioClient.post(
      '${ApiConstants.p2pOffers}/recommendations/price-alerts',
      data: {
        'cryptocurrency': cryptocurrency,
        'targetPrice': targetPrice,
        'alertType': alertType,
      },
    );

    return P2PRecommendationModel.fromJson(response.data['data']);
  }

  /// Update recommendation preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    await _dioClient.put(
      '${ApiConstants.p2pOffers}/recommendations/preferences',
      data: preferences,
    );
  }

  /// Get recommendation preferences
  Future<Map<String, dynamic>> getPreferences() async {
    final response = await _dioClient.get(
      '${ApiConstants.p2pOffers}/recommendations/preferences',
    );

    return response.data['data'] as Map<String, dynamic>;
  }
}
