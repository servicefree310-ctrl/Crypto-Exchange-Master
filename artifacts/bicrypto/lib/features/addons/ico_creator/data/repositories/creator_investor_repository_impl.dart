import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/creator_investor_entity.dart';
import '../../domain/repositories/creator_investor_repository.dart';
import '../datasources/creator_investor_remote_datasource.dart';
import '../models/creator_investor_model.dart';

@Injectable(as: CreatorInvestorRepository)
class CreatorInvestorRepositoryImpl implements CreatorInvestorRepository {
  const CreatorInvestorRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  final CreatorInvestorRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<CreatorInvestorEntity>>> getInvestors({
    int page = 1,
    int limit = 10,
    String? sortField,
    String? sortDirection,
    String? search,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final models = await _remoteDataSource.getInvestors(
        page: page,
        limit: limit,
        sortField: sortField,
        sortDirection: sortDirection,
        search: search,
      );

      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
