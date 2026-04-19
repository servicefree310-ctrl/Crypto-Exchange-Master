import 'package:equatable/equatable.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoriesRequested extends CategoriesEvent {
  const LoadCategoriesRequested();
}

class SearchCategoriesRequested extends CategoriesEvent {
  final String query;

  const SearchCategoriesRequested({required this.query});

  @override
  List<Object?> get props => [query];
}
