import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/futures_order_entity.dart';
import '../../domain/repositories/futures_order_repository.dart';
import '../datasources/futures_order_remote_datasource.dart';

@Injectable(as: FuturesOrderRepository)
class FuturesOrderRepositoryImpl implements FuturesOrderRepository {
  const FuturesOrderRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  final FuturesOrderRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, FuturesOrderEntity>> placeOrder({
    required String currency,
    required String pair,
    required String type,
    required String side,
    required double amount,
    double? price,
    required double leverage,
    double? stopLossPrice,
    double? takeProfitPrice,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final model = await _remoteDataSource.placeOrder(
        currency: currency,
        pair: pair,
        type: type,
        side: side,
        amount: amount,
        price: price,
        leverage: leverage,
        stopLossPrice: stopLossPrice,
        takeProfitPrice: takeProfitPrice,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FuturesOrderEntity>>> getOrders({
    required String symbol,
    String? status,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final models = await _remoteDataSource.getOrders(
        symbol: symbol,
        status: status,
      );
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FuturesOrderEntity>> cancelOrder(
    String id, {
    required DateTime createdAt,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final model = await _remoteDataSource.cancelOrder(
        id,
        createdAt: createdAt,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
