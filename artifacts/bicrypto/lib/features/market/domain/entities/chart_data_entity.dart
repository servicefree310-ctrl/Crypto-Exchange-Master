import 'package:equatable/equatable.dart';

class ChartDataEntity extends Equatable {
  const ChartDataEntity({
    required this.timestamp,
    required this.price,
    required this.volume,
  });

  final DateTime timestamp;
  final double price;
  final double volume;

  @override
  List<Object> get props => [timestamp, price, volume];

  ChartDataEntity copyWith({
    DateTime? timestamp,
    double? price,
    double? volume,
  }) {
    return ChartDataEntity(
      timestamp: timestamp ?? this.timestamp,
      price: price ?? this.price,
      volume: volume ?? this.volume,
    );
  }
}

class MarketChartEntity extends Equatable {
  const MarketChartEntity({
    required this.symbol,
    required this.dataPoints,
    this.maxDataPoints = 50,
  });

  final String symbol;
  final List<ChartDataEntity> dataPoints;
  final int maxDataPoints;

  @override
  List<Object> get props => [symbol, dataPoints, maxDataPoints];

  /// Add a new data point and maintain the maximum number of points
  MarketChartEntity addDataPoint(ChartDataEntity newPoint) {
    final updatedPoints = List<ChartDataEntity>.from(dataPoints);
    updatedPoints.add(newPoint);

    // Keep only the latest maxDataPoints
    if (updatedPoints.length > maxDataPoints) {
      updatedPoints.removeRange(0, updatedPoints.length - maxDataPoints);
    }

    return MarketChartEntity(
      symbol: symbol,
      dataPoints: updatedPoints,
      maxDataPoints: maxDataPoints,
    );
  }

  /// Get the price values for chart rendering
  List<double> get priceValues =>
      dataPoints.map((point) => point.price).toList();

  /// Get the latest price
  double? get latestPrice =>
      dataPoints.isNotEmpty ? dataPoints.last.price : null;

  /// Get the price change from first to last point
  double get priceChange {
    if (dataPoints.length < 2) return 0.0;
    final firstPrice = dataPoints.first.price;
    final lastPrice = dataPoints.last.price;
    return lastPrice - firstPrice;
  }

  /// Get the price change percentage
  double get priceChangePercent {
    if (dataPoints.length < 2) return 0.0;
    final firstPrice = dataPoints.first.price;
    final lastPrice = dataPoints.last.price;
    return ((lastPrice - firstPrice) / firstPrice) * 100;
  }

  /// Check if the chart trend is positive
  bool get isPositive => priceChange >= 0;

  MarketChartEntity copyWith({
    String? symbol,
    List<ChartDataEntity>? dataPoints,
    int? maxDataPoints,
  }) {
    return MarketChartEntity(
      symbol: symbol ?? this.symbol,
      dataPoints: dataPoints ?? this.dataPoints,
      maxDataPoints: maxDataPoints ?? this.maxDataPoints,
    );
  }
}
