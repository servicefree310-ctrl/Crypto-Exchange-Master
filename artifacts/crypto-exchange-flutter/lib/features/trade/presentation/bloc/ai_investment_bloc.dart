import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_ai_investment_plans_usecase.dart';
import '../../domain/usecases/get_user_ai_investments_usecase.dart';
import '../../domain/usecases/create_ai_investment_usecase.dart';
import 'ai_investment_event.dart';
import 'ai_investment_state.dart';

@injectable
class AiInvestmentBloc extends Bloc<AiInvestmentEvent, AiInvestmentState> {
  AiInvestmentBloc(
    this._getAiInvestmentPlansUseCase,
    this._getUserAiInvestmentsUseCase,
    this._createAiInvestmentUseCase,
  ) : super(const AiInvestmentInitial()) {
    on<AiInvestmentPlansLoadRequested>(_onPlansLoadRequested);
    on<AiInvestmentUserInvestmentsLoadRequested>(
        _onUserInvestmentsLoadRequested);
    on<AiInvestmentCreateRequested>(_onCreateRequested);
    on<AiInvestmentRefreshRequested>(_onRefreshRequested);
    on<AiInvestmentResetRequested>(_onResetRequested);
  }

  final GetAiInvestmentPlansUseCase _getAiInvestmentPlansUseCase;
  final GetUserAiInvestmentsUseCase _getUserAiInvestmentsUseCase;
  final CreateAiInvestmentUseCase _createAiInvestmentUseCase;

  Future<void> _onPlansLoadRequested(
    AiInvestmentPlansLoadRequested event,
    Emitter<AiInvestmentState> emit,
  ) async {
    emit(const AiInvestmentLoading());

    final result = await _getAiInvestmentPlansUseCase(NoParams());
    result.fold(
      (failure) => emit(AiInvestmentError(failure: failure)),
      (plans) => emit(AiInvestmentPlansLoaded(plans: plans)),
    );
  }

  Future<void> _onUserInvestmentsLoadRequested(
    AiInvestmentUserInvestmentsLoadRequested event,
    Emitter<AiInvestmentState> emit,
  ) async {
    emit(const AiInvestmentLoading());

    final params = GetUserAiInvestmentsParams(
      status: event.status,
      type: event.type,
      limit: event.limit,
      offset: event.offset,
    );

    final result = await _getUserAiInvestmentsUseCase(params);
    result.fold(
      (failure) => emit(AiInvestmentError(failure: failure)),
      (investments) =>
          emit(AiInvestmentUserInvestmentsLoaded(investments: investments)),
    );
  }

  Future<void> _onCreateRequested(
    AiInvestmentCreateRequested event,
    Emitter<AiInvestmentState> emit,
  ) async {
    emit(const AiInvestmentLoading());

    final params = CreateAiInvestmentParams(
      planId: event.planId,
      durationId: event.durationId,
      symbol: event.symbol,
      amount: event.amount,
      walletType: event.walletType,
    );

    final result = await _createAiInvestmentUseCase(params);
    result.fold(
      (failure) => emit(AiInvestmentError(failure: failure)),
      (investment) => emit(AiInvestmentCreated(investment: investment)),
    );
  }

  Future<void> _onRefreshRequested(
    AiInvestmentRefreshRequested event,
    Emitter<AiInvestmentState> emit,
  ) async {
    // Refresh both plans and user investments
    emit(const AiInvestmentLoading());

    final plansResult = await _getAiInvestmentPlansUseCase(NoParams());
    final investmentsResult = await _getUserAiInvestmentsUseCase(
      const GetUserAiInvestmentsParams(),
    );

    if (plansResult.isLeft() || investmentsResult.isLeft()) {
      final failure = plansResult.isLeft()
          ? plansResult.fold((l) => l, (r) => null)
          : investmentsResult.fold((l) => l, (r) => null);
      emit(AiInvestmentError(failure: failure!));
    } else {
      final plans = plansResult.getOrElse(() => []);
      final investments = investmentsResult.getOrElse(() => []);

      emit(AiInvestmentDashboardState(
        plans: plans,
        userInvestments: investments,
        isLoading: false,
      ));
    }
  }

  void _onResetRequested(
    AiInvestmentResetRequested event,
    Emitter<AiInvestmentState> emit,
  ) {
    emit(const AiInvestmentInitial());
  }
}
