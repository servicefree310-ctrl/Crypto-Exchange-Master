import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../repositories/p2p_dashboard_repository.dart';

/// Use case for retrieving P2P dashboard statistics
///
/// Matches v5 backend: GET /api/ext/p2p/dashboard/stats
/// - Returns basic trade counts and metrics
/// - Includes total, active, and completed trade counts
/// - Calculates success rates and volume metrics
/// - Provides quick overview statistics
@injectable
class GetDashboardStatsUseCase
    implements UseCase<DashboardStatsResponse, NoParams> {
  const GetDashboardStatsUseCase(this._repository);

  final P2PDashboardRepository _repository;

  @override
  Future<Either<Failure, DashboardStatsResponse>> call(NoParams params) async {
    // No validation needed for stats request
    return await _repository.getDashboardStats();
  }
}

/// Dashboard statistics response
class DashboardStatsResponse {
  const DashboardStatsResponse({
    required this.totalTrades,
    required this.activeTrades,
    required this.completedTrades,
    required this.disputedTrades,
    required this.cancelledTrades,
    required this.successRate,
    required this.totalVolume,
    required this.monthlyVolume,
    required this.averageTradeSize,
    required this.averageCompletionTime,
  });

  /// Total number of trades
  final int totalTrades;

  /// Currently active trades
  final int activeTrades;

  /// Successfully completed trades
  final int completedTrades;

  /// Trades in dispute
  final int disputedTrades;

  /// Cancelled trades
  final int cancelledTrades;

  /// Success rate percentage (0-100)
  final double successRate;

  /// Total trading volume
  final double totalVolume;

  /// Current month trading volume
  final double monthlyVolume;

  /// Average trade size
  final double averageTradeSize;

  /// Average time to complete trades (in minutes)
  final double? averageCompletionTime;
}

/// No parameters class
class NoParams {
  const NoParams();
}
