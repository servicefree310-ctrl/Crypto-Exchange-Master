import 'package:dartz/dartz.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../entities/p2p_recommendation_entity.dart';

/// Repository interface for P2P smart recommendations
abstract class P2PRecommendationRepository {
  /// Get personalized recommendations for user
  Future<Either<Failure, List<P2PRecommendationEntity>>> getRecommendations({
    String? category,
    int limit = 20,
  });

  /// Get price alerts for user
  Future<Either<Failure, List<P2PRecommendationEntity>>> getPriceAlerts({
    String? cryptocurrency,
    int limit = 10,
  });

  /// Get offer suggestions based on user preferences
  Future<Either<Failure, List<P2PRecommendationEntity>>> getOfferSuggestions({
    String? cryptocurrency,
    String? tradeType,
    int limit = 10,
  });

  /// Get market insights and trends
  Future<Either<Failure, List<P2PRecommendationEntity>>> getMarketInsights({
    String? cryptocurrency,
    int limit = 5,
  });

  /// Get trader recommendations
  Future<Either<Failure, List<P2PRecommendationEntity>>>
      getTraderRecommendations({
    String? cryptocurrency,
    int limit = 5,
  });

  /// Mark recommendation as read
  Future<Either<Failure, void>> markAsRead(String recommendationId);

  /// Mark all recommendations as read
  Future<Either<Failure, void>> markAllAsRead();

  /// Delete recommendation
  Future<Either<Failure, void>> deleteRecommendation(String recommendationId);

  /// Get unread recommendations count
  Future<Either<Failure, int>> getUnreadCount();

  /// Create price alert
  Future<Either<Failure, P2PRecommendationEntity>> createPriceAlert({
    required String cryptocurrency,
    required double targetPrice,
    required PriceAlertType alertType,
  });

  /// Update recommendation preferences
  Future<Either<Failure, void>> updatePreferences({
    required Map<String, dynamic> preferences,
  });

  /// Get recommendation preferences
  Future<Either<Failure, Map<String, dynamic>>> getPreferences();

  /// Stream of real-time recommendations
  Stream<List<P2PRecommendationEntity>> watchRecommendations();

  /// Stream of price alerts
  Stream<List<P2PRecommendationEntity>> watchPriceAlerts();
}
