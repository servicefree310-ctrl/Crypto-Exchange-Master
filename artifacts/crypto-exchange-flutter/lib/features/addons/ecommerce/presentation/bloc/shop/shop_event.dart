part of 'shop_bloc.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();

  @override
  List<Object?> get props => [];
}

class ShopLoadRequested extends ShopEvent {
  const ShopLoadRequested();
}

class ShopRefreshRequested extends ShopEvent {
  const ShopRefreshRequested();
}

class ShopCategorySelected extends ShopEvent {
  const ShopCategorySelected({required this.categoryId});

  final String? categoryId;

  @override
  List<Object?> get props => [categoryId];
}

class ShopSearchChanged extends ShopEvent {
  const ShopSearchChanged({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}

class ShopSortChanged extends ShopEvent {
  const ShopSortChanged({required this.sortBy});

  final String sortBy;

  @override
  List<Object> get props => [sortBy];
}
