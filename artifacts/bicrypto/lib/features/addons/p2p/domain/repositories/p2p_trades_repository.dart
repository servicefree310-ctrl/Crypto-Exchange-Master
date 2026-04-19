import 'package:dartz/dartz.dart';
import '../../../../../../../../core/errors/failures.dart';
import '../entities/p2p_trade_entity.dart';
import '../entities/p2p_dispute_entity.dart';
import '../entities/p2p_review_entity.dart';
import '../usecases/trades/get_trades_usecase.dart';

/// Repository interface for P2P trade operations
///
/// Defines all trade-related operations that can be performed
/// Implementation will handle API calls to backend endpoints
abstract class P2PTradesRepository {
  // ===== GET OPERATIONS =====

  /// Get user's trades with dashboard data
  /// Matches: GET /api/ext/p2p/trade
  Future<Either<Failure, P2PTradesResponse>> getTrades({
    String? status,
    int? limit,
    int? offset,
    String? sortBy,
    String? sortDirection,
    bool includeStats = true,
    bool includeActivity = true,
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  /// Get trade by ID with detailed information
  /// Matches: GET /api/ext/p2p/trade/{id}
  Future<Either<Failure, P2PTradeEntity>> getTradeById(
    String tradeId, {
    bool includeCounterparty = true,
    bool includeDispute = true,
    bool includeTimeline = true,
  });

  // ===== TRADE LIFECYCLE OPERATIONS =====

  /// Initiate new trade from offer
  /// Based on v5 pattern where trades are created from offers
  Future<Either<Failure, P2PTradeEntity>> initiateTrade({
    required String offerId,
    required double amount,
    double? fiatAmount,
    required String paymentMethodId,
    String? message,
    int? autoAcceptTime,
  });

  /// Confirm payment sent (buyer action)
  /// Matches: POST /api/ext/p2p/trade/{id}/confirm
  Future<Either<Failure, void>> confirmTrade({
    required String tradeId,
    String? paymentReference,
    String? paymentProof,
    String? notes,
  });

  /// Cancel trade with reason
  /// Matches: POST /api/ext/p2p/trade/{id}/cancel
  Future<Either<Failure, void>> cancelTrade({
    required String tradeId,
    required String reason,
    bool forceCancel = false,
  });

  /// Create dispute for trade
  /// Matches: POST /api/ext/p2p/trade/{id}/dispute
  Future<Either<Failure, P2PDisputeEntity>> disputeTrade({
    required String tradeId,
    required String reason,
    required String description,
    List<String>? evidence,
    String? priority,
  });

  /// Release escrow funds (seller action)
  /// Matches: POST /api/ext/p2p/trade/{id}/release
  Future<Either<Failure, void>> releaseEscrow({
    required String tradeId,
    String? releaseReason,
    bool partialRelease = false,
    double? releaseAmount,
  });

  /// Submit trade review
  /// Matches: POST /api/ext/p2p/trade/{id}/review
  Future<Either<Failure, P2PReviewEntity>> reviewTrade({
    required String tradeId,
    required int communicationRating,
    required int speedRating,
    required int trustRating,
    required String comment,
    bool? isPositive,
  });

  // ===== MESSAGING OPERATIONS =====

  /// Get trade messages/timeline
  /// Matches: GET /api/ext/p2p/trade/{id}/message
  Future<Either<Failure, List<Map<String, dynamic>>>> getTradeMessages(
    String tradeId,
  );

  /// Send message in trade
  /// Matches: POST /api/ext/p2p/trade/{id}/message
  Future<Either<Failure, void>> sendTradeMessage({
    required String tradeId,
    required String message,
  });
}
