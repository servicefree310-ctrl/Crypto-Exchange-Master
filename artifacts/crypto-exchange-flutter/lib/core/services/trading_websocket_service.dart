// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../constants/api_constants.dart';
import '../../features/chart/domain/entities/chart_entity.dart';
import '../../features/market/domain/entities/ticker_entity.dart';
import '../../features/market/domain/entities/market_data_entity.dart';
import '../../features/market/domain/entities/market_entity.dart';
import '../../features/trade/presentation/bloc/order_book_bloc.dart';

@singleton
class TradingWebSocketService {
  TradingWebSocketService() {
    // Auto-connect to default pair after a short delay to allow DI setup
    Timer(const Duration(milliseconds: 500), () {
      dev.log(
          '🚀 TRADING_WS: Auto-connecting to default pair: ${ApiConstants.defaultTradingPair}');
      _connectInternal(ApiConstants.defaultTradingPair);
    });
  }

  // Single WebSocket connection for all market data - SHARED between Chart & Trade
  WebSocketChannel? _marketWsChannel;
  StreamSubscription? _marketWsSubscription;

  // Connection status
  bool _isConnected = false;
  Timer? _pingTimer;
  String _currentSymbol = '';
  ChartTimeframe _currentTimeframe = ChartTimeframe.oneHour;

  // Track active subscriptions with subscription keys
  final Set<String> _activeSubscriptions = {};

  // Last connection time for debugging
  DateTime? _lastConnectionTime;

  // Stream controllers for different data types
  final StreamController<TickerEntity> _tickerController =
      StreamController<TickerEntity>.broadcast();
  final StreamController<OrderBookData> _orderBookController =
      StreamController<OrderBookData>.broadcast();
  final StreamController<List<TradeDataPoint>> _tradesController =
      StreamController<List<TradeDataPoint>>.broadcast();
  final StreamController<Map<String, dynamic>> _ohlcvController =
      StreamController<Map<String, dynamic>>.broadcast();

  // CHART FUNCTIONALITY (moved from ChartRealtimeDataSource)
  final StreamController<MarketDataEntity> _chartTickerController =
      StreamController<MarketDataEntity>.broadcast();

  // Symbol change notifications
  final StreamController<String> _symbolChangeController =
      StreamController<String>.broadcast();

  // Public streams for Trading features
  Stream<TickerEntity> get tickerStream => _tickerController.stream;
  Stream<OrderBookData> get orderBookStream => _orderBookController.stream;
  Stream<List<TradeDataPoint>> get tradesStream => _tradesController.stream;
  Stream<Map<String, dynamic>> get ohlcvStream => _ohlcvController.stream;

  // Public streams for Chart features
  Stream<MarketDataEntity> get chartTickerStream =>
      _chartTickerController.stream;

  // Symbol change stream
  Stream<String> get symbolChangeStream => _symbolChangeController.stream;

  // Connection status
  bool get isConnected => _isConnected;
  String get currentSymbol => _currentSymbol;
  ChartTimeframe get currentTimeframe => _currentTimeframe;

  /// PUBLIC: Change symbol - This is the main method that Chart/Trade should use
  Future<void> changeSymbol(String newSymbol) async {
    if (_currentSymbol == newSymbol) {
      dev.log('🔄 TRADING_WS: Already connected to $newSymbol');
      return;
    }

    dev.log(
        '🔄 TRADING_WS: PUBLIC Symbol change requested from $_currentSymbol to $newSymbol');

    // Notify all listeners about symbol change
    if (!_symbolChangeController.isClosed) _symbolChangeController.add(newSymbol);

    // Handle the symbol change
    await _changeSymbolInternal(newSymbol);
  }

