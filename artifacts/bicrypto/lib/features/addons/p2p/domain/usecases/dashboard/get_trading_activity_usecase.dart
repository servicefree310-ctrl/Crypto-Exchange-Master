import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../entities/p2p_activity_entity.dart';
import '../../repositories/p2p_dashboard_repository.dart';

/// Use case for retrieving recent trading activity
///
/// Matches v5 backend: GET /api/ext/p2p/dashboard/activity
/// - Returns recent activity logs for the user
/// - Includes trade actions, status changes, messages
/// - Sorted by creation time (most recent first)
/// - Limited to prevent excessive data loading
@injectable
class GetTradingActivityUseCase
    implements UseCase<List<P2PActivityEntity>, GetTradingActivityParams> {
  const GetTradingActivityUseCase(this._repository);

  final P2PDashboardRepository _repository;

  @override
  Future<Either<Failure, List<P2PActivityEntity>>> call(
      GetTradingActivityParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Get trading activity
    return await _repository.getTradingActivity(
      limit: params.limit,
      offset: params.offset,
      type: params.type,
    );
  }

  ValidationFailure? _validateParams(GetTradingActivityParams params) {
    // Limit validation
    if (params.limit < 1 || params.limit > 100) {
      return ValidationFailure('Limit must be between 1 and 100');
    }

    // Offset validation
    if (params.offset < 0) {
      return ValidationFailure('Offset must be non-negative');
    }

    return null;
  }
}

/// Parameters for getting trading activity
class GetTradingActivityParams {
  const GetTradingActivityParams({
    this.limit = 10,
    this.offset = 0,
    this.type,
  });

  /// Maximum number of activities to return
  final int limit;

  /// Number of activities to skip
  final int offset;

  /// Filter by activity type
  final String? type;
}
