import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/ico_offering_entity.dart';
import '../../domain/entities/ico_portfolio_entity.dart';
import '../../domain/entities/portfolio_performance_point_entity.dart';
import '../../domain/entities/ico_blockchain_entity.dart';
import '../../domain/entities/ico_token_type_entity.dart';
import '../../domain/entities/ico_launch_plan_entity.dart';
import '../../domain/entities/ico_stats_entity.dart';
import '../../domain/repositories/ico_repository.dart';
import '../datasources/ico_remote_datasource.dart';
import '../models/portfolio_performance_point_model.dart';

@Injectable(as: IcoRepository)
class IcoRepositoryImpl implements IcoRepository {
  const IcoRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  final IcoRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<IcoOfferingEntity>>>
      getFeaturedOfferings() async {
    if (await _networkInfo.isConnected) {
      try {
        final offeringsModels = await _remoteDataSource.getFeaturedOfferings();
        final offerings =
            offeringsModels.map((model) => model.toEntity()).toList();
        return Right(offerings);
      } on ServerException catch (e) {
        if (e.message.contains('404') ||
            e.message.toLowerCase().contains('not found')) {
          return const Right([]);
        }
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return const Right([]);
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<IcoOfferingEntity>>> getOfferings({
    IcoOfferingStatus? status,
    IcoTokenType? tokenType,
    String? blockchain,
    String? search,
    int? limit,
    int? offset,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final offeringsModels = await _remoteDataSource.getOfferings(
          status: status?.name,
          tokenType: tokenType != null ? [tokenType.name] : null,
          blockchain: blockchain != null ? [blockchain] : null,
          search: search,
          limit: limit,
          page: offset != null ? (offset ~/ (limit ?? 10)) + 1 : null,
        );
        final offerings =
            offeringsModels.map((model) => model.toEntity()).toList();
        return Right(offerings);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, IcoOfferingEntity>> getOfferingById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final offeringModel = await _remoteDataSource.getOfferingById(id);
        return Right(offeringModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, IcoPortfolioEntity>> getPortfolio() async {
    if (await _networkInfo.isConnected) {
      try {
        final portfolioModel = await _remoteDataSource.getPortfolio();
        final transactionsModels = await _remoteDataSource.getTransactions();
        return Right(portfolioModel.toEntity(transactions: transactionsModels));
      } on ServerException catch (e) {
        if (e.message.contains('404') ||
            e.message.toLowerCase().contains('not found')) {
          return Right(_createEmptyPortfolio());
        }
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Right(_createEmptyPortfolio());
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<IcoTransactionEntity>>> getTransactions({
    int? limit,
    int? offset,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final transactionsModels = await _remoteDataSource.getTransactions(
          limit: limit,
          offset: offset,
        );
        final transactions =
            transactionsModels.map((model) => model.toEntity()).toList();
        return Right(transactions);
      } on ServerException catch (e) {
        if (e.message.contains('404') ||
            e.message.toLowerCase().contains('not found')) {
          return const Right([]);
        }
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return const Right([]);
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, IcoTransactionEntity>> createInvestment({
    required String offeringId,
    required double amount,
    required String walletAddress,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final transactionModel = await _remoteDataSource.createInvestment(
          offeringId: offeringId,
          amount: amount,
          walletAddress: walletAddress,
        );
        return Right(transactionModel.toEntity());
      } on BadRequestException catch (e) {
        return Left(ValidationFailure(e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, IcoStatsEntity>> getIcoStats() async {
    if (await _networkInfo.isConnected) {
      try {
        final statsModel = await _remoteDataSource.getIcoStats();
        return Right(statsModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<PortfolioPerformancePointEntity>>>
      getPortfolioPerformance({String timeframe = '1M'}) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getPortfolioPerformance(
          timeframe: timeframe,
        );
        return Right(models.map((m) => m.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  IcoPortfolioEntity _createEmptyPortfolio() {
    return const IcoPortfolioEntity(
      totalInvested: 0.0,
      pendingInvested: 0.0,
      verificationInvested: 0.0,
      releasedValue: 0.0,
      totalProfitLoss: 0.0,
      profitLossPercentage: 0.0,
      totalTransactions: 0,
      activeInvestments: 0,
      completedInvestments: 0,
      investments: [],
    );
  }

  @override
  Future<Either<Failure, List<IcoBlockchainEntity>>> getBlockchains() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getBlockchains();
        return Right(models.map((m) => m.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<IcoTokenTypeEntity>>> getTokenTypes() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getTokenTypes();
        return Right(models.map((m) => m.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<IcoLaunchPlanEntity>>> getLaunchPlans() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getLaunchPlans();
        return Right(models.map((m) => m.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
