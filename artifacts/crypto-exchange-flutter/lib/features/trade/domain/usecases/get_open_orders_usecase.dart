import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

@lazySingleton
class GetOpenOrdersUseCase
    implements UseCase<List<OrderEntity>, String /*symbol*/ > {
  const GetOpenOrdersUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Either<Failure, List<OrderEntity>>> call(String symbol) {
    return _repository.getOpenOrders(symbol: symbol);
  }
}
