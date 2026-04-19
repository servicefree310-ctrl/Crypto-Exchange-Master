import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/errors/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class GetProductsByCategoryUseCase
    implements UseCase<List<ProductEntity>, GetProductsByCategoryParams> {
  final EcommerceRepository repository;

  const GetProductsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(
    GetProductsByCategoryParams params,
  ) async {
    return await repository.getProductsByCategory(params.categorySlug);
  }
}

class GetProductsByCategoryParams {
  final String categorySlug;

  const GetProductsByCategoryParams({required this.categorySlug});
}
