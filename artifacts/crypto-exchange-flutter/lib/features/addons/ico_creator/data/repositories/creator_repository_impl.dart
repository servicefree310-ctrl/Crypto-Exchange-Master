import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/network_info.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../domain/entities/creator_token_entity.dart';
import '../../domain/entities/launch_plan_entity.dart';
import '../../domain/entities/investor_entity.dart';
import '../../domain/entities/creator_stats_entity.dart';
import '../../domain/entities/team_member_entity.dart';
import '../../domain/entities/roadmap_item_entity.dart';
import '../../domain/entities/chart_point_entity.dart';
import '../../domain/repositories/creator_repository.dart';
import '../datasources/creator_remote_datasource.dart';
import '../models/creator_token_model.dart';
import '../models/launch_plan_model.dart';
import '../models/team_member_model.dart';
import '../models/roadmap_item_model.dart';

@Injectable(as: CreatorRepository)
class CreatorRepositoryImpl implements CreatorRepository {
  const CreatorRepositoryImpl(this._remote, this._networkInfo);

  final CreatorRemoteDataSource _remote;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<CreatorTokenEntity>>> getTokens() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remote.getTokens();
        return Right(models.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, CreatorTokenEntity>> getToken(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remote.getToken(id);
        return Right(model.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, void>> launchToken(
      Map<String, dynamic> payload) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remote.launchToken(payload);
        return const Right(null);
      } on BadRequestException catch (e) {
        return Left(ValidationFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, List<LaunchPlanEntity>>> getLaunchPlans() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remote.getLaunchPlans();
        return Right(models.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, List<InvestorEntity>>> getInvestors() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remote.getInvestors();
        return Right(models.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, CreatorStatsEntity>> getStats() async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remote.getStats();
        return Right(model.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, List<TeamMemberEntity>>> getTeamMembers(
      String tokenId) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remote.getTeamMembers(tokenId);
        return Right(models.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, void>> addTeamMember(
      String tokenId, TeamMemberEntity member) async {
    try {
      await _remote.addTeamMember(
          tokenId,
          TeamMemberModel(
            id: member.id,
            name: member.name,
            role: member.role,
            avatar: member.avatar,
          ).toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTeamMember(
      String tokenId, TeamMemberEntity member) async {
    try {
      await _remote.updateTeamMember(
          tokenId,
          member.id,
          TeamMemberModel(
            id: member.id,
            name: member.name,
            role: member.role,
            avatar: member.avatar,
          ).toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTeamMember(
      String tokenId, String memberId) async {
    try {
      await _remote.deleteTeamMember(tokenId, memberId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RoadmapItemEntity>>> getRoadmapItems(
      String tokenId) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remote.getRoadmapItems(tokenId);
        return Right(models.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, void>> addRoadmapItem(
      String tokenId, RoadmapItemEntity item) async {
    try {
      await _remote.addRoadmapItem(
          tokenId,
          RoadmapItemModel(
            id: item.id,
            title: item.title,
            description: item.description,
            targetDate: item.targetDate,
          ).toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateRoadmapItem(
      String tokenId, RoadmapItemEntity item) async {
    try {
      await _remote.updateRoadmapItem(
          tokenId,
          item.id,
          RoadmapItemModel(
            id: item.id,
            title: item.title,
            description: item.description,
            targetDate: item.targetDate,
          ).toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRoadmapItem(
      String tokenId, String roadmapId) async {
    try {
      await _remote.deleteRoadmapItem(tokenId, roadmapId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChartPointEntity>>> getPerformance(
      String range) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remote.getPerformance(range: range);
        return Right(models.map((e) => e.toEntity()).toList());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }
}
