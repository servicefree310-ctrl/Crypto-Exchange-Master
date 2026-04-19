import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../repositories/p2p_trades_repository.dart';

/// Use case for cancelling a P2P trade
///
/// Matches v5 backend: POST /api/ext/p2p/trade/{id}/cancel
/// - Updates trade status to 'CANCELLED'
/// - Requires cancellation reason
/// - Both buyer and seller can cancel (with restrictions)
/// - Handles escrow refund logic
@injectable
class CancelTradeUseCase implements UseCase<void, CancelTradeParams> {
  const CancelTradeUseCase(this._repository);

  final P2PTradesRepository _repository;

  @override
  Future<Either<Failure, void>> call(CancelTradeParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Execute repository call
    return await _repository.cancelTrade(
      tradeId: params.tradeId,
      reason: params.reason,
      forceCancel: params.forceCancel,
    );
  }

  ValidationFailure? _validateParams(CancelTradeParams params) {
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
      return ValidationFailure('Cancellation reason is required');
    }

    if (params.reason.length < 10) {
      return ValidationFailure(
          'Cancellation reason must be at least 10 characters');
    }

    if (params.reason.length > 500) {
      return ValidationFailure(
          'Cancellation reason cannot exceed 500 characters');
    }

    return null;
  }
}

/// Parameters for cancelling a trade
class CancelTradeParams {
  const CancelTradeParams({
    required this.tradeId,
    required this.reason,
    this.forceCancel = false,
  });

  /// Trade ID to cancel
  final String tradeId;

  /// Reason for cancellation
  final String reason;

  /// Force cancel even if trade is in progress (admin only)
  final bool forceCancel;
}
