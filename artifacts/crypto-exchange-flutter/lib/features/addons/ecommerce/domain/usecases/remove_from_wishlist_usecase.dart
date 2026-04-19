import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/errors/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class RemoveFromWishlistUseCase
    implements UseCase<List<ProductEntity>, RemoveFromWishlistParams> {
  final EcommerceRepository repository;

  const RemoveFromWishlistUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(
      RemoveFromWishlistParams params) async {
    return await repository.removeFromWishlist(params.productId);
  }
}

class RemoveFromWishlistParams {
  final String productId;

  const RemoveFromWishlistParams({required this.productId});
}