  /// PUBLIC: Change timeframe for OHLCV (Chart feature)
  Future<void> changeTimeframe(ChartTimeframe newTimeframe) async {
    if (_currentTimeframe == newTimeframe) {
      dev.log('🔄 TRADING_WS: Already on timeframe ${newTimeframe.value}');
      return;
    }

    dev.log(
        '🔄 TRADING_WS: Timeframe changing from ${_currentTimeframe.value} to ${newTimeframe.value}');

    // Unsubscribe from old timeframe OHLCV
    await _unsubscribeFromOHLCV(_currentSymbol, _currentTimeframe);

    // Update current timeframe
    _currentTimeframe = newTimeframe;

    // Subscribe to new timeframe OHLCV
    _subscribeToOHLCV(_currentSymbol, newTimeframe);
  }

  /// DEPRECATED: Use changeSymbol() instead
  @Deprecated('Use changeSymbol() instead - this method will be removed')
  Future<void> connect(String symbol) async {
    dev.log(
        '⚠️ TRADING_WS: DEPRECATED connect() called - use changeSymbol() instead');
    await changeSymbol(symbol);
  }

  /// INTERNAL: Connect to WebSocket (only called internally)
  Future<void> _connectInternal(String symbol) async {
    try {
      dev.log('🔍 TRADING_WS: Internal connection attempt for $symbol');

      // Skip if already connected
      if (_isConnected) {
        dev.log('🔄 TRADING_WS: Already connected, changing symbol instead');
        await _changeSymbolInternal(symbol);
        return;
      }

      await _connectMarketWebSocket(symbol);
    } catch (e) {
      dev.log('❌ Failed to connect trading WebSocket: $e');
      _handleDisconnection();
      rethrow;
    }
  }

  /// INTERNAL: Change symbol on existing connection
  Future<void> _changeSymbolInternal(String newSymbol) async {
    if (!_isConnected) {
      dev.log('🔌 TRADING_WS: Not connected, connecting to $newSymbol');
      await _connectInternal(newSymbol);
      return;
    }

    dev.log(
        '🔄 TRADING_WS: Internal symbol changing from $_currentSymbol to $newSymbol');

    // Unsubscribe from current symbol's data
    if (_currentSymbol.isNotEmpty) {
      await _unsubscribeFromAllData(_currentSymbol);
    }

    // Update current symbol
    _currentSymbol = newSymbol;

    // Subscribe to new symbol's data with current timeframe
    _subscribeToMarketData(newSymbol, _currentTimeframe);
  }

  /// Connect to market WebSocket endpoint - SHARED CONNECTION
  Future<void> _connectMarketWebSocket(String symbol) async {
    // CRITICAL: Always close existing connection first to prevent multiple connections
    if (_marketWsChannel != null) {
      dev.log(
          '🔌 TRADING_WS: Existing WebSocket detected, closing it first...');
      await _disconnectMarketWebSocket();
    }

    try {
      // Connect to the single market WebSocket endpoint
      final wsUrl = '${ApiConstants.wsBaseUrl}/api/exchange/market';
      dev.log('🔌 TRADING_WS: Connecting to market WebSocket: $wsUrl');
      dev.log('🚫 TRADING_WS: ENSURING ONLY ONE WEBSOCKET CONNECTION EXISTS');

      _marketWsChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Wait for connection to be ready
      dev.log('🔌 TRADING_WS: Waiting for WebSocket ready...');
      await _marketWsChannel!.ready;

      _isConnected = true;
      _currentSymbol = symbol;
      _lastConnectionTime = DateTime.now();

      dev.log('✅ TRADING_WS: WebSocket connection established for $symbol');
      dev.log('✅ TRADING_WS: Connection established (SINGLETON CONNECTION)');

      // Listen to all market messages
      _marketWsSubscription = _marketWsChannel!.stream.listen(
        (message) => _handleMarketMessage(message),
        onError: (error) {
          dev.log('❌ TRADING_WS: Market WebSocket error: $error');
          _handleDisconnection();
        },
        onDone: () {
          dev.log('🔌 TRADING_WS: Market WebSocket disconnected');
          _handleDisconnection();
        },
      );

      // Subscribe to symbol data for all features (Chart + Trade)
      _subscribeToMarketData(symbol, _currentTimeframe);

      // Start ping timer to keep connection alive
      _startPingTimer();
    } catch (e) {
      dev.log('❌ TRADING_WS: Failed to connect to market WebSocket: $e');
      _handleDisconnection();
      rethrow;
    }
  }

