import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/services/market_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/market_data_entity.dart';
import '../../domain/usecases/get_markets_usecase.dart';
import '../../domain/usecases/get_realtime_markets_usecase.dart';

part 'market_event.dart';
part 'market_state.dart';

// BLoC
@injectable
class MarketBloc extends Bloc<MarketEvent, MarketState> {
  MarketBloc(
    this._getMarketsUseCase,
    this._getTrendingMarketsUseCase,
    this._getHotMarketsUseCase,
    this._getGainersMarketsUseCase,
    this._getLosersMarketsUseCase,
    this._getHighVolumeMarketsUseCase,
    this._searchMarketsUseCase,
    this._getMarketsByCategoryUseCase,
    this._getRealtimeMarketsUseCase,
    this._marketService,
  ) : super(const MarketInitial()) {
    on<MarketLoadRequested>(_onMarketLoadRequested);
    on<MarketFilterChanged>(_onMarketFilterChanged);
    on<MarketSearchRequested>(_onMarketSearchRequested);
    on<MarketRefreshRequested>(_onMarketRefreshRequested);
    on<MarketCategoryChanged>(_onMarketCategoryChanged);
    on<MarketStartRealtimeRequested>(_onMarketStartRealtimeRequested);
    on<MarketStopRealtimeRequested>(_onMarketStopRealtimeRequested);
    on<MarketRealtimeDataReceived>(_onMarketRealtimeDataReceived);
    on<MarketConnectionStatusChanged>(_onMarketConnectionStatusChanged);
  }

  final GetMarketsUseCase _getMarketsUseCase;
  final GetTrendingMarketsUseCase _getTrendingMarketsUseCase;
  final GetHotMarketsUseCase _getHotMarketsUseCase;
  final GetGainersMarketsUseCase _getGainersMarketsUseCase;
  final GetLosersMarketsUseCase _getLosersMarketsUseCase;
  final GetHighVolumeMarketsUseCase _getHighVolumeMarketsUseCase;
  final SearchMarketsUseCase _searchMarketsUseCase;
  final GetMarketsByCategoryUseCase _getMarketsByCategoryUseCase;
  final GetRealtimeMarketsUseCase _getRealtimeMarketsUseCase;
  final MarketService _marketService;

  // Keep track of the original unfiltered markets
  List<MarketDataEntity> _allMarkets = [];
  String _currentFilter = 'All Markets';
  String _currentCategory = 'All';
  String _searchQuery = '';
  List<String> _dynamicCategories = ['All'];

  // Stream subscriptions for global cache
  StreamSubscription<List<MarketDataEntity>>? _marketCacheSubscription;

  Future<void> _onMarketLoadRequested(
    MarketLoadRequested event,
    Emitter<MarketState> emit,
  ) async {
    // Always subscribe to global market cache updates exactly once
    _subscribeToMarketStream();

    dev.log('🎯 MARKET_BLOC: Loading markets from global cache');

    // First, try to get data from global cache immediately
    final cachedMarkets = _marketService.cachedMarkets;
    if (cachedMarkets.isNotEmpty) {
      dev.log('✅ MARKET_BLOC: Found ${cachedMarkets.length} cached markets');
      _allMarkets = cachedMarkets;
      _dynamicCategories = _generateCategories(cachedMarkets);
      final filteredMarkets = _applyFilters(cachedMarkets);
      emit(MarketLoaded(
        markets: cachedMarkets,
        filteredMarkets: filteredMarkets,
        availableCategories: _dynamicCategories,
      ));
      return; // State emitted above; real-time updates will now arrive via the subscription
    }

    // If no cache, show loading and wait for cache to be populated
    dev.log('⏳ MARKET_BLOC: No cache found, waiting for data...');
    emit(const MarketLoading());

    // Also try to trigger a single API call to populate cache if empty
    // This should only happen once when the app starts
    try {
      final result = await _getMarketsUseCase(NoParams());
      result.fold(
        (failure) {
          dev.log('❌ MARKET_BLOC: Failed to populate cache: ${failure.message}');
          emit(MarketError(failure: failure));
        },
        (markets) {
          dev.log(
              '✅ MARKET_BLOC: Cache populated with ${markets.length} markets');
          // The cache subscription above should handle the state update
        },
      );
    } catch (e) {
      dev.log('❌ MARKET_BLOC: Error populating cache: $e');
      emit(MarketError(failure: ServerFailure('Failed to load markets: $e')));
    }
  }

