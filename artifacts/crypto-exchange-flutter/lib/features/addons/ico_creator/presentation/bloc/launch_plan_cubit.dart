import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/launch_plan_entity.dart';
import '../../domain/usecases/get_launch_plans_usecase.dart';

@injectable
class LaunchPlanCubit extends Cubit<LaunchPlanState> {
  LaunchPlanCubit(this._useCase) : super(const LaunchPlanInitial());

  final GetLaunchPlansUseCase _useCase;

  Future<void> fetchPlans() async {
    emit(const LaunchPlanLoading());
    final result = await _useCase();
    result.fold(
      (failure) => emit(LaunchPlanError(failure.message)),
      (plans) => emit(LaunchPlanLoaded(plans)),
    );
  }
}

abstract class LaunchPlanState {
  const LaunchPlanState();
}

class LaunchPlanInitial extends LaunchPlanState {
  const LaunchPlanInitial();
}

class LaunchPlanLoading extends LaunchPlanState {
  const LaunchPlanLoading();
}

class LaunchPlanError extends LaunchPlanState {
  const LaunchPlanError(this.message);
  final String message;
}

class LaunchPlanLoaded extends LaunchPlanState {
  const LaunchPlanLoaded(this.plans);
  final List<LaunchPlanEntity> plans;
}
