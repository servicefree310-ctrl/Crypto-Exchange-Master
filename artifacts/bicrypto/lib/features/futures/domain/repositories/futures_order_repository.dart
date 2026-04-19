import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/futures_order_entity.dart';

abstract class FuturesOrderRepository {
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
  });

  Future<Either<Failure, List<FuturesOrderEntity>>> getOrders({
    required String symbol,
    String? status,
  });

  Future<Either<Failure, FuturesOrderEntity>> cancelOrder(
    String id, {
    required DateTime createdAt,
  });
}
