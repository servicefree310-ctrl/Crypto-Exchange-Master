import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/p2p_offer_entity.dart';
import '../../../domain/entities/p2p_params.dart';
import '../../../domain/usecases/offers/get_offers_usecase.dart';
import '../../../domain/usecases/offers/get_offer_by_id_usecase.dart';
import '../../../domain/usecases/offers/get_popular_offers_usecase.dart';
import '../../../domain/usecases/matching/guided_matching_usecase.dart';
import 'offers_event.dart';
import 'offers_state.dart';

/// BLoC for managing P2P offers state
///
/// Based on v5's offers state management patterns:
/// - Handles offers list with filtering and pagination
/// - Manages loading states for different operations
/// - Supports pull-to-refresh and infinite scroll
/// - Provides search and filter functionality
@injectable
class OffersBloc extends Bloc<OffersEvent, OffersState> {
  OffersBloc(
    this._getOffersUseCase,
    this._getOfferByIdUseCase,
    this._getPopularOffersUseCase,
    this._guidedMatchingUseCase,
  ) : super(const OffersInitial()) {
    on<OffersLoadRequested>(_onOffersLoadRequested);
    on<OffersLoadMoreRequested>(_onOffersLoadMoreRequested);
    on<OffersRefreshRequested>(_onOffersRefreshRequested);
    on<OffersFiltersApplied>(_onOffersFiltersApplied);
    on<OffersFiltersClearRequested>(_onOffersFiltersClearRequested);
    on<OffersSearchRequested>(_onOffersSearchRequested);
    on<OfferLoadByIdRequested>(_onOfferLoadByIdRequested);
    on<PopularOffersLoadRequested>(_onPopularOffersLoadRequested);
    on<OffersRetryRequested>(_onOffersRetryRequested);
    on<GuidedMatchingRequested>(_onGuidedMatchingRequested);
  }

  final GetOffersUseCase _getOffersUseCase;
  final GetOfferByIdUseCase _getOfferByIdUseCase;
  final GetPopularOffersUseCase _getPopularOffersUseCase;
  final GuidedMatchingUseCase _guidedMatchingUseCase;

  // Cache for current filters and search
  OffersFilters? _currentFilters;
  String? _currentSearchQuery;

  /// Handle loading offers with optional filters
  Future<void> _onOffersLoadRequested(
    OffersLoadRequested event,
    Emitter<OffersState> emit,
  ) async {
    // Show loading state
    if (event.refresh) {
      if (state is OffersLoaded) {
        emit((state as OffersLoaded).copyWith(isRefreshing: true));
      } else {
        emit(const OffersLoading(isRefresh: true));
      }
    } else {
      emit(const OffersLoading());
    }

    // Update current filters
    _currentFilters = OffersFilters(
      type: event.type,
      currency: event.currency,
      paymentMethods: event.paymentMethods,
      minAmount: event.minAmount,
      maxAmount: event.maxAmount,
      location: event.location,
      sortBy: event.sortBy,
    );

    // Execute use case
    final result = await _getOffersUseCase(
      GetOffersParams(
        type: event.type,
        currency: event.currency,
        paymentMethodIds: event.paymentMethods,
        minAmount: event.minAmount,
        maxAmount: event.maxAmount,
        location: event.location,
        sortField: _mapSortBy(event.sortBy),
        page: event.page,
        perPage: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(OffersError(failure: failure)),
      (response) {
        if (response.offers.isEmpty) {
          emit(OffersEmpty(
            appliedFilters: _currentFilters,
            searchQuery: _currentSearchQuery,
          ));
        } else {
          emit(OffersLoaded(
            offers: response.offers,
            hasMore: response.pagination.hasNextPage,
            currentPage: response.pagination.currentPage,
            totalCount: response.pagination.totalItems,
            appliedFilters: _currentFilters,
            searchQuery: _currentSearchQuery,
          ));
        }
      },
    );
  }

  /// Handle loading more offers (pagination)
  Future<void> _onOffersLoadMoreRequested(
    OffersLoadMoreRequested event,
    Emitter<OffersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OffersLoaded || !currentState.hasMore) return;

    // Show loading more state
    emit(OffersLoading(
      isLoadMore: true,
      existingOffers: currentState.offers,
    ));

    // Load next page
    final result = await _getOffersUseCase(
      GetOffersParams(
        type: _currentFilters?.type,
        currency: _currentFilters?.currency,
        paymentMethodIds: _currentFilters?.paymentMethods,
        minAmount: _currentFilters?.minAmount,
        maxAmount: _currentFilters?.maxAmount,
        location: _currentFilters?.location,
        sortField: _mapSortBy(_currentFilters?.sortBy ?? 'newest'),
        page: currentState.currentPage + 1,
        perPage: 20,
      ),
    );

    result.fold(
      (failure) => emit(OffersError(
        failure: failure,
        existingOffers: currentState.offers,
      )),
      (response) {
        // Append new offers to existing ones
        final allOffers = [...currentState.offers, ...response.offers];
        emit(OffersLoaded(
          offers: allOffers,
          hasMore: response.pagination.hasNextPage,
          currentPage: response.pagination.currentPage,
          totalCount: response.pagination.totalItems,
          appliedFilters: _currentFilters,
          searchQuery: _currentSearchQuery,
        ));
      },
    );
  }

