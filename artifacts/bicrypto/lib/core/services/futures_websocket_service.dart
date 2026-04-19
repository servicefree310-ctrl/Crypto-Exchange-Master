import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../constants/api_constants.dart';
import '../../features/market/domain/entities/ticker_entity.dart';
import '../../features/trade/presentation/bloc/order_book_bloc.dart';
import '../../features/chart/domain/entities/chart_entity.dart';

/// Lightweight shared WebSocket service for **Futures** trading data.
/// It mirrors [TradingWebSocketService] but connects to `/api/futures/market`.
///
/// Streams currently exposed:
/// * Ticker
/// * Order-book depth
/// * Trades (TODO once backend sends data)
///
/// We keep the implementation intentionally minimal for milestone-1; additional
/// features (positions updates, liquidation alerts, etc.) will be layered later.
@singleton
class FuturesWebSocketService {
  FuturesWebSocketService();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _pingTimer;
  bool _isConnected = false;
  String _currentSymbol = '';

  // Controllers
  final _tickerCtrl = StreamController<TickerEntity>.broadcast();
  final _orderBookCtrl = StreamController<OrderBookData>.broadcast();
  final _tradesCtrl = StreamController<List<TradeDataPoint>>.broadcast();

  // Public streams
  Stream<TickerEntity> get tickerStream => _tickerCtrl.stream;
  Stream<OrderBookData> get orderBookStream => _orderBookCtrl.stream;
  Stream<List<TradeDataPoint>> get tradesStream => _tradesCtrl.stream;

  bool get isConnected => _isConnected;
  String get currentSymbol => _currentSymbol;

  Future<void> connect(String symbol) async {
    // If already connected to the same symbol, nothing to do
    if (_isConnected && symbol == _currentSymbol) {
      dev.log('🔌 FUTURES_WS: Already connected and subscribed to $symbol');
      return;
    }

    // If connected to a different symbol, just change subscriptions
    if (_isConnected && symbol != _currentSymbol) {
      dev.log('🔄 FUTURES_WS: Changing symbol from $_currentSymbol to $symbol');
      await _changeSymbol(symbol);
      return;
    }

    // Not connected, establish new connection
    await _establishConnection(symbol);
  }

  Future<void> _establishConnection(String symbol) async {
    final url = '${ApiConstants.wsBaseUrl}${ApiConstants.wsFuturesMarket}';
    dev.log('🔌 FUTURES_WS: Establishing connection to $url for symbol: $symbol');
    dev.log('🔌 FUTURES_WS: Connecting to $url');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      await _channel!.ready;

      _isConnected = true;
      _currentSymbol = symbol;

      // Listen incoming data
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (e) {
          dev.log('❌ FUTURES_WS error: $e');
          _handleDisconnection();
        },
        onDone: () {
          dev.log('🔌 FUTURES_WS closed');
          _handleDisconnection();
        },
      );

      // Subscribe to initial feeds
      _subscribeToFeeds(symbol);

