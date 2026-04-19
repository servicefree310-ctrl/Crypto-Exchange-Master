import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/trading_websocket_service.dart';
import '../../domain/usecases/place_order_usecase.dart';
import '../../../wallet/domain/usecases/get_symbol_balances_usecase.dart';

// Events
abstract class TradingFormEvent extends Equatable {
  const TradingFormEvent();

  @override
  List<Object?> get props => [];
}

class TradingFormInitialized extends TradingFormEvent {
  const TradingFormInitialized({required this.symbol});

  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

class TradingFormTabChanged extends TradingFormEvent {
  const TradingFormTabChanged({required this.isBuy});

  final bool isBuy;

  @override
  List<Object?> get props => [isBuy];
}

class TradingFormOrderTypeChanged extends TradingFormEvent {
  const TradingFormOrderTypeChanged({required this.orderType});

  final OrderType orderType;

  @override
  List<Object?> get props => [orderType];
}

class TradingFormPriceChanged extends TradingFormEvent {
  const TradingFormPriceChanged({required this.price});

  final double price;

  @override
  List<Object?> get props => [price];
}

class TradingFormQuantityChanged extends TradingFormEvent {
  const TradingFormQuantityChanged({required this.quantity});

  final double quantity;

  @override
  List<Object?> get props => [quantity];
}

class TradingFormPercentageSelected extends TradingFormEvent {
  const TradingFormPercentageSelected({required this.percentage});

  final int percentage;

  @override
  List<Object?> get props => [percentage];
}

class TradingFormOrderPlaced extends TradingFormEvent {
  const TradingFormOrderPlaced();
}

class _TradingFormCurrentPriceUpdated extends TradingFormEvent {
  const _TradingFormCurrentPriceUpdated({required this.currentPrice});

  final double currentPrice;

  @override
  List<Object?> get props => [currentPrice];
}

class TradingFormStopPriceChanged extends TradingFormEvent {
  const TradingFormStopPriceChanged({required this.stopPrice});

  final double stopPrice;

  @override
  List<Object?> get props => [stopPrice];
}

// States
abstract class TradingFormState extends Equatable {
  const TradingFormState();

  @override
  List<Object?> get props => [];
}

class TradingFormInitial extends TradingFormState {
  const TradingFormInitial();
}

class TradingFormLoading extends TradingFormState {
  const TradingFormLoading();
}

class TradingFormLoaded extends TradingFormState {
  const TradingFormLoaded({
    required this.symbol,
    required this.isBuy,
    required this.orderType,
    required this.price,
    required this.stopPrice,
    required this.quantity,
    required this.selectedPercentage,
    required this.availableBalance,
    required this.estimatedTotal,
    required this.fees,
    required this.currentPrice,
  });

  final String symbol;
  final bool isBuy;
  final OrderType orderType;
  final double price;
  final double stopPrice;
  final double quantity;
  final int selectedPercentage;
  final double availableBalance;
  final double estimatedTotal;
  final double fees;
  final double currentPrice;

  @override
  List<Object?> get props => [
        symbol,
        isBuy,
        orderType,
        price,
        stopPrice,
        quantity,
        selectedPercentage,
        availableBalance,
        estimatedTotal,
        fees,
        currentPrice,
      ];

