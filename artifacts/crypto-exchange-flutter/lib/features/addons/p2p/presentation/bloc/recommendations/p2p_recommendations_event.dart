part of 'p2p_recommendations_bloc.dart';

/// Base event class for P2P recommendations
abstract class P2PRecommendationsEvent extends Equatable {
  const P2PRecommendationsEvent();

  @override
  List<Object?> get props => [];
}

/// Load recommendations event
class P2PRecommendationsLoadRequested extends P2PRecommendationsEvent {
  const P2PRecommendationsLoadRequested({
    this.category,
    this.cryptocurrency,
    this.tradeType,
    this.limit = 20,
  });

  final String? category;
  final String? cryptocurrency;
  final String? tradeType;
  final int limit;

  @override
  List<Object?> get props => [category, cryptocurrency, tradeType, limit];
}

/// Load price alerts event
class P2PRecommendationsLoadPriceAlerts extends P2PRecommendationsEvent {
  const P2PRecommendationsLoadPriceAlerts({
    this.cryptocurrency,
    this.limit = 10,
  });

  final String? cryptocurrency;
  final int limit;

  @override
  List<Object?> get props => [cryptocurrency, limit];
}

/// Load offer suggestions event
class P2PRecommendationsLoadOfferSuggestions extends P2PRecommendationsEvent {
  const P2PRecommendationsLoadOfferSuggestions({
    this.cryptocurrency,
    this.tradeType,
    this.limit = 10,
  });

  final String? cryptocurrency;
  final String? tradeType;
  final int limit;

  @override
  List<Object?> get props => [cryptocurrency, tradeType, limit];
}

/// Load market insights event
class P2PRecommendationsLoadMarketInsights extends P2PRecommendationsEvent {
  const P2PRecommendationsLoadMarketInsights({
    this.cryptocurrency,
    this.limit = 5,
  });

  final String? cryptocurrency;
  final int limit;

  @override
  List<Object?> get props => [cryptocurrency, limit];
}

/// Load trader recommendations event
class P2PRecommendationsLoadTraderRecommendations
    extends P2PRecommendationsEvent {
  const P2PRecommendationsLoadTraderRecommendations({
    this.cryptocurrency,
    this.limit = 5,
  });

  final String? cryptocurrency;
  final int limit;

  @override
  List<Object?> get props => [cryptocurrency, limit];
}

/// Mark recommendation as read event
class P2PRecommendationsMarkAsRead extends P2PRecommendationsEvent {
  const P2PRecommendationsMarkAsRead(this.recommendationId);

  final String recommendationId;

  @override
  List<Object?> get props => [recommendationId];
}

/// Mark all recommendations as read event
class P2PRecommendationsMarkAllAsRead extends P2PRecommendationsEvent {
  const P2PRecommendationsMarkAllAsRead();
}

/// Delete recommendation event
class P2PRecommendationsDelete extends P2PRecommendationsEvent {
  const P2PRecommendationsDelete(this.recommendationId);

  final String recommendationId;

  @override
  List<Object?> get props => [recommendationId];
}

/// Create price alert event
class P2PRecommendationsCreatePriceAlert extends P2PRecommendationsEvent {
  const P2PRecommendationsCreatePriceAlert({
    required this.cryptocurrency,
    required this.targetPrice,
    required this.alertType,
    this.amount,
    this.offerId,
  });

  final String cryptocurrency;
  final double targetPrice;
  final PriceAlertType alertType;
  final double? amount;
  final String? offerId;

  @override
  List<Object?> get props =>
      [cryptocurrency, targetPrice, alertType, amount, offerId];
}

/// Update preferences event
class P2PRecommendationsUpdatePreferences extends P2PRecommendationsEvent {
  const P2PRecommendationsUpdatePreferences(this.preferences);

  final Map<String, dynamic> preferences;

  @override
  List<Object?> get props => [preferences];
}

/// Get unread count event
class P2PRecommendationsGetUnreadCount extends P2PRecommendationsEvent {
  const P2PRecommendationsGetUnreadCount();
}
