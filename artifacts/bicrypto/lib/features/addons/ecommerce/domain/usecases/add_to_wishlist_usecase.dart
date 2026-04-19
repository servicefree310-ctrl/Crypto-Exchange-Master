import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/errors/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class AddToWishlistUseCase
    implements UseCase<List<ProductEntity>, AddToWishlistParams> {
  final EcommerceRepository repository;

  const AddToWishlistUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(
      AddToWishlistParams params) async {
    return await repository.addToWishlist(params.product);
  }
}

class AddToWishlistParams {
  final ProductEntity product;

  const AddToWishlistParams({required this.product});
}