  /// Disconnect from market WebSocket - Internal method for connection management
  Future<void> _disconnectInternal() async {
    if (!_isConnected) return;

    dev.log('🛑 TRADING_WS: Internal disconnecting...');

    _pingTimer?.cancel();
    _pingTimer = null;

    await _marketWsSubscription?.cancel();
    await _marketWsChannel?.sink.close();

    _marketWsChannel = null;
    _marketWsSubscription = null;
    _isConnected = false;
    _currentSymbol = '';
    _activeSubscriptions.clear();

    dev.log('🔌 TRADING_WS: Connection state reset due to disconnection');
  }

  /// Disconnect from market WebSocket - Complete cleanup (use sparingly)
  Future<void> _disconnectMarketWebSocket() async {
    if (_marketWsChannel != null) {
      try {
        dev.log('🔌 TRADING_WS: Disconnecting from market WebSocket...');

        await _marketWsSubscription?.cancel();
        await _marketWsChannel!.sink.close(ws_status.normalClosure);

        _marketWsChannel = null;
        _marketWsSubscription = null;
        _activeSubscriptions.clear();

        dev.log(
            '✅ TRADING_WS: Successfully disconnected from market WebSocket');
      } catch (e) {
        dev.log('❌ TRADING_WS: Error disconnecting from market WebSocket: $e');
        // Force cleanup even if error occurred
        _marketWsChannel = null;
        _marketWsSubscription = null;
        _activeSubscriptions.clear();
      }
    } else {
      dev.log('🔌 TRADING_WS: No WebSocket connection to disconnect');
    }
  }

  /// Subscribe to all market data types for a symbol - Core logic from ChartBloc
  void _subscribeToMarketData(String symbol, ChartTimeframe timeframe) {
    dev.log('📡 TRADING_WS: Subscribing to all market data for $symbol');
    _subscribeToTicker(symbol);
    _subscribeToOHLCV(symbol, timeframe);
    _subscribeToOrderbook(symbol);
    _subscribeToTrades(symbol);
  }

  /// Subscribe to ticker data - Logic from ChartBloc
  void _subscribeToTicker(String symbol) {
    final formattedSymbol = _formatSymbolForWs(symbol);
    final subscriptionKey = 'ticker:$formattedSymbol';

    if (_activeSubscriptions.contains(subscriptionKey)) {
      dev.log(
          '🎯 TRADING_WS: Already subscribed to ticker for $formattedSymbol');
      return;
    }

    final message = {
      "action": "SUBSCRIBE",
      "payload": {"type": "ticker", "symbol": formattedSymbol}
    };

    _sendMessage(message);
    _activeSubscriptions.add(subscriptionKey);
    dev.log('📡 TRADING_WS: Subscribed to ticker for $formattedSymbol');
  }

  /// Subscribe to OHLCV data - Logic from ChartBloc
  void _subscribeToOHLCV(String symbol, ChartTimeframe timeframe) {
    final formattedSymbol = _formatSymbolForWs(symbol);
    final subscriptionKey = 'ohlcv:$formattedSymbol:${timeframe.value}';

    if (_activeSubscriptions.contains(subscriptionKey)) {
      dev.log(
          '🎯 TRADING_WS: Already subscribed to OHLCV ${timeframe.value} for $formattedSymbol');
      return;
    }

    final message = {
      "action": "SUBSCRIBE",
      "payload": {
        "type": "ohlcv",
        "interval": timeframe.value,
        "symbol": formattedSymbol
      }
    };

    _sendMessage(message);
    _activeSubscriptions.add(subscriptionKey);
    dev.log(
        '📡 TRADING_WS: Subscribed to OHLCV ${timeframe.value} for $formattedSymbol');
  }