  TradingFormLoaded copyWith({
    String? symbol,
    bool? isBuy,
    OrderType? orderType,
    double? price,
    double? stopPrice,
    double? quantity,
    int? selectedPercentage,
    double? availableBalance,
    double? estimatedTotal,
    double? fees,
    double? currentPrice,
  }) {
    return TradingFormLoaded(
      symbol: symbol ?? this.symbol,
      isBuy: isBuy ?? this.isBuy,
      orderType: orderType ?? this.orderType,
      price: price ?? this.price,
      stopPrice: stopPrice ?? this.stopPrice,
      quantity: quantity ?? this.quantity,
      selectedPercentage: selectedPercentage ?? this.selectedPercentage,
      availableBalance: availableBalance ?? this.availableBalance,
      estimatedTotal: estimatedTotal ?? this.estimatedTotal,
      fees: fees ?? this.fees,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }

  String get baseCurrency => symbol.contains('/') ? symbol.split('/')[0] : 'FT';
  String get quoteCurrency =>
      symbol.contains('/') ? symbol.split('/')[1] : 'USDT';

  String get formattedPrice => price.toStringAsFixed(4);
  String get formattedStopPrice => stopPrice.toStringAsFixed(4);
  String get formattedQuantity => quantity.toStringAsFixed(4);
  String get formattedTotal => estimatedTotal.toStringAsFixed(2);
  String get formattedBalance => availableBalance.toStringAsFixed(2);
  String get formattedFees => fees.toStringAsFixed(4);
}

class TradingFormError extends TradingFormState {
  const TradingFormError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// Lightweight state used purely to trigger UI side-effects (toast/snackbar)
class TradingFormMessage extends TradingFormState {
  const TradingFormMessage({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  List<Object?> get props => [message, isError];
}

// Enums
enum OrderType { limit, market, stop }

extension OrderTypeExtension on OrderType {
  String get displayName {
    switch (this) {
      case OrderType.limit:
        return 'Limit';
      case OrderType.market:
        return 'Market';
      case OrderType.stop:
        return 'Stop';
    }
  }
}

// BLoC
@injectable
class TradingFormBloc extends Bloc<TradingFormEvent, TradingFormState> {
  TradingFormBloc(
    this._placeOrderUseCase,
    this._tradingWebSocketService,
    this._getSymbolBalancesUseCase,
  ) : super(const TradingFormInitial()) {
    on<TradingFormInitialized>(_onInitialized);
    on<TradingFormTabChanged>(_onTabChanged);
    on<TradingFormOrderTypeChanged>(_onOrderTypeChanged);
    on<TradingFormPriceChanged>(_onPriceChanged);
    on<TradingFormQuantityChanged>(_onQuantityChanged);
    on<TradingFormPercentageSelected>(_onPercentageSelected);
    on<TradingFormOrderPlaced>(_onOrderPlaced);
    on<_TradingFormCurrentPriceUpdated>(_onCurrentPriceUpdated);
    on<TradingFormStopPriceChanged>(_onStopPriceChanged);
  }

  final PlaceOrderUseCase _placeOrderUseCase;
  final TradingWebSocketService _tradingWebSocketService;
  final GetSymbolBalancesUseCase _getSymbolBalancesUseCase;

  StreamSubscription? _tickerSub;

  Future<void> _onInitialized(
    TradingFormInitialized event,
    Emitter<TradingFormState> emit,
  ) async {
    emit(const TradingFormLoading());

    // Cancel existing ticker subscription if any
    await _tickerSub?.cancel();

    // Notify the global service about symbol change
    await _tradingWebSocketService.changeSymbol(event.symbol);

    // Fetch wallet balances for symbol
    double availableBalance = 0.0;
    final symbolParts = event.symbol.split('/');
    final base = symbolParts[0];
    final quote = symbolParts[1];

    final balanceResult = await _getSymbolBalancesUseCase(
      GetSymbolBalancesParams(type: 'SPOT', currency: base, pair: quote),
    );

    balanceResult.fold(
      (_) {},
      (data) {
        // default to base currency balance
        availableBalance = data['CURRENCY'] ?? 0.0;
      },
    );

    // Subscribe to live ticker from global service
    _tickerSub = _tradingWebSocketService.tickerStream
        .where((ticker) => ticker.symbol == event.symbol)
        .listen((ticker) {
      if (!isClosed) {
        add(_TradingFormCurrentPriceUpdated(currentPrice: ticker.last));
      }
    });

    // Wait briefly for initial ticker data
    await Future.delayed(const Duration(milliseconds: 300));

    emit(TradingFormLoaded(
      symbol: event.symbol,
      isBuy: true,
      orderType: OrderType.limit,
      price: 0.0,
      stopPrice: 0.0,
      quantity: 0.0,
      selectedPercentage: 0,
      availableBalance: availableBalance,
      estimatedTotal: 0.0,
      fees: 0.0,
      currentPrice: 0.0,
    ));
  }

  Future<void> _onTabChanged(
    TradingFormTabChanged event,
    Emitter<TradingFormState> emit,
  ) async {
    if (state is TradingFormLoaded) {
      final currentState = state as TradingFormLoaded;
      emit(currentState.copyWith(
        isBuy: event.isBuy,
        selectedPercentage: 0,
        quantity: 0.0,
      ));
      _calculateTotal(emit);
    }
  }

  Future<void> _onOrderTypeChanged(
    TradingFormOrderTypeChanged event,
    Emitter<TradingFormState> emit,
  ) async {
    if (state is TradingFormLoaded) {
      final currentState = state as TradingFormLoaded;

      // Handle price updates based on order type
      double newPrice = currentState.price;
      double newStopPrice = currentState.stopPrice;

      switch (event.orderType) {
        case OrderType.market:
          // Market orders use current price
          newPrice = currentState.currentPrice;
          newStopPrice = 0.0;
          break;
        case OrderType.limit:
          // Limit orders keep the current limit price or use current price if switching from market
          newPrice = currentState.orderType == OrderType.market
              ? currentState.currentPrice
              : currentState.price;
          newStopPrice = 0.0;
          break;
        case OrderType.stop:
          // Stop orders need both stop price and limit price
          // Initialize stop price to current price if not set
          newStopPrice = currentState.stopPrice > 0
              ? currentState.stopPrice
              : currentState.currentPrice;
          // Initialize limit price to current price if coming from market
          newPrice = currentState.orderType == OrderType.market
              ? currentState.currentPrice
              : currentState.price;
          break;
      }

      // Update state with new order type and prices
      emit(currentState.copyWith(
        orderType: event.orderType,
        price: newPrice,
        stopPrice: newStopPrice,
      ));

      // Recalculate total with new prices
      _calculateTotal(emit);
    }
  }

  Future<void> _onPriceChanged(
    TradingFormPriceChanged event,
    Emitter<TradingFormState> emit,
  ) async {
    if (state is TradingFormLoaded) {
      final currentState = state as TradingFormLoaded;
      emit(currentState.copyWith(price: event.price));
      _calculateTotal(emit);
    }
  }

  Future<void> _onQuantityChanged(
    TradingFormQuantityChanged event,
    Emitter<TradingFormState> emit,
  ) async {
    if (state is TradingFormLoaded) {
      final currentState = state as TradingFormLoaded;

      // Get the effective price based on order type
      final effectivePrice = currentState.orderType == OrderType.market
          ? currentState.currentPrice
          : currentState.price;

      // Calculate the current percentage based on the new quantity
      int newPercentage = 0;
      if (effectivePrice > 0) {
        final maxQuantity = currentState.isBuy
            ? (currentState.availableBalance / effectivePrice)
            : currentState.availableBalance;
        if (maxQuantity > 0) {
          final percentage = (event.quantity / maxQuantity) * 100;
          // Round to nearest predefined percentage (25, 50, 75, 100)
          newPercentage = [25, 50, 75, 100].firstWhere(
            (p) => (percentage - p).abs() < 1,
            orElse: () => 0,
          );
        }
      }

      // Update state with new quantity and calculated percentage
      emit(currentState.copyWith(
        quantity: event.quantity,
        selectedPercentage: newPercentage,
      ));

      // Recalculate total
      _calculateTotal(emit);
    }
  }

  Future<void> _onPercentageSelected(
    TradingFormPercentageSelected event,
    Emitter<TradingFormState> emit,
  ) async {
    if (state is TradingFormLoaded) {
      final currentState = state as TradingFormLoaded;

      // Get the effective price based on order type
      final effectivePrice = currentState.orderType == OrderType.market
          ? currentState.currentPrice
          : currentState.price;

      // Skip if price is zero or invalid
      if (effectivePrice <= 0) {
        return;
      }

      // Calculate max quantity based on order side and available balance
      final maxQuantity = currentState.isBuy
          ? (currentState.availableBalance / effectivePrice)
          : currentState.availableBalance;

      // Calculate new quantity based on percentage
      final newQuantity = (maxQuantity * event.percentage / 100);

      // Update state with new quantity and percentage
      emit(currentState.copyWith(
        quantity: newQuantity,
        selectedPercentage: event.percentage,
      ));

      // Recalculate total
      _calculateTotal(emit);
    }
  }

  Future<void> _onOrderPlaced(
    TradingFormOrderPlaced event,
    Emitter<TradingFormState> emit,
  ) async {
    if (state is! TradingFormLoaded) return;

    final currentState = state as TradingFormLoaded;

    // Validate order based on type
    if (!_validateOrder(currentState)) {
      emit(TradingFormMessage(
        message: 'Invalid order parameters. Please check your inputs.',
        isError: true,
      ));
      emit(currentState);
      return;
    }

    final params = PlaceOrderParams(
      currency: currentState.baseCurrency,
      pair: currentState.quoteCurrency,
      type: currentState.orderType.name.toUpperCase(), // limit/market/stop
      side: currentState.isBuy ? 'BUY' : 'SELL',
      amount: currentState.quantity,
      price: currentState.orderType == OrderType.market
          ? null
          : currentState.price,
      stopPrice: currentState.orderType == OrderType.stop
          ? currentState.stopPrice
          : null,
    );

    final result = await _placeOrderUseCase(params);

    result.fold(
      (failure) {
        emit(TradingFormMessage(message: failure.message, isError: true));
        emit(currentState);
      },
      (order) {
        // Success – reset quantity fields and notify UI
        emit(TradingFormLoaded(
          symbol: currentState.symbol,
          isBuy: currentState.isBuy,
          orderType: currentState.orderType,
          price: currentState.orderType == OrderType.market
              ? currentState.currentPrice
              : currentState.price,
          stopPrice: currentState.stopPrice,
          quantity: 0.0,
          selectedPercentage: 0,
          availableBalance: currentState.availableBalance,
          estimatedTotal: 0.0,
          fees: 0.0,
          currentPrice: currentState.currentPrice,
        ));

        emit(const TradingFormMessage(
          message: 'Order placed successfully',
          isError: false,
        ));
      },
    );
  }

  Future<void> _onCurrentPriceUpdated(
    _TradingFormCurrentPriceUpdated event,
    Emitter<TradingFormState> emit,
  ) async {
    if (state is TradingFormLoaded) {
      final currentState = state as TradingFormLoaded;

      // Update current price and market order price if needed
      emit(currentState.copyWith(
        currentPrice: event.currentPrice,
        // Only update the price if it's a market order
        price: currentState.orderType == OrderType.market
            ? event.currentPrice
            : currentState.price,
      ));

      // Recalculate total with new prices
      _calculateTotal(emit);
    }
  }

  Future<void> _onStopPriceChanged(
    TradingFormStopPriceChanged event,
    Emitter<TradingFormState> emit,
  ) async {
    if (state is TradingFormLoaded) {
      final currentState = state as TradingFormLoaded;
      emit(currentState.copyWith(stopPrice: event.stopPrice));
    }
  }

  void _calculateTotal(Emitter<TradingFormState> emit) {
    if (state is TradingFormLoaded) {
      final currentState = state as TradingFormLoaded;

      // Get the effective price based on order type and current state
      double effectivePrice;
      switch (currentState.orderType) {
        case OrderType.market:
          effectivePrice = currentState.currentPrice;
          break;
        case OrderType.limit:
          effectivePrice = currentState.price;
          break;
        case OrderType.stop:
          // For stop orders, use the limit price for total calculation
          effectivePrice = currentState.price;
          break;
      }

      // Calculate total and fees if we have a valid price
      if (effectivePrice > 0) {
        final total = effectivePrice * currentState.quantity;
        final fees = total * 0.001; // 0.1% fee

        emit(currentState.copyWith(
          estimatedTotal: total,
          fees: fees,
        ));
      }
    }
  }

  // Helper method to validate order parameters
  bool _validateOrder(TradingFormLoaded state) {
    if (state.quantity <= 0) return false;

    switch (state.orderType) {
      case OrderType.market:
        return state.currentPrice > 0;
      case OrderType.limit:
        return state.price > 0;
      case OrderType.stop:
        // For stop orders, need both stop price and limit price
        return state.stopPrice > 0 && state.price > 0;
    }
  }

  @override
  Future<void> close() async {
    await _tickerSub?.cancel();
    return super.close();
  }
}