  void _subscribeToMarketStream() {
    if (_marketCacheSubscription != null) return;

    _marketCacheSubscription = _marketService.marketsStream.listen((markets) {
      if (markets.isNotEmpty && !isClosed) {
        add(MarketRealtimeDataReceived(markets: markets));
      }
    });
  }

  Future<void> _onMarketRefreshRequested(
    MarketRefreshRequested event,
    Emitter<MarketState> emit,
  ) async {
    if (state is MarketLoaded) {
      final currentState = state as MarketLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    }

    final result = await _getMarketsUseCase(NoParams());

    result.fold(
      (failure) => emit(MarketError(failure: failure)),
      (markets) {
        _allMarkets = markets;
        _dynamicCategories = _generateCategories(markets);
        final filteredMarkets = _applyFilters(markets);
        emit(MarketLoaded(
          markets: markets,
          filteredMarkets: filteredMarkets,
          availableCategories: _dynamicCategories,
          isRefreshing: false,
        ));
      },
    );
  }

  void _onMarketFilterChanged(
    MarketFilterChanged event,
    Emitter<MarketState> emit,
  ) {
    _currentFilter = event.filter;

    if (state is MarketLoaded) {
      final currentState = state as MarketLoaded;
      final filteredMarkets = _applyFilters(_allMarkets);
      emit(currentState.copyWith(filteredMarkets: filteredMarkets));
    }
  }

  void _onMarketSearchRequested(
    MarketSearchRequested event,
    Emitter<MarketState> emit,
  ) {
    _searchQuery = event.query;

    if (state is MarketLoaded) {
      final currentState = state as MarketLoaded;
      final filteredMarkets = _applyFilters(_allMarkets);
      emit(currentState.copyWith(filteredMarkets: filteredMarkets));
    }
  }

  void _onMarketCategoryChanged(
    MarketCategoryChanged event,
    Emitter<MarketState> emit,
  ) {
    _currentCategory = event.category;

    if (state is MarketLoaded) {
      final currentState = state as MarketLoaded;
      final filteredMarkets = _applyFilters(_allMarkets);
      emit(currentState.copyWith(filteredMarkets: filteredMarkets));
    }
  }

  List<MarketDataEntity> _applyFilters(List<MarketDataEntity> markets) {
    var filtered = List<MarketDataEntity>.from(markets);

    // Apply search filter first
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((market) {
        final searchLower = _searchQuery.toLowerCase();
        return market.symbol.toLowerCase().contains(searchLower) ||
            market.currency.toLowerCase().contains(searchLower) ||
            market.pair.toLowerCase().contains(searchLower);
      }).toList();
    }

    // Apply category filter (filter by quote currency/pair)
    if (_currentCategory != 'All') {
      filtered =
          filtered.where((market) => market.pair == _currentCategory).toList();
    }

    // Apply main filter and sort
    switch (_currentFilter) {
      case 'All Markets':
        // Sort by volume (highest first) for all markets
        filtered.sort((a, b) => b.baseVolume.compareTo(a.baseVolume));
        break;

      case 'Gainers':
        // Filter only positive changes and sort by change percentage (highest first)
        filtered = filtered.where((market) => market.isPositive).toList();
        filtered.sort((a, b) => b.changePercent.compareTo(a.changePercent));
        break;

      case 'Losers':
        // Filter only negative changes and sort by change percentage (lowest first)
        filtered = filtered.where((market) => market.isNegative).toList();
        filtered.sort((a, b) => a.changePercent.compareTo(b.changePercent));
        break;

      case 'High Vol':
        // Filter markets with high volume (> 1M) and sort by volume (highest first)
        filtered =
            filtered.where((market) => market.baseVolume > 1000000).toList();
        filtered.sort((a, b) => b.baseVolume.compareTo(a.baseVolume));
        break;

      case 'Trending':
        // Filter markets marked as trending from API
        filtered = filtered.where((market) => market.isTrending).toList();
        // Sort trending markets by volume
        filtered.sort((a, b) => b.baseVolume.compareTo(a.baseVolume));
        break;

      case 'Hot':
        // Filter markets marked as hot from API
        filtered = filtered.where((market) => market.isHot).toList();
        // Sort hot markets by change percentage
        filtered.sort(
            (a, b) => b.changePercent.abs().compareTo(a.changePercent.abs()));
        break;

      default:
        // Default sorting by volume
        filtered.sort((a, b) => b.baseVolume.compareTo(a.baseVolume));
    }

