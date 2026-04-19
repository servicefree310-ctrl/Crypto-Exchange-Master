part of 'products_bloc.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<ProductEntity> products;
  final List<ProductEntity> filteredProducts;
  final List<CategoryEntity> categories;
  final String activeCategory;
  final String searchQuery;
  final SortOption sortOption;

  const ProductsLoaded({
    required this.products,
    this.filteredProducts = const [],
    this.categories = const [],
    this.activeCategory = 'all',
    this.searchQuery = '',
    this.sortOption = SortOption.newest,
  });

  @override
  List<Object?> get props => [
        products,
        filteredProducts,
        categories,
        activeCategory,
        searchQuery,
        sortOption,
      ];

  ProductsLoaded copyWith({
    List<ProductEntity>? products,
    List<ProductEntity>? filteredProducts,
    List<CategoryEntity>? categories,
    String? activeCategory,
    String? searchQuery,
    SortOption? sortOption,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      activeCategory: activeCategory ?? this.activeCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError({required this.message});

  @override
  List<Object> get props => [message];
}

class CategoriesLoaded extends ProductsState {
  final List<CategoryEntity> categories;

  const CategoriesLoaded({required this.categories});

  @override
  List<Object> get props => [categories];
}

class CategoriesError extends ProductsState {
  final String message;

  const CategoriesError({required this.message});

  @override
  List<Object> get props => [message];
}
