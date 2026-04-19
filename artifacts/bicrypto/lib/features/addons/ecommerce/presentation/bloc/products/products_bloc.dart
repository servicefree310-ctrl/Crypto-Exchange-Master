import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/get_products_usecase.dart';
import '../../../domain/usecases/get_categories_usecase.dart';

part 'products_event.dart';
part 'products_state.dart';

@injectable
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProductsUseCase getProductsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  ProductsBloc({
    required this.getProductsUseCase,
    required this.getCategoriesUseCase,
  }) : super(ProductsInitial()) {
    on<LoadProductsRequested>(_onLoadProductsRequested);
    on<LoadCategoriesRequested>(_onLoadCategoriesRequested);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
    on<SearchProducts>(_onSearchProducts);
    on<SortProducts>(_onSortProducts);
  }

  Future<void> _onLoadProductsRequested(
    LoadProductsRequested event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    final result = await getProductsUseCase(const GetProductsParams());
    result.fold(
      (failure) => emit(ProductsError(message: failure.message)),
      (products) => emit(ProductsLoaded(products: products)),
    );
  }

  Future<void> _onLoadCategoriesRequested(
    LoadCategoriesRequested event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      emit(ProductsLoading());
    }
    final result = await getCategoriesUseCase(NoParams());
    result.fold(
      (failure) => emit(CategoriesError(message: failure.message)),
      (categories) {
        if (state is ProductsLoaded) {
          emit((state as ProductsLoaded).copyWith(categories: categories));
        } else {
          emit(CategoriesLoaded(categories: categories));
        }
      },
    );
  }

  void _onFilterProductsByCategory(
    FilterProductsByCategory event,
    Emitter<ProductsState> emit,
  ) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;

      if (event.categoryId == 'all') {
        emit(currentState.copyWith(
          filteredProducts: currentState.products,
          activeCategory: 'all',
        ));
      } else {
        final filteredProducts = currentState.products
            .where((product) => product.categoryId == event.categoryId)
            .toList();
        emit(currentState.copyWith(
          filteredProducts: filteredProducts,
          activeCategory: event.categoryId,
        ));
      }
    }
  }

  void _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsState> emit,
  ) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;

      if (event.query.isEmpty) {
        emit(currentState.copyWith(
          filteredProducts: currentState.products,
          searchQuery: '',
        ));
      } else {
        final filteredProducts = currentState.products
            .where((product) =>
                product.name
                    .toLowerCase()
                    .contains(event.query.toLowerCase()) ||
                product.description
                    .toLowerCase()
                    .contains(event.query.toLowerCase()))
            .toList();
        emit(currentState.copyWith(
          filteredProducts: filteredProducts,
          searchQuery: event.query,
        ));
      }
    }
  }

  void _onSortProducts(
    SortProducts event,
    Emitter<ProductsState> emit,
  ) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      final sortedProducts = List<ProductEntity>.from(
          currentState.filteredProducts.isEmpty
              ? currentState.products
              : currentState.filteredProducts);

      switch (event.sortOption) {
        case SortOption.priceAsc:
          sortedProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case SortOption.priceDesc:
          sortedProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case SortOption.nameAsc:
          sortedProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        case SortOption.nameDesc:
          sortedProducts.sort((a, b) => b.name.compareTo(a.name));
          break;
        case SortOption.newest:
          sortedProducts.sort((a, b) {
            if (a.createdAt == null || b.createdAt == null) return 0;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          break;
        case SortOption.rating:
          sortedProducts.sort((a, b) {
            final ratingA = a.rating ?? 0.0;
            final ratingB = b.rating ?? 0.0;
            return ratingB.compareTo(ratingA);
          });
          break;
      }

      emit(currentState.copyWith(
        filteredProducts: sortedProducts,
        sortOption: event.sortOption,
      ));
    }
  }
}
