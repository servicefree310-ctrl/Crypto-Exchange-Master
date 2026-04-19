import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/futures_order_entity.dart';
import '../repositories/futures_order_repository.dart';

class PlaceFuturesOrderParams {
  const PlaceFuturesOrderParams({
    required this.currency,
    required this.pair,
    required this.type,
    required this.side,
    required this.amount,
    this.price,
    required this.leverage,
    this.stopLossPrice,
    this.takeProfitPrice,
  });

  final String currency;
  final String pair;
  final String type;
  final String side;
  final double amount;
  final double? price;
  final double leverage;
  final double? stopLossPrice;
  final double? takeProfitPrice;
}

@injectable
class PlaceFuturesOrderUseCase
    implements UseCase<FuturesOrderEntity, PlaceFuturesOrderParams> {
  const PlaceFuturesOrderUseCase(this._repository);

  final FuturesOrderRepository _repository;

  @override
  Future<Either<Failure, FuturesOrderEntity>> call(
      PlaceFuturesOrderParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _repository.placeOrder(
      currency: params.currency,
      pair: params.pair,
      type: params.type,
      side: params.side,
      amount: params.amount,
      price: params.price,
      leverage: params.leverage,
      stopLossPrice: params.stopLossPrice,
      takeProfitPrice: params.takeProfitPrice,
    );
  }

  ValidationFailure? _validateParams(PlaceFuturesOrderParams params) {
    if (params.currency.isEmpty) {
      return const ValidationFailure('Currency is required');
    }
    if (params.pair.isEmpty) {
      return const ValidationFailure('Pair is required');
    }
    if (params.type.isEmpty) {
      return const ValidationFailure('Order type is required');
    }
    if (params.side.isEmpty) {
      return const ValidationFailure('Order side is required');
    }
    if (params.amount <= 0) {
      return const ValidationFailure('Amount must be greater than 0');
    }
    if (params.type == 'limit' &&
        (params.price == null || params.price! <= 0)) {
      return const ValidationFailure('Price is required for limit orders');
    }
    if (params.leverage < 1 || params.leverage > 100) {
      return const ValidationFailure('Leverage must be between 1 and 100');
    }
    return null;
  }
}
