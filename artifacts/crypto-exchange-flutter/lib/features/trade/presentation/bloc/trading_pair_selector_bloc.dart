import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../market/domain/usecases/get_markets_usecase.dart';
import '../../../market/domain/usecases/get_realtime_markets_usecase.dart';
import '../../../market/domain/entities/market_data_entity.dart';
import '../../domain/entities/trading_pair_entity.dart';

part 'trading_pair_selector_event.dart';
part 'trading_pair_selector_state.dart';

@injectable
class TradingPairSelectorBloc
    extends Bloc<TradingPairSelectorEvent, TradingPairSelectorState> {
  TradingPairSelectorBloc(
    this._getMarketsUseCase,
    this._getRealtimeMarketsUseCase,
  ) : super(const TradingPairSelectorInitial()) {
    on<TradingPairSelectorLoadRequested>(_onLoadRequested);
    on<TradingPairSelectorSearchChanged>(_onSearchChanged);
    on<TradingPairSelectorCategoryChanged>(_onCategoryChanged);
    on<TradingPairSelectorFavoriteToggled>(_onFavoriteToggled);
    on<TradingPairSelectorRealtimeDataReceived>(_onRealtimeDataReceived);
    on<TradingPairSelectorStartRealtime>(_onStartRealtime);
    on<TradingPairSelectorStopRealtime>(_onStopRealtime);
  }

  final GetMarketsUseCase _getMarketsUseCase;
  final GetRealtimeMarketsUseCase _getRealtimeMarketsUseCase;

  // State management
  List<TradingPairEntity> _allPairs = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<String> _dynamicCategories = ['All'];
  final Set<String> _favoriteSymbols = <String>{};
  Set<String> _recentSymbols = <String>{};

  // Real-time subscription
  StreamSubscription<List<MarketDataEntity>>? _realtimeSubscription;

  Future<void> _onLoadRequested(
    TradingPairSelectorLoadRequested event,
    Emitter<TradingPairSelectorState> emit,
  ) async {
    emit(const TradingPairSelectorLoading());

    final result = await _getMarketsUseCase(NoParams());

    result.fold(
      (failure) => emit(TradingPairSelectorError(failure: failure)),
      (markets) {
        _allPairs = _convertToTradingPairs(markets);
        _dynamicCategories = _generateCategories(markets);
        final filteredPairs = _applyFilters(_allPairs);

        emit(TradingPairSelectorLoaded(
          allPairs: _allPairs,
          filteredPairs: filteredPairs,
          availableCategories: _dynamicCategories,
          searchQuery: _searchQuery,
          selectedCategory: _selectedCategory,
        ));
      },
    );
  }

  void _onSearchChanged(
    TradingPairSelectorSearchChanged event,
    Emitter<TradingPairSelectorState> emit,
  ) {
    _searchQuery = event.query;

    if (state is TradingPairSelectorLoaded) {
      final currentState = state as TradingPairSelectorLoaded;
      final filteredPairs = _applyFilters(_allPairs);

      emit(currentState.copyWith(
        filteredPairs: filteredPairs,
        searchQuery: _searchQuery,
      ));
    }
  }

  void _onCategoryChanged(
    TradingPairSelectorCategoryChanged event,
    Emitter<TradingPairSelectorState> emit,
  ) {
    _selectedCategory = event.category;

    if (state is TradingPairSelectorLoaded) {
      final currentState = state as TradingPairSelectorLoaded;
      final filteredPairs = _applyFilters(_allPairs);

      emit(currentState.copyWith(
        filteredPairs: filteredPairs,
        selectedCategory: _selectedCategory,
      ));
    }
  }

  void _onFavoriteToggled(
    TradingPairSelectorFavoriteToggled event,
    Emitter<TradingPairSelectorState> emit,
  ) {
    if (_favoriteSymbols.contains(event.symbol)) {
      _favoriteSymbols.remove(event.symbol);
    } else {
      _favoriteSymbols.add(event.symbol);
    }

    // Update pairs with new favorite status
    _allPairs = _allPairs.map((pair) {
      if (pair.symbol == event.symbol) {
        return pair.copyWith(
            isFavorite: _favoriteSymbols.contains(event.symbol));
      }
      return pair;
    }).toList();

    if (state is TradingPairSelectorLoaded) {
      final currentState = state as TradingPairSelectorLoaded;
      final filteredPairs = _applyFilters(_allPairs);

      emit(currentState.copyWith(
        allPairs: _allPairs,
        filteredPairs: filteredPairs,
      ));
    }
  }

  Future<void> _onStartRealtime(
    TradingPairSelectorStartRealtime event,
    Emitter<TradingPairSelectorState> emit,
  ) async {
    // Start real-time updates using market infrastructure
    final result = await _getRealtimeMarketsUseCase.startRealtimeUpdates();

    result.fold(
      (failure) => dev.log(
          '❌ TRADING_PAIR_SELECTOR: Failed to start real-time: ${failure.message}'),
      (_) {
        // dev.log('✅ TRADING_PAIR_SELECTOR: Real-time updates started');

        // Subscribe to real-time data
        _realtimeSubscription =
            _getRealtimeMarketsUseCase.getRealtimeMarkets().listen((markets) {
          add(TradingPairSelectorRealtimeDataReceived(markets: markets));
        });
      },
    );
  }

  Future<void> _onStopRealtime(
    TradingPairSelectorStopRealtime event,
    Emitter<TradingPairSelectorState> emit,
  ) async {
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    await _getRealtimeMarketsUseCase.stopRealtimeUpdates();
  }

  void _onRealtimeDataReceived(
    TradingPairSelectorRealtimeDataReceived event,
    Emitter<TradingPairSelectorState> emit,
  ) {
    _allPairs = _convertToTradingPairs(event.markets);

    if (state is TradingPairSelectorLoaded) {
      final currentState = state as TradingPairSelectorLoaded;
      final filteredPairs = _applyFilters(_allPairs);

      emit(currentState.copyWith(
        allPairs: _allPairs,
        filteredPairs: filteredPairs,
        isRealtime: true,
      ));
    }
  }

  /// Convert market data to trading pairs with favorite/recent status
  List<TradingPairEntity> _convertToTradingPairs(
      List<MarketDataEntity> markets) {
    return markets.map((market) {
      return TradingPairEntity(
        marketData: market,
        isFavorite: _favoriteSymbols.contains(market.symbol),
        isRecent: _recentSymbols.contains(market.symbol),
      );
    }).toList();
  }

  /// Apply search and category filters
  List<TradingPairEntity> _applyFilters(List<TradingPairEntity> pairs) {
    var filtered = List<TradingPairEntity>.from(pairs);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      filtered = filtered.where((pair) {
        return pair.symbol.toLowerCase().contains(searchLower) ||
            pair.currency.toLowerCase().contains(searchLower) ||
            pair.pair.toLowerCase().contains(searchLower);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      if (_selectedCategory == 'Favorites') {
        filtered = filtered.where((pair) => pair.isFavorite).toList();
      } else if (_selectedCategory == 'Recent') {
        filtered = filtered.where((pair) => pair.isRecent).toList();
      } else {
        // Filter by quote currency
        filtered =
            filtered.where((pair) => pair.pair == _selectedCategory).toList();
      }
    }

    // Sort by volume (highest first)
    filtered.sort((a, b) => b.baseVolume.compareTo(a.baseVolume));

    return filtered;
  }

  /// Generate dynamic categories based on quote currencies
  List<String> _generateCategories(List<MarketDataEntity> markets) {
    final Map<String, int> pairCounts = {};

    for (final market in markets) {
      final pair = market.pair;
      pairCounts[pair] = (pairCounts[pair] ?? 0) + 1;
    }

    // Sort by count and take top pairs
    final sortedPairs = pairCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Start with special categories
    final categories = ['All', 'Favorites', 'Recent'];

    // Add top quote currencies (limit to 5 more)
    for (final entry in sortedPairs.take(5)) {
      categories.add(entry.key);
    }

    return categories;
  }

  /// Add symbol to recent list
  void addToRecent(String symbol) {
    _recentSymbols.add(symbol);
    // Keep only last 10 recent pairs
    if (_recentSymbols.length > 10) {
      _recentSymbols = _recentSymbols.skip(_recentSymbols.length - 10).toSet();
    }
  }

  @override
  Future<void> close() async {
    await _realtimeSubscription?.cancel();
    await _getRealtimeMarketsUseCase.stopRealtimeUpdates();
    return super.close();
  }
}
