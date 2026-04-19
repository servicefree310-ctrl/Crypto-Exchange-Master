import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/utils/debouncer.dart';
import '../../domain/usecases/get_creator_investors_usecase.dart';
import 'creator_investors_event.dart';
import 'creator_investors_state.dart';

@injectable
class CreatorInvestorsBloc
    extends Bloc<CreatorInvestorsEvent, CreatorInvestorsState> {
  CreatorInvestorsBloc(this._getInvestorsUseCase)
      : super(const CreatorInvestorsInitial()) {
    on<CreatorInvestorsLoadRequested>(_onLoadRequested);
    on<CreatorInvestorsRefreshRequested>(_onRefreshRequested);
    on<CreatorInvestorsSearchChanged>(_onSearchChanged);
  }

  final GetCreatorInvestorsUseCase _getInvestorsUseCase;
  final _searchDebouncer = Debouncer(milliseconds: 500);

  Future<void> _onLoadRequested(
    CreatorInvestorsLoadRequested event,
    Emitter<CreatorInvestorsState> emit,
  ) async {
    if (state is CreatorInvestorsLoading) return;

    // For pagination, show existing data while loading more
    if (event.page > 1 && state is CreatorInvestorsLoaded) {
      final currentState = state as CreatorInvestorsLoaded;
      // Don't emit loading state for pagination
    } else {
      emit(const CreatorInvestorsLoading());
    }

    final result = await _getInvestorsUseCase(
      GetInvestorsParams(
        page: event.page,
        search: event.search,
        sortField: event.sortField,
        sortDirection: event.sortDirection,
      ),
    );

    result.fold(
      (failure) => emit(CreatorInvestorsError(failure)),
      (investors) {
        if (investors.isEmpty && event.page == 1) {
          emit(CreatorInvestorsEmpty(searchQuery: event.search));
        } else {
          // For pagination, append to existing list
          if (event.page > 1 && state is CreatorInvestorsLoaded) {
            final currentState = state as CreatorInvestorsLoaded;
            emit(
              currentState.copyWith(
                investors: [...currentState.investors, ...investors],
                hasMore: investors.length >= 10, // Assuming 10 per page
                currentPage: event.page,
              ),
            );
          } else {
            emit(
              CreatorInvestorsLoaded(
                investors: investors,
                hasMore: investors.length >= 10,
                currentPage: event.page,
                searchQuery: event.search,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _onRefreshRequested(
    CreatorInvestorsRefreshRequested event,
    Emitter<CreatorInvestorsState> emit,
  ) async {
    // Get current search query if exists
    String? currentSearch;
    if (state is CreatorInvestorsLoaded) {
      currentSearch = (state as CreatorInvestorsLoaded).searchQuery;
    } else if (state is CreatorInvestorsEmpty) {
      currentSearch = (state as CreatorInvestorsEmpty).searchQuery;
    }

    add(CreatorInvestorsLoadRequested(
      page: 1,
      search: currentSearch,
    ));
  }

  Future<void> _onSearchChanged(
    CreatorInvestorsSearchChanged event,
    Emitter<CreatorInvestorsState> emit,
  ) async {
    _searchDebouncer.run(() {
      add(CreatorInvestorsLoadRequested(
        page: 1,
        search: event.query.isEmpty ? null : event.query,
      ));
    });
  }

  @override
  Future<void> close() {
    _searchDebouncer.dispose();
    return super.close();
  }
}
