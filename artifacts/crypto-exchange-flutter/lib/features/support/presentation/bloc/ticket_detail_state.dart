part of 'ticket_detail_bloc.dart';

abstract class TicketDetailState extends Equatable {
  const TicketDetailState();

  @override
  List<Object?> get props => [];
}

class TicketDetailInitial extends TicketDetailState {
  const TicketDetailInitial();
}

class TicketDetailLoading extends TicketDetailState {
  const TicketDetailLoading();
}

class TicketDetailLoaded extends TicketDetailState {
  const TicketDetailLoaded(
      {required this.ticket, this.isSending = false, this.error});

  final SupportTicketEntity ticket;
  final bool isSending;
  final String? error;

  bool get isClosed => ticket.status == TicketStatus.closed;

  @override
  List<Object?> get props => [ticket, isSending, error];

  TicketDetailLoaded copyWith({
    SupportTicketEntity? ticket,
    bool? isSending,
    String? error,
  }) {
    return TicketDetailLoaded(
      ticket: ticket ?? this.ticket,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

class TicketDetailError extends TicketDetailState {
  const TicketDetailError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
