import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/get_products_by_category_usecase.dart';
import 'category_products_event.dart';
import 'category_products_state.dart';

@injectable
class CategoryProductsBloc
    extends Bloc<CategoryProductsEvent, CategoryProductsState> {
  final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;
  String _categorySlug = '';

  String get categorySlug => _categorySlug;

  CategoryProductsBloc({
    required GetProductsByCategoryUseCase getProductsByCategoryUseCase,
  })  : _getProductsByCategoryUseCase = getProductsByCategoryUseCase,
        super(const CategoryProductsInitial()) {
    on<LoadCategoryProductsRequested>(_onLoadCategoryProductsRequested);
  }

  Future<void> _onLoadCategoryProductsRequested(
    LoadCategoryProductsRequested event,
    Emitter<CategoryProductsState> emit,
  ) async {
    _categorySlug = event.categorySlug;
    emit(const CategoryProductsLoading());

    final result = await _getProductsByCategoryUseCase(
      GetProductsByCategoryParams(categorySlug: event.categorySlug),
    );

    result.fold(
      (failure) => emit(CategoryProductsError(message: failure.message)),
      (products) => emit(CategoryProductsLoaded(products: products)),
    );
  }
}
