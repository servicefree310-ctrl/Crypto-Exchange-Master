import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/futures_order_entity.dart';
import '../repositories/futures_order_repository.dart';

class GetFuturesOrdersParams {
  const GetFuturesOrdersParams({
    required this.symbol,
    this.status,
  });

  final String symbol;
  final String? status; // OPEN, FILLED, CANCELLED, etc.
}

@injectable
class GetFuturesOrdersUseCase
    implements UseCase<List<FuturesOrderEntity>, GetFuturesOrdersParams> {
  const GetFuturesOrdersUseCase(this._repository);

  final FuturesOrderRepository _repository;

  @override
  Future<Either<Failure, List<FuturesOrderEntity>>> call(
      GetFuturesOrdersParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _repository.getOrders(
      symbol: params.symbol,
      status: params.status,
    );
  }

  ValidationFailure? _validateParams(GetFuturesOrdersParams params) {
    if (params.symbol.isEmpty) {
      return const ValidationFailure('Symbol is required');
    }
    return null;
  }
}
