// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/trading_websocket_service.dart';
import '../../../market/domain/entities/market_data_entity.dart';
import '../../domain/entities/chart_entity.dart';
import '../../domain/usecases/get_realtime_ticker_usecase.dart';
import '../../domain/usecases/get_chart_history_usecase.dart';
import '../../domain/usecases/get_chart_with_volume_usecase.dart';
import '../../domain/usecases/get_recent_trades_usecase.dart';
import '../../../trade/presentation/bloc/order_book_bloc.dart';

part 'chart_event.dart';
part 'chart_state.dart';

@injectable
class ChartBloc extends Bloc<ChartEvent, ChartState> {
  ChartBloc(
    this._getRealtimeTickerUseCase,
    this._getChartHistoryUseCase,
    this._getChartWithVolumeUseCase,
    this._getRecentTradesUseCase,
    this._tradingWebSocketService,
  ) : super(const ChartInitial()) {
    on<ChartLoadRequested>(_onChartLoadRequested);
    on<ChartHistoryLoadRequested>(_onChartHistoryLoadRequested);
    on<ChartTimeframeChanged>(_onChartTimeframeChanged);
    on<ChartTypeChanged>(_onChartTypeChanged);
    on<ChartIndicatorToggled>(_onChartIndicatorToggled);
    on<ChartRefreshRequested>(_onChartRefreshRequested);
    on<ChartStartRealtimeRequested>(_onChartStartRealtimeRequested);
    on<ChartStopRealtimeRequested>(_onChartStopRealtimeRequested);
    on<ChartRealtimeDataReceived>(_onChartRealtimeDataReceived);
    on<ChartVolumeToggled>(_onChartVolumeToggled);
    on<ChartMainStateChanged>(_onChartMainStateChanged);
    on<ChartRealtimeTickerReceived>(_onChartRealtimeTickerReceived);
    on<ChartSymbolChanged>(_onChartSymbolChanged);
    on<ChartCleanupRequested>(_onChartCleanupRequested);
  }

  final GetRealtimeTickerUseCase _getRealtimeTickerUseCase;
  final GetChartHistoryUseCase _getChartHistoryUseCase;
  final GetChartWithVolumeUseCase _getChartWithVolumeUseCase;
  final GetRecentTradesUseCase _getRecentTradesUseCase;
  final TradingWebSocketService _tradingWebSocketService;

  // Current chart configuration
  String _currentSymbol = '';
  ChartTimeframe _currentTimeframe = ChartTimeframe.oneHour; // Default 1h
  ChartType _currentChartType = ChartType.candlestick;
  Set<String> _activeIndicators = {};

  // WebSocket subscriptions - now delegated to TradingWebSocketService
  StreamSubscription? _tickerSubscription;
  StreamSubscription? _ohlcvSubscription;
  StreamSubscription? _orderBookSubscription;
  StreamSubscription? _tradesSubscription;
  StreamSubscription? _symbolChangeSubscription;

  FutureOr<void> _onChartLoadRequested(
    ChartLoadRequested event,
    Emitter<ChartState> emit,
  ) async {
    emit(const ChartLoading());

    try {
      _currentSymbol = event.symbol;
      _currentTimeframe = ChartTimeframe.oneHour; // Always start with 1h

      // Subscribe to WebSocket streams immediately
      _subscribeToSharedWebSocketData(event.symbol, _currentTimeframe);

      // Notify the global service about symbol change (no connect needed)
      await _tradingWebSocketService.changeSymbol(event.symbol);

      // Load chart history with default 1h timeframe
      add(ChartHistoryLoadRequested(
        symbol: event.symbol,
        interval: _currentTimeframe,
        limit: 500, // Load 500 candles as per API example
      ));
    } catch (e) {
      emit(ChartError(failure: ServerFailure('Failed to load chart data: $e')));
    }
  }

