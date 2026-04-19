import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/get_order_by_id_usecase.dart';
import 'order_detail_event.dart';
import 'order_detail_state.dart';

@injectable
class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final GetOrderByIdUseCase _getOrderByIdUseCase;
  String _orderId = '';

  String get orderId => _orderId;

  OrderDetailBloc({
    required GetOrderByIdUseCase getOrderByIdUseCase,
  })  : _getOrderByIdUseCase = getOrderByIdUseCase,
        super(const OrderDetailInitial()) {
    on<LoadOrderDetailRequested>(_onLoadOrderDetailRequested);
  }

  Future<void> _onLoadOrderDetailRequested(
    LoadOrderDetailRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    _orderId = event.orderId;
    emit(const OrderDetailLoading());

    final result = await _getOrderByIdUseCase(
      GetOrderByIdParams(orderId: event.orderId),
    );

    result.fold(
      (failure) => emit(OrderDetailError(message: failure.message)),
      (order) => emit(OrderDetailLoaded(order: order)),
    );
  }
}
