import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../repositories/p2p_trades_repository.dart';

/// Use case for confirming payment for a P2P trade
///
/// Matches v5 backend: POST /api/ext/p2p/trade/{id}/confirm
/// - Updates trade status to 'PAYMENT_SENT'
/// - Only buyer can confirm payment
/// - Validates trade is in correct status for confirmation
/// - Records payment confirmation timestamp
@injectable
class ConfirmTradeUseCase implements UseCase<void, ConfirmTradeParams> {
  const ConfirmTradeUseCase(this._repository);

  final P2PTradesRepository _repository;

  @override
  Future<Either<Failure, void>> call(ConfirmTradeParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Execute repository call
    return await _repository.confirmTrade(
      tradeId: params.tradeId,
      paymentReference: params.paymentReference,
      paymentProof: params.paymentProof,
      notes: params.notes,
    );
  }

  ValidationFailure? _validateParams(ConfirmTradeParams params) {
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

    // Validate payment reference if provided
    if (params.paymentReference != null && params.paymentReference!.isEmpty) {
      return ValidationFailure('Payment reference cannot be empty if provided');
    }

    // Validate payment reference length
    if (params.paymentReference != null &&
        params.paymentReference!.length > 100) {
      return ValidationFailure(
          'Payment reference cannot exceed 100 characters');
    }

    // Validate notes length
    if (params.notes != null && params.notes!.length > 500) {
      return ValidationFailure('Notes cannot exceed 500 characters');
    }

    return null;
  }
}

/// Parameters for confirming trade payment
class ConfirmTradeParams {
  const ConfirmTradeParams({
    required this.tradeId,
    this.paymentReference,
    this.paymentProof,
    this.notes,
  });

  /// Trade ID to confirm payment for
  final String tradeId;

  /// Payment reference number or transaction ID
  final String? paymentReference;

  /// Payment proof (receipt image URL/path)
  final String? paymentProof;

  /// Additional notes about the payment
  final String? notes;
}
