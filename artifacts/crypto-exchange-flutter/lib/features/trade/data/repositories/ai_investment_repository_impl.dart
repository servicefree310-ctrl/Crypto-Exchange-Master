import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/ai_investment_plan_entity.dart';
import '../../domain/entities/ai_investment_entity.dart';
import '../../domain/repositories/ai_investment_repository.dart';
import '../datasources/ai_investment_remote_datasource.dart';
import '../models/ai_investment_plan_model.dart';
import '../models/ai_investment_model.dart';

@Injectable(as: AiInvestmentRepository)
class AiInvestmentRepositoryImpl implements AiInvestmentRepository {
  const AiInvestmentRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  final AiInvestmentRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<AiInvestmentPlanEntity>>>
      getAiInvestmentPlans() async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final plans = await _remoteDataSource.getAiInvestmentPlans();
      return Right(plans.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AiInvestmentEntity>>> getUserAiInvestments({
    String? status,
    String? type,
    int? limit,
    int? offset,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final investments = await _remoteDataSource.getUserAiInvestments(
        status: status,
        type: type,
        limit: limit,
        offset: offset,
      );
      return Right(investments.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AiInvestmentEntity>> getAiInvestmentById(
      String id) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final investment = await _remoteDataSource.getAiInvestmentById(id);
      return Right(investment.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AiInvestmentEntity>> createAiInvestment({
    required String planId,
    required String durationId,
    required String symbol,
    required double amount,
    required String walletType,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final investment = await _remoteDataSource.createAiInvestment(
        planId: planId,
        durationId: durationId,
        symbol: symbol,
        amount: amount,
        walletType: walletType,
      );
      return Right(investment.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAiInvestment(String id) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await _remoteDataSource.cancelAiInvestment(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
