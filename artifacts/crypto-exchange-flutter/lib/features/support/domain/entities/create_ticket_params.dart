import 'package:equatable/equatable.dart';
import 'support_ticket_entity.dart';

class CreateTicketParams extends Equatable {
  const CreateTicketParams({
    required this.subject,
    required this.message,
    required this.importance,
    this.tags = const [],
  });

  final String subject;
  final String message;
  final TicketImportance importance;
  final List<String> tags;

  @override
  List<Object?> get props => [subject, message, importance, tags];
}

class ReplyTicketParams extends Equatable {
  const ReplyTicketParams({
    required this.ticketId,
    required this.type,
    required this.text,
    required this.userId,
    this.attachment,
  });

  final String ticketId;
  final String type; // "client" or "agent"
  final String text;
  final String userId;
  final String? attachment;

  @override
  List<Object?> get props => [ticketId, type, text, userId, attachment];
}

class CloseTicketParams extends Equatable {
  const CloseTicketParams({
    required this.ticketId,
  });

  final String ticketId;

  @override
  List<Object?> get props => [ticketId];
}

class RateTicketParams extends Equatable {
  const RateTicketParams({
    required this.ticketId,
    required this.satisfaction,
  });

  final String ticketId;
  final double satisfaction;

  @override
  List<Object?> get props => [ticketId, satisfaction];
}

class SendLiveChatMessageParams extends Equatable {
  const SendLiveChatMessageParams({
    required this.sessionId,
    required this.content,
    required this.sender,
  });

  final String sessionId;
  final String content;
  final String sender;

  @override
  List<Object?> get props => [sessionId, content, sender];
}
