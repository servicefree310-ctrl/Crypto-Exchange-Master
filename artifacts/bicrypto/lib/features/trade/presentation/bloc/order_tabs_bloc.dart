import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/get_open_orders_usecase.dart';
import '../../domain/usecases/get_order_history_usecase.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../../../injection/injection.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../profile/data/services/profile_service.dart';
import 'package:injectable/injectable.dart';

part 'order_tabs_event.dart';
part 'order_tabs_state.dart';

@injectable
class OrderTabsBloc extends Bloc<OrderTabsEvent, OrderTabsState> {
  OrderTabsBloc(this._openOrdersUseCase, this._historyUseCase)
      : super(const OrderTabsInitial()) {
    on<FetchOpenOrders>(_onFetchOpen);
    on<FetchOrderHistory>(_onFetchHistory);
    on<InitializeOrderRealtime>(_onInitializeOrderRealtime);
    on<RealtimeOrderUpdateReceived>(_onRealtimeOrderUpdateReceived);
    on<CancelOpenOrder>(_onCancelOpenOrder);
  }

  final GetOpenOrdersUseCase _openOrdersUseCase;
  final GetOrderHistoryUseCase _historyUseCase;
  final OrderRemoteDataSource _orderRemoteDataSource =
      getIt<OrderRemoteDataSource>();

  WebSocketChannel? _ordersWsChannel;
  StreamSubscription? _ordersWsSubscription;
  StreamSubscription? _profileSubscription;
  String _realtimeSymbol = '';
  String? _wsUserId;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isConnectingWs = false;
  static const int _maxReconnectAttempts = 6;

  Future<void> _onFetchOpen(
      FetchOpenOrders event, Emitter<OrderTabsState> emit) async {
    emit(const OrderTabsLoading());
    final result = await _openOrdersUseCase(event.symbol);
    result.fold(
      (failure) => emit(OrderTabsError(message: failure.message)),
      (orders) => emit(OpenOrdersLoaded(orders: orders)),
    );
  }

  Future<void> _onFetchHistory(
      FetchOrderHistory event, Emitter<OrderTabsState> emit) async {
    emit(const OrderTabsLoading());
    final result = await _historyUseCase(event.symbol);
    result.fold(
      (failure) => emit(OrderTabsError(message: failure.message)),
      (orders) => emit(OrderHistoryLoaded(orders: orders)),
    );
  }

  Future<void> _onInitializeOrderRealtime(
      InitializeOrderRealtime event, Emitter<OrderTabsState> emit) async {
    _realtimeSymbol = event.symbol;

    if (_ordersWsChannel != null) {
      return;
    }

    final userId = ProfileService.instance.currentProfile?.id;
    if (userId != null && userId.isNotEmpty) {
      await _connectOrdersWebSocket(userId);
      return;
    }

    _profileSubscription ??=
        ProfileService.instance.profileStream.listen((profile) async {
      final resolvedUserId = profile?.id;
      if (resolvedUserId != null &&
          resolvedUserId.isNotEmpty &&
          _ordersWsChannel == null) {
        await _connectOrdersWebSocket(resolvedUserId);
      }
    });
  }

  Future<void> _connectOrdersWebSocket(String userId) async {
    if (_isConnectingWs) return;
    _isConnectingWs = true;
    _wsUserId = userId;

    await _ordersWsSubscription?.cancel();
    await _ordersWsChannel?.sink.close();
    _ordersWsSubscription = null;
    _ordersWsChannel = null;

    final wsUrl =
        '${ApiConstants.wsBaseUrl}${ApiConstants.orders}?userId=$userId';
    _ordersWsChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

    try {
      await _ordersWsChannel!.ready;
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      _ordersWsChannel!.sink.add(jsonEncode({
        'action': 'SUBSCRIBE',
        'payload': {'type': 'orders', 'userId': userId}
      }));
    } catch (_) {
      _isConnectingWs = false;
      _scheduleReconnect();
      return;
    }

    _ordersWsSubscription = _ordersWsChannel!.stream.listen((message) {
      try {
        final data = jsonDecode(message.toString());
        if (data is! Map<String, dynamic>) return;

        final stream = data['stream']?.toString();
        final payload = data['data'];

        if (stream != 'orders' || payload is! List) return;

        if (_isRealtimeUpdateRelevant(payload, _realtimeSymbol)) {
          add(const RealtimeOrderUpdateReceived());
        }
      } catch (_) {}
    }, onError: (_) {
      _scheduleReconnect();
    }, onDone: () {
      _scheduleReconnect();
    });

    _isConnectingWs = false;
  }

  void _scheduleReconnect() {
    if (isClosed) return;
    if (_wsUserId == null || _wsUserId!.isEmpty) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) return;

    _ordersWsChannel = null;
    _ordersWsSubscription = null;
    _reconnectTimer?.cancel();

    _reconnectAttempts += 1;
    final delaySeconds =
        _reconnectAttempts <= 4 ? (1 << (_reconnectAttempts - 1)) : 16;

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      if (isClosed) return;
      await _connectOrdersWebSocket(_wsUserId!);
    });
  }

  bool _isRealtimeUpdateRelevant(List payload, String symbol) {
    if (symbol.isEmpty) return true;
    final target = _normalizeSymbol(symbol);

    for (final item in payload) {
      if (item is Map<String, dynamic>) {
        final orderSymbol = _normalizeSymbol(item['symbol']?.toString() ?? '');
        if (orderSymbol == target) {
          return true;
        }
      }
    }

    return false;
  }

  String _normalizeSymbol(String value) {
    return value.replaceAll('/', '').toUpperCase().trim();
  }

  Future<void> _onRealtimeOrderUpdateReceived(
      RealtimeOrderUpdateReceived event, Emitter<OrderTabsState> emit) async {
    if (_realtimeSymbol.isEmpty) return;

    if (state is OrderHistoryLoaded) {
      final result = await _historyUseCase(_realtimeSymbol);
      result.fold(
        (_) {},
        (orders) => emit(OrderHistoryLoaded(orders: orders)),
      );
      return;
    }

    final result = await _openOrdersUseCase(_realtimeSymbol);
    result.fold(
      (_) {},
      (orders) => emit(OpenOrdersLoaded(orders: orders)),
    );
  }

  Future<void> _onCancelOpenOrder(
      CancelOpenOrder event, Emitter<OrderTabsState> emit) async {
    emit(const OrderTabsLoading());
    try {
      await _orderRemoteDataSource.cancelOrder(orderId: event.orderId);
      final result = await _openOrdersUseCase(event.symbol);
      result.fold(
        (failure) => emit(OrderTabsError(message: failure.message)),
        (orders) => emit(OpenOrdersLoaded(orders: orders)),
      );
    } catch (e) {
      emit(OrderTabsError(message: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    _reconnectTimer?.cancel();
    await _ordersWsSubscription?.cancel();
    await _profileSubscription?.cancel();
    await _ordersWsChannel?.sink.close();
    return super.close();
  }
}
