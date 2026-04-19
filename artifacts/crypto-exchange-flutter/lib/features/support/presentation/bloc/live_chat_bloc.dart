import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../../domain/entities/support_message_entity.dart';
import '../../domain/entities/create_ticket_params.dart';
import '../../domain/usecases/live_chat_usecase.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

// Events
abstract class LiveChatEvent extends Equatable {
  const LiveChatEvent();
  @override
  List<Object?> get props => [];
}

class InitializeLiveChatRequested extends LiveChatEvent {
  const InitializeLiveChatRequested();
}

class SendMessageRequested extends LiveChatEvent {
  const SendMessageRequested(this.content);
  final String content;

  @override
  List<Object?> get props => [content];
}

class ResumeLiveChatRequested extends LiveChatEvent {
  const ResumeLiveChatRequested({required this.ticketId});
  final String ticketId;

  @override
  List<Object?> get props => [ticketId];
}

class EndChatRequested extends LiveChatEvent {
  const EndChatRequested();
}

class ReceiveMessageRequested extends LiveChatEvent {
  const ReceiveMessageRequested(this.message);
  final SupportMessageEntity message;

  @override
  List<Object?> get props => [message];
}

// States
abstract class LiveChatState extends Equatable {
  const LiveChatState();
  @override
  List<Object?> get props => [];
}

class LiveChatInitial extends LiveChatState {
  const LiveChatInitial();
}

class LiveChatLoading extends LiveChatState {
  const LiveChatLoading();
}

class LiveChatSessionActive extends LiveChatState {
  const LiveChatSessionActive({
    required this.ticket,
    required this.messages,
    this.isAgentConnected = false,
    this.error,
  });

  final SupportTicketEntity ticket;
  final List<SupportMessageEntity> messages;
  final bool isAgentConnected;
  final String? error;

  // Map v5 ticket status to chat status
  String get chatStatus {
    switch (ticket.status) {
      case TicketStatus.pending:
        return 'WAITING';
      case TicketStatus.open:
      case TicketStatus.replied:
        return 'CONNECTED';
      case TicketStatus.closed:
        return 'ENDED';
    }
  }

  @override
  List<Object?> get props => [ticket, messages, isAgentConnected, error];

  LiveChatSessionActive copyWith({
    SupportTicketEntity? ticket,
    List<SupportMessageEntity>? messages,
    bool? isAgentConnected,
    String? error,
  }) {
    return LiveChatSessionActive(
      ticket: ticket ?? this.ticket,
      messages: messages ?? this.messages,
      isAgentConnected: isAgentConnected ?? this.isAgentConnected,
      error: error,
    );
  }
}

class LiveChatError extends LiveChatState {
  const LiveChatError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class LiveChatEnded extends LiveChatState {
  const LiveChatEnded();
}

@injectable
class LiveChatBloc extends Bloc<LiveChatEvent, LiveChatState> {
  LiveChatBloc(this._liveChatUseCase, this._authBloc)
      : super(const LiveChatInitial()) {
    on<InitializeLiveChatRequested>(_onInitializeChat);
    on<ResumeLiveChatRequested>(_onResumeChat);
    on<SendMessageRequested>(_onSendMessage);
    on<EndChatRequested>(_onEndChat);
    on<ReceiveMessageRequested>(_onReceiveMessage);
  }

  final LiveChatUseCase _liveChatUseCase;
  final AuthBloc _authBloc;

  /// Get current authenticated user ID
  String? _getCurrentUserId() {
    final authState = _authBloc.state;
    if (authState is AuthAuthenticated) {
      return authState.user.id;
    }
    return null;
  }

  Future<void> _onInitializeChat(
    InitializeLiveChatRequested event,
    Emitter<LiveChatState> emit,
  ) async {
    emit(const LiveChatLoading());

    final result = await _liveChatUseCase.getOrCreateSession();

    result.fold(
      (failure) => emit(LiveChatError(failure.message)),
      (ticket) {
        // Parse messages from v5 format
        final messages = _parseMessagesFromTicket(ticket);

        emit(LiveChatSessionActive(
          ticket: ticket,
          messages: messages,
          isAgentConnected: ticket.status == TicketStatus.open ||
              ticket.status == TicketStatus.replied,
        ));
      },
    );
  }

