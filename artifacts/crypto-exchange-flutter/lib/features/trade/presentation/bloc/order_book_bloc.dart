import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/trading_websocket_service.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../chart/domain/entities/chart_entity.dart';
import '../../../market/domain/entities/ticker_entity.dart';
import '../../domain/usecases/get_realtime_orderbook_usecase.dart';

part 'order_book_event.dart';
part 'order_book_state.dart';

@injectable
class OrderBookBloc extends Bloc<OrderBookEvent, OrderBookState> {
  final GetRealtimeOrderbookUseCase _getRealtimeOrderbookUseCase;
  final TradingWebSocketService _tradingWebSocketService;

  OrderBookBloc(
    this._getRealtimeOrderbookUseCase,
    this._tradingWebSocketService,
  ) : super(const OrderBookInitial()) {
    on<OrderBookInitialized>(_onOrderBookInitialized);
    on<OrderBookDataRequested>(_onOrderBookDataRequested);
    on<OrderBookRealtimeDataReceived>(_onOrderBookRealtimeDataReceived);
    on<OrderBookPriceUpdated>(_onOrderBookPriceUpdated);
    on<OrderBookSymbolChanged>(_onOrderBookSymbolChanged);
    on<OrderBookEntrySelected>(_onOrderBookEntrySelected);
    on<OrderBookRefreshRequested>(_onOrderBookRefreshRequested);
    on<OrderBookReset>(_onOrderBookReset);
    on<OrderBookCleanupRequested>(_onOrderBookCleanupRequested);
  }

  String _currentSymbol = '';
  StreamSubscription<Either<Failure, OrderBookData>>? _orderBookSubscription;
  StreamSubscription<TickerEntity>? _tickerSubscription;
  double? _currentPrice;
  double? _previousPrice;
  DateTime? _lastPriceUpdate;
  Timer? _colorResetTimer;

  @override
  Future<void> close() {
    // dev.log('🔄 ORDER_BOOK_BLOC: BLoC closing - stopping subscriptions only');
    _orderBookSubscription?.cancel();
    _tickerSubscription?.cancel();
    _colorResetTimer?.cancel();
    return super.close();
  }

  Future<void> _onOrderBookInitialized(
    OrderBookInitialized event,
    Emitter<OrderBookState> emit,
  ) async {
    // dev.log('🎯 ORDER_BOOK_BLOC: Initializing order book for ${event.symbol}');
    emit(OrderBookLoading(symbol: event.symbol));

    try {
      _currentSymbol = event.symbol;

      // Get real-time order book stream from shared WebSocket service
      final stream = _getRealtimeOrderbookUseCase(event.symbol);

      // Subscribe to the stream of Either values
      _orderBookSubscription = stream.listen(
        (either) {
          either.fold(
            (failure) {
              dev.log(
                  '❌ ORDER_BOOK_BLOC: Failed to get order book data: ${failure.message}');
              emit(OrderBookError(
                message: 'Failed to get order book data: ${failure.message}',
                symbol: event.symbol,
              ));
            },
            (orderBookData) {
              // dev.log(
              //     '📊 ORDER_BOOK_BLOC: Received shared order book data: ${orderBookData.buyOrders.length} buy + ${orderBookData.sellOrders.length} sell orders');

              add(OrderBookRealtimeDataReceived(orderBookData: orderBookData));
            },
          );
        },
        onError: (error) {
          dev.log('❌ ORDER_BOOK_BLOC: WebSocket order book error: $error');
          add(OrderBookReset());
        },
      );

      // Subscribe to ticker data from shared WebSocket service for real-time price
      _tickerSubscription = _tradingWebSocketService.tickerStream.listen(
        (tickerData) {
          // dev.log(
          //     '📊 ORDER_BOOK_BLOC: Received ticker data: ${tickerData.symbol} - ${tickerData.last}');

          // Track price changes for color indication
          _previousPrice = _currentPrice;
          _currentPrice = tickerData.last;
          _lastPriceUpdate = DateTime.now();

          // Cancel existing color reset timer
          _colorResetTimer?.cancel();

          // Notify bloc to update price and color via event
          add(OrderBookPriceUpdated(
            currentPrice: _currentPrice ?? 0.0,
            currentPriceColor: getCurrentPriceColor(),
          ));

          // Schedule color reset after 2 seconds
          _colorResetTimer?.cancel();
          _colorResetTimer = Timer(const Duration(seconds: 2), () {
            add(const OrderBookPriceUpdated(
                currentPrice: 0.0, // won't update price, only color reset
                currentPriceColor: Colors.white));
          });
        },
        onError: (error) {
          dev.log('❌ ORDER_BOOK_BLOC: WebSocket ticker error: $error');
        },
      );

      // Emit initial loaded state with empty data (will be populated by real-time updates)
      emit(OrderBookLoaded(
        symbol: event.symbol,
        orderBookData: OrderBookData.empty(),
        currentPrice: _currentPrice, // Use real current price or null
        currentPriceColor: getCurrentPriceColor(),
        lastUpdated: DateTime.now(),
      ));

      // dev.log(
      //     '✅ ORDER_BOOK_BLOC: Subscribed to all shared WebSocket order book streams');
    } catch (e) {
      dev.log('❌ ORDER_BOOK_BLOC: Error initializing order book: $e');
      emit(OrderBookError(
        message: 'Failed to initialize order book: $e',
        symbol: event.symbol,
      ));
    }
  }

