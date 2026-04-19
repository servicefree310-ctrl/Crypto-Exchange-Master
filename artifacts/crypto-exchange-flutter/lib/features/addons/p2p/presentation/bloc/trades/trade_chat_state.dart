import 'package:equatable/equatable.dart';
import '../../../../../../../core/errors/failures.dart';

abstract class TradeChatState extends Equatable {
  const TradeChatState();
  @override
  List<Object?> get props => [];
}

class TradeChatInitial extends TradeChatState {
  const TradeChatInitial();
}

class TradeChatLoading extends TradeChatState {
  const TradeChatLoading();
}

class TradeChatLoaded extends TradeChatState {
  const TradeChatLoaded(this.messages);
  final List<Map<String, dynamic>> messages;
  @override
  List<Object?> get props => [messages];
}

class TradeChatSending extends TradeChatState {
  const TradeChatSending(this.messages);
  final List<Map<String, dynamic>> messages;
  @override
  List<Object?> get props => [messages];
}

class TradeChatError extends TradeChatState {
  const TradeChatError(this.failure, this.messages);
  final Failure failure;
  final List<Map<String, dynamic>> messages;
  @override
  List<Object?> get props => [failure, messages];
}