  Future<void> _onResumeChat(
    ResumeLiveChatRequested event,
    Emitter<LiveChatState> emit,
  ) async {
    emit(const LiveChatLoading());

    // Resume existing live chat session by ticket ID
    final result = await _liveChatUseCase.resumeSession(event.ticketId);

    result.fold(
      (failure) => emit(LiveChatError(failure.message)),
      (ticket) {
        // Parse messages from v5 format
        final messages = _parseMessagesFromTicket(ticket);

        emit(LiveChatSessionActive(
          ticket: ticket,
          messages: messages,
          isAgentConnected: ticket.status == TicketStatus.open ||
              ticket.status == TicketStatus.replied,
        ));
      },
    );
  }

  Future<void> _onSendMessage(
    SendMessageRequested event,
    Emitter<LiveChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LiveChatSessionActive) return;

    // Use the ticket's userId (it comes from the authenticated session)
    final userId = currentState.ticket.userId;

    // Create optimistic message
    final optimisticMessage = SupportMessageEntity(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      type: 'client',
      text: event.content,
      time: DateTime.now().toIso8601String(),
      userId: userId,
    );

    // Add optimistic message to UI
    final updatedMessages = [...currentState.messages, optimisticMessage];
    emit(currentState.copyWith(messages: updatedMessages, error: null));

    // Send message via API
    final params = SendLiveChatMessageParams(
      sessionId: currentState.ticket.id,
      content: event.content,
      sender: 'user',
    );

    final result = await _liveChatUseCase.sendMessage(params);

    result.fold(
      (failure) {
        // Keep the optimistic message but show error - don't remove user's message
        emit(currentState.copyWith(
          messages: updatedMessages, // Keep the message visible
          error: failure.message,
        ));
      },
      (_) {
        // Message sent successfully - check if we should add contextual automated message
        final automatedMessage =
            _liveChatUseCase.getContextualAutomatedMessage(event.content);
        if (automatedMessage != null && currentState.chatStatus == 'WAITING') {
          // Add contextual automated message for better UX
          final contextualSystemMessage = SupportMessageEntity(
            id: 'system_${DateTime.now().millisecondsSinceEpoch}',
            type: 'agent', // Show as agent message
            text: automatedMessage,
            time: DateTime.now().toIso8601String(),
            userId: 'system',
          );

          emit(currentState.copyWith(
            messages: [...updatedMessages, contextualSystemMessage],
            error: null,
          ));
        } else {
          // Just clear any previous errors and keep the messages
          emit(currentState.copyWith(
            messages: updatedMessages,
            error: null,
          ));
        }
      },
    );
  }

  Future<void> _onEndChat(
    EndChatRequested event,
    Emitter<LiveChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LiveChatSessionActive) return;

    final result = await _liveChatUseCase.endSession(currentState.ticket.id);

    result.fold(
      (failure) => emit(currentState.copyWith(error: failure.message)),
      (_) => emit(const LiveChatEnded()),
    );
  }

  Future<void> _onReceiveMessage(
    ReceiveMessageRequested event,
    Emitter<LiveChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LiveChatSessionActive) return;

    // Add new message from WebSocket
    final updatedMessages = [...currentState.messages, event.message];

    emit(currentState.copyWith(
      messages: updatedMessages,
      isAgentConnected: event.message.type == 'agent',
    ));
  }

  List<SupportMessageEntity> _parseMessagesFromTicket(
      SupportTicketEntity ticket) {
    // Parse messages from v5 ticket format
    return ticket.messages.map((message) {
      return SupportMessageEntity(
        id: message.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: message.type,
        text: message.text,
        time: message.time,
        userId: message.userId,
      );
    }).toList();
  }
}
