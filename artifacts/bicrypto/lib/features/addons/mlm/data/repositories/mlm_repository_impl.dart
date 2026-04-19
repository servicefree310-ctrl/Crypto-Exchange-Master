import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/mlm_dashboard_entity.dart';
import '../../domain/entities/mlm_landing_entity.dart';
import '../../domain/entities/mlm_referral_entity.dart';
import '../../domain/entities/mlm_reward_entity.dart';
import '../../domain/entities/mlm_condition_entity.dart';
import '../../domain/entities/mlm_network_entity.dart';
import '../../domain/repositories/mlm_repository.dart';
import '../datasources/mlm_remote_datasource.dart';
import '../models/mlm_dashboard_model.dart';
import '../models/mlm_landing_model.dart';
import '../models/mlm_referral_model.dart';
import '../models/mlm_reward_model.dart';
import '../models/mlm_condition_model.dart';
import '../models/mlm_network_model.dart';

@Injectable(as: MlmRepository)
class MlmRepositoryImpl implements MlmRepository {
  const MlmRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  final MlmRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, MlmDashboardEntity>> getDashboard({
    String period = '6m',
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch data from remote source
      final model = await _remoteDataSource.getDashboard(period: period);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MlmReferralEntity>>> getReferrals({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch data from remote source
      final data = await _remoteDataSource.getReferrals(
        page: page,
        perPage: perPage,
      );

      // Convert to entities
      final entities = <MlmReferralEntity>[];
      for (final item in data) {
        try {
          final model = MlmReferralModel.fromJson(item as Map<String, dynamic>);
          entities.add(model.toEntity());
        } catch (e) {
          // Skip invalid items but log the error
          dev.log('Error parsing referral: $e');
        }
      }

      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MlmReferralEntity>> getReferralById(String id) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch data from remote source
      final data = await _remoteDataSource.getReferralById(id);

      // Convert to entity
      final model = MlmReferralModel.fromJson(data);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> analyzeReferral({
    required String referralId,
    required Map<String, dynamic> analysisData,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Execute analysis
      final result = await _remoteDataSource.analyzeReferral(
        referralId: referralId,
        analysisData: analysisData,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MlmRewardEntity>>> getRewards({
    int page = 1,
    int perPage = 10,
    String? sortField,
    String? sortOrder,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch data from remote source
      final data = await _remoteDataSource.getRewards(
        page: page,
        perPage: perPage,
        sortField: sortField,
        sortOrder: sortOrder,
      );

      // Convert to entities
      final entities = <MlmRewardEntity>[];
      for (final item in data) {
        try {
          final model = MlmRewardModel.fromJson(item as Map<String, dynamic>);
          entities.add(model.toEntity());
        } catch (e) {
          // Skip invalid items but log the error
          dev.log('Error parsing reward: $e');
        }
      }

      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MlmRewardEntity>> getRewardById(String id) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch data from remote source
      final data = await _remoteDataSource.getRewardById(id);

      // Convert to entity
      final model = MlmRewardModel.fromJson(data);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> claimReward(
      String rewardId) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Claim reward
      final result = await _remoteDataSource.claimReward(rewardId);

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MlmNetworkEntity>> getNetwork() async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch data from remote source
      final data = await _remoteDataSource.getNetwork();

      // Convert to entity
      final model = MlmNetworkModel.fromJson(data);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getNetworkNode() async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch data from remote source
      final result = await _remoteDataSource.getNetworkNode();

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MlmConditionEntity>>> getConditions() async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch data from remote source
      final data = await _remoteDataSource.getConditions();

      // Convert to entities
      final entities = <MlmConditionEntity>[];
      for (final item in data) {
        try {
          final model =
              MlmConditionModel.fromJson(item as Map<String, dynamic>);
          entities.add(model.toEntity());
        } catch (e) {
          // Skip invalid items but log the error
          dev.log('Error parsing condition: $e');
        }
      }

      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MlmConditionEntity>> getConditionById(
      String id) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch data from remote source
      final data = await _remoteDataSource.getConditionById(id);

      // Convert to entity
      final model = MlmConditionModel.fromJson(data);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAnalytics({
    String period = '6m',
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch data from remote source
      final result = await _remoteDataSource.getAnalytics(period: period);

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPerformanceMetrics() async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch data from remote source
      final result = await _remoteDataSource.getPerformanceMetrics();

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MlmLandingEntity>> getLanding() async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch data from remote source
      final model = await _remoteDataSource.getLanding();

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}

// Custom exceptions for better error handling
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}
