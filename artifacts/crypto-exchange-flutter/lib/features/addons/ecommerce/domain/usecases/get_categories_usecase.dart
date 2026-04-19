import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class GetCategoriesUseCase implements UseCase<List<CategoryEntity>, NoParams> {
  const GetCategoriesUseCase(this._repository);

  final EcommerceRepository _repository;

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) async {
    return await _repository.getCategories();
  }
}
