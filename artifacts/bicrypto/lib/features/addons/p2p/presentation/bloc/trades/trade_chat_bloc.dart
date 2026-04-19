import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'trade_chat_event.dart';
import 'trade_chat_state.dart';
import '../../../domain/usecases/trades/get_trade_messages_usecase.dart';
import '../../../domain/usecases/trades/send_trade_message_usecase.dart';
import '../../../../../../../core/errors/failures.dart';

@injectable
class TradeChatBloc extends Bloc<TradeChatEvent, TradeChatState> {
  TradeChatBloc(this._getMessages, this._sendMessage)
      : super(const TradeChatInitial()) {
    on<TradeChatStarted>(_onStarted);
    on<TradeChatMessagesRefreshed>(_onRefresh);
    on<TradeChatMessageSent>(_onSendMessage);
  }

  final GetTradeMessagesUseCase _getMessages;
  final SendTradeMessageUseCase _sendMessage;
  String? _tradeId;
  List<Map<String, dynamic>> _messages = [];
  Timer? _pollingTimer;

  Future<void> _onStarted(
    TradeChatStarted event,
    Emitter<TradeChatState> emit,
  ) async {
    _tradeId = event.tradeId;
    emit(const TradeChatLoading());
    await _loadMessages(emit);
    // Start simple polling every 10s (replace with WebSocket later)
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      add(const TradeChatMessagesRefreshed());
    });
  }

  Future<void> _onRefresh(
    TradeChatMessagesRefreshed event,
    Emitter<TradeChatState> emit,
  ) async {
    await _loadMessages(emit, silent: true);
  }

  Future<void> _loadMessages(
    Emitter<TradeChatState> emit, {
    bool silent = false,
  }) async {
    if (_tradeId == null) return;
    if (!silent) emit(const TradeChatLoading());
    final result =
        await _getMessages(GetTradeMessagesParams(tradeId: _tradeId!));
    result.fold(
      (Failure failure) => emit(TradeChatError(failure, _messages)),
      (msgs) {
        _messages = msgs;
        emit(TradeChatLoaded(_messages));
      },
    );
  }

  Future<void> _onSendMessage(
    TradeChatMessageSent event,
    Emitter<TradeChatState> emit,
  ) async {
    if (_tradeId == null) return;
    emit(TradeChatSending(_messages));
    final result = await _sendMessage(
      SendTradeMessageParams(tradeId: _tradeId!, message: event.message.trim()),
    );
    result.fold(
      (Failure failure) => emit(TradeChatError(failure, _messages)),
      (_) async {
        // Reload messages to include the sent one
        await _loadMessages(emit);
      },
    );
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
