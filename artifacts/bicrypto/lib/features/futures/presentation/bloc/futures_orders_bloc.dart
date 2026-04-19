import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/futures_order_entity.dart';
import '../../domain/usecases/get_futures_orders_usecase.dart';
import '../../domain/usecases/cancel_futures_order_usecase.dart';

part 'futures_orders_event.dart';
part 'futures_orders_state.dart';

@injectable
class FuturesOrdersBloc extends Bloc<FuturesOrdersEvent, FuturesOrdersState> {
  FuturesOrdersBloc(
    this._getOrdersUseCase,
    this._cancelOrderUseCase,
  ) : super(const FuturesOrdersInitial()) {
    on<FuturesOrdersLoadRequested>(_onLoadRequested);
    on<FuturesOrdersRefreshRequested>(_onRefreshRequested);
    on<FuturesOrdersFilterChanged>(_onFilterChanged);
    on<FuturesOrderCancelRequested>(_onCancelRequested);
  }

  final GetFuturesOrdersUseCase _getOrdersUseCase;
  final CancelFuturesOrderUseCase _cancelOrderUseCase;

  // Keep track of current filter
  OrderStatusFilter _currentFilter = OrderStatusFilter.all;
  String? _currentSymbol;

  Future<void> _onLoadRequested(
    FuturesOrdersLoadRequested event,
    Emitter<FuturesOrdersState> emit,
  ) async {
    emit(const FuturesOrdersLoading());

    _currentSymbol = event.symbol;

    final params = GetFuturesOrdersParams(
      symbol: event.symbol,
      status: _getStatusString(_currentFilter),
    );

    final result = await _getOrdersUseCase(params);

    result.fold(
      (failure) => emit(FuturesOrdersError(failure: failure)),
      (orders) => emit(FuturesOrdersLoaded(
        orders: orders,
        filter: _currentFilter,
      )),
    );
  }

  String? _getStatusString(OrderStatusFilter filter) {
    switch (filter) {
      case OrderStatusFilter.all:
        return null;
      case OrderStatusFilter.open:
        return 'OPEN';
      case OrderStatusFilter.filled:
        return 'FILLED';
      case OrderStatusFilter.cancelled:
        return 'CANCELLED';
    }
  }

  Future<void> _onRefreshRequested(
    FuturesOrdersRefreshRequested event,
    Emitter<FuturesOrdersState> emit,
  ) async {
    final params = GetFuturesOrdersParams(
      symbol: event.symbol,
      status: _getStatusString(_currentFilter),
    );

    final result = await _getOrdersUseCase(params);

    result.fold(
      (failure) => emit(FuturesOrdersError(failure: failure)),
      (orders) => emit(FuturesOrdersLoaded(
        orders: orders,
        filter: _currentFilter,
      )),
    );
  }

  Future<void> _onFilterChanged(
    FuturesOrdersFilterChanged event,
    Emitter<FuturesOrdersState> emit,
  ) async {
    _currentFilter = event.filter;

    emit(const FuturesOrdersLoading());

    if (_currentSymbol == null) return;

    final params = GetFuturesOrdersParams(
      symbol: _currentSymbol!,
      status: _getStatusString(_currentFilter),
    );

    final result = await _getOrdersUseCase(params);

    result.fold(
      (failure) => emit(FuturesOrdersError(failure: failure)),
      (orders) => emit(FuturesOrdersLoaded(
        orders: orders,
        filter: _currentFilter,
      )),
    );
  }

  Future<void> _onCancelRequested(
    FuturesOrderCancelRequested event,
    Emitter<FuturesOrdersState> emit,
  ) async {
    // Keep current orders in state while cancelling
    if (state is FuturesOrdersLoaded) {
      final currentState = state as FuturesOrdersLoaded;

      // Show loading for the specific order
      emit(FuturesOrdersLoaded(
        orders: currentState.orders,
        filter: currentState.filter,
        cancellingOrderId: event.orderId,
      ));

      final cancelParams = CancelFuturesOrderParams(
        orderId: event.orderId,
        createdAt: event.createdAt,
      );
      final cancelResult = await _cancelOrderUseCase(cancelParams);

      await cancelResult.fold(
        (failure) async {
          // Show error but keep current state
          emit(FuturesOrdersLoaded(
            orders: currentState.orders,
            filter: currentState.filter,
            error: 'Failed to cancel order: ${failure.message}',
          ));
        },
        (cancelledOrder) async {
          // Reload orders to get updated list
          final params = GetFuturesOrdersParams(
            symbol: event.symbol,
            status: _getStatusString(_currentFilter),
          );

          final result = await _getOrdersUseCase(params);

          result.fold(
            (failure) => emit(FuturesOrdersError(failure: failure)),
            (orders) => emit(FuturesOrdersLoaded(
              orders: orders,
              filter: _currentFilter,
              successMessage: 'Order cancelled successfully',
            )),
          );
        },
      );
    }
  }
}
