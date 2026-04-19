import 'dart:async';
import 'dart:developer' as dev;

import 'package:injectable/injectable.dart';

import '../../../../core/services/websocket_service.dart';
import '../models/ticker_model.dart';

abstract class MarketRealtimeDataSource {
  Stream<Map<String, TickerModel>> get tickersStream;
  Future<void> startRealtimeUpdates();
  Future<void> stopRealtimeUpdates();
  bool get isConnected;
  Stream<WebSocketConnectionStatus> get connectionStatusStream;
}

@Injectable(as: MarketRealtimeDataSource)
class MarketRealtimeDataSourceImpl implements MarketRealtimeDataSource {
  final WebSocketService _webSocketService;

  // Stream controllers
  final StreamController<Map<String, TickerModel>> _tickersController =
      StreamController<Map<String, TickerModel>>.broadcast();

  // Cache for the latest ticker data
  final Map<String, TickerModel> _latestTickers = {};

  // Subscription management
  StreamSubscription<Map<String, dynamic>>? _webSocketSubscription;
  bool _isActive = false;

  MarketRealtimeDataSourceImpl(this._webSocketService);

  @override
  Stream<Map<String, TickerModel>> get tickersStream =>
      _tickersController.stream;

  @override
  bool get isConnected => _webSocketService.isConnected;

  @override
  Stream<WebSocketConnectionStatus> get connectionStatusStream =>
      _webSocketService.statusStream;

  @override
  Future<void> startRealtimeUpdates() async {
    if (_isActive) return;

    dev.log('🚀 Starting real-time market updates');
    _isActive = true;

    // Initialize WebSocket connection
    await _webSocketService.initialize();
    await _webSocketService.subscribeToTickers();

    // Listen to incoming ticker data
    _webSocketSubscription = _webSocketService.tickersStream.listen(
      _handleTickerUpdate,
      onError: _handleError,
    );
    dev.log('✅ Real-time updates active');
  }

  @override
  Future<void> stopRealtimeUpdates() async {
    if (!_isActive) return;

    dev.log('🛑 Stopping real-time updates');
    _isActive = false;

    // Cancel WebSocket subscription
    await _webSocketSubscription?.cancel();
    _webSocketSubscription = null;

    // Unsubscribe from ticker updates
    await _webSocketService.unsubscribeFromTickers();

    // Disconnect WebSocket completely
    await _webSocketService.disconnect();

    // Clear cache
    _latestTickers.clear();

    dev.log('✅ Real-time updates stopped');
  }

  /// Handle incoming ticker updates from WebSocket
  void _handleTickerUpdate(Map<String, dynamic> rawData) {
    try {
      final Map<String, TickerModel> updatedTickers = {};

      // Parse each ticker in the update
      for (final entry in rawData.entries) {
        final symbol = entry.key;
        final tickerData = entry.value;

        if (tickerData is Map<String, dynamic>) {
          try {
            // Create TickerModel from WebSocket data
            final ticker = TickerModel(
              symbol: symbol,
              last: _parseDouble(tickerData['last']),
              baseVolume: _parseDouble(tickerData['baseVolume']),
              quoteVolume: _parseDouble(tickerData['quoteVolume']),
              change: _parseDouble(tickerData['change']),
              bid: _latestTickers[symbol]
                  ?.bid, // Keep existing bid if not provided
              ask: _latestTickers[symbol]
                  ?.ask, // Keep existing ask if not provided
              high: _latestTickers[symbol]
                  ?.high, // Keep existing high if not provided
              low: _latestTickers[symbol]
                  ?.low, // Keep existing low if not provided
              open: _latestTickers[symbol]
                  ?.open, // Keep existing open if not provided
              close: _latestTickers[symbol]
                  ?.close, // Keep existing close if not provided
            );

            updatedTickers[symbol] = ticker;
            _latestTickers[symbol] = ticker;
          } catch (e) {
            dev.log('Error parsing ticker for $symbol: $e');
            // Keep the existing ticker if parsing fails
            if (_latestTickers.containsKey(symbol)) {
              updatedTickers[symbol] = _latestTickers[symbol]!;
            }
          }
        }
      }

      // Emit the updated tickers
      if (updatedTickers.isNotEmpty) {
        _tickersController.add(Map.from(_latestTickers));
      }
    } catch (error) {
      dev.log('Error handling ticker update: $error');
    }
  }

  /// Handle WebSocket errors
  void _handleError(dynamic error) {
    dev.log('WebSocket ticker stream error: $error');
  }

  /// Parse double value safely
  double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }

    return null;
  }

  /// Get current ticker data for a specific symbol
  TickerModel? getTickerForSymbol(String symbol) {
    return _latestTickers[symbol];
  }

  /// Get all current ticker data
  Map<String, TickerModel> getAllTickers() {
    return Map.from(_latestTickers);
  }

  /// Dispose of the data source
  Future<void> dispose() async {
    await stopRealtimeUpdates();
    await _tickersController.close();
  }
}
