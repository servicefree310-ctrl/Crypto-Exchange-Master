import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'trade_detail_event.dart';
import 'trade_detail_state.dart';
import '../../../domain/usecases/trades/get_trade_by_id_usecase.dart';
import '../../../domain/usecases/trades/confirm_trade_usecase.dart';
import '../../../domain/usecases/trades/cancel_trade_usecase.dart';
import '../../../domain/usecases/trades/release_escrow_usecase.dart';
import '../../../domain/usecases/trades/dispute_trade_usecase.dart';
import '../../../domain/usecases/trades/review_trade_usecase.dart';
import '../../../../../../../core/errors/failures.dart';

@injectable
class TradeDetailBloc extends Bloc<TradeDetailEvent, TradeDetailState> {
  TradeDetailBloc(
    this._getTradeById,
    this._confirmTrade,
    this._cancelTrade,
    this._releaseEscrow,
    this._disputeTrade,
    this._reviewTrade,
  ) : super(const TradeDetailInitial()) {
    on<TradeDetailRequested>(_onRequested);
    on<TradeDetailRetryRequested>(_onRetry);
    on<TradeConfirmPaymentRequested>(_onConfirmPayment);
    on<TradeCancelRequested>(_onCancel);
    on<TradeReleaseEscrowRequested>(_onReleaseEscrow);
    on<TradeDisputeRequested>(_onDispute);
    on<TradeReviewSubmitted>(_onReview);
  }

  final GetTradeByIdUseCase _getTradeById;
  final ConfirmTradeUseCase _confirmTrade;
  final CancelTradeUseCase _cancelTrade;
  final ReleaseEscrowUseCase _releaseEscrow;
  final DisputeTradeUseCase _disputeTrade;
  final ReviewTradeUseCase _reviewTrade;

  String? _tradeId;

  Future<void> _onRequested(
    TradeDetailRequested event,
    Emitter<TradeDetailState> emit,
  ) async {
    _tradeId = event.tradeId;
    if (event.refresh && state is TradeDetailLoaded) {
      emit(TradeDetailLoading(event.tradeId, isRefresh: true));
    } else {
      emit(TradeDetailLoading(event.tradeId));
    }
    final result =
        await _getTradeById(GetTradeByIdParams(tradeId: event.tradeId));
    result.fold(
      (Failure failure) => emit(TradeDetailError(failure, event.tradeId)),
      (trade) => emit(TradeDetailLoaded(trade)),
    );
  }

  Future<void> _onRetry(
    TradeDetailRetryRequested event,
    Emitter<TradeDetailState> emit,
  ) async {
    if (_tradeId != null) {
      add(TradeDetailRequested(_tradeId!, refresh: true));
    }
  }

  Future<void> _onConfirmPayment(
    TradeConfirmPaymentRequested event,
    Emitter<TradeDetailState> emit,
  ) async {
    if (_tradeId == null) return;
    emit(TradeActionInProgress((state as TradeDetailLoaded).trade));
    final params = ConfirmTradeParams(
      tradeId: _tradeId!,
      paymentReference: event.paymentReference,
      paymentProof: event.paymentProof,
      notes: event.notes,
    );
    final result = await _confirmTrade(params);
    result.fold(
      (failure) =>
          emit(TradeActionFailure(failure, (state as TradeDetailLoaded).trade)),
      (_) => add(TradeDetailRequested(_tradeId!, refresh: true)),
    );
  }

  Future<void> _onCancel(
    TradeCancelRequested event,
    Emitter<TradeDetailState> emit,
  ) async {
    if (_tradeId == null) return;
    emit(TradeActionInProgress((state as TradeDetailLoaded).trade));
    final params = CancelTradeParams(
      tradeId: _tradeId!,
      reason: event.reason,
      forceCancel: event.forceCancel,
    );
    final result = await _cancelTrade(params);
    result.fold(
      (failure) =>
          emit(TradeActionFailure(failure, (state as TradeDetailLoaded).trade)),
      (_) => add(TradeDetailRequested(_tradeId!, refresh: true)),
    );
  }

  Future<void> _onReleaseEscrow(
    TradeReleaseEscrowRequested event,
    Emitter<TradeDetailState> emit,
  ) async {
    if (_tradeId == null) return;
    emit(TradeActionInProgress((state as TradeDetailLoaded).trade));
    final params = ReleaseEscrowParams(
      tradeId: _tradeId!,
      releaseReason: event.releaseReason,
      partialRelease: event.partialRelease,
      releaseAmount: event.releaseAmount,
    );
    final result = await _releaseEscrow(params);
    result.fold(
      (failure) =>
          emit(TradeActionFailure(failure, (state as TradeDetailLoaded).trade)),
      (_) => add(TradeDetailRequested(_tradeId!, refresh: true)),
    );
  }

  Future<void> _onDispute(
    TradeDisputeRequested event,
    Emitter<TradeDetailState> emit,
  ) async {
    if (_tradeId == null) return;
    emit(TradeActionInProgress((state as TradeDetailLoaded).trade));
    final params = DisputeTradeParams(
      tradeId: _tradeId!,
      reason: event.reason,
      description: event.description,
      evidence: event.evidence,
      priority: event.priority,
    );
    final result = await _disputeTrade(params);
    result.fold(
      (failure) =>
          emit(TradeActionFailure(failure, (state as TradeDetailLoaded).trade)),
      (dispute) => emit(TradeActionSuccess((state as TradeDetailLoaded).trade,
          dispute: dispute)),
    );
  }

  Future<void> _onReview(
    TradeReviewSubmitted event,
    Emitter<TradeDetailState> emit,
  ) async {
    if (_tradeId == null) return;
    emit(TradeActionInProgress((state as TradeDetailLoaded).trade));
    final params = ReviewTradeParams(
      tradeId: _tradeId!,
      communicationRating: event.communicationRating,
      speedRating: event.speedRating,
      trustRating: event.trustRating,
      comment: event.comment,
      isPositive: event.isPositive,
    );
    final result = await _reviewTrade(params);
    result.fold(
      (failure) =>
          emit(TradeActionFailure(failure, (state as TradeDetailLoaded).trade)),
      (review) => emit(TradeActionSuccess((state as TradeDetailLoaded).trade,
          review: review)),
    );
  }
}
