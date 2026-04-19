import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

@Injectable(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl(this._remoteDataSource, this._networkInfo);

  final OrderRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required String currency,
    required String pair,
    required String type,
    required String side,
    required double amount,
    double? price,
    double? stopPrice,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final model = await _remoteDataSource.createOrder(
        currency: currency,
        pair: pair,
        type: type,
        side: side,
        amount: amount,
        price: price,
        stopPrice: stopPrice,
      );
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOpenOrders({
    required String symbol,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final models = await _remoteDataSource.fetchOpenOrders(symbol: symbol);
      return Right(models.map((m) => m.toEntity()).toList());
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrderHistory({
    required String symbol,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final models = await _remoteDataSource.fetchOrderHistory(symbol: symbol);
      return Right(models.map((m) => m.toEntity()).toList());
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
