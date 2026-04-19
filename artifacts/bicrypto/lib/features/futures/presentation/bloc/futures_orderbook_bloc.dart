import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/futures_websocket_service.dart';
import '../../../../features/trade/presentation/bloc/order_book_bloc.dart';

part 'futures_orderbook_event.dart';
part 'futures_orderbook_state.dart';

@injectable
class FuturesOrderBookBloc
    extends Bloc<FuturesOrderBookEvent, FuturesOrderBookState> {
  FuturesOrderBookBloc(this._webSocketService)
      : super(const FuturesOrderBookInitial()) {
    on<FuturesOrderBookConnectRequested>(_onConnectRequested);
    on<FuturesOrderBookDisconnectRequested>(_onDisconnectRequested);
    on<FuturesOrderBookDataReceived>(_onDataReceived);
    on<FuturesOrderBookErrorOccurred>(_onErrorOccurred);
  }

  final FuturesWebSocketService _webSocketService;
  StreamSubscription<OrderBookData>? _orderBookSubscription;

  Future<void> _onConnectRequested(
    FuturesOrderBookConnectRequested event,
    Emitter<FuturesOrderBookState> emit,
  ) async {
    emit(const FuturesOrderBookLoading());

    try {
      await _webSocketService.connect(event.symbol);

      _orderBookSubscription = _webSocketService.orderBookStream.listen(
        (orderBookData) {
          add(FuturesOrderBookDataReceived(orderBookData));
        },
        onError: (error) {
          add(FuturesOrderBookErrorOccurred(error.toString()));
        },
      );

      emit(const FuturesOrderBookConnected());
    } catch (e) {
      emit(FuturesOrderBookError(message: e.toString()));
    }
  }

  Future<void> _onDisconnectRequested(
    FuturesOrderBookDisconnectRequested event,
    Emitter<FuturesOrderBookState> emit,
  ) async {
    await _orderBookSubscription?.cancel();
    await _webSocketService.disconnect();
    emit(const FuturesOrderBookDisconnected());
  }

  Future<void> _onDataReceived(
    FuturesOrderBookDataReceived event,
    Emitter<FuturesOrderBookState> emit,
  ) async {
    emit(FuturesOrderBookLoaded(orderBookData: event.orderBookData));
  }

  Future<void> _onErrorOccurred(
    FuturesOrderBookErrorOccurred event,
    Emitter<FuturesOrderBookState> emit,
  ) async {
    emit(FuturesOrderBookError(message: event.error));
  }

  @override
  Future<void> close() {
    _orderBookSubscription?.cancel();
    _webSocketService.disconnect();
    return super.close();
  }
}
