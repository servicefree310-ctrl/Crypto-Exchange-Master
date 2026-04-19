part of 'products_bloc.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object> get props => [];
}

class LoadProductsRequested extends ProductsEvent {
  const LoadProductsRequested();
}

class LoadCategoriesRequested extends ProductsEvent {
  const LoadCategoriesRequested();
}

class FilterProductsByCategory extends ProductsEvent {
  final String categoryId;

  const FilterProductsByCategory({required this.categoryId});

  @override
  List<Object> get props => [categoryId];
}

class SearchProducts extends ProductsEvent {
  final String query;

  const SearchProducts({required this.query});

  @override
  List<Object> get props => [query];
}

enum SortOption {
  priceAsc,
  priceDesc,
  nameAsc,
  nameDesc,
  newest,
  rating,
}

class SortProducts extends ProductsEvent {
  final SortOption sortOption;

  const SortProducts({required this.sortOption});

  @override
  List<Object> get props => [sortOption];
}
