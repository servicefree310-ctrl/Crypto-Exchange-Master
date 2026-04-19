import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../entities/p2p_trade_entity.dart';
import '../../entities/p2p_activity_entity.dart';
import '../../repositories/p2p_dashboard_repository.dart';

/// Use case for retrieving comprehensive P2P dashboard data
///
/// Matches v5 backend: GET /api/ext/p2p/dashboard
/// - Returns complete dashboard with all sections
/// - Includes notifications, portfolio, stats, activity, transactions
/// - Provides aggregated data for dashboard overview
/// - Calculates key performance metrics
@injectable
class GetDashboardDataUseCase
    implements UseCase<P2PDashboardResponse, NoParams> {
  const GetDashboardDataUseCase(this._repository);

  final P2PDashboardRepository _repository;

  @override
  Future<Either<Failure, P2PDashboardResponse>> call(NoParams params) async {
    // No validation needed for dashboard request
    return await _repository.getDashboardData();
  }
}

/// Complete dashboard response
class P2PDashboardResponse {
  const P2PDashboardResponse({
    required this.notifications,
    required this.portfolio,
    required this.stats,
    required this.tradingActivity,
    required this.transactions,
    required this.summary,
  });

  /// Notification count
  final int notifications;

  /// Portfolio data
  final PortfolioData portfolio;

  /// Trading statistics
  final DashboardStats stats;

  /// Recent trading activity
  final List<P2PActivityEntity> tradingActivity;

  /// Recent transactions
  final List<P2PTradeEntity> transactions;

  /// Dashboard summary metrics
  final DashboardSummary summary;
}

/// Portfolio data
class PortfolioData {
  const PortfolioData({
    required this.totalValue,
    required this.totalTrades,
    required this.profitLoss,
    required this.monthlyVolume,
  });

  final double totalValue;
  final int totalTrades;
  final double profitLoss;
  final double monthlyVolume;
}

/// Dashboard statistics
class DashboardStats {
  const DashboardStats({
    required this.totalTrades,
    required this.activeTrades,
    required this.completedTrades,
    required this.successRate,
    required this.totalVolume,
    required this.avgTradeSize,
  });

  final int totalTrades;
  final int activeTrades;
  final int completedTrades;
  final double successRate;
  final double totalVolume;
  final double avgTradeSize;
}

/// Dashboard summary metrics
class DashboardSummary {
  const DashboardSummary({
    required this.todayTrades,
    required this.weeklyTrades,
    required this.monthlyTrades,
    required this.pendingActions,
    required this.alerts,
  });

  final int todayTrades;
  final int weeklyTrades;
  final int monthlyTrades;
  final int pendingActions;
  final int alerts;
}

/// No parameters class for usecase without params
class NoParams {
  const NoParams();
}
