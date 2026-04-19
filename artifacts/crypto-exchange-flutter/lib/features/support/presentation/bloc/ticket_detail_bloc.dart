import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/create_ticket_params.dart';
import '../../domain/entities/support_message_entity.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../../domain/repositories/support_repository.dart';

part 'ticket_detail_event.dart';
part 'ticket_detail_state.dart';

/// Handles a single normal (non-live) support ticket – loading, replying and
/// reacting to server / WebSocket updates.
@injectable
class TicketDetailBloc extends Bloc<TicketDetailEvent, TicketDetailState> {
  TicketDetailBloc(this._repository) : super(const TicketDetailInitial()) {
    on<LoadTicketRequested>(_onLoadTicket);
    on<SendReplyRequested>(_onSendReply);
    on<_IncomingTicketUpdate>(_onIncomingUpdate);
  }

  final SupportRepository _repository;
  StreamSubscription<SupportTicketEntity>? _subscription;

  Future<void> _onLoadTicket(
    LoadTicketRequested event,
    Emitter<TicketDetailState> emit,
  ) async {
    emit(const TicketDetailLoading());

    // First fetch REST copy so we have latest history immediately.
    final result = await _repository.getSupportTicket(event.ticketId);
    await result.fold(
      (failure) async => emit(TicketDetailError(failure.message)),
      (ticket) async {
        // Listen for WebSocket updates so new messages appear in real-time.
        await _subscription?.cancel();
        _subscription = _repository
            .watchSupportTicket(event.ticketId)
            .listen((updated) => add(_IncomingTicketUpdate(updated)));
        emit(TicketDetailLoaded(ticket: ticket));
      },
    );
  }

  Future<void> _onSendReply(
    SendReplyRequested event,
    Emitter<TicketDetailState> emit,
  ) async {
    final current = state;
    if (current is! TicketDetailLoaded) return;
    if (current.ticket.status == TicketStatus.closed) return;

    // Optimistic message view.
    final optimisticMessage = SupportMessageEntity(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      type: 'client',
      text: event.message,
      time: DateTime.now().toIso8601String(),
      userId: current.ticket.userId,
    );

    final optimisticTicket = current.ticket.copyWith(
      messages: [...current.ticket.messages, optimisticMessage],
    );

    emit(current.copyWith(
      ticket: optimisticTicket,
      isSending: true,
    ));

    final params = ReplyTicketParams(
      ticketId: current.ticket.id,
      type: 'client',
      text: event.message,
      userId: current.ticket.userId,
    );

    final result = await _repository.replyToTicket(params);

    await result.fold(
      (failure) async => emit(current.copyWith(
        ticket: optimisticTicket,
        error: failure.message,
        isSending: false,
      )),
      (_) async {
        // Refresh ticket from API to get authoritative state
        final refetch = await _repository.getSupportTicket(params.ticketId);
        refetch.fold(
          (failure) => emit(current.copyWith(
            ticket: optimisticTicket,
            error: failure.message,
            isSending: false,
          )),
          (ticket) => emit(current.copyWith(
            ticket: ticket,
            isSending: false,
            error: null,
          )),
        );
      },
    );
  }

  Future<void> _onIncomingUpdate(
    _IncomingTicketUpdate event,
    Emitter<TicketDetailState> emit,
  ) async {
    final current = state;
    if (current is TicketDetailLoaded) {
      emit(current.copyWith(ticket: event.ticket));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
