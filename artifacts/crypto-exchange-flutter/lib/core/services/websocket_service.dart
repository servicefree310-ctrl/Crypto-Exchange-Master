import 'dart:async';
import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math' as math;
import 'dart:developer' as dev;

import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../constants/api_constants.dart';
import 'market_service.dart';

enum WebSocketConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
  reconnecting,
}

class WebSocketMessage {
  final String action;
  final Map<String, dynamic> payload;

  const WebSocketMessage({
    required this.action,
    required this.payload,
  });

  Map<String, dynamic> toJson() => {
        'action': action,
        'payload': payload,
      };
}

@lazySingleton
class WebSocketService {
  WebSocketService(this._marketService);

  final MarketService _marketService;

  WebSocketChannel? _channel;
  WebSocketConnectionStatus _status = WebSocketConnectionStatus.disconnected;
  bool _manuallyDisconnected = false;

  // Global state management
  static bool _isGlobalInitialized = false;
  static int _globalSubscriptionCount = 0;
  static Timer? _autoDisconnectTimer;

  // Stream controllers for different data types
  final StreamController<Map<String, dynamic>> _tickersController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<WebSocketConnectionStatus> _statusController =
      StreamController<WebSocketConnectionStatus>.broadcast();

  // Subscription management
  final Set<String> _activeSubscriptions = <String>{};

  // Reconnection management
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  // Message queue for when disconnected
  final List<WebSocketMessage> _messageQueue = [];

  // Performance optimization - debounced updates
  Timer? _updateDebounceTimer;
  Map<String, dynamic>? _pendingTickerUpdate;
  static const Duration _updateDebounceDelay = Duration(milliseconds: 100);

  // Auto-disconnect delay when no subscribers
  static const Duration _autoDisconnectDelay = Duration(seconds: 10);

  // Getters
  Stream<Map<String, dynamic>> get tickersStream => _tickersController.stream;
  Stream<WebSocketConnectionStatus> get statusStream =>
      _statusController.stream;
  WebSocketConnectionStatus get status => _status;
  bool get isConnected => _status == WebSocketConnectionStatus.connected;
  bool get isGlobalInitialized => _isGlobalInitialized;
  int get globalSubscriptionCount => _globalSubscriptionCount;

  /// Initialize the global WebSocket service (called once from main.dart)
  Future<void> initializeGlobal() async {
    if (_isGlobalInitialized) {
      dev.log('🔄 TICKER_WS: Global service already initialized');
      return;
    }

    dev.log('🚀 TICKER_WS: Initializing global ticker service');
    _isGlobalInitialized = true;
    await _connect();
  }

  /// Initialize the WebSocket service (legacy method for backward compatibility)
  Future<void> initialize() async {
    if (_status != WebSocketConnectionStatus.disconnected) {
      return;
    }

    _manuallyDisconnected = false;
    await _connect();
  }

  /// Connect to the WebSocket server
  Future<void> _connect() async {
    // Force close any existing connection first
    if (_status == WebSocketConnectionStatus.connecting ||
        _status == WebSocketConnectionStatus.connected) {
      dev.log('🔄 TICKER_WS: Closing existing connection before new one...');
      await disconnect();
    }

    try {
      _status = WebSocketConnectionStatus.connecting;
      final url = '${ApiConstants.wsBaseUrl}${ApiConstants.wsMarketTicker}';
      dev.log('🔌 TICKER_WS: Connecting to $url');

      _channel = WebSocketChannel.connect(Uri.parse(url));
      _status = WebSocketConnectionStatus.connected;
      _reconnectAttempts = 0;

      dev.log('✅ TICKER_WS: Connected successfully');

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      // Start heartbeat
      _startHeartbeat();

      // Immediately send subscription message so backend begins streaming tickers
      await _sendSubscriptionMessage();
    } catch (e) {
      dev.log('❌ TICKER_WS: Connection failed - $e');
      _status = WebSocketConnectionStatus.error;
      _scheduleReconnect();
    }
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());

