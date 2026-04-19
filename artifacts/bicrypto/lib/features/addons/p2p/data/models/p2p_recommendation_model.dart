import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/p2p_recommendation_entity.dart';

part 'p2p_recommendation_model.freezed.dart';
part 'p2p_recommendation_model.g.dart';

/// P2P Recommendation Data Model
@freezed
class P2PRecommendationModel with _$P2PRecommendationModel {
  const factory P2PRecommendationModel({
    required String id,
    required String type,
    required String title,
    required String description,
    required String priority,
    required String category,
    required Map<String, dynamic> data,
    required bool isRead,
    required DateTime createdAt,
    DateTime? expiresAt,
  }) = _P2PRecommendationModel;

  factory P2PRecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$P2PRecommendationModelFromJson(json);
}

/// Extension to convert model to entity
extension P2PRecommendationModelX on P2PRecommendationModel {
  P2PRecommendationEntity toEntity() {
    return P2PRecommendationEntity(
      id: id,
      type: _parseRecommendationType(type),
      title: title,
      description: description,
      priority: _parseRecommendationPriority(priority),
      category: _parseRecommendationCategory(category),
      data: data,
      isRead: isRead,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  RecommendationType _parseRecommendationType(String type) {
    switch (type.toLowerCase()) {
      case 'offer_suggestion':
        return RecommendationType.offerSuggestion;
      case 'price_alert':
        return RecommendationType.priceAlert;
      case 'match_notification':
        return RecommendationType.matchNotification;
      case 'market_insight':
        return RecommendationType.marketInsight;
      case 'trader_recommendation':
        return RecommendationType.traderRecommendation;
      case 'payment_method_suggestion':
        return RecommendationType.paymentMethodSuggestion;
      default:
        return RecommendationType.offerSuggestion;
    }
  }

  RecommendationPriority _parseRecommendationPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return RecommendationPriority.high;
      case 'medium':
        return RecommendationPriority.medium;
      case 'low':
        return RecommendationPriority.low;
      default:
        return RecommendationPriority.medium;
    }
  }

  RecommendationCategory _parseRecommendationCategory(String category) {
    switch (category.toLowerCase()) {
      case 'trading':
        return RecommendationCategory.trading;
      case 'market':
        return RecommendationCategory.market;
      case 'security':
        return RecommendationCategory.security;
      case 'optimization':
        return RecommendationCategory.optimization;
      case 'social':
        return RecommendationCategory.social;
      default:
        return RecommendationCategory.trading;
    }
  }
}

/// Extension to convert entity to model
extension P2PRecommendationEntityX on P2PRecommendationEntity {
  P2PRecommendationModel toModel() {
    return P2PRecommendationModel(
      id: id,
      type: _typeToString(type),
      title: title,
      description: description,
      priority: _priorityToString(priority),
      category: _categoryToString(category),
      data: data,
      isRead: isRead,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  String _typeToString(RecommendationType type) {
    switch (type) {
      case RecommendationType.offerSuggestion:
        return 'offer_suggestion';
      case RecommendationType.priceAlert:
        return 'price_alert';
      case RecommendationType.matchNotification:
        return 'match_notification';
      case RecommendationType.marketInsight:
        return 'market_insight';
      case RecommendationType.traderRecommendation:
        return 'trader_recommendation';
      case RecommendationType.paymentMethodSuggestion:
        return 'payment_method_suggestion';
    }
  }

  String _priorityToString(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.high:
        return 'high';
      case RecommendationPriority.medium:
        return 'medium';
      case RecommendationPriority.low:
        return 'low';
    }
  }

  String _categoryToString(RecommendationCategory category) {
    switch (category) {
      case RecommendationCategory.trading:
        return 'trading';
      case RecommendationCategory.market:
        return 'market';
      case RecommendationCategory.security:
        return 'security';
      case RecommendationCategory.optimization:
        return 'optimization';
      case RecommendationCategory.social:
        return 'social';
    }
  }
}