      // Keep-alive ping every 30s
      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (_channel != null && _isConnected) {
          _sendMessage({'action': 'PING'});
        }
      });

      dev.log('✅ FUTURES_WS: Successfully connected and subscribed to $symbol');
    } catch (e) {
      dev.log('❌ FUTURES_WS connect failed: $e');
      _isConnected = false;
      _currentSymbol = '';
      rethrow;
    }
  }

  Future<void> _changeSymbol(String newSymbol) async {
    // Unsubscribe from old symbol
    _unsubscribeFromFeeds(_currentSymbol);

    // Update current symbol
    final oldSymbol = _currentSymbol;
    _currentSymbol = newSymbol;

    // Subscribe to new symbol
    _subscribeToFeeds(newSymbol);

    dev.log('✅ FUTURES_WS: Changed symbol from $oldSymbol to $newSymbol');
  }

  void _subscribeToFeeds(String symbol) {
    // Following v5 pattern - send subscription messages for each data type
    _sendMessage({
      'action': 'SUBSCRIBE',
      'payload': {'type': 'ticker', 'symbol': symbol},
    });

    _sendMessage({
      'action': 'SUBSCRIBE',
      'payload': {'type': 'orderbook', 'symbol': symbol, 'limit': 15},
    });

    _sendMessage({
      'action': 'SUBSCRIBE',
      'payload': {'type': 'trades', 'symbol': symbol},
    });

    dev.log(
        '📡 FUTURES_WS: Subscribed to ticker, orderbook, and trades for $symbol');
  }

  void _unsubscribeFromFeeds(String symbol) {
    // Following v5 pattern - send unsubscription messages for each data type
    _sendMessage({
      'action': 'UNSUBSCRIBE',
      'payload': {'type': 'ticker', 'symbol': symbol},
    });

    _sendMessage({
      'action': 'UNSUBSCRIBE',
      'payload': {'type': 'orderbook', 'symbol': symbol, 'limit': 15},
    });

    _sendMessage({
      'action': 'UNSUBSCRIBE',
      'payload': {'type': 'trades', 'symbol': symbol},
    });

    dev.log(
        '📡 FUTURES_WS: Unsubscribed from ticker, orderbook, and trades for $symbol');
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (!_isConnected || _channel == null) {
      dev.log('⚠️ FUTURES_WS: Cannot send message - not connected');
      return;
    }

    final jsonMessage = jsonEncode(message);
    try {
      _channel!.sink.add(jsonMessage);
      dev.log('➡️ FUTURES_WS send: $jsonMessage');
      dev.log('➡️ FUTURES_WS send: $jsonMessage');
    } catch (e) {
      dev.log('❌ FUTURES_WS send failed: $e');
    }
  }

  void _handleMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw.toString());
      final stream = data['stream'];
      final payload = data['data'];

      switch (stream) {
        case 'ticker':
          _parseTicker(payload);
          break;
        case 'orderbook':
          _parseOrderBook(payload);
          break;
        case 'trades':
          _parseTrades(payload);
          break;
        default:
          break;
      }
    } catch (e) {
      dev.log('❌ FUTURES_WS handleMessage error: $e');
    }
  }

  void _parseTicker(Map<String, dynamic>? json) {
    if (json == null) return;

    final ticker = TickerEntity(
      symbol: json['symbol'] as String? ?? _currentSymbol,
      last: (json['last'] as num?)?.toDouble() ?? 0.0,
      baseVolume: (json['baseVolume'] as num?)?.toDouble() ?? 0.0,
      quoteVolume: (json['quoteVolume'] as num?)?.toDouble() ?? 0.0,
      change: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      bid: (json['bid'] as num?)?.toDouble() ?? 0.0,
      ask: (json['ask'] as num?)?.toDouble() ?? 0.0,
      high: (json['high'] as num?)?.toDouble() ?? 0.0,
      low: (json['low'] as num?)?.toDouble() ?? 0.0,
      open: (json['open'] as num?)?.toDouble(),
      close: (json['close'] as num?)?.toDouble(),
    );
    _tickerCtrl.add(ticker);
  }

  void _parseOrderBook(Map<String, dynamic>? json) {
    if (json == null) return;
    final bidsRaw = json['bids'] as List<dynamic>?;
    final asksRaw = json['asks'] as List<dynamic>?;

    List<OrderBookEntry> buy = [];
    List<OrderBookEntry> sell = [];

    if (bidsRaw != null) {
      for (final b in bidsRaw) {
        if (b is List && b.length >= 2) {
          buy.add(OrderBookEntry(
            price: (b[0] as num).toDouble(),
            quantity: (b[1] as num).toDouble(),
            total: (b[1] as num).toDouble(),
          ));
        }
      }
    }
    if (asksRaw != null) {
      for (final a in asksRaw) {
        if (a is List && a.length >= 2) {
          sell.add(OrderBookEntry(
            price: (a[0] as num).toDouble(),
            quantity: (a[1] as num).toDouble(),
            total: (a[1] as num).toDouble(),
          ));
        }
      }
    }

    // Optional: sort
    buy.sort((a, b) => b.price.compareTo(a.price));
    sell.sort((a, b) => a.price.compareTo(b.price));

    _orderBookCtrl.add(OrderBookData(
      buyOrders: buy,
      sellOrders: sell,
      spread: sell.isNotEmpty && buy.isNotEmpty
          ? sell.first.price - buy.first.price
          : 0.0,
      midPrice: (sell.isNotEmpty && buy.isNotEmpty)
          ? (sell.first.price + buy.first.price) / 2
          : 0.0,
    ));
    dev.log('⬅️ FUTURES_WS orderbook update (${buy.length}/${sell.length})');
    dev.log('⬅️ FUTURES_WS orderbook update');
  }

  void _parseTrades(dynamic payload) {
    // TODO – implement when backend provides data
    _tradesCtrl.add(const []);
  }

  void _handleDisconnection() {
    _isConnected = false;
    _currentSymbol = '';
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  Future<void> disconnect() async {
    dev.log('🔌 FUTURES_WS: Disconnecting...');

    // Unsubscribe from current symbol before disconnecting
    if (_isConnected && _currentSymbol.isNotEmpty) {
      _unsubscribeFromFeeds(_currentSymbol);
    }

    _pingTimer?.cancel();
    _pingTimer = null;

    await _subscription?.cancel();
    _subscription = null;

    if (_channel != null) {
      try {
        await _channel!.sink.close(ws_status.normalClosure);
      } catch (e) {
        dev.log('⚠️ FUTURES_WS: Error closing channel: $e');
      }
    }

    _channel = null;
    _isConnected = false;
    _currentSymbol = '';

    dev.log('✅ FUTURES_WS: Disconnected');
  }

  @disposeMethod
  void dispose() {
    dev.log('🧹 FUTURES_WS: Disposing service');
    disconnect();
    _tickerCtrl.close();
    _orderBookCtrl.close();
    _tradesCtrl.close();
  }
}
