import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/errors/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class GetOrdersUseCase implements UseCase<List<OrderEntity>, NoParams> {
  final EcommerceRepository repository;

  const GetOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(NoParams params) async {
    return await repository.getOrders();
  }
}
