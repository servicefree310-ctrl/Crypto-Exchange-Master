import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/services/trading_websocket_service.dart';
import '../../../chart/domain/entities/chart_entity.dart';
import '../../../market/domain/entities/market_data_entity.dart';
import '../../domain/usecases/get_trading_chart_history_usecase.dart';

part 'trading_chart_event.dart';
part 'trading_chart_state.dart';

@injectable
class TradingChartBloc extends Bloc<TradingChartEvent, TradingChartState> {
  TradingChartBloc(
    this._getTradingChartHistoryUseCase,
    this._tradingWebSocketService,
  ) : super(const TradingChartInitial()) {
    on<TradingChartInitialized>(_onTradingChartInitialized);
    on<TradingChartExpansionToggled>(_onTradingChartExpansionToggled);
    on<TradingChartHistoryLoaded>(_onTradingChartHistoryLoaded);
    on<TradingChartTimeframeChanged>(_onTradingChartTimeframeChanged);
    on<TradingChartRealtimeDataReceived>(_onTradingChartRealtimeDataReceived);
    on<TradingChartReset>(_onTradingChartReset);
  }

  final GetTradingChartHistoryUseCase _getTradingChartHistoryUseCase;
  final TradingWebSocketService _tradingWebSocketService;

  // Current chart configuration
  String _currentSymbol = '';
  ChartTimeframe _currentTimeframe =
      ChartTimeframe.oneHour; // Default 1h for trading
  bool _isExpanded = false;
  List<ChartDataPoint> _preloadedChartData = [];
  bool _isDataPreloaded = false;

  // WebSocket subscriptions - using shared service
  StreamSubscription? _tickerSubscription;
  StreamSubscription? _ohlcvSubscription;

  Future<void> _onTradingChartInitialized(
    TradingChartInitialized event,
    Emitter<TradingChartState> emit,
  ) async {
    _currentSymbol = event.symbol;
    // dev.log('📈 TRADING_CHART_BLOC: Initialized for symbol: $_currentSymbol');

    emit(TradingChartCollapsed(symbol: event.symbol));

    // Preload chart data in background (silent, no UI loading state)
    _preloadChartDataInBackground();
  }

  Future<void> _preloadChartDataInBackground() async {
    try {
      // dev.log(
      //     '📈 TRADING_CHART_BLOC: Preloading chart history in background (1h)');

      // Calculate from and to timestamps for the API call (same logic as chart_bloc)
      final now = DateTime.now();
      final to = now.millisecondsSinceEpoch;
      final from = now
          .subtract(Duration(
            milliseconds: _currentTimeframe.milliseconds * 100,
          ))
          .millisecondsSinceEpoch;

      // Load chart history from API
      final result =
          await _getTradingChartHistoryUseCase(GetTradingChartHistoryParams(
        symbol: _currentSymbol,
        interval: _currentTimeframe,
        from: from,
        to: to,
        limit: 100,
      ));

      result.fold(
        (failure) {
          dev.log(
              '🔴 TRADING_CHART_BLOC: Background preload failed: ${failure.message}');
          _isDataPreloaded = false;
        },
        (chartDataPoints) {
          // dev.log(
          //     '✅ TRADING_CHART_BLOC: Background preload successful: ${chartDataPoints.length} data points');
          _preloadedChartData = chartDataPoints;
          _isDataPreloaded = true;
        },
      );
    } catch (e) {
      dev.log('🔴 TRADING_CHART_BLOC: Background preload error: $e');
      _isDataPreloaded = false;
    }
  }

