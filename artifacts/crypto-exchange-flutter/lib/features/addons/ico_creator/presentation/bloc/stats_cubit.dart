import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/creator_stats_entity.dart';
import '../../domain/usecases/get_creator_stats_usecase.dart';

part 'stats_state.dart';

@injectable
class StatsCubit extends Cubit<StatsState> {
  StatsCubit(this._getStatsUseCase) : super(const StatsInitial());

  final GetCreatorStatsUseCase _getStatsUseCase;

  Future<void> fetchStats() async {
    emit(const StatsLoading());
    final result = await _getStatsUseCase();
    result.fold(
      (failure) => emit(StatsError(failure.message)),
      (stats) => emit(StatsLoaded(stats)),
    );
  }
}