  /// Subscribe to orderbook data - Logic from ChartBloc
  void _subscribeToOrderbook(String symbol) {
    final formattedSymbol = _formatSymbolForWs(symbol);
    final subscriptionKey = 'orderbook:$formattedSymbol';

    if (_activeSubscriptions.contains(subscriptionKey)) {
      dev.log(
          '🎯 TRADING_WS: Already subscribed to orderbook for $formattedSymbol');
      return;
    }

    final message = {
      "action": "SUBSCRIBE",
      "payload": {"type": "orderbook", "limit": 15, "symbol": formattedSymbol}
    };

    _sendMessage(message);
    _activeSubscriptions.add(subscriptionKey);
    dev.log('📡 TRADING_WS: Subscribed to orderbook for $formattedSymbol');
  }

  /// Subscribe to trades data - Logic from ChartBloc
  void _subscribeToTrades(String symbol) {
    final formattedSymbol = _formatSymbolForWs(symbol);
    final subscriptionKey = 'trades:$formattedSymbol';

    if (_activeSubscriptions.contains(subscriptionKey)) {
      dev.log(
          '🎯 TRADING_WS: Already subscribed to trades for $formattedSymbol');
      return;
    }

    final message = {
      "action": "SUBSCRIBE",
      "payload": {"type": "trades", "symbol": formattedSymbol}
    };

    _sendMessage(message);
    _activeSubscriptions.add(subscriptionKey);
    dev.log('📡 TRADING_WS: Subscribed to trades for $formattedSymbol');
  }

  /// Unsubscribe from OHLCV data only (for timeframe changes) - Logic from ChartBloc
  Future<void> _unsubscribeFromOHLCV(
      String symbol, ChartTimeframe timeframe) async {
    final formattedSymbol = _formatSymbolForWs(symbol);
    final subscriptionKey = 'ohlcv:$formattedSymbol:${timeframe.value}';

    if (!_activeSubscriptions.contains(subscriptionKey)) {
      dev.log(
          '🎯 TRADING_WS: Not subscribed to OHLCV ${timeframe.value} for $formattedSymbol');
      return;
    }

    final message = {
      "action": "UNSUBSCRIBE",
      "payload": {
        "type": "ohlcv",
        "interval": timeframe.value,
        "symbol": formattedSymbol
      }
    };

    _sendMessage(message);
    _activeSubscriptions.remove(subscriptionKey);
    dev.log(
        '📡 TRADING_WS: Unsubscribed from OHLCV ${timeframe.value} for $formattedSymbol');
  }

  /// Unsubscribe from all data for a symbol (for symbol changes) - Logic from ChartBloc
  Future<void> _unsubscribeFromAllData(String symbol) async {
    final formattedSymbol = _formatSymbolForWs(symbol);

    // Get current timeframe from active subscriptions or use default
    ChartTimeframe currentTimeframe = ChartTimeframe.oneHour;
    for (final subscription in _activeSubscriptions) {
      if (subscription.contains('ohlcv:$formattedSymbol:')) {
        final parts = subscription.split(':');
        if (parts.length >= 3) {
          final interval = parts[2];
          currentTimeframe = ChartTimeframe.values.firstWhere(
            (tf) => tf.value == interval,
            orElse: () => ChartTimeframe.oneHour,
          );
          break;
        }
      }
    }

    // Unsubscribe from all data types
    final messagesToSend = [
      {
        "action": "UNSUBSCRIBE",
        "payload": {"type": "ticker", "symbol": formattedSymbol}
      },
      {
        "action": "UNSUBSCRIBE",
        "payload": {
          "type": "ohlcv",
          "interval": currentTimeframe.value,
          "symbol": formattedSymbol
        }
      },
      {
        "action": "UNSUBSCRIBE",
        "payload": {"type": "orderbook", "limit": 15, "symbol": formattedSymbol}
      },
      {
        "action": "UNSUBSCRIBE",
        "payload": {"type": "trades", "symbol": formattedSymbol}
      },
    ];

    for (final message in messagesToSend) {
      _sendMessage(message);
    }

    // Remove all subscriptions for this symbol
    _activeSubscriptions.removeWhere((key) => key.contains(formattedSymbol));
    dev.log('📡 TRADING_WS: Unsubscribed from all data for $formattedSymbol');
  }