      if (data['stream'] == 'tickers' && data['data'] != null) {
        final tickerData = data['data'] as Map<String, dynamic>;

        _pendingTickerUpdate = tickerData;

        _updateDebounceTimer?.cancel();
        _updateDebounceTimer = Timer(_updateDebounceDelay, () {
          if (_pendingTickerUpdate != null) {
            if (!_tickersController.isClosed) {
              _tickersController.add(_pendingTickerUpdate!);
            }
            _marketService.updateMarketsWithTickers(_pendingTickerUpdate!);
            _pendingTickerUpdate = null;
          }
        });
      }
    } catch (_) {
      // Ignore malformed messages
    }
  }

  /// Handle WebSocket errors
  void _handleError(error) {
    dev.log('❌ TICKER_WS: Error - $error');
    _status = WebSocketConnectionStatus.error;
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnection
  void _handleDisconnection() {
    dev.log('🔌 TICKER_WS: Disconnected');
    _status = WebSocketConnectionStatus.disconnected;
    _channel = null;
    _heartbeatTimer?.cancel();

    // Only auto-reconnect if not manually disconnected and we have subscribers
    if (!_manuallyDisconnected && _globalSubscriptionCount > 0) {
      _scheduleReconnect();
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      dev.log('❌ TICKER_WS: Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(
        seconds: math.min(30, math.pow(2, _reconnectAttempts).toInt()));

    dev.log(
        '🔄 TICKER_WS: Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts/$_maxReconnectAttempts)');

    Timer(delay, () async {
      if (_status != WebSocketConnectionStatus.connected &&
          _globalSubscriptionCount > 0) {
        await _connect();
      }
    });
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (isConnected) {
        _sendHeartbeat();
      }
    });
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Send a heartbeat message to the WebSocket server
  void _sendHeartbeat() {
    if (isConnected && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode({
          'action': 'PING',
          'payload': {},
        }));
      } catch (e) {
        dev.log('⚠️ TICKER_WS: Heartbeat failed - $e');
      }
    }
  }

  /// Subscribe to ticker updates (increment global counter)
  void subscribeToTickerUpdates() {
    _globalSubscriptionCount++;
    dev.log('📊 TICKER_WS: Global subscription count: $_globalSubscriptionCount');

    // Cancel auto-disconnect timer if it was running
    _autoDisconnectTimer?.cancel();
    _autoDisconnectTimer = null;

    // Connect if not already connected
    if (!isConnected) {
      _connect();
    } else if (isConnected && _globalSubscriptionCount == 1) {
      // First subscriber, send subscription message
      _sendSubscriptionMessage();
    }
  }

  /// Unsubscribe from ticker updates (decrement global counter)
  void unsubscribeFromTickerUpdates() {
    _globalSubscriptionCount--;
    dev.log('📊 TICKER_WS: Global subscription count: $_globalSubscriptionCount');

    // Keep subscription count non-negative
    if (_globalSubscriptionCount < 0) {
      _globalSubscriptionCount = 0;
    }

    // If no more subscribers, schedule auto-disconnect
    if (_globalSubscriptionCount == 0) {
      _scheduleAutoDisconnect();
    }
  }

  /// Schedule auto-disconnect when no subscribers
  void _scheduleAutoDisconnect() {
    _autoDisconnectTimer?.cancel();
    _autoDisconnectTimer = Timer(_autoDisconnectDelay, () {
      if (_globalSubscriptionCount == 0 && isConnected) {
        dev.log('🛑 TICKER_WS: No subscribers, auto-disconnecting...');
        disconnect();
      }
    });
  }

  /// Subscribe to ticker updates (legacy method)
  Future<void> subscribeToTickers() async {
    subscribeToTickerUpdates();
  }

  /// Unsubscribe from ticker updates (legacy method)
  Future<void> unsubscribeFromTickers() async {
    unsubscribeFromTickerUpdates();
  }

  /// Send subscription message to the WebSocket server
  Future<void> _sendSubscriptionMessage() async {
    if (_channel == null) return;
    try {
      final message = jsonEncode({
        'action': 'SUBSCRIBE',
        'payload': {'type': 'tickers'},
      });
      _channel!.sink.add(message);
      dev.log('📡 TICKER_WS: Sent subscription message: $message');
    } catch (e) {
      dev.log('⚠️ TICKER_WS: Subscription failed - $e');
    }
  }

  /// Update connection status and notify listeners
  void _updateStatus(WebSocketConnectionStatus status) {
    if (_status != status) {
      _status = status;
      if (!_statusController.isClosed) {
        _statusController.add(status);
      }
    }
  }

  /// Manually trigger reconnection
  Future<void> reconnect() async {
    await disconnect();
    _reconnectAttempts = 0;
    await _connect();
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    dev.log('🛑 TICKER_WS: Disconnecting...');

    _manuallyDisconnected = true;
    _reconnectTimer?.cancel();
    _stopHeartbeat();
    _updateDebounceTimer?.cancel();
    _autoDisconnectTimer?.cancel();

    _activeSubscriptions.clear();
    _messageQueue.clear();

    if (_channel != null) {
      await _channel!.sink.close(ws_status.normalClosure);
      _channel = null;
    }

    // Reset reconnection attempts to prevent auto-reconnect
    _reconnectAttempts = 0;

    _updateStatus(WebSocketConnectionStatus.disconnected);
    dev.log('🛑 TICKER_WS: Disconnected successfully');
  }

  /// Dispose of the service
  Future<void> dispose() async {
    await disconnect();
    await _tickersController.close();
    await _statusController.close();
    _isGlobalInitialized = false;
    _globalSubscriptionCount = 0;
    dev.log('🔌 TICKER_WS: Service disposed');
  }
}
