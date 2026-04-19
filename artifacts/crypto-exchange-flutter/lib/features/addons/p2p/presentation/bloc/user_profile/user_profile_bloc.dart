import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'user_profile_event.dart';
import 'user_profile_state.dart';
import '../../../domain/usecases/reviews/get_user_reviews_usecase.dart';
import '../../../../../../../core/errors/failures.dart';

@injectable
class P2PUserProfileBloc
    extends Bloc<P2PUserProfileEvent, P2PUserProfileState> {
  P2PUserProfileBloc(this._getUserReviews)
      : super(const P2PUserProfileInitial()) {
    on<P2PUserProfileRequested>(_onRequested);
    on<P2PUserProfileRetryRequested>(_onRetry);
  }

  final GetUserReviewsUseCase _getUserReviews;
  String? _userId;

  Future<void> _onRequested(
    P2PUserProfileRequested event,
    Emitter<P2PUserProfileState> emit,
  ) async {
    _userId = event.userId;
    if (event.refresh && state is P2PUserProfileLoaded) {
      emit(const P2PUserProfileLoading(isRefresh: true));
    } else {
      emit(const P2PUserProfileLoading());
    }

    final params = GetUserReviewsParams(userId: event.userId);
    final result = await _getUserReviews(params);
    result.fold(
      (Failure failure) => emit(P2PUserProfileError(failure)),
      (resp) => emit(P2PUserProfileLoaded(resp)),
    );
  }

  Future<void> _onRetry(
    P2PUserProfileRetryRequested event,
    Emitter<P2PUserProfileState> emit,
  ) async {
    if (_userId != null) {
      add(P2PUserProfileRequested(_userId!, refresh: true));
    }
  }
}