  Future<void> _onOrderBookDataRequested(
    OrderBookDataRequested event,
    Emitter<OrderBookState> emit,
  ) async {
    // For refresh, we just keep listening to WebSocket - no separate API call needed
    // dev.log('🔄 ORDER_BOOK_BLOC: Data refresh requested for ${event.symbol}');

    if (event.forceRefresh) {
      emit(OrderBookLoading(symbol: event.symbol));
    }
  }

  Future<void> _onOrderBookRealtimeDataReceived(
    OrderBookRealtimeDataReceived event,
    Emitter<OrderBookState> emit,
  ) async {
    if (state is OrderBookLoaded) {
      final currentState = state as OrderBookLoaded;

      // dev.log(
      //     '✅ ORDER_BOOK_BLOC: Updated with ${event.orderBookData.buyOrders.length} buy orders and ${event.orderBookData.sellOrders.length} sell orders via shared service');

      emit(currentState.copyWith(
        orderBookData: event.orderBookData,
        lastUpdated: DateTime.now(),
      ));
    } else {
      // If not in loaded state, emit a new loaded state
      emit(OrderBookLoaded(
        symbol: _currentSymbol,
        orderBookData: event.orderBookData,
        currentPrice: _currentPrice,
        currentPriceColor: getCurrentPriceColor(),
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onOrderBookPriceUpdated(
    OrderBookPriceUpdated event,
    Emitter<OrderBookState> emit,
  ) async {
    if (state is OrderBookLoaded) {
      final currentState = state as OrderBookLoaded;
      emit(currentState.copyWith(
        currentPrice: event.currentPrice == 0.0
            ? currentState.currentPrice
            : event.currentPrice,
        currentPriceColor: event.currentPriceColor,
      ));
    }
  }

  Future<void> _onOrderBookSymbolChanged(
    OrderBookSymbolChanged event,
    Emitter<OrderBookState> emit,
  ) async {
    // dev.log('🔄 ORDER_BOOK_BLOC: Symbol changed to ${event.symbol}');

    // Cancel existing subscriptions
    await _orderBookSubscription?.cancel();
    await _tickerSubscription?.cancel();
    _colorResetTimer?.cancel();

    // Initialize with new symbol
    add(OrderBookInitialized(symbol: event.symbol));
  }

  Future<void> _onOrderBookEntrySelected(
    OrderBookEntrySelected event,
    Emitter<OrderBookState> emit,
  ) async {
    // dev.log(
    //     '🎯 ORDER_BOOK_BLOC: Order book entry selected: ${event.entry.formattedPrice}');
    // Handle order book entry selection
    // This can be used to populate trading form with selected price/quantity
    // Implementation depends on trading form integration
  }

  Future<void> _onOrderBookRefreshRequested(
    OrderBookRefreshRequested event,
    Emitter<OrderBookState> emit,
  ) async {
    add(OrderBookDataRequested(symbol: event.symbol, forceRefresh: true));
  }

  Future<void> _onOrderBookReset(
    OrderBookReset event,
    Emitter<OrderBookState> emit,
  ) async {
    // dev.log('🧹 ORDER_BOOK_BLOC: Reset requested - cleaning up subscriptions');
    await _orderBookSubscription?.cancel();
    await _tickerSubscription?.cancel();
    _colorResetTimer?.cancel();
    emit(const OrderBookInitial());
  }

  Future<void> _onOrderBookCleanupRequested(
    OrderBookCleanupRequested event,
    Emitter<OrderBookState> emit,
  ) async {
    // dev.log(
    //     '🧹 ORDER_BOOK_BLOC: Cleanup requested - stopping subscriptions but preserving shared connection');

    // Cancel subscriptions but don't dispose the shared WebSocket service
    await _orderBookSubscription?.cancel();
    await _tickerSubscription?.cancel();
    _colorResetTimer?.cancel();
    _orderBookSubscription = null;
    _tickerSubscription = null;
    _colorResetTimer = null;

    // dev.log(
    //     '✅ ORDER_BOOK_BLOC: Cleanup completed successfully - shared connection preserved');
  }

  /// Get current price color based on price movement
  Color getCurrentPriceColor() {
    if (_currentPrice == null || _previousPrice == null) {
      return Colors.white; // Default color when no data
    }

    if (_currentPrice! > _previousPrice!) {
      return const Color(0xFF00D4AA); // Green for price increase
    } else if (_currentPrice! < _previousPrice!) {
      return const Color(0xFFFF4757); // Red for price decrease
    } else {
      return Colors.white; // White for no change
    }
  }

  /// Convert DepthDataPoint list to OrderBookData - Logic similar to ChartBloc
  OrderBookData _convertDepthDataToOrderBook(
      List<DepthDataPoint> depthDataPoints, String symbol) {
    if (depthDataPoints.isEmpty) {
      // dev.log('📊 ORDER_BOOK_BLOC: Empty depth data, returning empty order book');
      return OrderBookData.empty();
    }

    // In the WebSocket response, the data comes as mixed bids and asks
    // We need to separate them based on price relative to current market price
    // For now, we'll use a simple approach: split around midpoint

    final prices = depthDataPoints.map((e) => e.price).toList();
    prices.sort();

    final midIndex = prices.length ~/ 2;
    final midPrice = prices.isNotEmpty ? prices[midIndex] : 0.0;

    final List<OrderBookEntry> buyOrders = [];
    final List<OrderBookEntry> sellOrders = [];

    for (final depth in depthDataPoints) {
      final entry = OrderBookEntry(
        price: depth.price,
        quantity: depth.volume,
        total: depth.volume, // For simplicity, using volume as total
      );

      if (depth.price <= midPrice) {
        buyOrders.add(entry);
      } else {
        sellOrders.add(entry);
      }
    }

    // Sort orders: buy orders highest first, sell orders lowest first
    buyOrders.sort((a, b) => b.price.compareTo(a.price));
    sellOrders.sort((a, b) => a.price.compareTo(b.price));

    // Limit to reasonable number of entries for UI
    final limitedBuyOrders = buyOrders.take(10).toList();
    final limitedSellOrders = sellOrders.take(10).toList();

    final spread = sellOrders.isNotEmpty && buyOrders.isNotEmpty
        ? sellOrders.first.price - buyOrders.first.price
        : 0.0;

    // dev.log(
    //     '📊 ORDER_BOOK_BLOC: Converted ${depthDataPoints.length} depth points to ${limitedBuyOrders.length} buy + ${limitedSellOrders.length} sell orders');

    return OrderBookData(
      sellOrders: limitedSellOrders,
      buyOrders: limitedBuyOrders,
      spread: spread,
      midPrice: midPrice,
    );
  }
}
