import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/support_ticket_entity.dart';
import '../entities/create_ticket_params.dart';
import '../repositories/support_repository.dart';

@injectable
class LiveChatUseCase {
  const LiveChatUseCase(this._repository);

  final SupportRepository _repository;

  /// Get existing LIVE chat session or create a new one
  /// This follows v5 logic: GET /api/user/support/chat
  Future<Either<Failure, SupportTicketEntity>> getOrCreateSession() async {
    return await _repository.getOrCreateLiveChat();
  }

  /// Resume an existing live chat session by ticket ID
  /// This follows v5 logic: GET /api/user/support/ticket/{id}
  Future<Either<Failure, SupportTicketEntity>> resumeSession(
      String ticketId) async {
    return await _repository.getSupportTicketById(ticketId);
  }

  /// Send a message in the live chat session
  /// This follows v5 logic: POST /api/user/support/chat
  Future<Either<Failure, void>> sendMessage(
      SendLiveChatMessageParams params) async {
    return await _repository.sendLiveChatMessage(params);
  }

  /// End the live chat session
  /// This follows v5 logic: DELETE /api/user/support/chat
  Future<Either<Failure, void>> endSession(String sessionId) async {
    return await _repository.endLiveChat(sessionId);
  }

  /// Generate contextual automated message based on user's message
  /// This is mobile-only feature for better UX
  String? getContextualAutomatedMessage(String userMessage) {
    final message = userMessage.toLowerCase();

    // Trading related
    if (message.contains('trade') ||
        message.contains('order') ||
        message.contains('buy') ||
        message.contains('sell')) {
      return "I see you have a question about trading. Our trading experts will help you with orders, market analysis, and trading strategies.";
    }

    // Wallet related
    if (message.contains('wallet') ||
        message.contains('deposit') ||
        message.contains('withdraw') ||
        message.contains('balance')) {
      return "I understand you need help with your wallet. Our team will assist you with deposits, withdrawals, and balance inquiries.";
    }

    // Account related
    if (message.contains('account') ||
        message.contains('profile') ||
        message.contains('kyc') ||
        message.contains('verification')) {
      return "Got it! You need help with your account. We'll help you with verification, profile settings, and account security.";
    }

    // Technical issues
    if (message.contains('error') ||
        message.contains('bug') ||
        message.contains('problem') ||
        message.contains('issue') ||
        message.contains('not working')) {
      return "I see you're experiencing a technical issue. Our technical support team will help you resolve this quickly.";
    }

    // Security related
    if (message.contains('security') ||
        message.contains('password') ||
        message.contains('2fa') ||
        message.contains('login')) {
      return "Security is important! Our team will help you with login issues, password resets, and account security.";
    }

    // General support for first message
    if (message.length > 10) {
      return "Thank you for contacting support! I've received your message and an agent will be with you shortly to provide personalized assistance.";
    }

    return null; // No automated message for short/generic messages
  }
}