  Future<void> _onTradingChartExpansionToggled(
    TradingChartExpansionToggled event,
    Emitter<TradingChartState> emit,
  ) async {
    _isExpanded = !_isExpanded;
    // dev.log('📈 TRADING_CHART_BLOC: Expansion toggled to: $_isExpanded');

    if (_isExpanded) {
      // When expanding, use preloaded data if available
      if (_isDataPreloaded && _preloadedChartData.isNotEmpty) {
        // dev.log('📈 TRADING_CHART_BLOC: Using preloaded data (instant display)');

        // Calculate current price and change from preloaded data
        final currentPrice = _preloadedChartData.last.close;
        final firstPrice = _preloadedChartData.first.open;
        final change = currentPrice - firstPrice;
        final changePercent =
            firstPrice != 0 ? (change / firstPrice) * 100 : 0.0;

        emit(TradingChartExpanded(
          symbol: _currentSymbol,
          chartData: _preloadedChartData,
          timeframe: _currentTimeframe,
          currentPrice: currentPrice,
          changePercent: changePercent,
        ));

        // Subscribe to real-time updates
        _subscribeToSharedWebSocketData(_currentSymbol, _currentTimeframe);
      } else {
        // Fallback: Load data with loading state
        // dev.log('📈 TRADING_CHART_BLOC: No preloaded data, loading...');
        emit(TradingChartLoading(symbol: _currentSymbol));

        // Load chart history
        add(TradingChartHistoryLoaded(
          symbol: _currentSymbol,
          timeframe: _currentTimeframe,
        ));
      }
    } else {
      // When collapsing, return to collapsed state and cleanup subscriptions
      _cancelWebSocketSubscriptions();
      emit(TradingChartCollapsed(symbol: _currentSymbol));
    }
  }

  Future<void> _onTradingChartHistoryLoaded(
    TradingChartHistoryLoaded event,
    Emitter<TradingChartState> emit,
  ) async {
    try {
      // dev.log(
      //     '📈 TRADING_CHART_BLOC: Loading chart history for ${event.symbol} with timeframe ${event.timeframe.value}');

      // Calculate from and to timestamps for the API call (same logic as chart_bloc)
      final now = DateTime.now();
      final to = now.millisecondsSinceEpoch;
      final from = now
          .subtract(Duration(
            milliseconds: event.timeframe.milliseconds *
                (100), // Load 100 candles for trading chart
          ))
          .millisecondsSinceEpoch;

      // Load chart history from API
      final result =
          await _getTradingChartHistoryUseCase(GetTradingChartHistoryParams(
        symbol: event.symbol,
        interval: event.timeframe,
        from: from,
        to: to,
        limit: 100, // Smaller limit for trading chart
      ));

      result.fold(
        (failure) {
          dev.log(
              '❌ TRADING_CHART_BLOC: Failed to load chart history: ${failure.message}');
          emit(TradingChartError(
            message: 'Failed to load chart data: ${failure.message}',
            symbol: event.symbol,
          ));
        },
        (chartDataPoints) {
          // dev.log(
          //     '✅ TRADING_CHART_BLOC: Received ${chartDataPoints.length} chart data points');

          if (chartDataPoints.isNotEmpty) {
            final first = chartDataPoints.first;
            final last = chartDataPoints.last;
            // dev.log(
            //     '✅ TRADING_CHART_BLOC: First candle: ${first.timestamp} - O:${first.open} H:${first.high} L:${first.low} C:${first.close}');
            // dev.log(
            //     '✅ TRADING_CHART_BLOC: Last candle: ${last.timestamp} - O:${last.open} H:${last.high} L:${last.low} C:${last.close}');

            // Calculate current price and change
            final currentPrice = last.close;
            final firstPrice = first.open;
            final change = currentPrice - firstPrice;
            final changePercent =
                firstPrice != 0 ? (change / firstPrice) * 100 : 0.0;

            emit(TradingChartExpanded(
              symbol: event.symbol,
              chartData: chartDataPoints,
              timeframe: event.timeframe,
              currentPrice: currentPrice,
              changePercent: changePercent,
            ));

            // Subscribe to real-time updates
            _subscribeToSharedWebSocketData(event.symbol, event.timeframe);
          } else {
            emit(TradingChartError(
              message: 'No chart data available for this timeframe',
              symbol: event.symbol,
            ));
          }
        },
      );
    } catch (e) {
      emit(TradingChartError(
        message: 'Unexpected error loading chart: $e',
        symbol: event.symbol,
      ));
    }
  }

