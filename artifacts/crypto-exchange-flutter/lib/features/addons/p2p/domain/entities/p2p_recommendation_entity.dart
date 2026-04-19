import 'package:equatable/equatable.dart';

/// P2P Recommendation Entity
///
/// Represents smart recommendations for P2P trading including:
/// - Personalized offer suggestions
/// - Price optimization alerts
/// - Best match notifications
class P2PRecommendationEntity extends Equatable {
  const P2PRecommendationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.data,
    required this.isRead,
    required this.createdAt,
    required this.expiresAt,
  });

  /// Unique identifier
  final String id;

  /// Recommendation type
  final RecommendationType type;

  /// Recommendation title
  final String title;

  /// Detailed description
  final String description;

  /// Priority level (high, medium, low)
  final RecommendationPriority priority;

  /// Category of recommendation
  final RecommendationCategory category;

  /// Recommendation-specific data
  final Map<String, dynamic> data;

  /// Whether user has read this recommendation
  final bool isRead;

  /// When recommendation was created
  final DateTime createdAt;

  /// When recommendation expires (null if no expiration)
  final DateTime? expiresAt;

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        priority,
        category,
        data,
        isRead,
        createdAt,
        expiresAt,
      ];

  P2PRecommendationEntity copyWith({
    String? id,
    RecommendationType? type,
    String? title,
    String? description,
    RecommendationPriority? priority,
    RecommendationCategory? category,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return P2PRecommendationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

/// Recommendation types
enum RecommendationType {
  offerSuggestion,
  priceAlert,
  matchNotification,
  marketInsight,
  traderRecommendation,
  paymentMethodSuggestion,
}

/// Recommendation priority levels
enum RecommendationPriority {
  high,
  medium,
  low,
}

/// Recommendation categories
enum RecommendationCategory {
  trading,
  market,
  security,
  optimization,
  social,
}

/// Price Alert Data
class PriceAlertData {
  const PriceAlertData({
    required this.cryptocurrency,
    required this.targetPrice,
    required this.currentPrice,
    required this.alertType,
    required this.percentageChange,
    this.offerId,
  });

  final String cryptocurrency;
  final double targetPrice;
  final double currentPrice;
  final PriceAlertType alertType;
  final double percentageChange;
  final String? offerId;
}

/// Price alert types
enum PriceAlertType {
  priceDrop,
  priceRise,
  targetReached,
  marketOpportunity,
}

/// Offer Suggestion Data
class OfferSuggestionData {
  const OfferSuggestionData({
    required this.offerId,
    required this.cryptocurrency,
    required this.tradeType,
    required this.price,
    required this.estimatedSavings,
    required this.matchScore,
    required this.traderRating,
    required this.reason,
  });

  final String offerId;
  final String cryptocurrency;
  final String tradeType;
  final double price;
  final double estimatedSavings;
  final int matchScore;
  final double traderRating;
  final String reason;
}

/// Match Notification Data
class MatchNotificationData {
  const MatchNotificationData({
    required this.offerId,
    required this.cryptocurrency,
    required this.tradeType,
    required this.price,
    required this.matchScore,
    required this.traderName,
    required this.responseTime,
    required this.paymentMethods,
  });

  final String offerId;
  final String cryptocurrency;
  final String tradeType;
  final double price;
  final int matchScore;
  final String traderName;
  final int responseTime;
  final List<String> paymentMethods;
}

/// Market Insight Data
class MarketInsightData {
  const MarketInsightData({
    required this.cryptocurrency,
    required this.insightType,
    required this.description,
    required this.confidence,
    required this.timeframe,
  });

  final String cryptocurrency;
  final MarketInsightType insightType;
  final String description;
  final double confidence; // 0-1
  final String timeframe;
}

/// Market insight types
enum MarketInsightType {
  volumeSpike,
  priceTrend,
  liquidityChange,
  marketSentiment,
  volatilityAlert,
}

/// Trader Recommendation Data
class TraderRecommendationData {
  const TraderRecommendationData({
    required this.traderId,
    required this.traderName,
    required this.completionRate,
    required this.avgRating,
    required this.completedTrades,
    required this.responseTime,
    required this.reason,
  });

  final String traderId;
  final String traderName;
  final int completionRate;
  final double avgRating;
  final int completedTrades;
  final int responseTime;
  final String reason;
}
