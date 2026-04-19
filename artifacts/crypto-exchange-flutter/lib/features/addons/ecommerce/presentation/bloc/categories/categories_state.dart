import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_entity.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryEntity> categories;
  final List<CategoryEntity> filteredCategories;
  final String searchQuery;

  const CategoriesLoaded({
    required this.categories,
    required this.filteredCategories,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [categories, filteredCategories, searchQuery];

  CategoriesLoaded copyWith({
    List<CategoryEntity>? categories,
    List<CategoryEntity>? filteredCategories,
    String? searchQuery,
  }) {
    return CategoriesLoaded(
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError({required this.message});

  @override
  List<Object?> get props => [message];
}
