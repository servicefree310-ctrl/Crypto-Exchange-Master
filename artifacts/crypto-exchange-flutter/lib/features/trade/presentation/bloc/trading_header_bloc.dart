import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/trading_websocket_service.dart';
import '../../../../core/services/market_service.dart';
import '../../../../core/services/price_animation_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection/injection.dart';
import '../../../market/domain/entities/market_data_entity.dart';
import '../../../market/domain/entities/market_entity.dart';
import '../../../market/domain/entities/ticker_entity.dart';
import '../../../market/domain/usecases/get_markets_usecase.dart';
import '../../domain/usecases/connect_trading_websocket_usecase.dart';

part 'trading_header_event.dart';
part 'trading_header_state.dart';

@injectable
class TradingHeaderBloc extends Bloc<TradingHeaderEvent, TradingHeaderState> {
  TradingHeaderBloc(
    this._getMarketsUseCase,
    this._connectTradingWebSocketUseCase,
    this._tradingWebSocketService,
    this._marketService,
  ) : super(const TradingHeaderInitial()) {
    on<TradingHeaderInitialized>(_onTradingHeaderInitialized);
    on<TradingPairChanged>(_onTradingPairChanged);
    on<TradingTypeChanged>(_onTradingTypeChanged);
    on<TradingPairDropdownRequested>(_onTradingPairDropdownRequested);
    on<TradingPriceDataRequested>(_onTradingPriceDataRequested);
    on<TradingActionRequested>(_onTradingActionRequested);
    on<_TradingHeaderTickerUpdated>(_onTradingHeaderTickerUpdatedEvent);

    // Listen to global market updates for real-time price changes
    _marketSubscription = _marketService.marketsStream.listen(_onMarketUpdate);
  }

  final GetMarketsUseCase _getMarketsUseCase;
  final ConnectTradingWebSocketUseCase _connectTradingWebSocketUseCase;
  final TradingWebSocketService _tradingWebSocketService;
  final MarketService _marketService;
  late final PriceAnimationService _priceAnimationService =
      getIt<PriceAnimationService>();

  StreamSubscription<List<MarketDataEntity>>? _marketSubscription;

  String _currentSymbol = ApiConstants.defaultTradingPair;
  TradingType _selectedType = TradingType.spot;
  List<MarketDataEntity> _availableMarkets = [];

  /// Handle global market updates (converted from ticker stream)
  void _onMarketUpdate(List<MarketDataEntity> markets) {
    if (state is! TradingHeaderLoaded) return;

    // Find market data for current symbol
    MarketDataEntity? market;
    for (final m in markets) {
      if (m.symbol == _currentSymbol) {
        market = m;
        break;
      }
    }
    if (market == null) return;

    final tickerLast = market.price;
    final changePercent = market.changePercent;

    final currentState = state as TradingHeaderLoaded;

    // Update global price animation service (context will be handled by AnimatedPrice widgets)
    _priceAnimationService.updatePrice(_currentSymbol, tickerLast);

    // Also update change percentage animation
    _priceAnimationService.updateChangePercentage(
        _currentSymbol, changePercent);

    final updatedPairData = currentState.pairData.copyWith(
      price: market.price,
      change24h: market.change,
      changePercentage24h: market.changePercent,
      volume24h: market.baseVolume,
    );

    add(_TradingHeaderTickerUpdated(
      pairData: updatedPairData,
    ));
  }

  Future<void> _onTradingHeaderInitialized(
    TradingHeaderInitialized event,
    Emitter<TradingHeaderState> emit,
  ) async {
    emit(TradingHeaderLoading(symbol: event.symbol));

    try {
      _currentSymbol = event.symbol;

      // Load available markets for dropdown (using cached data)
      final marketsResult = await _getMarketsUseCase(NoParams());
      marketsResult.fold(
        (failure) => {
          // Continue with empty markets list but log error
          dev.log('Failed to load markets: ${failure.message}')
        },
        (markets) => _availableMarkets = markets,
      );

      // Connect to WebSocket for real-time data
      final connectResult = await _connectTradingWebSocketUseCase(
        ConnectTradingWebSocketParams(symbol: event.symbol),
      );

      connectResult.fold(
        (failure) => dev.log('Failed to connect WebSocket: ${failure.message}'),
        (_) => dev.log('WebSocket connected successfully'),
      );

      // Find actual market data for the symbol instead of using mock data
      final pairData =
          _createPairDataFromMarkets(event.symbol, _availableMarkets);

      emit(TradingHeaderLoaded(
        symbol: event.symbol,
        selectedType: _selectedType,
        pairData: pairData,
        availableMarkets: _availableMarkets,
      ));
    } catch (e) {
      emit(TradingHeaderError(
        message: 'Failed to initialize trading header: $e',
        symbol: event.symbol,
      ));
    }
  }

