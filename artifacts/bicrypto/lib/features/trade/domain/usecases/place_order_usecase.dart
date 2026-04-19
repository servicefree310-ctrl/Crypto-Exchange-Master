import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class PlaceOrderParams {
  const PlaceOrderParams({
    required this.currency,
    required this.pair,
    required this.type,
    required this.side,
    required this.amount,
    this.price,
    this.stopPrice,
  });

  final String currency;
  final String pair;
  final String type; // limit, market, stop
  final String side; // BUY, SELL
  final double amount;
  final double? price;
  final double? stopPrice;
}

@injectable
class PlaceOrderUseCase implements UseCase<OrderEntity, PlaceOrderParams> {
  const PlaceOrderUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Either<Failure, OrderEntity>> call(PlaceOrderParams params) {
    // Basic validation
    if (params.amount <= 0) {
      return Future.value(
          const Left(ValidationFailure('Amount must be greater than zero')));
    }

    if (params.type.toLowerCase() == 'limit' &&
        (params.price == null || params.price! <= 0)) {
      return Future.value(
          const Left(ValidationFailure('Price is required for limit orders')));
    }

    if (params.type.toLowerCase() == 'stop' &&
        (params.stopPrice == null || params.stopPrice! <= 0)) {
      return Future.value(const Left(
          ValidationFailure('Stop price is required for stop orders')));
    }

    return _repository.createOrder(
      currency: params.currency,
      pair: params.pair,
      type: params.type.toLowerCase(),
      side: params.side.toUpperCase(),
      amount: params.amount,
      price: params.price,
      stopPrice: params.stopPrice,
    );
  }
}
