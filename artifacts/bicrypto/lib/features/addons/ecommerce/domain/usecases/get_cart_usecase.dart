import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/cart_entity.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class GetCartUseCase implements UseCase<CartEntity, NoParams> {
  final EcommerceRepository repository;

  GetCartUseCase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(NoParams params) {
    return repository.getCart();
  }
}
