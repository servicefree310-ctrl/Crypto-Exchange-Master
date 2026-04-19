import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/order_entity.dart';
import '../../../domain/usecases/get_orders_usecase.dart';
import '../../../../../../../core/usecases/usecase.dart';
import 'orders_event.dart';
import 'orders_state.dart';

@injectable
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetOrdersUseCase _getOrdersUseCase;

  OrdersBloc({
    required GetOrdersUseCase getOrdersUseCase,
  })  : _getOrdersUseCase = getOrdersUseCase,
        super(const OrdersInitial()) {
    on<LoadOrdersRequested>(_onLoadOrdersRequested);
    on<FilterOrdersRequested>(_onFilterOrdersRequested);
  }

  Future<void> _onLoadOrdersRequested(
    LoadOrdersRequested event,
    Emitter<OrdersState> emit,
  ) async {
    dev.log('🎯 OrdersBloc: Starting load orders request');
    emit(const OrdersLoading());

    final result = await _getOrdersUseCase(NoParams());

    result.fold(
      (failure) {
        dev.log('❌ OrdersBloc: Error loading orders - ${failure.message}');
        emit(OrdersError(message: failure.message));
      },
      (orders) {
        dev.log('✅ OrdersBloc: Successfully loaded ${orders.length} orders');
        emit(OrdersLoaded(
          orders: orders,
          filteredOrders: orders,
          selectedStatus: null,
        ));
      },
    );
  }

  void _onFilterOrdersRequested(
    FilterOrdersRequested event,
    Emitter<OrdersState> emit,
  ) {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;

      List<OrderEntity> filtered;
      if (event.status == null) {
        filtered = currentState.orders;
      } else {
        filtered = currentState.orders
            .where((order) => order.status == event.status)
            .toList();
      }

      emit(currentState.copyWith(
        filteredOrders: filtered,
        selectedStatus: event.status,
      ));
    }
  }
}
