import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/errors/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class GetWishlistUseCase implements UseCase<List<ProductEntity>, NoParams> {
  final EcommerceRepository repository;

  const GetWishlistUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) async {
    return await repository.getWishlist();
  }
}
