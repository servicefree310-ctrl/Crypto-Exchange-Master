import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/get_categories_usecase.dart';
import '../../../domain/usecases/get_products_usecase.dart';

part 'shop_event.dart';
part 'shop_state.dart';

@injectable
class ShopBloc extends Bloc<ShopEvent, ShopState> {
  ShopBloc(
    this._getProductsUseCase,
    this._getCategoriesUseCase,
  ) : super(const ShopInitial()) {
    on<ShopLoadRequested>(_onShopLoadRequested);
    on<ShopRefreshRequested>(_onShopRefreshRequested);
    on<ShopCategorySelected>(_onShopCategorySelected);
    on<ShopSearchChanged>(_onShopSearchChanged);
    on<ShopSortChanged>(_onShopSortChanged);
  }

  final GetProductsUseCase _getProductsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;

  Future<void> _onShopLoadRequested(
    ShopLoadRequested event,
    Emitter<ShopState> emit,
  ) async {
    emit(const ShopLoading());

    // Load both products and categories in parallel
    final productsResult = await _getProductsUseCase(
      const GetProductsParams(limit: 20),
    );
    final categoriesResult = await _getCategoriesUseCase(NoParams());

    // Handle results
    productsResult.fold(
      (failure) => emit(ShopError(message: failure.message)),
      (products) {
        categoriesResult.fold(
          (failure) => emit(ShopError(message: failure.message)),
          (categories) => emit(
            ShopLoaded(
              products: products,
              categories: categories,
              featuredProducts: _getFeaturedProducts(products),
              selectedCategoryId: null,
              searchQuery: '',
              sortBy: 'featured',
            ),
          ),
        );
      },
    );
  }

  Future<void> _onShopRefreshRequested(
    ShopRefreshRequested event,
    Emitter<ShopState> emit,
  ) async {
    if (state is ShopLoaded) {
      final currentState = state as ShopLoaded;
      emit(currentState.copyWith(isRefreshing: true));

      final productsResult = await _getProductsUseCase(
        GetProductsParams(
          categoryId: currentState.selectedCategoryId,
          search: currentState.searchQuery,
          sortBy: currentState.sortBy,
        ),
      );

      productsResult.fold(
        (failure) => emit(currentState.copyWith(isRefreshing: false)),
        (products) => emit(
          currentState.copyWith(
            products: products,
            featuredProducts: _getFeaturedProducts(products),
            isRefreshing: false,
          ),
        ),
      );
    }
  }

  Future<void> _onShopCategorySelected(
    ShopCategorySelected event,
    Emitter<ShopState> emit,
  ) async {
    if (state is ShopLoaded) {
      final currentState = state as ShopLoaded;
      emit(currentState.copyWith(isLoadingProducts: true));

      final result = await _getProductsUseCase(
        GetProductsParams(
          categoryId: event.categoryId,
          sortBy: currentState.sortBy,
        ),
      );

      result.fold(
        (failure) => emit(currentState.copyWith(isLoadingProducts: false)),
        (products) => emit(
          currentState.copyWith(
            products: products,
            selectedCategoryId: event.categoryId,
            isLoadingProducts: false,
          ),
        ),
      );
    }
  }

  Future<void> _onShopSearchChanged(
    ShopSearchChanged event,
    Emitter<ShopState> emit,
  ) async {
    if (state is ShopLoaded) {
      final currentState = state as ShopLoaded;

      if (event.query.isEmpty) {
        // Clear search
        add(const ShopRefreshRequested());
        return;
      }

      emit(currentState.copyWith(isLoadingProducts: true));

      final result = await _getProductsUseCase(
        GetProductsParams(
          search: event.query,
          categoryId: currentState.selectedCategoryId,
          sortBy: currentState.sortBy,
        ),
      );

      result.fold(
        (failure) => emit(currentState.copyWith(isLoadingProducts: false)),
        (products) => emit(
          currentState.copyWith(
            products: products,
            searchQuery: event.query,
            isLoadingProducts: false,
          ),
        ),
      );
    }
  }

  Future<void> _onShopSortChanged(
    ShopSortChanged event,
    Emitter<ShopState> emit,
  ) async {
    if (state is ShopLoaded) {
      final currentState = state as ShopLoaded;
      emit(currentState.copyWith(isLoadingProducts: true));

      final result = await _getProductsUseCase(
        GetProductsParams(
          categoryId: currentState.selectedCategoryId,
          search: currentState.searchQuery,
          sortBy: event.sortBy,
        ),
      );

      result.fold(
        (failure) => emit(currentState.copyWith(isLoadingProducts: false)),
        (products) => emit(
          currentState.copyWith(
            products: products,
            sortBy: event.sortBy,
            isLoadingProducts: false,
          ),
        ),
      );
    }
  }

  List<ProductEntity> _getFeaturedProducts(List<ProductEntity> products) {
    final featured = products.where((p) => p.isFeatured).toList();
    // Fall back to first 8 if no products are explicitly marked as featured
    return featured.isNotEmpty ? featured : products.take(8).toList();
  }
}