  Future<void> _onTradingChartTimeframeChanged(
    TradingChartTimeframeChanged event,
    Emitter<TradingChartState> emit,
  ) async {
    // dev.log(
    //     '📈 TRADING_CHART_BLOC: Timeframe changed from ${_currentTimeframe.value} to ${event.timeframe.value}');

    final oldTimeframe = _currentTimeframe;
    _currentTimeframe = event.timeframe;

    // Reset preloaded data when timeframe changes
    _isDataPreloaded = false;
    _preloadedChartData = [];

    if (state is TradingChartExpanded) {
      emit(TradingChartLoading(symbol: _currentSymbol));

      // Update timeframe in shared WebSocket service (unsubscribes old, subscribes new)
      // dev.log(
      //     '📈 TRADING_CHART_BLOC: Calling changeTimeframe - unsubscribing from ${oldTimeframe.value}, subscribing to ${_currentTimeframe.value}');
      await _tradingWebSocketService.changeTimeframe(_currentTimeframe);
      // dev.log(
      //     '📈 TRADING_CHART_BLOC: Timeframe change completed in WebSocket service');

      // Load new chart data for the selected timeframe
      add(TradingChartHistoryLoaded(
        symbol: _currentSymbol,
        timeframe: _currentTimeframe,
      ));
    }

    // Preload data for new timeframe in background
    _preloadChartDataInBackground();
  }

  void _onTradingChartRealtimeDataReceived(
    TradingChartRealtimeDataReceived event,
    Emitter<TradingChartState> emit,
  ) {
    if (state is TradingChartExpanded) {
      final currentState = state as TradingChartExpanded;

      // Update the last candle or add new candle
      final updatedChartData =
          List<ChartDataPoint>.from(currentState.chartData);

      if (updatedChartData.isNotEmpty) {
        final lastCandle = updatedChartData.last;
        final newCandleTime =
            DateTime.fromMillisecondsSinceEpoch(event.timestamp);

        // Check if this is an update to the last candle or a new candle
        if (lastCandle.timestamp.millisecondsSinceEpoch == event.timestamp) {
          // Update the last candle
          updatedChartData[updatedChartData.length - 1] = ChartDataPoint(
            timestamp: newCandleTime,
            open: event.open,
            high: event.high,
            low: event.low,
            close: event.close,
          );
        } else {
          // Add new candle
          updatedChartData.add(ChartDataPoint(
            timestamp: newCandleTime,
            open: event.open,
            high: event.high,
            low: event.low,
            close: event.close,
          ));

          // Keep only the last 100 candles for trading chart
          if (updatedChartData.length > 100) {
            updatedChartData.removeAt(0);
          }
        }

        // Calculate new change percent
        final currentPrice = event.close;
        final firstPrice = updatedChartData.first.open;
        final change = currentPrice - firstPrice;
        final changePercent =
            firstPrice != 0 ? (change / firstPrice) * 100 : 0.0;

        emit(currentState.copyWith(
          chartData: updatedChartData,
          currentPrice: currentPrice,
          changePercent: changePercent,
        ));
      }
    }
  }

  Future<void> _onTradingChartReset(
    TradingChartReset event,
    Emitter<TradingChartState> emit,
  ) async {
    // dev.log('📈 TRADING_CHART_BLOC: Resetting chart');

    _isExpanded = false;
    _currentTimeframe = ChartTimeframe.oneHour;

    // Cancel subscriptions
    _cancelWebSocketSubscriptions();

    if (_currentSymbol.isNotEmpty) {
      emit(TradingChartCollapsed(symbol: _currentSymbol));
    } else {
      emit(const TradingChartInitial());
    }
  }

