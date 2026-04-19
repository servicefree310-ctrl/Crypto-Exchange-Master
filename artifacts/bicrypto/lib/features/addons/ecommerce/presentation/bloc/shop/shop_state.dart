part of 'shop_bloc.dart';

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

class ShopInitial extends ShopState {
  const ShopInitial();
}

class ShopLoading extends ShopState {
  const ShopLoading();
}

class ShopLoaded extends ShopState {
  const ShopLoaded({
    required this.products,
    required this.categories,
    required this.featuredProducts,
    required this.selectedCategoryId,
    required this.searchQuery,
    required this.sortBy,
    this.isRefreshing = false,
    this.isLoadingProducts = false,
  });

  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final List<ProductEntity> featuredProducts;
  final String? selectedCategoryId;
  final String searchQuery;
  final String sortBy;
  final bool isRefreshing;
  final bool isLoadingProducts;

  @override
  List<Object?> get props => [
        products,
        categories,
        featuredProducts,
        selectedCategoryId,
        searchQuery,
        sortBy,
        isRefreshing,
        isLoadingProducts,
      ];

  ShopLoaded copyWith({
    List<ProductEntity>? products,
    List<CategoryEntity>? categories,
    List<ProductEntity>? featuredProducts,
    String? selectedCategoryId,
    String? searchQuery,
    String? sortBy,
    bool? isRefreshing,
    bool? isLoadingProducts,
  }) {
    return ShopLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
    );
  }
}

class ShopError extends ShopState {
  const ShopError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}
