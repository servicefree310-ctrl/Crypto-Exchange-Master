import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'offer_detail_event.dart';
import 'offer_detail_state.dart';
import '../../../domain/entities/p2p_params.dart';
import '../../../domain/usecases/offers/get_offer_by_id_usecase.dart';
import '../../../../../../../core/errors/failures.dart';

@injectable
class OfferDetailBloc extends Bloc<OfferDetailEvent, OfferDetailState> {
  OfferDetailBloc(this._getOfferByIdUseCase)
      : super(const OfferDetailInitial()) {
    on<OfferDetailRequested>(_onRequested);
    on<OfferDetailRetryRequested>(_onRetry);
  }

  final GetOfferByIdUseCase _getOfferByIdUseCase;

  Future<void> _onRequested(
    OfferDetailRequested event,
    Emitter<OfferDetailState> emit,
  ) async {
    // If refreshing, keep UI but show loading spinner
    if (event.refresh && state is OfferDetailLoaded) {
      emit(OfferDetailLoading(event.offerId, isRefresh: true));
    } else {
      emit(OfferDetailLoading(event.offerId));
    }

    final result =
        await _getOfferByIdUseCase(GetOfferByIdParams(offerId: event.offerId));

    result.fold(
      (Failure failure) => emit(OfferDetailError(failure, event.offerId)),
      (offer) => emit(OfferDetailLoaded(offer)),
    );
  }

  void _onRetry(
    OfferDetailRetryRequested event,
    Emitter<OfferDetailState> emit,
  ) {
    if (state is OfferDetailError) {
      final failedState = state as OfferDetailError;
      add(OfferDetailRequested(failedState.offerId));
    }
  }
}