  Future<void> _onTradingPairChanged(
    TradingPairChanged event,
    Emitter<TradingHeaderState> emit,
  ) async {
    emit(TradingHeaderLoading(symbol: event.symbol));

    try {
      // Update current symbol
      _currentSymbol = event.symbol;

      // Change WebSocket subscription to new symbol
      await _tradingWebSocketService.changeSymbol(event.symbol);
      // dev.log(
      //     '✅ TRADING_WS: Successfully changed subscription to ${event.symbol}');

      // Find actual market data for the symbol instead of using mock data
      final pairData =
          _createPairDataFromMarkets(event.symbol, _availableMarkets);

      if (state is TradingHeaderLoaded) {
        final currentState = state as TradingHeaderLoaded;
        emit(currentState.copyWith(
          symbol: event.symbol,
          pairData: pairData,
        ));
      } else {
        emit(TradingHeaderLoaded(
          symbol: event.symbol,
          selectedType: _selectedType,
          pairData: pairData,
          availableMarkets: _availableMarkets,
        ));
      }
    } catch (e) {
      emit(TradingHeaderError(
        message: 'Failed to change trading pair: $e',
        symbol: event.symbol,
      ));
    }
  }

  Future<void> _onTradingTypeChanged(
    TradingTypeChanged event,
    Emitter<TradingHeaderState> emit,
  ) async {
    _selectedType = event.tradingType;

    if (state is TradingHeaderLoaded) {
      final currentState = state as TradingHeaderLoaded;
      emit(currentState.copyWith(selectedType: _selectedType));
    }
  }

  Future<void> _onTradingPairDropdownRequested(
    TradingPairDropdownRequested event,
    Emitter<TradingHeaderState> emit,
  ) async {
    // This event can be used to trigger dropdown UI logic
    // The actual UI logic will be handled in the widget
  }

  Future<void> _onTradingPriceDataRequested(
    TradingPriceDataRequested event,
    Emitter<TradingHeaderState> emit,
  ) async {
    if (state is TradingHeaderLoaded) {
      final currentState = state as TradingHeaderLoaded;

      if (event.forceRefresh) {
        emit(TradingHeaderLoading(symbol: event.symbol));
      }

      try {
        // TODO: Replace with real API call
        final updatedPairData = TradingPairData.mock(event.symbol);

        emit(currentState.copyWith(pairData: updatedPairData));
      } catch (e) {
        emit(TradingHeaderError(
          message: 'Failed to refresh price data: $e',
          symbol: event.symbol,
        ));
      }
    }
  }

  Future<void> _onTradingActionRequested(
    TradingActionRequested event,
    Emitter<TradingHeaderState> emit,
  ) async {
    // Handle action button taps
    // This can trigger navigation or show modals
    // Implementation depends on specific action requirements
    switch (event.action) {
      case TradingAction.info:
        // Handle info action
        break;
      case TradingAction.analytics:
        // Handle analytics action
        break;
      case TradingAction.more:
        // Handle more options action
        break;
    }
  }

  /// Handle ticker update events
  Future<void> _onTradingHeaderTickerUpdatedEvent(
    _TradingHeaderTickerUpdated event,
    Emitter<TradingHeaderState> emit,
  ) async {
    if (state is TradingHeaderLoaded) {
      final currentState = state as TradingHeaderLoaded;
      emit(currentState.copyWith(
        pairData: event.pairData,
      ));
    }
  }

  /// Create TradingPairData from actual market data instead of mock data
  TradingPairData _createPairDataFromMarkets(
      String symbol, List<MarketDataEntity> markets) {
    // Find the market data for the given symbol
    final marketData = markets.firstWhere(
      (market) => market.symbol == symbol,
      orElse: () {
        // If symbol not found, try fallback searches
        final fallbackMarket = markets.firstWhere(
          (market) =>
              market.symbol.contains(symbol.split('/')[0]) ||
              market.pair.contains(symbol.split('/')[0]),
          orElse: () => markets.isNotEmpty
              ? markets.first
              : _createEmptyMarketData(symbol),
        );
        return fallbackMarket;
      },
    );

    // Convert MarketDataEntity to TradingPairData using real data
    return TradingPairData(
      symbol: marketData.symbol,
      price: marketData.price,
      change24h: marketData.change,
      changePercentage24h: marketData.changePercent,
      high24h: 0.0, // Will be updated by WebSocket
      low24h: 0.0, // Will be updated by WebSocket
      volume24h: marketData.baseVolume,
      lastUpdated: DateTime.now(),
    );
  }

  /// Create empty market data as fallback
  MarketDataEntity _createEmptyMarketData(String symbol) {
    return MarketDataEntity(
      market: MarketEntity(
        id: '0',
        symbol: symbol,
        currency: symbol.split('/')[0],
        pair: symbol,
        isTrending: false,
        isHot: false,
        status: true,
        isEco: false,
        precision: const MarketPrecisionEntity(price: 8, amount: 8),
      ),
      ticker: TickerEntity(
        symbol: symbol,
        last: 0.0,
        baseVolume: 0.0,
        quoteVolume: 0.0,
        change: 0.0,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _marketSubscription?.cancel();
    return super.close();
  }
}