    return filtered;
  }

  /// Generate dynamic categories based on the most common quote currencies
  List<String> _generateCategories(List<MarketDataEntity> markets) {
    // Count occurrences of each pair/quote currency
    final Map<String, int> pairCounts = {};

    for (final market in markets) {
      final pair = market.pair;
      pairCounts[pair] = (pairCounts[pair] ?? 0) + 1;
    }

    // Sort by count and take the top 7 most common pairs
    final sortedPairs = pairCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Start with 'All' and add the top pairs
    final categories = ['All'];

    // Add the most common pairs (limit to 6 more to have 7 total)
    for (final entry in sortedPairs.take(6)) {
      categories.add(entry.key);
    }

    return categories;
  }

  // Real-time event handlers
  StreamSubscription<List<MarketDataEntity>>? _realtimeSubscription;
  StreamSubscription<WebSocketConnectionStatus>? _connectionSubscription;

  Future<void> _onMarketStartRealtimeRequested(
    MarketStartRealtimeRequested event,
    Emitter<MarketState> emit,
  ) async {
    dev.log('🎯 BLoC: Subscribing to global real-time updates');

    // Don't start WebSocket - it's managed globally
    // Just subscribe to the global streams

    // Subscribe to real-time data stream from global service
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _marketService.marketsStream.listen((markets) {
      if (!isClosed && markets.isNotEmpty) {
        add(MarketRealtimeDataReceived(markets: markets));
      }
    });

    // Subscribe to connection status from global WebSocket service
    _connectionSubscription?.cancel();
    // Note: We'll get connection status from the global WebSocket service
    // For now, assume connected since it's managed globally
    if (state is MarketLoaded) {
      final currentState = state as MarketLoaded;
      emit(currentState.copyWith(
          connectionStatus: WebSocketConnectionStatus.connected));
    }

    dev.log('✅ BLoC: Subscribed to global real-time updates');
  }

  Future<void> _onMarketStopRealtimeRequested(
    MarketStopRealtimeRequested event,
    Emitter<MarketState> emit,
  ) async {
    dev.log('🛑 BLoC: Unsubscribing from global real-time updates');

    // Only cancel subscriptions, don't stop the global WebSocket
    await _realtimeSubscription?.cancel();
    await _connectionSubscription?.cancel();
    _realtimeSubscription = null;
    _connectionSubscription = null;

    dev.log('✅ BLoC: Unsubscribed from global real-time updates');
  }

  void _onMarketRealtimeDataReceived(
    MarketRealtimeDataReceived event,
    Emitter<MarketState> emit,
  ) {
    _allMarkets = event.markets;
    _dynamicCategories = _generateCategories(event.markets);

    if (state is MarketLoaded) {
      final currentState = state as MarketLoaded;
      final filteredMarkets = _applyFilters(event.markets);

      emit(currentState.copyWith(
        markets: event.markets,
        filteredMarkets: filteredMarkets,
        availableCategories: _dynamicCategories,
        isRealtime: true,
      ));
    }
  }

  void _onMarketConnectionStatusChanged(
    MarketConnectionStatusChanged event,
    Emitter<MarketState> emit,
  ) {
    if (state is MarketLoaded) {
      final currentState = state as MarketLoaded;
      emit(currentState.copyWith(connectionStatus: event.status));
    }
  }

  @override
  Future<void> close() async {
    await _marketCacheSubscription?.cancel();
    await _realtimeSubscription?.cancel();
    await _connectionSubscription?.cancel();
    return super.close();
  }
}
