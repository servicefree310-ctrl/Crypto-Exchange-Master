import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/errors/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class GetOrderByIdUseCase implements UseCase<OrderEntity, GetOrderByIdParams> {
  final EcommerceRepository repository;

  const GetOrderByIdUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(GetOrderByIdParams params) async {
    return await repository.getOrderById(params.orderId);
  }
}

class GetOrderByIdParams {
  final String orderId;

  const GetOrderByIdParams({required this.orderId});
}
