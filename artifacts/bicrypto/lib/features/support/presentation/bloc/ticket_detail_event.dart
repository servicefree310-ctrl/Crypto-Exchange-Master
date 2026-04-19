part of 'ticket_detail_bloc.dart';

abstract class TicketDetailEvent extends Equatable {
  const TicketDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadTicketRequested extends TicketDetailEvent {
  const LoadTicketRequested({required this.ticketId});
  final String ticketId;

  @override
  List<Object?> get props => [ticketId];
}

class SendReplyRequested extends TicketDetailEvent {
  const SendReplyRequested(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class _IncomingTicketUpdate extends TicketDetailEvent {
  const _IncomingTicketUpdate(this.ticket);
  final SupportTicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}