  /// Handle refresh offers
  Future<void> _onOffersRefreshRequested(
    OffersRefreshRequested event,
    Emitter<OffersState> emit,
  ) async {
    add(OffersLoadRequested(
      type: _currentFilters?.type,
      currency: _currentFilters?.currency,
      paymentMethods: _currentFilters?.paymentMethods,
      minAmount: _currentFilters?.minAmount,
      maxAmount: _currentFilters?.maxAmount,
      location: _currentFilters?.location,
      sortBy: _currentFilters?.sortBy ?? 'newest',
      refresh: true,
    ));
  }

  /// Handle applying filters
  Future<void> _onOffersFiltersApplied(
    OffersFiltersApplied event,
    Emitter<OffersState> emit,
  ) async {
    add(OffersLoadRequested(
      type: event.type,
      currency: event.currency,
      paymentMethods: event.paymentMethods,
      minAmount: event.minAmount,
      maxAmount: event.maxAmount,
      location: event.location,
      sortBy: event.sortBy,
      page: 1, // Reset to first page
    ));
  }

  /// Handle clearing filters
  Future<void> _onOffersFiltersClearRequested(
    OffersFiltersClearRequested event,
    Emitter<OffersState> emit,
  ) async {
    _currentFilters = null;
    _currentSearchQuery = null;
    add(const OffersLoadRequested());
  }

  /// Handle search
  Future<void> _onOffersSearchRequested(
    OffersSearchRequested event,
    Emitter<OffersState> emit,
  ) async {
    _currentSearchQuery = event.query.trim().isEmpty ? null : event.query;

    // Apply search with current filters
    add(OffersLoadRequested(
      type: _currentFilters?.type,
      currency: _currentFilters?.currency,
      paymentMethods: _currentFilters?.paymentMethods,
      minAmount: _currentFilters?.minAmount,
      maxAmount: _currentFilters?.maxAmount,
      location: _currentFilters?.location,
      sortBy: _currentFilters?.sortBy ?? 'newest',
      page: 1, // Reset to first page
    ));
  }

  /// Handle loading single offer by ID
  Future<void> _onOfferLoadByIdRequested(
    OfferLoadByIdRequested event,
    Emitter<OffersState> emit,
  ) async {
    emit(OfferByIdLoading(event.offerId));

    final result = await _getOfferByIdUseCase(
      GetOfferByIdParams(offerId: event.offerId),
    );

    result.fold(
      (failure) => emit(OfferByIdError(
        failure: failure,
        offerId: event.offerId,
      )),
      (offer) => emit(OfferByIdLoaded(offer)),
    );
  }

  /// Handle loading popular offers
  Future<void> _onPopularOffersLoadRequested(
    PopularOffersLoadRequested event,
    Emitter<OffersState> emit,
  ) async {
    emit(const PopularOffersLoading());

    final result = await _getPopularOffersUseCase(
      GetPopularOffersParams(limit: event.limit),
    );

    result.fold(
      (failure) => emit(PopularOffersError(failure)),
      (offers) => emit(PopularOffersLoaded(offers)),
    );
  }

  /// Handle retry after error
  Future<void> _onOffersRetryRequested(
    OffersRetryRequested event,
    Emitter<OffersState> emit,
  ) async {
    final currentState = state;

    if (currentState is OffersError) {
      // Retry with preserved settings
      add(OffersLoadRequested(
        type: _currentFilters?.type,
        currency: _currentFilters?.currency,
        paymentMethods: _currentFilters?.paymentMethods,
        minAmount: _currentFilters?.minAmount,
        maxAmount: _currentFilters?.maxAmount,
        location: _currentFilters?.location,
        sortBy: _currentFilters?.sortBy ?? 'newest',
      ));
    } else if (currentState is OfferByIdError) {
      add(OfferLoadByIdRequested(currentState.offerId));
    } else if (currentState is PopularOffersError) {
      add(const PopularOffersLoadRequested());
    }
  }

