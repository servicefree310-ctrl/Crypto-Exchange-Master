import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/trades/initiate_trade_usecase.dart';
import '../../../domain/usecases/trades/confirm_trade_usecase.dart';
import '../../../domain/usecases/trades/cancel_trade_usecase.dart';
import '../../../domain/usecases/trades/release_escrow_usecase.dart';
import '../../../domain/usecases/trades/dispute_trade_usecase.dart';
import 'trade_execution_event.dart';
import 'trade_execution_state.dart';

@injectable
class TradeExecutionBloc
    extends Bloc<TradeExecutionEvent, TradeExecutionState> {
  TradeExecutionBloc(
    this._initiateTradeUseCase,
    this._confirmTradeUseCase,
    this._cancelTradeUseCase,
    this._releaseEscrowUseCase,
    this._disputeTradeUseCase,
  ) : super(const TradeExecutionInitial()) {
    on<TradeInitiateRequested>(_onTradeInitiateRequested);
    on<TradeConfirmRequested>(_onTradeConfirmRequested);
    on<TradeCancelRequested>(_onTradeCancelRequested);
    on<TradeEscrowReleaseRequested>(_onTradeEscrowReleaseRequested);
    on<TradeDisputeRequested>(_onTradeDisputeRequested);
    on<TradeExecutionReset>(_onTradeExecutionReset);
  }

  final InitiateTradeUseCase _initiateTradeUseCase;
  final ConfirmTradeUseCase _confirmTradeUseCase;
  final CancelTradeUseCase _cancelTradeUseCase;
  final ReleaseEscrowUseCase _releaseEscrowUseCase;
  final DisputeTradeUseCase _disputeTradeUseCase;

  Future<void> _onTradeInitiateRequested(
    TradeInitiateRequested event,
    Emitter<TradeExecutionState> emit,
  ) async {
    emit(const TradeExecutionLoading());

    final result = await _initiateTradeUseCase(InitiateTradeParams(
      offerId: event.offerId,
      amount: event.amount,
      paymentMethodId: event.paymentMethodId,
      message: event.notes,
    ));

    result.fold(
      (failure) => emit(TradeExecutionError(failure: failure)),
      (trade) => emit(TradeExecutionSuccess(
        trade: trade,
        message: 'Trade initiated successfully',
      )),
    );
  }

  Future<void> _onTradeConfirmRequested(
    TradeConfirmRequested event,
    Emitter<TradeExecutionState> emit,
  ) async {
    emit(const TradeExecutionLoading());

    final result = await _confirmTradeUseCase(ConfirmTradeParams(
      tradeId: event.tradeId,
      paymentProof: event.proofOfPayment,
      notes: event.confirmationType,
    ));

    result.fold(
      (failure) => emit(TradeExecutionError(failure: failure)),
      (_) => emit(TradeExecutionSuccess(
        trade: null,
        message: 'Payment confirmation sent',
      )),
    );
  }

  Future<void> _onTradeCancelRequested(
    TradeCancelRequested event,
    Emitter<TradeExecutionState> emit,
  ) async {
    emit(const TradeExecutionLoading());

    final result = await _cancelTradeUseCase(CancelTradeParams(
      tradeId: event.tradeId,
      reason: event.reason,
    ));

    result.fold(
      (failure) => emit(TradeExecutionError(failure: failure)),
      (_) => emit(TradeExecutionSuccess(
        trade: null,
        message: 'Trade cancelled successfully',
      )),
    );
  }

  Future<void> _onTradeEscrowReleaseRequested(
    TradeEscrowReleaseRequested event,
    Emitter<TradeExecutionState> emit,
  ) async {
    emit(const TradeExecutionLoading());

    final result = await _releaseEscrowUseCase(ReleaseEscrowParams(
      tradeId: event.tradeId,
    ));

    result.fold(
      (failure) => emit(TradeExecutionError(failure: failure)),
      (_) => emit(TradeExecutionSuccess(
        trade: null,
        message: 'Escrow released successfully',
      )),
    );
  }

  Future<void> _onTradeDisputeRequested(
    TradeDisputeRequested event,
    Emitter<TradeExecutionState> emit,
  ) async {
    emit(const TradeExecutionLoading());

    final result = await _disputeTradeUseCase(DisputeTradeParams(
      tradeId: event.tradeId,
      reason: event.reason,
      description: event.description,
      evidence: event.evidence,
    ));

    result.fold(
      (failure) => emit(TradeExecutionError(failure: failure)),
      (dispute) => emit(TradeExecutionSuccess(
        trade: null,
        message: 'Dispute filed successfully',
      )),
    );
  }

  void _onTradeExecutionReset(
    TradeExecutionReset event,
    Emitter<TradeExecutionState> emit,
  ) {
    emit(const TradeExecutionInitial());
  }
}