  Future<void> _onChartHistoryLoadRequested(
    ChartHistoryLoadRequested event,
    Emitter<ChartState> emit,
  ) async {
    emit(const ChartLoading());

    try {
      // Update current configuration
      _currentSymbol = event.symbol;

      // Calculate from and to timestamps for the API call
      final now = DateTime.now();
      final to = now.millisecondsSinceEpoch;
      final from = now
          .subtract(Duration(
            milliseconds: event.interval.milliseconds * (event.limit ?? 500),
          ))
          .millisecondsSinceEpoch;

      // dev.log(
      //     '🎯 CHART_BLOC: Loading chart history for ${event.symbol} with interval ${event.interval.value}');
      // dev.log(
      //     '🎯 CHART_BLOC: From: ${DateTime.fromMillisecondsSinceEpoch(from)} To: ${DateTime.fromMillisecondsSinceEpoch(to)}');

      // Load chart history with volume data from the v5 backend
      final result = await _getChartWithVolumeUseCase(GetChartWithVolumeParams(
        symbol: event.symbol,
        interval: event.interval,
        from: from,
        to: to,
        limit: event.limit,
      ));

      result.fold(
        (failure) {
          dev.log(
              '❌ CHART_BLOC: Failed to load chart history: ${failure.message}');
          emit(ChartError(failure: failure));
        },
        (chartWithVolumeData) {
          // dev.log(
          //     '✅ CHART_BLOC: Received chart data points: ${chartWithVolumeData.chartDataPoints.length}');
          // dev.log(
          //     '✅ CHART_BLOC: Received volume data points: ${chartWithVolumeData.volumeDataPoints.length}');

          if (chartWithVolumeData.chartDataPoints.isNotEmpty) {
            final first = chartWithVolumeData.chartDataPoints.first;
            final last = chartWithVolumeData.chartDataPoints.last;
            // dev.log(
            //     '✅ CHART_BLOC: First candle: ${first.timestamp} - O:${first.open} H:${first.high} L:${first.low} C:${first.close}');
            // dev.log(
            //     '✅ CHART_BLOC: Last candle: ${last.timestamp} - O:${last.open} H:${last.high} L:${last.low} C:${last.close}');
          }

          if (chartWithVolumeData.volumeDataPoints.isNotEmpty) {
            final firstVol = chartWithVolumeData.volumeDataPoints.first;
            final lastVol = chartWithVolumeData.volumeDataPoints.last;
            // dev.log(
            //     '✅ CHART_BLOC: First volume: ${firstVol.timestamp} - Vol:${firstVol.volume}');
            // dev.log(
            //     '✅ CHART_BLOC: Last volume: ${lastVol.timestamp} - Vol:${lastVol.volume}');
          }

          // Convert chart data points with volume to ChartEntity
          final chartData = _buildChartEntityFromHistory(
            event.symbol,
            chartWithVolumeData.chartDataPoints,
            volumeData: chartWithVolumeData.volumeDataPoints,
          );

          // dev.log(
          //     '✅ CHART_BLOC: Built chart entity with price: ${chartData.price}, volume24h: ${chartData.volume24h}');

          emit(ChartLoaded(
            chartData: chartData,
            timeframe: event.interval,
            chartType: _currentChartType,
            activeIndicators: _activeIndicators,
            tickerData: null, // Will be updated when ticker data arrives
          ));

          // Subscribe to shared WebSocket data for this symbol
          _subscribeToSharedWebSocketData(event.symbol, event.interval);
        },
      );
    } catch (e) {
      emit(ChartError(
          failure: ServerFailure('Failed to load chart history: $e')));
    }
  }

