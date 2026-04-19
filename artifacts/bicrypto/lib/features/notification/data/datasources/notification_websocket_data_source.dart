import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/notification_service.dart';

enum WebSocketStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error
}

abstract class NotificationWebSocketDataSource {
  Stream<List<dynamic>> get notificationsStream;
  Stream<List<dynamic>> get announcementsStream;
  Stream<bool> get connectionStatusStream;
  bool get isConnected;
  Future<void> connect(String userId);
  Future<void> disconnect();
  void dispose();
}

@Injectable(as: NotificationWebSocketDataSource)
class NotificationWebSocketDataSourceImpl
    implements NotificationWebSocketDataSource {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final _statusController = StreamController<WebSocketStatus>.broadcast();
  final _notificationController = StreamController<List<dynamic>>.broadcast();
  final _announcementController = StreamController<List<dynamic>>.broadcast();

  WebSocketStatus _status = WebSocketStatus.disconnected;
  String? _userId;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  @override
  Stream<List<dynamic>> get notificationsStream =>
      _notificationController.stream;

  @override
  Stream<List<dynamic>> get announcementsStream =>
      _announcementController.stream;

  @override
  Stream<bool> get connectionStatusStream => _statusController.stream
      .map((status) => status == WebSocketStatus.connected);

  @override
  bool get isConnected => _status == WebSocketStatus.connected;

  @override
  Future<void> connect(String userId) async {
    if (isConnected && _userId == userId) return;

    await disconnect();

    _userId = userId;
    _setStatus(WebSocketStatus.connecting);

    final url =
        '${ApiConstants.wsBaseUrl}${ApiConstants.userWebSocket}?userId=$userId';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _subscription = _channel!.stream
          .listen(_handleMessage, onError: _handleError, onDone: _handleDone);

      await _channel!.ready;
      _setStatus(WebSocketStatus.connected);
      _reconnectAttempts = 0;

      // Send SUBSCRIBE message according to backend structure
      final subscribeMessage = {
        'type': 'SUBSCRIBE',
        'payload': {'type': 'auth'}
      };
      _channel!.sink.add(jsonEncode(subscribeMessage));

      developer.log('Connected to notification WebSocket',
          name: 'NotificationWebSocket');
    } catch (e) {
      developer.log('Connection failed: $e',
          name: 'NotificationWebSocket', level: 1000);
      _setStatus(WebSocketStatus.error);
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message.toString());
      final type = decoded['type'] as String?;
      final method = decoded['method'] as String?;
      final payload =
          decoded['payload'] as List<dynamic>?; // Backend sends 'payload'

      developer.log(
          'Received WebSocket message: type=$type, method=$method, payload_length=${payload?.length}',
          name: 'NotificationWebSocket');

      if (type == 'notifications' && method == 'create' && payload != null) {
        _notificationController.add(payload);
        _showLocalNotifications(payload);
      } else if (type == 'announcements' &&
          method == 'create' &&
          payload != null) {
        _announcementController.add(payload);
      }
    } catch (e) {
      developer.log('Failed to parse WebSocket message: $e',
          name: 'NotificationWebSocket', level: 900);
    }
  }

  void _showLocalNotifications(List<dynamic> data) {
    final notificationService = NotificationService();
    for (final notification in data) {
      if (notification is Map<String, dynamic>) {
        final title = notification['title']?.toString() ?? 'Notification';
        final message = notification['message']?.toString() ?? '';
        notificationService.showNotification(title: title, body: message);
      }
    }
  }

  void _handleError(dynamic error) {
    developer.log('WebSocket error: $error',
        name: 'NotificationWebSocket', level: 1000);
    _setStatus(WebSocketStatus.error);
    _scheduleReconnect();
  }

  void _handleDone() {
    developer.log('WebSocket connection closed', name: 'NotificationWebSocket');
    _setStatus(WebSocketStatus.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts || _userId == null) {
      developer.log('Max reconnection attempts reached',
          name: 'NotificationWebSocket', level: 900);
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () async {
      if (_status != WebSocketStatus.connected && _userId != null) {
        _reconnectAttempts++;
        _setStatus(WebSocketStatus.reconnecting);
        developer.log(
            'Attempting to reconnect ($_reconnectAttempts/$_maxReconnectAttempts)',
            name: 'NotificationWebSocket');
        await connect(_userId!);
      }
    });
  }

  @override
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    _subscription = null;
    _channel = null;
    _reconnectAttempts = 0;
    _setStatus(WebSocketStatus.disconnected);
  }

  void _setStatus(WebSocketStatus status) {
    _status = status;
    _statusController.add(status);
  }

  @override
  void dispose() {
    disconnect();
    _statusController.close();
    _notificationController.close();
    _announcementController.close();
  }
}
