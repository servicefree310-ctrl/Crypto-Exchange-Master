import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/cart_entity.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class UpdateCartItemQuantityUseCase
    implements UseCase<CartEntity, UpdateCartItemQuantityParams> {
  final EcommerceRepository repository;

  UpdateCartItemQuantityUseCase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(
      UpdateCartItemQuantityParams params) {
    return repository.updateCartItemQuantity(params.productId, params.quantity);
  }
}

class UpdateCartItemQuantityParams extends Equatable {
  final String productId;
  final int quantity;

  const UpdateCartItemQuantityParams({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object> get props => [productId, quantity];
}
