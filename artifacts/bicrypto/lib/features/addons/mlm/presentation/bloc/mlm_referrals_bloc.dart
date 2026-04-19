import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/mlm_referral_entity.dart';
import '../../domain/repositories/mlm_repository.dart';
import '../../domain/usecases/get_mlm_referrals_usecase.dart';
import 'mlm_referrals_event.dart';
import 'mlm_referrals_state.dart';

@injectable
class MlmReferralsBloc extends Bloc<MlmReferralsEvent, MlmReferralsState> {
  MlmReferralsBloc(this._getReferralsUseCase, this._repository)
      : super(const MlmReferralsInitial()) {
    on<MlmReferralsLoadRequested>(_onLoadRequested);
    on<MlmReferralsRefreshRequested>(_onRefreshRequested);
    on<MlmReferralsLoadMoreRequested>(_onLoadMoreRequested);
    on<MlmReferralDetailRequested>(_onDetailRequested);
    on<MlmReferralAnalysisRequested>(_onAnalysisRequested);
    on<MlmReferralsRetryRequested>(_onRetryRequested);
  }

  final GetMlmReferralsUseCase _getReferralsUseCase;
  final MlmRepository _repository;

  Future<void> _onLoadRequested(
    MlmReferralsLoadRequested event,
    Emitter<MlmReferralsState> emit,
  ) async {
    // Don't reload if already loaded first page and not forced refresh
    if (state is MlmReferralsLoaded && event.page == 1 && !event.forceRefresh) {
      return;
    }

    emit(MlmReferralsLoading(
      message: 'Loading referrals...',
      page: event.page,
    ));

    final params = GetMlmReferralsParams(
      page: event.page,
      perPage: event.perPage,
    );
    final result = await _getReferralsUseCase(params);

    result.fold(
      (failure) => emit(MlmReferralsError(
        failure: failure,
        page: event.page,
      )),
      (referrals) => emit(MlmReferralsLoaded(
        referrals: referrals,
        currentPage: event.page,
        hasReachedMax: referrals.length < event.perPage,
        totalCount: null, // Will be provided by API in future
        lastUpdated: DateTime.now(),
      )),
    );
  }

  Future<void> _onRefreshRequested(
    MlmReferralsRefreshRequested event,
    Emitter<MlmReferralsState> emit,
  ) async {
    // Keep current data visible during refresh
    if (state is MlmReferralsLoaded) {
      final loadedState = state as MlmReferralsLoaded;
      emit(MlmReferralsRefreshing(
        currentReferrals: loadedState.referrals,
      ));
    } else {
      emit(const MlmReferralsLoading(
        message: 'Refreshing referrals...',
      ));
    }

    final params = GetMlmReferralsParams(
      page: 1,
      perPage: event.perPage,
    );
    final result = await _getReferralsUseCase(params);

    result.fold(
      (failure) {
        // If we were refreshing, preserve the previous data
        if (state is MlmReferralsRefreshing) {
          final refreshingState = state as MlmReferralsRefreshing;
          emit(MlmReferralsError(
            failure: failure,
            previousReferrals: refreshingState.currentReferrals,
            page: 1,
          ));
        } else {
          emit(MlmReferralsError(
            failure: failure,
            page: 1,
          ));
        }
      },
      (referrals) => emit(MlmReferralsLoaded(
        referrals: referrals,
        currentPage: 1,
        hasReachedMax: referrals.length < event.perPage,
        lastUpdated: DateTime.now(),
      )),
    );
  }

  Future<void> _onLoadMoreRequested(
    MlmReferralsLoadMoreRequested event,
    Emitter<MlmReferralsState> emit,
  ) async {
    if (state is! MlmReferralsLoaded) return;

    final loadedState = state as MlmReferralsLoaded;

    // Don't load more if already at max
    if (loadedState.hasReachedMax) return;

    emit(MlmReferralsLoadingMore(
      currentReferrals: loadedState.referrals,
      currentPage: loadedState.currentPage,
    ));

    final params = GetMlmReferralsParams(
      page: event.nextPage,
      perPage: event.perPage,
    );
    final result = await _getReferralsUseCase(params);

    result.fold(
      (failure) => emit(MlmReferralsError(
        failure: failure,
        previousReferrals: loadedState.referrals,
        page: event.nextPage,
      )),
      (newReferrals) {
        final allReferrals = [...loadedState.referrals, ...newReferrals];
        emit(MlmReferralsLoaded(
          referrals: allReferrals,
          currentPage: event.nextPage,
          hasReachedMax: newReferrals.length < event.perPage,
          totalCount: loadedState.totalCount,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onDetailRequested(
    MlmReferralDetailRequested event,
    Emitter<MlmReferralsState> emit,
  ) async {
    List<MlmReferralEntity>? currentReferrals;
    if (state is MlmReferralsLoaded) {
      currentReferrals = (state as MlmReferralsLoaded).referrals;
    }

    emit(MlmReferralDetailLoading(
      referralId: event.referralId,
      currentReferrals: currentReferrals,
    ));

    // Find referral in current list first
    if (currentReferrals != null) {
      try {
        final referral = currentReferrals.firstWhere(
          (r) => r.id == event.referralId,
        );
        emit(MlmReferralDetailLoaded(
          referral: referral,
          currentReferrals: currentReferrals,
        ));
        return;
      } catch (e) {
        // Not found in current list, try API
      }
    }

    // Fetch from API when not found locally
    final result = await _repository.getReferralById(event.referralId);
    result.fold(
      (failure) => emit(MlmReferralsError(
        failure: failure,
        previousReferrals: currentReferrals,
      )),
      (referral) => emit(MlmReferralDetailLoaded(
        referral: referral,
        currentReferrals: currentReferrals,
      )),
    );
  }

  Future<void> _onAnalysisRequested(
    MlmReferralAnalysisRequested event,
    Emitter<MlmReferralsState> emit,
  ) async {
    List<MlmReferralEntity>? currentReferrals;
    if (state is MlmReferralsLoaded) {
      currentReferrals = (state as MlmReferralsLoaded).referrals;
    }

    emit(MlmReferralAnalysisLoading(
      referralId: event.referralId,
      currentReferrals: currentReferrals,
    ));

    final result = await _repository.analyzeReferral(
      referralId: event.referralId,
      analysisData: event.analysisData,
    );

    result.fold(
      (failure) => emit(MlmReferralsError(
        failure: failure,
        previousReferrals: currentReferrals,
      )),
      (analysisResult) => emit(MlmReferralAnalysisCompleted(
        referralId: event.referralId,
        analysisResult: analysisResult,
        currentReferrals: currentReferrals,
      )),
    );
  }

  Future<void> _onRetryRequested(
    MlmReferralsRetryRequested event,
    Emitter<MlmReferralsState> emit,
  ) async {
    emit(MlmReferralsLoading(
      message: 'Retrying...',
      page: event.page,
    ));

    final params = GetMlmReferralsParams(
      page: event.page,
      perPage: event.perPage,
    );
    final result = await _getReferralsUseCase(params);

    result.fold(
      (failure) => emit(MlmReferralsError(
        failure: failure,
        page: event.page,
      )),
      (referrals) => emit(MlmReferralsLoaded(
        referrals: referrals,
        currentPage: event.page,
        hasReachedMax: referrals.length < event.perPage,
        lastUpdated: DateTime.now(),
      )),
    );
  }
}
