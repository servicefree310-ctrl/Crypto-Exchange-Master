import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/support_ticket_entity.dart';
import '../entities/create_ticket_params.dart';

abstract class SupportRepository {
  // Regular support tickets
  Future<Either<Failure, List<SupportTicketEntity>>> getSupportTickets({
    int page = 1,
    int perPage = 20,
    String? search,
    TicketStatus? status,
    TicketImportance? importance,
  });
  Future<Either<Failure, SupportTicketEntity>> createSupportTicket(
      CreateTicketParams params);
  Future<Either<Failure, void>> replyToTicket(ReplyTicketParams params);
  Future<Either<Failure, SupportTicketEntity>> getSupportTicket(
      String ticketId);
  Future<Either<Failure, SupportTicketEntity>> getSupportTicketById(
      String ticketId);

  // Live chat methods - matching v5 API structure exactly
  /// GET /api/user/support/chat - Get existing LIVE ticket or create new one
  Future<Either<Failure, SupportTicketEntity>> getOrCreateLiveChat();

  /// POST /api/user/support/chat - Send message to live chat session
  Future<Either<Failure, void>> sendLiveChatMessage(
      SendLiveChatMessageParams params);

  /// DELETE /api/user/support/chat - End live chat session
  Future<Either<Failure, void>> endLiveChat(String sessionId);

  // WebSocket for real-time updates
  Stream<SupportTicketEntity> watchSupportTicket(String ticketId);
}
