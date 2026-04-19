import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../repositories/p2p_dashboard_repository.dart';

/// Use case for retrieving P2P portfolio data
///
/// Matches v5 backend: GET /api/ext/p2p/dashboard/portfolio
/// - Returns portfolio summary for the user
/// - Includes total value from completed trades
/// - Calculates profit/loss and performance metrics
/// - Provides asset distribution data
@injectable
class GetPortfolioDataUseCase
    implements UseCase<PortfolioDataResponse, NoParams> {
  const GetPortfolioDataUseCase(this._repository);

  final P2PDashboardRepository _repository;

  @override
  Future<Either<Failure, PortfolioDataResponse>> call(NoParams params) async {
    // No validation needed for portfolio request
    return await _repository.getPortfolioData();
  }
}

/// Portfolio data response
class PortfolioDataResponse {
  const PortfolioDataResponse({
    required this.totalValue,
    required this.totalTrades,
    required this.monthlyVolume,
    required this.profitLoss,
    required this.profitLossPercentage,
    required this.topCurrencies,
    required this.recentPerformance,
  });

  /// Total portfolio value
  final double totalValue;

  /// Total number of completed trades
  final int totalTrades;

  /// Trading volume this month
  final double monthlyVolume;

  /// Total profit/loss amount
  final double profitLoss;

  /// Profit/loss as percentage
  final double profitLossPercentage;

  /// Top traded currencies
  final List<CurrencyData> topCurrencies;

  /// Recent performance data
  final List<PerformanceData> recentPerformance;
}

/// Currency trading data
class CurrencyData {
  const CurrencyData({
    required this.currency,
    required this.volume,
    required this.trades,
    required this.percentage,
  });

  final String currency;
  final double volume;
  final int trades;
  final double percentage;
}

/// Performance data point
class PerformanceData {
  const PerformanceData({
    required this.date,
    required this.volume,
    required this.trades,
    required this.profit,
  });

  final DateTime date;
  final double volume;
  final int trades;
  final double profit;
}

/// No parameters class
class NoParams {
  const NoParams();
}
