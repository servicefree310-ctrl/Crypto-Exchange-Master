part of 'order_book_bloc.dart';

abstract class OrderBookState extends Equatable {
  const OrderBookState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OrderBookInitial extends OrderBookState {
  const OrderBookInitial();
}

/// Loading state
class OrderBookLoading extends OrderBookState {
  final String? symbol;

  const OrderBookLoading({this.symbol});

  @override
  List<Object?> get props => [symbol];
}

/// Loaded state with order book data
class OrderBookLoaded extends OrderBookState {
  final String symbol;
  final OrderBookData orderBookData;
  final double? currentPrice;
  final Color? currentPriceColor;
  final DateTime lastUpdated;

  const OrderBookLoaded({
    required this.symbol,
    required this.orderBookData,
    this.currentPrice,
    this.currentPriceColor,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props =>
      [symbol, orderBookData, currentPrice, currentPriceColor, lastUpdated];

  OrderBookLoaded copyWith({
    String? symbol,
    OrderBookData? orderBookData,
    double? currentPrice,
    Color? currentPriceColor,
    DateTime? lastUpdated,
  }) {
    return OrderBookLoaded(
      symbol: symbol ?? this.symbol,
      orderBookData: orderBookData ?? this.orderBookData,
      currentPrice: currentPrice ?? this.currentPrice,
      currentPriceColor: currentPriceColor ?? this.currentPriceColor,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Error state
class OrderBookError extends OrderBookState {
  final String message;
  final String? symbol;

  const OrderBookError({
    required this.message,
    this.symbol,
  });

  @override
  List<Object?> get props => [message, symbol];
}

/// Order book side enum
enum OrderBookSide { buy, sell }

/// Order book entry model
class OrderBookEntry extends Equatable {
  final double price;
  final double quantity;
  final double total;

  const OrderBookEntry({
    required this.price,
    required this.quantity,
    required this.total,
  });

  @override
  List<Object?> get props => [price, quantity, total];

  String get formattedPrice => price.toStringAsFixed(4);
  String get formattedQuantity => quantity.toStringAsFixed(4);
  String get formattedTotal => total.toStringAsFixed(4);

  OrderBookEntry copyWith({
    double? price,
    double? quantity,
    double? total,
  }) {
    return OrderBookEntry(
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
    );
  }
}

/// Order book data model
class OrderBookData extends Equatable {
  final List<OrderBookEntry> sellOrders; // Red - higher prices
  final List<OrderBookEntry> buyOrders; // Green - lower prices
  final double? spread;
  final double? midPrice;

  const OrderBookData({
    required this.sellOrders,
    required this.buyOrders,
    this.spread,
    this.midPrice,
  });

  @override
  List<Object?> get props => [sellOrders, buyOrders, spread, midPrice];

  OrderBookData copyWith({
    List<OrderBookEntry>? sellOrders,
    List<OrderBookEntry>? buyOrders,
    double? spread,
    double? midPrice,
  }) {
    return OrderBookData(
      sellOrders: sellOrders ?? this.sellOrders,
      buyOrders: buyOrders ?? this.buyOrders,
      spread: spread ?? this.spread,
      midPrice: midPrice ?? this.midPrice,
    );
  }

  /// Create empty order book data
  factory OrderBookData.empty() {
    return const OrderBookData(
      sellOrders: [],
      buyOrders: [],
      spread: 0.0,
      midPrice: 0.0,
    );
  }

  factory OrderBookData.mock(String symbol) {
    // Generate mock order book data based on the image
    final sellOrders = [
      const OrderBookEntry(price: 0.0536, quantity: 708.5455, total: 708.5455),
      const OrderBookEntry(price: 0.0531, quantity: 637.1759, total: 637.1759),
      const OrderBookEntry(price: 0.0530, quantity: 250.1576, total: 250.1576),
      const OrderBookEntry(price: 0.0523, quantity: 248.1576, total: 248.1576),
      const OrderBookEntry(price: 0.0522, quantity: 110.6026, total: 110.6026),
    ];

    final buyOrders = [
      const OrderBookEntry(price: 0.0507, quantity: 102.8013, total: 102.8013),
      const OrderBookEntry(price: 0.0506, quantity: 571.1887, total: 571.1887),
      const OrderBookEntry(price: 0.0505, quantity: 575.1887, total: 575.1887),
      const OrderBookEntry(price: 0.0500, quantity: 934.0827, total: 934.0827),
      const OrderBookEntry(price: 0.0495, quantity: 1000.0, total: 1000.0),
    ];

    return OrderBookData(
      sellOrders: sellOrders,
      buyOrders: buyOrders,
      spread: 0.0009, // 0.0516 - 0.0507
      midPrice: 0.0516,
    );
  }
}

/// Order book side extensions
extension OrderBookSideExtension on OrderBookSide {
  Color getColor(BuildContext context) {
    switch (this) {
      case OrderBookSide.buy:
        return context.priceUpColor; // Use theme green
      case OrderBookSide.sell:
        return context.priceDownColor; // Use theme red
    }
  }

  String get displayName {
    switch (this) {
      case OrderBookSide.buy:
        return 'Buy';
      case OrderBookSide.sell:
        return 'Sell';
    }
  }
}