  Future<void> _onChartTimeframeChanged(
    ChartTimeframeChanged event,
    Emitter<ChartState> emit,
  ) async {
    // dev.log(
    //     '🎯 CHART_BLOC: Timeframe changed from ${_currentTimeframe.value} to ${event.timeframe.value}');

    final oldTimeframe = _currentTimeframe;
    _currentTimeframe = event.timeframe;

    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      emit(currentState.copyWith(
        timeframe: _currentTimeframe,
        isLoading: true,
      ));

      // Update timeframe in shared WebSocket service
      await _tradingWebSocketService.changeTimeframe(_currentTimeframe);

      // Calculate timestamps for new timeframe
      final now = DateTime.now();
      final to = now.millisecondsSinceEpoch;
      final from = now
          .subtract(Duration(
            milliseconds: _currentTimeframe.milliseconds * 500,
          ))
          .millisecondsSinceEpoch;

      // dev.log(
      //     '🎯 CHART_BLOC: Fetching new chart data for ${_currentTimeframe.value}');

      // Fetch new chart data with volume for the selected timeframe
      final result = await _getChartWithVolumeUseCase(GetChartWithVolumeParams(
        symbol: _currentSymbol,
        interval: _currentTimeframe,
        from: from,
        to: to,
        limit: 500,
      ));

      result.fold(
        (failure) {
          emit(ChartError(failure: failure));
        },
        (chartWithVolumeData) {
          final newChartData = _buildChartEntityFromHistory(
            _currentSymbol,
            chartWithVolumeData.chartDataPoints,
            volumeData: chartWithVolumeData.volumeDataPoints,
          );

          // dev.log(
          //     '🎯 CHART_BLOC: Emitting new chart state for ${_currentTimeframe.value}');
          // dev.log(
          //     '🎯 CHART_BLOC: New chart data - Price points: ${newChartData.priceData.length}, Volume points: ${newChartData.volumeData.length}');
          if (newChartData.priceData.isNotEmpty) {
            // dev.log(
            //     '🎯 CHART_BLOC: Price data range: ${newChartData.priceData.first.timestamp} to ${newChartData.priceData.last.timestamp}');
          }

          emit(currentState.copyWith(
            chartData: newChartData,
            timeframe: _currentTimeframe,
            isLoading: false,
          ));

          // dev.log('🎯 CHART_BLOC: Chart state emitted successfully');
        },
      );
    }
  }

  /// Ensure WebSocket connection via shared TradingWebSocketService
  Future<void> _ensureWebSocketConnection(String symbol) async {
    // dev.log('🔌 CHART_BLOC: Ensuring shared WebSocket connection for $symbol');

    // Connect via shared service if not connected
    if (!_tradingWebSocketService.isConnected ||
        _tradingWebSocketService.currentSymbol != symbol) {
      // dev.log(
      //     '🔌 CHART_BLOC: Connecting to shared WebSocket service for $symbol');
      await _tradingWebSocketService.connect(symbol);
    }
  }

  /// Subscribe to shared WebSocket data streams
  void _subscribeToSharedWebSocketData(
      String symbol, ChartTimeframe timeframe) {
    // dev.log('📡 CHART_BLOC: Subscribing to shared WebSocket data for $symbol');

    // Cancel existing subscriptions
    _cancelWebSocketSubscriptions();

    // Subscribe to ticker data from shared service
    _tickerSubscription = _tradingWebSocketService.chartTickerStream
        .where((data) =>
            data.ticker?.symbol == symbol ||
            data.ticker?.symbol.replaceAll('/', '') ==
                symbol.replaceAll('/', ''))
        .listen(
          (marketData) => _handleSharedTickerData(marketData),
          onError: (error) =>
              dev.log('❌ CHART_BLOC: Shared ticker error: $error'),
        );

    // Subscribe to OHLCV data from shared service
    _ohlcvSubscription = _tradingWebSocketService.ohlcvStream.listen(
      (ohlcvData) => _handleSharedOHLCVData(ohlcvData),
      onError: (error) => dev.log('❌ CHART_BLOC: Shared OHLCV error: $error'),
    );

    // Subscribe to order book data from shared service
    _orderBookSubscription = _tradingWebSocketService.orderBookStream.listen(
      (orderBookData) => _handleSharedOrderBookData(orderBookData),
      onError: (error) => dev.log('❌ CHART_BLOC: Shared OrderBook error: $error'),
    );

    // Subscribe to trades data from shared service
    _tradesSubscription = _tradingWebSocketService.tradesStream.listen(
      (tradesData) => _handleSharedTradesData(tradesData),
      onError: (error) => dev.log('❌ CHART_BLOC: Shared Trades error: $error'),
    );

    // Listen to symbol changes (track subscription so it gets cancelled on
    // close — otherwise it leaks across navigation and may fire on a closed
    // bloc).
    _symbolChangeSubscription =
        _tradingWebSocketService.symbolChangeStream.listen((newSymbol) {
      if (isClosed) return;
      if (newSymbol != _currentSymbol) {
        dev.log('📡 CHART_BLOC: Symbol changed externally to $newSymbol');
        // Optionally handle external symbol changes
      }
    });

    // dev.log('✅ CHART_BLOC: Subscribed to all shared WebSocket streams');
  }

  /// Handle shared ticker data from TradingWebSocketService
  void _handleSharedTickerData(MarketDataEntity marketData) {
    if (isClosed) return;
    try {
      // dev.log(
      //     '📊 CHART_BLOC: Received shared ticker data: ${marketData.ticker?.symbol}');

      if (state is ChartLoaded) {
        final currentState = state as ChartLoaded;
        final ticker = marketData.ticker;

        if (ticker != null) {
          // dev.log(
          //     '🔄 CHART_BLOC: Processing shared ticker - Symbol: ${ticker.symbol}, Price: ${ticker.last}, Change: ${(ticker.change * 100).toStringAsFixed(3)}%');

          // Update chart entity with new ticker data
          var updatedChartData = currentState.chartData.copyWith(
            price: ticker.last,
            change: ticker.change * 100, // Convert to percentage
            changePercent: ticker.change * 100,
            high24h: ticker.high,
            low24h: ticker.low,
            volume24h: ticker.baseVolume,
          );

          // dev.log(
          //     '✅ CHART_BLOC: Updated ticker data via shared service - Price: ${ticker.last}, Change: ${(ticker.change * 100).toStringAsFixed(3)}%');

          // Emit updated state with both chart data and ticker data
          emit(currentState.copyWith(
            chartData: updatedChartData,
            tickerData: marketData,
          ));
        }
      }
    } catch (e) {
      dev.log('❌ CHART_BLOC: Error handling shared ticker data: $e');
    }
  }

  /// Handle shared OHLCV data from TradingWebSocketService
  void _handleSharedOHLCVData(Map<String, dynamic> ohlcvData) {
    if (isClosed) return;
    try {
      // dev.log('📊 CHART_BLOC: Received shared OHLCV data: $ohlcvData');

      if (state is ChartLoaded) {
        final currentState = state as ChartLoaded;

        // Extract OHLCV data
        final timestamp = ohlcvData['timestamp'] as int?;
        final open = ohlcvData['open'] as double?;
        final high = ohlcvData['high'] as double?;
        final low = ohlcvData['low'] as double?;
        final close = ohlcvData['close'] as double?;
        final volume = ohlcvData['volume'] as double?;

        if (timestamp != null &&
            open != null &&
            high != null &&
            low != null &&
            close != null &&
            volume != null) {
          // dev.log(
          //     '📈 CHART_BLOC: Shared OHLCV details - O:$open H:$high L:$low C:$close V:$volume at ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');

          // Create new data points
          final newChartDataPoint = ChartDataPoint(
            timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
            open: open,
            high: high,
            low: low,
            close: close,
          );

          final newVolumeDataPoint = VolumeDataPoint(
            timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
            volume: volume,
          );

          // Update chart data by either updating the last candle or adding a new one
          final updatedPriceData =
              List<ChartDataPoint>.from(currentState.chartData.priceData);
          final updatedVolumeData =
              List<VolumeDataPoint>.from(currentState.chartData.volumeData);

          // Check if this is an update to the last candle or a new candle
          if (updatedPriceData.isNotEmpty &&
              updatedPriceData.last.timestamp.millisecondsSinceEpoch ==
                  timestamp) {
            // Update the last candle
            // dev.log(
            //     '🔄 CHART_BLOC: Updating existing candle via shared service at ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');
            updatedPriceData[updatedPriceData.length - 1] = newChartDataPoint;
            if (updatedVolumeData.isNotEmpty) {
              updatedVolumeData[updatedVolumeData.length - 1] =
                  newVolumeDataPoint;
            }
          } else {
            // Add new candle
            // dev.log(
            //     '🆕 CHART_BLOC: Adding new candle via shared service at ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');
            updatedPriceData.add(newChartDataPoint);
            updatedVolumeData.add(newVolumeDataPoint);

            // Keep only the last 500 candles to prevent memory issues
            if (updatedPriceData.length > 500) {
              updatedPriceData.removeAt(0);
              if (updatedVolumeData.isNotEmpty) {
                updatedVolumeData.removeAt(0);
              }
            }
          }

          // Update the current price in chart entity
          final updatedChartData = currentState.chartData.copyWith(
            price: close,
            priceData: updatedPriceData,
            volumeData: updatedVolumeData,
          );

          // dev.log(
          //     '📊 CHART_BLOC: Updated chart via shared service with ${updatedPriceData.length} candles, current price: \$${close}');
          emit(currentState.copyWith(chartData: updatedChartData));
        }
      }
    } catch (e) {
      dev.log('❌ CHART_BLOC: Error handling shared OHLCV data: $e');
    }
  }

  /// Handle shared order book data from TradingWebSocketService
  void _handleSharedOrderBookData(OrderBookData orderBookData) {
    if (isClosed) return;
    try {
      // dev.log(
      //     '📊 CHART_BLOC: Received shared order book data: ${orderBookData.buyOrders.length} buy + ${orderBookData.sellOrders.length} sell orders');

      if (state is ChartLoaded) {
        final currentState = state as ChartLoaded;

        // Convert OrderBookEntry to DepthDataPoint for chart compatibility
        List<DepthDataPoint> bidsData = orderBookData.buyOrders
            .map((entry) => DepthDataPoint(
                  price: entry.price,
                  volume: entry.quantity,
                ))
            .toList();

        List<DepthDataPoint> asksData = orderBookData.sellOrders
            .map((entry) => DepthDataPoint(
                  price: entry.price,
                  volume: entry.quantity,
                ))
            .toList();

        // dev.log(
        //     '📊 CHART_BLOC: Converted ${bidsData.length} bids and ${asksData.length} asks via shared service');

        // Update chart entity with new orderbook data
        final updatedChartData = currentState.chartData.copyWith(
          bidsData: bidsData,
          asksData: asksData,
        );

        emit(currentState.copyWith(chartData: updatedChartData));
        // dev.log(
        //     '✅ CHART_BLOC: Updated order book via shared service - ${bidsData.length} bids, ${asksData.length} asks');
      }
    } catch (e) {
      dev.log('❌ CHART_BLOC: Error handling shared order book data: $e');
    }
  }

  /// Handle shared trades data from TradingWebSocketService
  void _handleSharedTradesData(List<TradeDataPoint> tradesData) {
    if (isClosed) return;
    try {
      // dev.log(
      //     '📊 CHART_BLOC: Received shared trades data: ${tradesData.length} trades');

      if (state is ChartLoaded) {
        final currentState = state as ChartLoaded;

        if (tradesData.isNotEmpty) {
          // Get existing trades from current state
          final existingTrades =
              List<TradeDataPoint>.from(currentState.chartData.tradesData);

          // Combine new trades with existing ones (new trades first)
          final allTrades = [...tradesData, ...existingTrades];

          // Sort by timestamp (newest first)
          allTrades.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          // Keep only the latest 20 trades for UI display (rolling window)
          final latestTrades = allTrades.take(20).toList();

          // dev.log(
          //     '📊 CHART_BLOC: Added ${tradesData.length} new trades via shared service, keeping latest ${latestTrades.length}');

          // Update chart entity with accumulated trades data
          final updatedChartData = currentState.chartData.copyWith(
            tradesData: latestTrades,
          );

          emit(currentState.copyWith(chartData: updatedChartData));
          // dev.log(
          //     '✅ CHART_BLOC: Updated with ${latestTrades.length} total trades via shared service (newest first)');
        }
      }
    } catch (e) {
      dev.log('❌ CHART_BLOC: Error handling shared trades data: $e');
    }
  }

  /// Cancel WebSocket subscriptions
  void _cancelWebSocketSubscriptions() {
    _tickerSubscription?.cancel();
    _ohlcvSubscription?.cancel();
    _orderBookSubscription?.cancel();
    _tradesSubscription?.cancel();
    _symbolChangeSubscription?.cancel();

    _tickerSubscription = null;
    _ohlcvSubscription = null;
    _orderBookSubscription = null;
    _symbolChangeSubscription = null;
    _tradesSubscription = null;
  }

  void _onChartTypeChanged(
    ChartTypeChanged event,
    Emitter<ChartState> emit,
  ) {
    _currentChartType = event.chartType;

    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      emit(currentState.copyWith(chartType: _currentChartType));
    }
  }

  void _onChartIndicatorToggled(
    ChartIndicatorToggled event,
    Emitter<ChartState> emit,
  ) {
    // dev.log('🎯 CHART_BLOC: Indicator ${event.indicator} toggled');
    // dev.log(
    //     '🎯 CHART_BLOC: Before toggle - active indicators: $_activeIndicators');

    // Create a new Set to avoid mutating the existing one directly
    final updatedIndicators = Set<String>.from(_activeIndicators);

    if (_activeIndicators.contains(event.indicator)) {
      updatedIndicators.remove(event.indicator);
      // dev.log('🎯 CHART_BLOC: Removed ${event.indicator}');
    } else {
      updatedIndicators.add(event.indicator);
      // dev.log('🎯 CHART_BLOC: Added ${event.indicator}');
    }

    // Update the class field after we've created a copy for state emission
    _activeIndicators = updatedIndicators;

    // dev.log(
    //     '🎯 CHART_BLOC: After toggle - active indicators: $_activeIndicators');

    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      // dev.log(
      //     '🎯 CHART_BLOC: Emitting new state with indicators: $_activeIndicators');

      // Emit only one state update with the new indicators
      emit(currentState.copyWith(
        activeIndicators: updatedIndicators,
      ));
    } else {
      // dev.log('🎯 CHART_BLOC: State is not ChartLoaded: ${state.runtimeType}');
    }
  }

  Future<void> _onChartRefreshRequested(
    ChartRefreshRequested event,
    Emitter<ChartState> emit,
  ) async {
    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      emit(currentState.copyWith(isRefreshing: true));

      try {
        // Reload chart history with volume from API
        final result = await _getChartWithVolumeUseCase(
          GetChartWithVolumeParams(
            symbol: _currentSymbol,
            interval: _currentTimeframe,
            limit: 500,
          ),
        );

        result.fold(
          (failure) {
            emit(currentState.copyWith(isRefreshing: false));
            // Keep current data on failure, just stop refreshing
          },
          (chartWithVolumeData) {
            final refreshedChartData = _buildChartEntityFromHistory(
              _currentSymbol,
              chartWithVolumeData.chartDataPoints,
              volumeData: chartWithVolumeData.volumeDataPoints,
            );
            emit(currentState.copyWith(
              chartData: refreshedChartData,
              isRefreshing: false,
            ));
          },
        );
      } catch (e) {
        dev.log('❌ CHART_BLOC: Error during refresh: $e');
        emit(currentState.copyWith(isRefreshing: false));
      }
    }
  }

  Future<void> _onChartStartRealtimeRequested(
    ChartStartRealtimeRequested event,
    Emitter<ChartState> emit,
  ) async {
    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      emit(currentState.copyWith(isRealtime: true));

      // Start subscriptions to shared WebSocket service
      _subscribeToSharedWebSocketData(_currentSymbol, _currentTimeframe);
    }
  }

  Future<void> _onChartStopRealtimeRequested(
    ChartStopRealtimeRequested event,
    Emitter<ChartState> emit,
  ) async {
    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      emit(currentState.copyWith(isRealtime: false));

      // Stop subscriptions (but don't disconnect shared service)
      _cancelWebSocketSubscriptions();
    }
  }

  void _onChartRealtimeDataReceived(
    ChartRealtimeDataReceived event,
    Emitter<ChartState> emit,
  ) {
    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      emit(currentState.copyWith(chartData: event.chartData));
    }
  }

  void _onChartVolumeToggled(
    ChartVolumeToggled event,
    Emitter<ChartState> emit,
  ) {
    // dev.log('🎯 CHART_BLOC: Volume toggled');

    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      final newVolumeVisible = !currentState.volumeVisible;

      // dev.log('🎯 CHART_BLOC: Volume visibility changed to: $newVolumeVisible');

      // Force rebuild with loading state
      emit(currentState.copyWith(isLoading: true));

      emit(currentState.copyWith(
        volumeVisible: newVolumeVisible,
        isLoading: false,
      ));
    }
  }

  void _onChartMainStateChanged(
    ChartMainStateChanged event,
    Emitter<ChartState> emit,
  ) {
    // dev.log('🎯 CHART_BLOC: Main state changed to: ${event.mainState}');

    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;

      // Force rebuild with loading state
      emit(currentState.copyWith(isLoading: true));

      emit(currentState.copyWith(
        mainState: event.mainState,
        isLoading: false,
      ));
    }
  }

  void _onChartRealtimeTickerReceived(
    ChartRealtimeTickerReceived event,
    Emitter<ChartState> emit,
  ) {
    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      emit(currentState.copyWith(tickerData: event.tickerData));
    }
  }

  /// Build ChartEntity from historical chart data points
  ChartEntity _buildChartEntityFromHistory(
      String symbol, List<ChartDataPoint> chartDataPoints,
      {List<VolumeDataPoint>? volumeData}) {
    if (chartDataPoints.isEmpty) {
      // Return minimal chart entity if no data
      return ChartEntity(
        symbol: symbol,
        price: 0.0,
        change: 0.0,
        changePercent: 0.0,
        high24h: 0.0,
        low24h: 0.0,
        volume24h: 0.0,
        marketCap: 0.0,
        priceData: [],
        volumeData: [],
        bidsData: [],
        asksData: [],
      );
    }

    // Calculate derived values
    final currentPrice = chartDataPoints.last.close;
    final firstPrice = chartDataPoints.first.open;
    final change = currentPrice - firstPrice;
    final changePercent = firstPrice != 0 ? (change / firstPrice) * 100 : 0.0;

    // Get 24h high and low
    final high24h =
        chartDataPoints.map((p) => p.high).reduce((a, b) => a > b ? a : b);
    final low24h =
        chartDataPoints.map((p) => p.low).reduce((a, b) => a < b ? a : b);

    // Use provided volume data or create empty list
    final finalVolumeData = volumeData ?? <VolumeDataPoint>[];
    final volume24h = finalVolumeData.isNotEmpty
        ? finalVolumeData.map((v) => v.volume).reduce((a, b) => a + b)
        : 0.0;

    // Initialize empty orderbook data - will be populated by shared WebSocket
    final bidsData = <DepthDataPoint>[];
    final asksData = <DepthDataPoint>[];

    // Estimate market cap based on common supply patterns
    double estimatedMarketCap = 0.0;
    if (symbol.contains('BTC')) {
      estimatedMarketCap = currentPrice * 19700000; // Bitcoin supply
    } else if (symbol.contains('ETH')) {
      estimatedMarketCap = currentPrice * 120000000; // Ethereum supply
    } else {
      estimatedMarketCap = currentPrice * 1000000000; // Generic estimation
    }

    return ChartEntity(
      symbol: symbol,
      price: currentPrice,
      change: change,
      changePercent: changePercent,
      high24h: high24h,
      low24h: low24h,
      volume24h: volume24h,
      marketCap: estimatedMarketCap,
      priceData: chartDataPoints,
      volumeData: finalVolumeData,
      bidsData: bidsData,
      asksData: asksData,
    );
  }

  /// Handle symbol change - use shared service symbol change
  FutureOr<void> _onChartSymbolChanged(
    ChartSymbolChanged event,
    Emitter<ChartState> emit,
  ) async {
    // dev.log(
    //     '🔄 CHART_BLOC: Symbol changing from $_currentSymbol to ${event.newSymbol} via shared service');

    // Show loading state
    emit(const ChartLoading());

    try {
      // Change symbol in shared WebSocket service
      await _tradingWebSocketService.changeSymbol(event.newSymbol);

      // Update current symbol
      _currentSymbol = event.newSymbol;

      // Reload chart data for new symbol
      add(ChartHistoryLoadRequested(
        symbol: event.newSymbol,
        interval: _currentTimeframe,
        limit: 500,
      ));
    } catch (e) {
      dev.log('❌ CHART_BLOC: Error during symbol change: $e');
      emit(
          ChartError(failure: ServerFailure('Error during symbol change: $e')));
    }
  }

  /// Handle cleanup request - stop subscriptions but preserve shared connection
  Future<void> _onChartCleanupRequested(
    ChartCleanupRequested event,
    Emitter<ChartState> emit,
  ) async {
    // dev.log(
    //     '🧹 CHART_BLOC: Cleanup requested - stopping subscriptions but preserving shared connection');

    try {
      // Cancel our subscriptions to shared service (but don't disconnect the service)
      _cancelWebSocketSubscriptions();

      // Clear current symbol
      _currentSymbol = '';

      // dev.log(
      //     '✅ CHART_BLOC: Cleanup completed successfully - shared connection preserved');
    } catch (e) {
      dev.log('❌ CHART_BLOC: Error during cleanup: $e');
    }
  }

  @override
  Future<void> close() async {
    // dev.log('🔄 CHART_BLOC: BLoC closing - stopping subscriptions only');

    // Cancel our subscriptions to shared service (but preserve shared connection)
    _cancelWebSocketSubscriptions();

    return super.close();
  }
}
