import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class GetProductsUseCase
    implements UseCase<List<ProductEntity>, GetProductsParams> {
  const GetProductsUseCase(this._repository);

  final EcommerceRepository _repository;

  @override
  Future<Either<Failure, List<ProductEntity>>> call(
      GetProductsParams params) async {
    return await _repository.getProducts(
      page: params.page,
      limit: params.limit,
      search: params.search,
      sortBy: params.sortBy,
      categoryId: params.categoryId,
    );
  }
}

class GetProductsParams extends Equatable {
  const GetProductsParams({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.sortBy,
    this.categoryId,
  });

  final int page;
  final int limit;
  final String? search;
  final String? sortBy;
  final String? categoryId;

  @override
  List<Object?> get props => [page, limit, search, sortBy, categoryId];
}
