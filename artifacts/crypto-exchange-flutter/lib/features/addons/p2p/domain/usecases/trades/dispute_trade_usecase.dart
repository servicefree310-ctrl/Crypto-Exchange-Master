import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../entities/p2p_dispute_entity.dart';
import '../../repositories/p2p_trades_repository.dart';

/// Use case for creating a dispute for a P2P trade
///
/// Matches v5 backend: POST /api/ext/p2p/trade/{id}/dispute
/// - Creates a dispute record with reason and description
/// - Updates trade status to 'DISPUTED'
/// - Sets dispute priority and initial status
/// - Both buyer and seller can create disputes
@injectable
class DisputeTradeUseCase
    implements UseCase<P2PDisputeEntity, DisputeTradeParams> {
  const DisputeTradeUseCase(this._repository);

  final P2PTradesRepository _repository;

  @override
  Future<Either<Failure, P2PDisputeEntity>> call(
      DisputeTradeParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Execute repository call
    return await _repository.disputeTrade(
      tradeId: params.tradeId,
      reason: params.reason,
      description: params.description,
      evidence: params.evidence,
      priority: params.priority,
    );
  }

  ValidationFailure? _validateParams(DisputeTradeParams params) {
    // Validate trade ID
    if (params.tradeId.isEmpty) {
      return ValidationFailure('Trade ID cannot be empty');
    }

    // Validate UUID format
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    if (!uuidRegex.hasMatch(params.tradeId)) {
      return ValidationFailure('Invalid trade ID format');
    }

    // Validate reason
    if (params.reason.isEmpty) {
      return ValidationFailure('Dispute reason is required');
    }

    if (!_isValidDisputeReason(params.reason)) {
      return ValidationFailure('Invalid dispute reason');
    }

    // Validate description
    if (params.description.isEmpty) {
      return ValidationFailure('Dispute description is required');
    }

    if (params.description.length < 20) {
      return ValidationFailure(
          'Dispute description must be at least 20 characters');
    }

    if (params.description.length > 1000) {
      return ValidationFailure(
          'Dispute description cannot exceed 1000 characters');
    }

    // Validate priority
    if (params.priority != null && !_isValidPriority(params.priority!)) {
      return ValidationFailure('Invalid dispute priority');
    }

    // Validate evidence URLs
    if (params.evidence != null && params.evidence!.isNotEmpty) {
      for (final url in params.evidence!) {
        if (!_isValidUrl(url)) {
          return ValidationFailure('Invalid evidence URL: $url');
        }
      }
    }

    return null;
  }

  bool _isValidDisputeReason(String reason) {
    const validReasons = [
      'PAYMENT_NOT_RECEIVED',
      'PAYMENT_NOT_SENT',
      'WRONG_AMOUNT',
      'SCAM_ATTEMPT',
      'BUYER_UNRESPONSIVE',
      'SELLER_UNRESPONSIVE',
      'PAYMENT_METHOD_ISSUE',
      'OTHER',
    ];
    return validReasons.contains(reason);
  }

  bool _isValidPriority(String priority) {
    const validPriorities = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];
    return validPriorities.contains(priority);
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}

/// Parameters for creating a trade dispute
class DisputeTradeParams {
  const DisputeTradeParams({
    required this.tradeId,
    required this.reason,
    required this.description,
    this.evidence,
    this.priority,
  });

  /// Trade ID to dispute
  final String tradeId;

  /// Dispute reason (predefined categories)
  final String reason;

  /// Detailed description of the dispute
  final String description;

  /// Evidence URLs (screenshots, documents)
  final List<String>? evidence;

  /// Dispute priority (LOW, MEDIUM, HIGH, URGENT)
  final String? priority;
}