  /// Subscribe to shared WebSocket data streams
  void _subscribeToSharedWebSocketData(
      String symbol, ChartTimeframe timeframe) {
    // dev.log(
    //     '📈 TRADING_CHART_BLOC: Subscribing to shared WebSocket data for $symbol');

    // Cancel existing subscriptions
    _cancelWebSocketSubscriptions();

    // Subscribe to ticker data from shared service
    _tickerSubscription = _tradingWebSocketService.chartTickerStream.listen(
      (marketData) => _handleSharedTickerData(marketData),
      onError: (error) =>
          dev.log('❌ TRADING_CHART_BLOC: Shared ticker error: $error'),
    );

    // Subscribe to OHLCV data from shared service
    _ohlcvSubscription = _tradingWebSocketService.ohlcvStream.listen(
      (ohlcvData) => _handleSharedOHLCVData(ohlcvData),
      onError: (error) =>
          dev.log('❌ TRADING_CHART_BLOC: Shared OHLCV error: $error'),
    );

    // dev.log('✅ TRADING_CHART_BLOC: Subscribed to shared WebSocket streams');
  }

  /// Handle shared ticker data from TradingWebSocketService
  void _handleSharedTickerData(MarketDataEntity marketData) {
    try {
      // dev.log('📈 TRADING_CHART_BLOC: Received shared ticker data');
      // For trading chart, we mainly rely on OHLCV data for price updates
    } catch (e) {
      dev.log('❌ TRADING_CHART_BLOC: Error handling shared ticker data: $e');
    }
  }

  /// Handle shared OHLCV data from TradingWebSocketService
  void _handleSharedOHLCVData(Map<String, dynamic> ohlcvData) {
    try {
      final stream = ohlcvData['stream'] as String?;
      // dev.log(
      //     '📈 TRADING_CHART_BLOC: Received shared OHLCV data for stream: $stream');
      // dev.log(
      //     '📈 TRADING_CHART_BLOC: Current timeframe: ${_currentTimeframe.value}');

      // Verify this OHLCV data matches our current timeframe
      if (stream != null && !stream.contains(_currentTimeframe.value)) {
        // dev.log(
        //     '📈 TRADING_CHART_BLOC: Ignoring OHLCV data from different timeframe: $stream');
        return;
      }

      // Extract OHLCV data
      int? asInt(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value);
        return null;
      }

      double? asDouble(dynamic value) {
        if (value == null) return null;
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value);
        return null;
      }

      final timestamp = asInt(ohlcvData['timestamp']);
      final open = asDouble(ohlcvData['open']);
      final high = asDouble(ohlcvData['high']);
      final low = asDouble(ohlcvData['low']);
      final close = asDouble(ohlcvData['close']);

      if (timestamp != null &&
          open != null &&
          high != null &&
          low != null &&
          close != null) {
        // dev.log(
        //     '📈 TRADING_CHART_BLOC: Processing OHLCV - O:$open H:$high L:$low C:$close at ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');

        add(TradingChartRealtimeDataReceived(
          timestamp: timestamp,
          open: open,
          high: high,
          low: low,
          close: close,
        ));
      }
    } catch (e) {
      dev.log('❌ TRADING_CHART_BLOC: Error handling shared OHLCV data: $e');
    }
  }

  /// Cancel WebSocket subscriptions
  void _cancelWebSocketSubscriptions() {
    _tickerSubscription?.cancel();
    _ohlcvSubscription?.cancel();
    _tickerSubscription = null;
    _ohlcvSubscription = null;
    // dev.log('📈 TRADING_CHART_BLOC: WebSocket subscriptions canceled');
  }

  @override
  Future<void> close() async {
    // dev.log('📈 TRADING_CHART_BLOC: BLoC closing - stopping subscriptions only');

    // Cancel our subscriptions to shared service (but preserve shared connection)
    _cancelWebSocketSubscriptions();

    return super.close();
  }
}
