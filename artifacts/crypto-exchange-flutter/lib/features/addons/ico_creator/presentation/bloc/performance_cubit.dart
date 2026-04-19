import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/chart_point_entity.dart';
import '../../domain/usecases/get_creator_performance_usecase.dart';

part 'performance_state.dart';

@injectable
class PerformanceCubit extends Cubit<PerformanceState> {
  PerformanceCubit(this._getPerformance) : super(const PerformanceInitial());

  final GetCreatorPerformanceUseCase _getPerformance;

  Future<void> fetch(String range) async {
    emit(const PerformanceLoading());
    final result = await _getPerformance(range);
    result.fold(
      (failure) => emit(PerformanceError(failure.message)),
      (data) => emit(PerformanceLoaded(range, data)),
    );
  }
}
