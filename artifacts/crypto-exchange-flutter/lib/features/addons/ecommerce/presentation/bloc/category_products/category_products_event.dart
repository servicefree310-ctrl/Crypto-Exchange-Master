import 'package:equatable/equatable.dart';

abstract class CategoryProductsEvent extends Equatable {
  const CategoryProductsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoryProductsRequested extends CategoryProductsEvent {
  final String categorySlug;

  const LoadCategoryProductsRequested({required this.categorySlug});

  @override
  List<Object?> get props => [categorySlug];
}