  /// Handle V5-style guided matching request
  /// ✅ Now uses proper /api/p2p/guided-matching endpoint!
  Future<void> _onGuidedMatchingRequested(
    GuidedMatchingRequested event,
    Emitter<OffersState> emit,
  ) async {
    emit(const OffersLoading());

    final criteria = event.criteria;

    // 🔥 DEBUG LOGGING - Print received criteria
    dev.log('\n📥 ===== GUIDED MATCHING REQUEST =====');
    criteria.forEach((key, value) {
      if (value is List) {
        dev.log('   $key: [${value.join(', ')}]');
      } else {
        dev.log('   $key: "$value"');
      }
    });

    // ✅ FIXED: No more conversion! Use EXACT trade type as user selected
    dev.log(
        '   ✅ Using EXACT tradeType: "${criteria['tradeType']}" (no conversion)');
    dev.log('   🚀 Calling: /api/p2p/guided-matching');

    // ✅ Now calling the CORRECT guided matching endpoint!
    final result = await _guidedMatchingUseCase(
      GuidedMatchingParams(
        tradeType:
            criteria['tradeType'] ?? 'buy', // ✅ EXACT type, no conversion
        cryptocurrency: criteria['cryptocurrency'] ?? '',
        amount: double.tryParse(criteria['amount']?.toString() ?? '0') ?? 0,
        paymentMethods: List<String>.from(criteria['paymentMethods'] ?? []),
        pricePreference: criteria['pricePreference'] ?? 'best_price',
        traderPreference: criteria['traderPreference'] ?? 'all',
        location: criteria['location'] ?? 'any',
        maxResults: 30,
      ),
    );

    result.fold(
      (failure) {
        dev.log('❌ Guided matching failed: ${failure.toString()}');
        dev.log('===========================================\n');
        emit(OffersError(failure: failure));
      },
      (response) {
        dev.log('✅ Guided matching succeeded!');
        dev.log('   📊 Found ${response.matchCount} matches');
        dev.log('   💰 Best price: \$${response.bestPrice}');
        dev.log('   📈 Market price: \$${response.marketPrice ?? 'N/A'}');
        dev.log('   💵 Estimated savings: \$${response.estimatedSavings}');

        if (response.matches.isNotEmpty) {
          dev.log('   🏷️  Sample matches:');
          for (int i = 0; i < response.matches.take(3).length; i++) {
            final match = response.matches[i];
            dev.log(
                '      ${i + 1}. ${match.coin} - ${match.type.toUpperCase()} - \$${match.price} (${match.matchScore}% match)');
          }
        }
        dev.log('===========================================\n');

        // Convert guided matching response to offers state
        final offers = response.matches
            .map((match) => _convertMatchToOffer(match))
            .toList();

        if (offers.isEmpty) {
          emit(const OffersEmpty(
            message: 'No matching offers found for your criteria',
          ));
        } else {
          emit(OffersLoaded(
            offers: offers,
            hasMore: false, // Guided matching returns all results at once
            currentPage: 1,
            totalCount: response.matchCount,
          ));
        }
      },
    );
  }

  /// Convert guided matching result to P2P offer entity
  P2POfferEntity _convertMatchToOffer(MatchedOffer match) {
    return P2POfferEntity(
      id: match.id,
      userId: match.trader.id,
      type: match.type == 'buy' ? P2PTradeType.buy : P2PTradeType.sell,
      currency: match.coin,
      walletType: _parseWalletType(match.walletType),
      amountConfig: AmountConfiguration(
        total: match.availableAmount,
        min: match.minLimit,
        max: match.maxLimit,
      ),
      priceConfig: PriceConfiguration(
        model: P2PPriceModel.fixed,
        value: match.price,
        finalPrice: match.price,
      ),
      tradeSettings: const TradeSettings(
        autoCancel: 30,
        kycRequired: false,
        visibility: P2POfferVisibility.public,
      ),
      status: P2POfferStatus.active,
      views: 0,
      paymentMethods: match.paymentMethods,
      user: {
        'firstName': match.trader.name,
        'username': match.trader.name,
        'completedTrades': match.trader.completedTrades,
        'completionRate': match.trader.completionRate,
        'verified': match.trader.verified,
        'avatar': match.trader.avatar,
        'responseTime': match.trader.responseTime,
        'rating': match.trader.avgRating,
      },
      createdAt: match.createdAt,
      updatedAt: match.updatedAt,
    );
  }

  /// Parse wallet type from string
  P2PWalletType _parseWalletType(String walletType) {
    switch (walletType.toLowerCase()) {
      case 'fiat':
        return P2PWalletType.fiat;
      case 'spot':
        return P2PWalletType.spot;
      case 'eco':
        return P2PWalletType.eco;
      default:
        return P2PWalletType.spot;
    }
  }

  /// Check if current state has offers
  bool get hasOffers {
    final currentState = state;
    return currentState is OffersLoaded && currentState.offers.isNotEmpty;
  }

  /// Get current offers list
  List<P2POfferEntity> get currentOffers {
    final currentState = state;
    if (currentState is OffersLoaded) {
      return currentState.offers;
    }
    if (currentState is OffersError) {
      return currentState.existingOffers;
    }
    return [];
  }

  /// Check if filters are applied
  bool get hasFiltersApplied {
    return _currentFilters?.hasActiveFilters ?? false;
  }

  /// Get current filters
  OffersFilters? get currentFilters => _currentFilters;

  /// Get current search query
  String? get currentSearchQuery => _currentSearchQuery;

  /// Map sort by to actual sort field
  String _mapSortBy(String sortBy) {
    switch (sortBy) {
      case 'newest':
        return 'createdAt';
      case 'price-low':
        return 'priceConfig.finalPrice';
      case 'price-high':
        return 'priceConfig.finalPrice';
      case 'reputation':
        return 'user.completionRate';
      default:
        return 'createdAt';
    }
  }
}
