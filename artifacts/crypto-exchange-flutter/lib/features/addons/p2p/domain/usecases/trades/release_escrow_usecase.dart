import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../repositories/p2p_trades_repository.dart';

/// Use case for releasing escrow funds for a P2P trade
///
/// Matches v5 backend: POST /api/ext/p2p/trade/{id}/release
/// - Updates trade status to 'COMPLETED'
/// - Only seller can release funds
/// - Transfers cryptocurrency from escrow to buyer
/// - Records completion timestamp
@injectable
class ReleaseEscrowUseCase implements UseCase<void, ReleaseEscrowParams> {
  const ReleaseEscrowUseCase(this._repository);

  final P2PTradesRepository _repository;

  @override
  Future<Either<Failure, void>> call(ReleaseEscrowParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Execute repository call
    return await _repository.releaseEscrow(
      tradeId: params.tradeId,
      releaseReason: params.releaseReason,
      partialRelease: params.partialRelease,
      releaseAmount: params.releaseAmount,
    );
  }

  ValidationFailure? _validateParams(ReleaseEscrowParams params) {
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

    // Validate partial release amount
    if (params.partialRelease && params.releaseAmount == null) {
      return ValidationFailure(
          'Release amount is required for partial release');
    }

    if (params.releaseAmount != null && params.releaseAmount! <= 0) {
      return ValidationFailure('Release amount must be greater than 0');
    }

    // Validate release reason length
    if (params.releaseReason != null && params.releaseReason!.length > 200) {
      return ValidationFailure('Release reason cannot exceed 200 characters');
    }

    return null;
  }
}

/// Parameters for releasing escrow funds
class ReleaseEscrowParams {
  const ReleaseEscrowParams({
    required this.tradeId,
    this.releaseReason,
    this.partialRelease = false,
    this.releaseAmount,
  });

  /// Trade ID to release funds for
  final String tradeId;

  /// Optional reason for release
  final String? releaseReason;

  /// Whether this is a partial release
  final bool partialRelease;

  /// Amount to release (for partial releases)
  final double? releaseAmount;
}
