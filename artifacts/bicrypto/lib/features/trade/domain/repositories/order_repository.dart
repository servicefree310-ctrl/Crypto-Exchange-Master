import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderEntity>> createOrder({
    required String currency,
    required String pair,
    required String type, // limit, market, stop
    required String side, // BUY, SELL
    required double amount,
    double? price,
    double? stopPrice,
  });

  Future<Either<Failure, List<OrderEntity>>> getOpenOrders({
    required String symbol,
  });

  Future<Either<Failure, List<OrderEntity>>> getOrderHistory({
    required String symbol,
  });
}
