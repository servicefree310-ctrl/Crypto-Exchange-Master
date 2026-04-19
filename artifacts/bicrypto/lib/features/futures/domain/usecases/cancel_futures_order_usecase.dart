import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/futures_order_entity.dart';
import '../repositories/futures_order_repository.dart';

class CancelFuturesOrderParams {
  const CancelFuturesOrderParams({
    required this.orderId,
    required this.createdAt,
  });

  final String orderId;
  final DateTime createdAt;
}

@injectable
class CancelFuturesOrderUseCase
    implements UseCase<FuturesOrderEntity, CancelFuturesOrderParams> {
  const CancelFuturesOrderUseCase(this._repository);

  final FuturesOrderRepository _repository;

  @override
  Future<Either<Failure, FuturesOrderEntity>> call(
      CancelFuturesOrderParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _repository.cancelOrder(
      params.orderId,
      createdAt: params.createdAt,
    );
  }

  ValidationFailure? _validateParams(CancelFuturesOrderParams params) {
    if (params.orderId.isEmpty) {
      return const ValidationFailure('Order ID is required');
    }
    return null;
  }
}
