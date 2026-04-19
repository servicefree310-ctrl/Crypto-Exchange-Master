import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/futures_order_entity.dart';
import '../../domain/entities/futures_position_entity.dart';
import '../../domain/usecases/place_futures_order_usecase.dart';
import '../../domain/usecases/change_leverage_usecase.dart';

part 'futures_form_event.dart';
part 'futures_form_state.dart';

@injectable
class FuturesFormBloc extends Bloc<FuturesFormEvent, FuturesFormState> {
  FuturesFormBloc(
    this._placeOrderUseCase,
    this._changeLeverageUseCase,
  ) : super(const FuturesFormLoaded()) {
    on<FuturesFormInitialized>(_onInitialized);
    on<FuturesFormOrderTypeChanged>(_onOrderTypeChanged);
    on<FuturesFormSideChanged>(_onSideChanged);
    on<FuturesFormAmountChanged>(_onAmountChanged);
    on<FuturesFormPriceChanged>(_onPriceChanged);
    on<FuturesFormLeverageChanged>(_onLeverageChanged);
    on<FuturesFormStopLossChanged>(_onStopLossChanged);
    on<FuturesFormTakeProfitChanged>(_onTakeProfitChanged);
    on<FuturesFormOrderSubmitted>(_onOrderSubmitted);
    on<FuturesFormSubmitted>(_onFormSubmitted);
    on<FuturesFormLeverageUpdated>(_onLeverageUpdated);
  }

  final PlaceFuturesOrderUseCase _placeOrderUseCase;
  final ChangeLeverageUseCase _changeLeverageUseCase;

  Future<void> _onInitialized(
    FuturesFormInitialized event,
    Emitter<FuturesFormState> emit,
  ) async {
    // Initialize form with default values
    emit(const FuturesFormLoaded(
      orderType: 'market',
      side: 'long',
      amount: 0.0,
      leverage: 10.0,
    ));
  }

  Future<void> _onOrderTypeChanged(
    FuturesFormOrderTypeChanged event,
    Emitter<FuturesFormState> emit,
  ) async {
    if (state is FuturesFormLoaded) {
      final currentState = state as FuturesFormLoaded;
      emit(currentState.copyWith(orderType: event.orderType));
    }
  }

  Future<void> _onSideChanged(
    FuturesFormSideChanged event,
    Emitter<FuturesFormState> emit,
  ) async {
    if (state is FuturesFormLoaded) {
      final currentState = state as FuturesFormLoaded;
      emit(currentState.copyWith(side: event.side));
    }
  }

  Future<void> _onAmountChanged(
    FuturesFormAmountChanged event,
    Emitter<FuturesFormState> emit,
  ) async {
    if (state is FuturesFormLoaded) {
      final currentState = state as FuturesFormLoaded;
      emit(currentState.copyWith(amount: event.amount));
    }
  }

  Future<void> _onPriceChanged(
    FuturesFormPriceChanged event,
    Emitter<FuturesFormState> emit,
  ) async {
    if (state is FuturesFormLoaded) {
      final currentState = state as FuturesFormLoaded;
      emit(currentState.copyWith(price: event.price));
    }
  }

  Future<void> _onLeverageChanged(
    FuturesFormLeverageChanged event,
    Emitter<FuturesFormState> emit,
  ) async {
    if (state is FuturesFormLoaded) {
      final currentState = state as FuturesFormLoaded;
      emit(currentState.copyWith(leverage: event.leverage));
    }
  }

  Future<void> _onStopLossChanged(
    FuturesFormStopLossChanged event,
    Emitter<FuturesFormState> emit,
  ) async {
    if (state is FuturesFormLoaded) {
      final currentState = state as FuturesFormLoaded;
      emit(currentState.copyWith(stopLossPrice: event.stopLossPrice));
    }
  }

  Future<void> _onTakeProfitChanged(
    FuturesFormTakeProfitChanged event,
    Emitter<FuturesFormState> emit,
  ) async {
    if (state is FuturesFormLoaded) {
      final currentState = state as FuturesFormLoaded;
      emit(currentState.copyWith(takeProfitPrice: event.takeProfitPrice));
    }
  }

  Future<void> _onOrderSubmitted(
    FuturesFormOrderSubmitted event,
    Emitter<FuturesFormState> emit,
  ) async {
    emit(const FuturesFormLoading());

    if (state is! FuturesFormLoaded) return;

    final currentState = state as FuturesFormLoaded;
    final params = PlaceFuturesOrderParams(
      currency: event.currency,
      pair: event.pair,
      type: currentState.orderType,
      side: currentState.side,
      amount: currentState.amount,
      price: currentState.price,
      leverage: currentState.leverage,
      stopLossPrice: currentState.stopLossPrice,
      takeProfitPrice: currentState.takeProfitPrice,
    );

    final result = await _placeOrderUseCase(params);

    result.fold(
      (failure) => emit(FuturesFormError(failure: failure)),
      (order) => emit(FuturesFormOrderPlaced(order: order)),
    );
  }

  Future<void> _onFormSubmitted(
    FuturesFormSubmitted event,
    Emitter<FuturesFormState> emit,
  ) async {
    emit(const FuturesFormLoading());

    final orderData = event.orderData;

    // Extract symbol into currency and pair
    final symbol = orderData['symbol'] as String;
    final parts = symbol.split('/');
    final currency = parts.isNotEmpty ? parts[0] : 'BTC';
    final pair = parts.length > 1 ? parts[1] : 'USDT';

    // Helper function to convert dynamic number to double
    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    final params = PlaceFuturesOrderParams(
      currency: currency,
      pair: pair,
      type: orderData['type'] as String? ?? 'MARKET',
      side: orderData['side'] as String? ?? 'LONG',
      amount: toDouble(orderData['amount']) ?? 0.0,
      price: toDouble(orderData['price']),
      leverage: toDouble(orderData['leverage']) ?? 10.0,
      stopLossPrice: toDouble(orderData['stopLoss']),
      takeProfitPrice: toDouble(orderData['takeProfit']),
    );

    final result = await _placeOrderUseCase(params);

    result.fold(
      (failure) => emit(FuturesFormError(failure: failure)),
      (order) => emit(FuturesFormOrderPlaced(order: order)),
    );

    // Reset form to initial state after submission
    emit(const FuturesFormLoaded());
  }

  Future<void> _onLeverageUpdated(
    FuturesFormLeverageUpdated event,
    Emitter<FuturesFormState> emit,
  ) async {
    emit(const FuturesFormLoading());

    final params = ChangeLeverageParams(
      symbol: event.symbol,
      leverage: event.leverage,
    );

    final result = await _changeLeverageUseCase(params);

    result.fold(
      (failure) => emit(FuturesFormError(failure: failure)),
      (position) => emit(FuturesFormLeverageUpdateSuccess(position: position)),
    );
  }
}
