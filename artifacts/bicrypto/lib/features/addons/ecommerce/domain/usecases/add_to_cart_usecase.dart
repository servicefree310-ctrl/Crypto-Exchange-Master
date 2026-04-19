import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/cart_entity.dart';
import '../entities/product_entity.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class AddToCartUseCase implements UseCase<CartEntity, AddToCartParams> {
  final EcommerceRepository repository;

  AddToCartUseCase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(AddToCartParams params) {
    return repository.addToCart(params.product, params.quantity);
  }
}

class AddToCartParams extends Equatable {
  final ProductEntity product;
  final int quantity;

  const AddToCartParams({
    required this.product,
    required this.quantity,
  });

  @override
  List<Object> get props => [product, quantity];
}
