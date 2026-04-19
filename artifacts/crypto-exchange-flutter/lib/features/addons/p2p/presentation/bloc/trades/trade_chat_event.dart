import 'package:equatable/equatable.dart';

abstract class TradeChatEvent extends Equatable {
  const TradeChatEvent();
  @override
  List<Object?> get props => [];
}

class TradeChatStarted extends TradeChatEvent {
  const TradeChatStarted(this.tradeId);
  final String tradeId;
  @override
  List<Object?> get props => [tradeId];
}

class TradeChatMessageSent extends TradeChatEvent {
  const TradeChatMessageSent(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class TradeChatMessagesRefreshed extends TradeChatEvent {
  const TradeChatMessagesRefreshed();
}
