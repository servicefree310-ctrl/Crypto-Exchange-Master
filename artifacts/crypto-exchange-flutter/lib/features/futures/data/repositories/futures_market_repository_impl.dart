import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/futures_market_entity.dart';
import '../../domain/repositories/futures_market_repository.dart';
import '../datasources/futures_market_remote_datasource.dart';

@Injectable(as: FuturesMarketRepository)
class FuturesMarketRepositoryImpl implements FuturesMarketRepository {
  const FuturesMarketRepositoryImpl(this._remoteDataSource, this._networkInfo);

  final FuturesMarketRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<FuturesMarketEntity>>> getFuturesMarkets() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final models = await _remoteDataSource.getFuturesMarkets();
      return Right(models.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