  /// Send message to WebSocket - Logic from ChartBloc
  void _sendMessage(Map<String, dynamic> message) {
    if (_marketWsChannel != null) {
      final jsonMessage = jsonEncode(message);
      _marketWsChannel!.sink.add(jsonMessage);
      // dev.log('📤 TRADING_WS_SEND: $jsonMessage');
    } else {
      dev.log('❌ TRADING_WS: Cannot send message - WebSocket not connected');
    }
  }

  /// Handle incoming market WebSocket messages - Logic from ChartBloc
  void _handleMarketMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      // dev.log('📥 TRADING_WS_RECEIVE: $data');

      final stream = data['stream'];
      final messageData = data['data'];

      if (stream != null && messageData != null) {
        // Handle different stream types
        if (stream == 'ticker') {
          _handleTickerData(messageData);
        } else if (stream.startsWith('ohlcv')) {
          _handleOHLCVData(messageData, stream);
        } else if (stream.startsWith('orderbook')) {
          _handleOrderbookData(messageData);
        } else if (stream == 'trades') {
          _handleTradesData(messageData);
        }
      }
    } catch (e) {
      dev.log('❌ TRADING_WS: Error handling market message: $e');
    }
  }

  double _toDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  String _toStringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  /// Handle ticker data updates - Enhanced logic from ChartBloc
  void _handleTickerData(dynamic tickerData) {
    try {
      // dev.log('📊 TRADING_WS: Received ticker data: $tickerData');

      if (tickerData is Map<String, dynamic>) {
        // Extract data from WebSocket ticker format
        final symbol =
            _toStringValue(tickerData['symbol'], fallback: _currentSymbol);
        final closeValue = _toDouble(tickerData['close']);
        final lastValue = _toDouble(tickerData['last']);
        final last = lastValue > 0 ? lastValue : closeValue;
        final high = _toDouble(tickerData['high']);
        final low = _toDouble(tickerData['low']);
        final bid = _toDouble(tickerData['bid']);
        final ask = _toDouble(tickerData['ask']);
        final percentage = _toDouble(tickerData['percentage']);
        final baseVolume = _toDouble(tickerData['baseVolume']);
        final quoteVolume = _toDouble(tickerData['quoteVolume']);
        final open =
            tickerData['open'] == null ? null : _toDouble(tickerData['open']);
        final close = closeValue > 0 ? closeValue : last;

        // dev.log(
        //     '🔄 TRADING_WS: Creating ticker entity - Symbol: $symbol, Price: $last, Change: ${percentage.toStringAsFixed(3)}%');

        // Create TickerEntity for Trading features
        final tickerEntity = TickerEntity(
          symbol: symbol,
          last: last,
          baseVolume: baseVolume,
          quoteVolume: quoteVolume,
          change: percentage / 100.0, // Convert percentage to decimal
          bid: bid,
          ask: ask,
          high: high,
          low: low,
          open: open,
          close: close,
        );

        // Emit to Trading streams
        dev.log(
            '📊 TRADING_WS: Ticker - ${tickerEntity.symbol}: ${tickerEntity.last} (${tickerEntity.change}%)');
        if (!_tickerController.isClosed) _tickerController.add(tickerEntity);

        // Create MarketDataEntity for Chart features
        if (last > 0) {
          final marketEntity = MarketEntity(
            id: symbol,
            symbol: symbol,
            currency: symbol.split('/')[0],
            pair: symbol.split('/').length > 1 ? symbol.split('/')[1] : 'USDT',
            isTrending: false,
            isHot: false,
            status: true,
            isEco: false,
            icon: null,
            taker: 0.0,
            maker: 0.0,
          );

          final chartMarketData = MarketDataEntity(
            market: marketEntity,
            ticker: tickerEntity,
          );

          // Emit to Chart streams
          // dev.log(
          //     '✅ TRADING_WS: Updated ticker data for Chart - Price: $last, Change: ${percentage.toStringAsFixed(3)}%');
          if (!_chartTickerController.isClosed) _chartTickerController.add(chartMarketData);
        }
      }
    } catch (e) {
      dev.log('❌ TRADING_WS: Error handling ticker data: $e');
    }
  }

  /// Handle OHLCV data updates - Logic from ChartBloc
  void _handleOHLCVData(dynamic ohlcvData, String stream) {
    try {
      // dev.log('📊 TRADING_WS: Received OHLCV data for $stream: $ohlcvData');

      // Check if ohlcvData is a list of lists (array of OHLCV data points)
      if (ohlcvData is List) {
        // Handle both single OHLCV point and array of OHLCV points
        if (ohlcvData.isEmpty) {
          // dev.log('📊 TRADING_WS: Empty OHLCV data received');
          return;
        }

        // If it's an array of OHLCV points (list of lists)
        if (ohlcvData[0] is List) {
          // Process the most recent candle (last item in the array)
          final latestCandle = ohlcvData.last;
          if (latestCandle is List && latestCandle.length >= 6) {
            _processOHLCVCandle(latestCandle, stream);
          }

          // Also emit the full array for historical data purposes
          final fullOhlcvMap = {
            'candles': ohlcvData,
            'stream': stream,
          };
          if (!_ohlcvController.isClosed) _ohlcvController.add(fullOhlcvMap);

          // dev.log('📊 TRADING_WS: Processed ${ohlcvData.length} OHLCV candles');
        }
        // If it's a single OHLCV point (direct array with values)
        else if (ohlcvData.length >= 6) {
          _processOHLCVCandle(ohlcvData, stream);
        }
      }
    } catch (e) {
      dev.log('❌ TRADING_WS: Error handling OHLCV data: $e');
    }
  }

  /// Process a single OHLCV candle
  void _processOHLCVCandle(List<dynamic> candle, String stream) {
    try {
      // Parse OHLCV data array format: [timestamp, open, high, low, close, volume]
      final timestamp = _toInt(candle[0]);
      final open = _toDouble(candle[1]);
      final high = _toDouble(candle[2]);
      final low = _toDouble(candle[3]);
      final close = _toDouble(candle[4]);
      final volume = _toDouble(candle[5]);

      // dev.log(
      //     '📈 TRADING_WS: OHLCV details - O:$open H:$high L:$low C:$close V:$volume at ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');

      // Emit to OHLCV stream for both Chart and Trade features
      final ohlcvMap = {
        'timestamp': timestamp,
        'open': open,
        'high': high,
        'low': low,
        'close': close,
        'volume': volume,
        'stream': stream,
      };

      dev.log('📊 TRADING_WS: OHLCV data processed');
      if (!_ohlcvController.isClosed) _ohlcvController.add(ohlcvMap);
    } catch (e) {
      dev.log('❌ TRADING_WS: Error processing OHLCV candle: $e');
    }
  }

  /// Handle orderbook data updates - Enhanced logic from ChartBloc
  void _handleOrderbookData(dynamic orderbookData) {
    try {
      // dev.log('📊 TRADING_WS: Received orderbook data: $orderbookData');

      if (orderbookData is Map<String, dynamic>) {
        // Parse orderbook data
        final bidsRaw = orderbookData['bids'] as List<dynamic>?;
        final asksRaw = orderbookData['asks'] as List<dynamic>?;

        List<OrderBookEntry> bids = [];
        List<OrderBookEntry> asks = [];

        // Parse bids (buy orders) - highest prices first
        if (bidsRaw != null) {
          for (final bid in bidsRaw) {
            if (bid is List && bid.length >= 2) {
              final price = _toDouble(bid[0]);
              final volume = _toDouble(bid[1]);
              bids.add(OrderBookEntry(
                price: price,
                quantity: volume,
                total: volume,
              ));
            }
          }
          // Sort bids: highest price first (descending)
          bids.sort((a, b) => b.price.compareTo(a.price));
        }

        // Parse asks (sell orders) - lowest prices first
        if (asksRaw != null) {
          for (final ask in asksRaw) {
            if (ask is List && ask.length >= 2) {
              final price = _toDouble(ask[0]);
              final volume = _toDouble(ask[1]);
              asks.add(OrderBookEntry(
                price: price,
                quantity: volume,
                total: volume,
              ));
            }
          }
          // Sort asks: lowest price first (ascending)
          asks.sort((a, b) => a.price.compareTo(b.price));
        }

        // dev.log(
        //     '📊 TRADING_WS: Parsed ${bids.length} bids and ${asks.length} asks with proper sorting');

        // Calculate spread
        final spread = asks.isNotEmpty && bids.isNotEmpty
            ? asks.first.price - bids.first.price
            : 0.0;

        final midPrice = asks.isNotEmpty && bids.isNotEmpty
            ? (asks.first.price + bids.first.price) / 2
            : 0.0;

        // Create properly structured order book data
        final orderBookData = OrderBookData(
          sellOrders: asks.take(10).toList(), // Limit to 10 for UI
          buyOrders: bids.take(10).toList(), // Limit to 10 for UI
          spread: spread,
          midPrice: midPrice,
        );

        // Emit to OrderBook stream
        dev.log(
            '📊 TRADING_WS: OrderBook - ${bids.length} bids, ${asks.length} asks, spread: ${spread.toStringAsFixed(8)}');
        if (!_orderBookController.isClosed) _orderBookController.add(orderBookData);
      }
    } catch (e) {
      dev.log('❌ TRADING_WS: Error handling orderbook data: $e');
    }
  }

  /// Handle trades data updates - Enhanced logic from ChartBloc
  void _handleTradesData(dynamic tradesData) {
    try {
      // dev.log('📊 TRADING_WS: Received trades data: $tradesData');

      if (tradesData is List<dynamic>) {
        // Parse new incoming trades
        List<TradeDataPoint> newTrades = [];

        for (final trade in tradesData) {
          if (trade is Map<String, dynamic>) {
            try {
              final price = _toDouble(trade['price']);
              final amount = _toDouble(trade['amount']);
              final timestamp = DateTime.fromMillisecondsSinceEpoch(_toInt(
                  trade['timestamp'],
                  fallback: DateTime.now().millisecondsSinceEpoch));
              final side = _toStringValue(trade['side']).toLowerCase();
              final type = _toStringValue(trade['type']).toLowerCase();
              final isBuy = side == 'buy' ||
                  type == 'buy' ||
                  (trade['isBuy'] as bool?) == true;

              newTrades.add(TradeDataPoint(
                price: price,
                amount: amount,
                timestamp: timestamp,
                isBuy: isBuy,
              ));
            } catch (e) {
              dev.log('❌ TRADING_WS: Error parsing individual trade: $e');
            }
          }
        }

        if (newTrades.isNotEmpty) {
          // dev.log('📊 TRADING_WS: Processed ${newTrades.length} new trades');

          // Emit to Trades stream
          dev.log('📊 TRADING_WS: Trades - ${newTrades.length} trades');
          if (!_tradesController.isClosed) _tradesController.add(newTrades);
        }
      }
    } catch (e) {
      dev.log('❌ TRADING_WS: Error handling trades data: $e');
    }
  }

  /// Format symbol for WebSocket - Consistent with backend format
  String _formatSymbolForWs(String symbol) {
    if (symbol.contains('/')) {
      return symbol; // Keep BTC/USDT format as-is for backend consistency
    }

    // Handle common quote currencies - convert to BTC/USDT format
    final quoteCurrencies = ['USDT', 'USD', 'BTC', 'ETH', 'BNB'];

    for (final quote in quoteCurrencies) {
      if (symbol.endsWith(quote)) {
        final base = symbol.substring(0, symbol.length - quote.length);
        return '$base/$quote'; // Convert BTCUSDT to BTC/USDT
      }
    }

    // Fallback: assume last 4 characters are quote currency
    if (symbol.length > 4) {
      final base = symbol.substring(0, symbol.length - 4);
      final quote = symbol.substring(symbol.length - 4);
      return '$base/$quote';
    }

    return symbol;
  }

  /// Start ping timer to keep connection alive
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _marketWsChannel != null) {
        _marketWsChannel!.sink.add(jsonEncode({"action": "PING"}));
        dev.log('💓 TRADING_WS: Ping sent');
      }
    });
  }

  /// Handle disconnection - Reset state
  void _handleDisconnection() {
    _isConnected = false;
    _pingTimer?.cancel();
    _pingTimer = null;
    _marketWsChannel = null;
    _marketWsSubscription = null;
    _activeSubscriptions.clear();

    dev.log('🔌 TRADING_WS: Connection state reset due to disconnection');
  }

  // ========================================
  // PUBLIC METHODS FOR CHART & TRADE FEATURES
  // ========================================

  /// Subscribe to symbol ticker (Chart feature)
  Stream<MarketDataEntity> subscribeToSymbolTicker(String symbol) {
    dev.log(
        '📊 CHART_DATASOURCE: Subscribing to $symbol via TradingWebSocketService');

    // Ensure connection exists for this symbol
    if (!_isConnected || _currentSymbol != symbol) {
      connect(symbol);
    }

    return chartTickerStream.where((data) =>
        data.ticker?.symbol == symbol ||
        data.ticker?.symbol.replaceAll('/', '') == symbol.replaceAll('/', ''));
  }

  /// Unsubscribe from symbol (Chart feature)
  Future<void> unsubscribeFromSymbol(String symbol) async {
    dev.log(
        '📊 CHART_DATASOURCE: Unsubscribing from $symbol via TradingWebSocketService');
    // Note: We don't actually unsubscribe to maintain shared connection
    // This method exists for compatibility but doesn't break the shared connection
  }

  /// PUBLIC: Disconnect (use sparingly - this will affect all features)
  Future<void> disconnect() async {
    dev.log(
        '🛑 TRADING_WS: Public disconnect requested - this will affect all features');
    await _disconnectMarketWebSocket();
    _handleDisconnection();
  }

  /// Dispose service - Clean shutdown
  void dispose() {
    dev.log('🧹 TRADING_WS: Disposing service - cleaning up all connections');
    disconnect();
    _tickerController.close();
    _orderBookController.close();
    _tradesController.close();
    _ohlcvController.close();
    _chartTickerController.close();
    _symbolChangeController.close();
  }

  // ---------------------------------------------------------------------------
  // Test-only seam. Do NOT call from production code.
  // Lets regression tests drive the private message-parsing path directly so
  // the per-controller `isClosed` guards (added for the closed-controller crash
  // fix) can be exercised without standing up a real WebSocket.
  // ---------------------------------------------------------------------------

  @visibleForTesting
  void debugInjectMarketMessage(dynamic raw) => _handleMarketMessage(raw);
}
