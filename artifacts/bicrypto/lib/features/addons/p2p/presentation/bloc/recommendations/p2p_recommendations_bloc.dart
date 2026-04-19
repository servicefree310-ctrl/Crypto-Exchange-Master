import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../../core/errors/failures.dart';
import '../../../domain/entities/p2p_recommendation_entity.dart';
import '../../../domain/usecases/recommendations/get_recommendations_usecase.dart';
import '../../../domain/usecases/recommendations/create_price_alert_usecase.dart';
import '../../../domain/usecases/recommendations/manage_recommendations_usecase.dart';

part 'p2p_recommendations_event.dart';
part 'p2p_recommendations_state.dart';

/// BLoC for P2P smart recommendations
///
/// Handles:
/// - Personalized offer suggestions
/// - Price optimization alerts
/// - Best match notifications
/// - Market insights
/// - Trader recommendations
@injectable
class P2PRecommendationsBloc
    extends Bloc<P2PRecommendationsEvent, P2PRecommendationsState> {
  P2PRecommendationsBloc(
    this._getRecommendationsUseCase,
    this._createPriceAlertUseCase,
    this._manageRecommendationsUseCase,
  ) : super(const P2PRecommendationsInitial()) {
    on<P2PRecommendationsLoadRequested>(_onLoadRequested);
    on<P2PRecommendationsLoadPriceAlerts>(_onLoadPriceAlerts);
    on<P2PRecommendationsLoadOfferSuggestions>(_onLoadOfferSuggestions);
    on<P2PRecommendationsLoadMarketInsights>(_onLoadMarketInsights);
    on<P2PRecommendationsLoadTraderRecommendations>(
        _onLoadTraderRecommendations);
    on<P2PRecommendationsMarkAsRead>(_onMarkAsRead);
    on<P2PRecommendationsMarkAllAsRead>(_onMarkAllAsRead);
    on<P2PRecommendationsDelete>(_onDelete);
    on<P2PRecommendationsCreatePriceAlert>(_onCreatePriceAlert);
    on<P2PRecommendationsUpdatePreferences>(_onUpdatePreferences);
    on<P2PRecommendationsGetUnreadCount>(_onGetUnreadCount);
  }

  final GetRecommendationsUseCase _getRecommendationsUseCase;
  final CreatePriceAlertUseCase _createPriceAlertUseCase;
  final ManageRecommendationsUseCase _manageRecommendationsUseCase;

  Future<void> _onLoadRequested(
    P2PRecommendationsLoadRequested event,
    Emitter<P2PRecommendationsState> emit,
  ) async {
    emit(const P2PRecommendationsLoading());

    final result = await _getRecommendationsUseCase(
      GetRecommendationsParams(
        category: event.category,
        cryptocurrency: event.cryptocurrency,
        tradeType: event.tradeType,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(P2PRecommendationsError(failure: failure)),
      (recommendations) => emit(P2PRecommendationsLoaded(
        recommendations: recommendations,
        category: event.category,
      )),
    );
  }

  Future<void> _onLoadPriceAlerts(
    P2PRecommendationsLoadPriceAlerts event,
    Emitter<P2PRecommendationsState> emit,
  ) async {
    emit(const P2PRecommendationsLoading());

    final result = await _getRecommendationsUseCase(
      GetRecommendationsParams(
        category: 'price_alerts',
        cryptocurrency: event.cryptocurrency,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(P2PRecommendationsError(failure: failure)),
      (recommendations) => emit(P2PRecommendationsPriceAlertsLoaded(
        priceAlerts: recommendations,
      )),
    );
  }

  Future<void> _onLoadOfferSuggestions(
    P2PRecommendationsLoadOfferSuggestions event,
    Emitter<P2PRecommendationsState> emit,
  ) async {
    emit(const P2PRecommendationsLoading());

    final result = await _getRecommendationsUseCase(
      GetRecommendationsParams(
        category: 'offer_suggestions',
        cryptocurrency: event.cryptocurrency,
        tradeType: event.tradeType,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(P2PRecommendationsError(failure: failure)),
      (recommendations) => emit(P2PRecommendationsOfferSuggestionsLoaded(
        offerSuggestions: recommendations,
      )),
    );
  }

  Future<void> _onLoadMarketInsights(
    P2PRecommendationsLoadMarketInsights event,
    Emitter<P2PRecommendationsState> emit,
  ) async {
    emit(const P2PRecommendationsLoading());

    final result = await _getRecommendationsUseCase(
      GetRecommendationsParams(
        category: 'market_insights',
        cryptocurrency: event.cryptocurrency,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(P2PRecommendationsError(failure: failure)),
      (recommendations) => emit(P2PRecommendationsMarketInsightsLoaded(
        marketInsights: recommendations,
      )),
    );
  }

  Future<void> _onLoadTraderRecommendations(
    P2PRecommendationsLoadTraderRecommendations event,
    Emitter<P2PRecommendationsState> emit,
  ) async {
    emit(const P2PRecommendationsLoading());

    final result = await _getRecommendationsUseCase(
      GetRecommendationsParams(
        category: 'trader_recommendations',
        cryptocurrency: event.cryptocurrency,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(P2PRecommendationsError(failure: failure)),
      (recommendations) => emit(P2PRecommendationsTraderRecommendationsLoaded(
        traderRecommendations: recommendations,
      )),
    );
  }

  Future<void> _onMarkAsRead(
    P2PRecommendationsMarkAsRead event,
    Emitter<P2PRecommendationsState> emit,
  ) async {
    final result = await _manageRecommendationsUseCase(
      ManageRecommendationsParams(
        operation: RecommendationOperation.markAsRead,
        recommendationId: event.recommendationId,
      ),
    );

    result.fold(
      (failure) => emit(P2PRecommendationsError(failure: failure)),
      (_) => emit(const P2PRecommendationsMarkedAsRead()),
    );
  }

  Future<void> _onMarkAllAsRead(
    P2PRecommendationsMarkAllAsRead event,
    Emitter<P2PRecommendationsState> emit,
  ) async {
    final result = await _manageRecommendationsUseCase(
      const ManageRecommendationsParams(
        operation: RecommendationOperation.markAllAsRead,
      ),
    );

    result.fold(
      (failure) => emit(P2PRecommendationsError(failure: failure)),
      (_) => emit(const P2PRecommendationsAllMarkedAsRead()),
    );
  }

  Future<void> _onDelete(
    P2PRecommendationsDelete event,
    Emitter<P2PRecommendationsState> emit,
  ) async {
    final result = await _manageRecommendationsUseCase(
      ManageRecommendationsParams(
        operation: RecommendationOperation.delete,
        recommendationId: event.recommendationId,
      ),
    );

    result.fold(
      (failure) => emit(P2PRecommendationsError(failure: failure)),
      (_) => emit(const P2PRecommendationsDeleted()),
    );
  }

  Future<void> _onCreatePriceAlert(
    P2PRecommendationsCreatePriceAlert event,
    Emitter<P2PRecommendationsState> emit,
  ) async {
    emit(const P2PRecommendationsLoading());

    final result = await _createPriceAlertUseCase(
      CreatePriceAlertParams(
        cryptocurrency: event.cryptocurrency,
        targetPrice: event.targetPrice,
        alertType: event.alertType,
        amount: event.amount,
        offerId: event.offerId,
      ),
    );

    result.fold(
      (failure) => emit(P2PRecommendationsError(failure: failure)),
      (recommendation) => emit(P2PRecommendationsPriceAlertCreated(
        priceAlert: recommendation,
      )),
    );
  }

  Future<void> _onUpdatePreferences(
    P2PRecommendationsUpdatePreferences event,
    Emitter<P2PRecommendationsState> emit,
  ) async {
    final result = await _manageRecommendationsUseCase(
      ManageRecommendationsParams(
        operation: RecommendationOperation.updatePreferences,
        preferences: event.preferences,
      ),
    );

    result.fold(
      (failure) => emit(P2PRecommendationsError(failure: failure)),
      (_) => emit(const P2PRecommendationsPreferencesUpdated()),
    );
  }

  Future<void> _onGetUnreadCount(
    P2PRecommendationsGetUnreadCount event,
    Emitter<P2PRecommendationsState> emit,
  ) async {
    final result = await _manageRecommendationsUseCase(
      const ManageRecommendationsParams(
        operation: RecommendationOperation.getUnreadCount,
      ),
    );

    result.fold(
      (failure) => emit(P2PRecommendationsError(failure: failure)),
      (count) => emit(P2PRecommendationsUnreadCountLoaded(count: count as int)),
    );
  }
}
