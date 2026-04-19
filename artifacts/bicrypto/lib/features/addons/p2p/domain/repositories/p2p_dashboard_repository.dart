import 'package:dartz/dartz.dart';
import '../../../../../../../../core/errors/failures.dart';
import '../entities/p2p_activity_entity.dart';
import '../usecases/dashboard/get_dashboard_data_usecase.dart';
import '../usecases/dashboard/get_dashboard_stats_usecase.dart';
import '../usecases/dashboard/get_portfolio_data_usecase.dart';

/// Repository interface for P2P dashboard operations
///
/// Defines all dashboard-related operations that can be performed
/// Implementation will handle API calls to backend endpoints
abstract class P2PDashboardRepository {
  /// Get complete dashboard data
  /// Matches: GET /api/ext/p2p/dashboard
  Future<Either<Failure, P2PDashboardResponse>> getDashboardData();

  /// Get dashboard statistics
  /// Matches: GET /api/ext/p2p/dashboard/stats
  Future<Either<Failure, DashboardStatsResponse>> getDashboardStats();

  /// Get trading activity
  /// Matches: GET /api/ext/p2p/dashboard/activity
  Future<Either<Failure, List<P2PActivityEntity>>> getTradingActivity({
    int limit = 10,
    int offset = 0,
    String? type,
  });

  /// Get portfolio data
  /// Matches: GET /api/ext/p2p/dashboard/portfolio
  Future<Either<Failure, PortfolioDataResponse>> getPortfolioData();
}
