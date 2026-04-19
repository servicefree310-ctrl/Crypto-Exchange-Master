import 'package:dartz/dartz.dart';
import '../entities/ico_offering_entity.dart';
import '../entities/ico_portfolio_entity.dart';
import '../entities/portfolio_performance_point_entity.dart';
import '../entities/ico_blockchain_entity.dart';
import '../entities/ico_token_type_entity.dart';
import '../entities/ico_launch_plan_entity.dart';
import '../entities/ico_stats_entity.dart';
import '../../../../../core/errors/failures.dart';

abstract class IcoRepository {
  /// Get ICO offerings with optional filters
  Future<Either<Failure, List<IcoOfferingEntity>>> getOfferings({
    IcoOfferingStatus? status,
    IcoTokenType? tokenType,
    String? blockchain,
    String? search,
    int? limit,
    int? offset,
  });

  /// Get a specific ICO offering by ID
  Future<Either<Failure, IcoOfferingEntity>> getOfferingById(String id);

  /// Get featured ICO offerings
  Future<Either<Failure, List<IcoOfferingEntity>>> getFeaturedOfferings();

  /// Get user's ICO portfolio
  Future<Either<Failure, IcoPortfolioEntity>> getPortfolio();

  /// Get user's ICO transactions
  Future<Either<Failure, List<IcoTransactionEntity>>> getTransactions({
    int? limit,
    int? offset,
  });

  /// Create a new investment in an ICO
  Future<Either<Failure, IcoTransactionEntity>> createInvestment({
    required String offeringId,
    required double amount,
    required String walletAddress,
  });

  /// Get ICO platform statistics
  Future<Either<Failure, IcoStatsEntity>> getIcoStats();

  /// Get portfolio performance
  Future<Either<Failure, List<PortfolioPerformancePointEntity>>>
      getPortfolioPerformance({String timeframe = '1M'});

  /// Get available blockchains for ICO
  Future<Either<Failure, List<IcoBlockchainEntity>>> getBlockchains();

  /// Get available token types
  Future<Either<Failure, List<IcoTokenTypeEntity>>> getTokenTypes();

  /// Get available launch plans
  Future<Either<Failure, List<IcoLaunchPlanEntity>>> getLaunchPlans();
}
