part of 'p2p_recommendations_bloc.dart';

/// Base state class for P2P recommendations
abstract class P2PRecommendationsState extends Equatable {
  const P2PRecommendationsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class P2PRecommendationsInitial extends P2PRecommendationsState {
  const P2PRecommendationsInitial();
}

/// Loading state
class P2PRecommendationsLoading extends P2PRecommendationsState {
  const P2PRecommendationsLoading();
}

/// Loaded state for general recommendations
class P2PRecommendationsLoaded extends P2PRecommendationsState {
  const P2PRecommendationsLoaded({
    required this.recommendations,
    this.category,
  });

  final List<P2PRecommendationEntity> recommendations;
  final String? category;

  @override
  List<Object?> get props => [recommendations, category];
}

/// Loaded state for price alerts
class P2PRecommendationsPriceAlertsLoaded extends P2PRecommendationsState {
  const P2PRecommendationsPriceAlertsLoaded({
    required this.priceAlerts,
  });

  final List<P2PRecommendationEntity> priceAlerts;

  @override
  List<Object?> get props => [priceAlerts];
}

/// Loaded state for offer suggestions
class P2PRecommendationsOfferSuggestionsLoaded extends P2PRecommendationsState {
  const P2PRecommendationsOfferSuggestionsLoaded({
    required this.offerSuggestions,
  });

  final List<P2PRecommendationEntity> offerSuggestions;

  @override
  List<Object?> get props => [offerSuggestions];
}

/// Loaded state for market insights
class P2PRecommendationsMarketInsightsLoaded extends P2PRecommendationsState {
  const P2PRecommendationsMarketInsightsLoaded({
    required this.marketInsights,
  });

  final List<P2PRecommendationEntity> marketInsights;

  @override
  List<Object?> get props => [marketInsights];
}

/// Loaded state for trader recommendations
class P2PRecommendationsTraderRecommendationsLoaded
    extends P2PRecommendationsState {
  const P2PRecommendationsTraderRecommendationsLoaded({
    required this.traderRecommendations,
  });

  final List<P2PRecommendationEntity> traderRecommendations;

  @override
  List<Object?> get props => [traderRecommendations];
}

/// Price alert created state
class P2PRecommendationsPriceAlertCreated extends P2PRecommendationsState {
  const P2PRecommendationsPriceAlertCreated({
    required this.priceAlert,
  });

  final P2PRecommendationEntity priceAlert;

  @override
  List<Object?> get props => [priceAlert];
}

/// Marked as read state
class P2PRecommendationsMarkedAsRead extends P2PRecommendationsState {
  const P2PRecommendationsMarkedAsRead();
}

/// All marked as read state
class P2PRecommendationsAllMarkedAsRead extends P2PRecommendationsState {
  const P2PRecommendationsAllMarkedAsRead();
}

/// Deleted state
class P2PRecommendationsDeleted extends P2PRecommendationsState {
  const P2PRecommendationsDeleted();
}

/// Preferences updated state
class P2PRecommendationsPreferencesUpdated extends P2PRecommendationsState {
  const P2PRecommendationsPreferencesUpdated();
}

/// Unread count loaded state
class P2PRecommendationsUnreadCountLoaded extends P2PRecommendationsState {
  const P2PRecommendationsUnreadCountLoaded({
    required this.count,
  });

  final int count;

  @override
  List<Object?> get props => [count];
}

/// Error state
class P2PRecommendationsError extends P2PRecommendationsState {
  const P2PRecommendationsError({
    required this.failure,
  });

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
