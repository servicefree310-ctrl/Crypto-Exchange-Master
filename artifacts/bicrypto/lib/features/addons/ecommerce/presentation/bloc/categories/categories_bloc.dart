import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/get_categories_usecase.dart';
import '../../../../../../../core/usecases/usecase.dart';
import 'categories_event.dart';
import 'categories_state.dart';

@injectable
class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final GetCategoriesUseCase _getCategoriesUseCase;

  CategoriesBloc({
    required GetCategoriesUseCase getCategoriesUseCase,
  })  : _getCategoriesUseCase = getCategoriesUseCase,
        super(const CategoriesInitial()) {
    on<LoadCategoriesRequested>(_onLoadCategoriesRequested);
    on<SearchCategoriesRequested>(_onSearchCategoriesRequested);
  }

  Future<void> _onLoadCategoriesRequested(
    LoadCategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesLoading());

    final result = await _getCategoriesUseCase(NoParams());

    result.fold(
      (failure) => emit(CategoriesError(message: failure.message)),
      (categories) => emit(CategoriesLoaded(
        categories: categories,
        filteredCategories: const [],
        searchQuery: '',
      )),
    );
  }

  void _onSearchCategoriesRequested(
    SearchCategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) {
    if (state is CategoriesLoaded) {
      final currentState = state as CategoriesLoaded;

      if (event.query.isEmpty) {
        emit(currentState.copyWith(
          filteredCategories: [],
          searchQuery: '',
        ));
        return;
      }

      final filtered = currentState.categories.where((category) {
        final query = event.query.toLowerCase();
        return category.name.toLowerCase().contains(query) ||
            (category.description?.toLowerCase().contains(query) ?? false);
      }).toList();

      emit(currentState.copyWith(
        filteredCategories: filtered,
        searchQuery: event.query,
      ));
    }
  }
}
