import 'dart:async';
import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import '../../../../core/constants/api_constants.dart';
import '../models/support_ticket_model.dart';
import '../models/support_message_model.dart';
import '../../domain/entities/support_ticket_entity.dart';

abstract class SupportWebSocketDataSource {
  Stream<SupportTicketModel> watchTicket(String ticketId);
  Stream<SupportTicketModel> watchLiveChat();
  Future<void> subscribeToTicket(String ticketId);
  Future<void> unsubscribeFromTicket(String ticketId);
  void disconnect();
}

@Injectable(as: SupportWebSocketDataSource)
class SupportWebSocketDataSourceImpl implements SupportWebSocketDataSource {
  SupportWebSocketDataSourceImpl();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  final Map<String, StreamController<SupportTicketModel>> _ticketStreams = {};
  StreamController<SupportTicketModel>? _liveChatStream;

  @override
  Stream<SupportTicketModel> watchTicket(String ticketId) {
    if (!_ticketStreams.containsKey(ticketId)) {
      _ticketStreams[ticketId] =
          StreamController<SupportTicketModel>.broadcast();
      _connectIfNeeded();
      _subscribeToTicket(ticketId);
    }
    return _ticketStreams[ticketId]!.stream;
  }

  @override
  Stream<SupportTicketModel> watchLiveChat() {
    _liveChatStream ??= StreamController<SupportTicketModel>.broadcast();
    _connectIfNeeded();
    return _liveChatStream!.stream;
  }

  Future<void> _connectIfNeeded() async {
    if (_isConnected) return;

    try {
      final wsUrl = '${ApiConstants.wsBaseUrl}${ApiConstants.supportWebSocket}';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );
    } catch (e) {
      _isConnected = false;
      dev.log('Support WebSocket connection failed: $e');
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final json = jsonDecode(message.toString());
      if (json['method'] == 'update' || json['method'] == 'reply') {
        final ticketData = json['data'];
        if (ticketData == null) return;

        // 'reply' events may contain only the new message payload, not full ticket
        if (ticketData is Map && !ticketData.containsKey('id')) {
          // Attempt to extract ticketId from parent message (if provided)
          final ticketId =
              json['id'] ?? json['ticketId'] ?? json['params']?['id'];
          if (ticketId != null && _ticketStreams.containsKey(ticketId)) {
            try {
              final msgJson = ticketData['message'];
              if (msgJson != null) {
                final msg = SupportMessageModel.fromJson(msgJson).toEntity();
                // Emit minimal update: clone last ticket with extra message
                // Since we don't have full ticket, rely on UI to fetchRest.
                _ticketStreams[ticketId]!.add(SupportTicketModel(
                  id: ticketId,
                  userId: msg.userId,
                  subject: '',
                  importance: TicketImportance.low,
                  status: TicketStatus.replied,
                  type: TicketType.ticket,
                  messages: [msg],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ));
              }
            } catch (_) {}
          }
          return;
        }

        try {
          final ticket = SupportTicketModel.fromJson(ticketData);

          if (_ticketStreams.containsKey(ticket.id)) {
            _ticketStreams[ticket.id]!.add(ticket);
          }

          if (ticket.type == TicketType.live && _liveChatStream != null) {
            _liveChatStream!.add(ticket);
          }
        } catch (_) {/* ignore malformed */}
      }
    } catch (e) {
      dev.log('Support WebSocket message parsing error: $e');
    }
  }

  void _handleError(error) {
    dev.log('Support WebSocket error: $error');
    _isConnected = false;
  }

  void _handleDisconnection() {
    dev.log('Support WebSocket disconnected');
    _isConnected = false;
    _channel = null;
  }

  void _subscribeToTicket(String ticketId) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode({
        'action': 'SUBSCRIBE',
        'payload': {'id': ticketId},
      }));
    }
  }

  @override
  Future<void> subscribeToTicket(String ticketId) async {
    await _connectIfNeeded();
    _subscribeToTicket(ticketId);
  }

  @override
  Future<void> unsubscribeFromTicket(String ticketId) async {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode({
        'action': 'UNSUBSCRIBE',
        'payload': {'id': ticketId},
      }));
    }

    if (_ticketStreams.containsKey(ticketId)) {
      await _ticketStreams[ticketId]!.close();
      _ticketStreams.remove(ticketId);
    }
  }

  @override
  void disconnect() {
    _isConnected = false;

    _channel?.sink.close(ws_status.normalClosure);
    _channel = null;

    for (final stream in _ticketStreams.values) {
      stream.close();
    }
    _ticketStreams.clear();

    _liveChatStream?.close();
    _liveChatStream = null;
  }
}
