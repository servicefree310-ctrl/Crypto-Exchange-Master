import 'dart:async';
import 'dart:math' as math;

import 'package:injectable/injectable.dart';

import '../../features/market/domain/entities/chart_data_entity.dart';
import '../../features/market/domain/entities/market_data_entity.dart';
import 'market_service.dart';

@singleton
class ChartService {
  ChartService(this._marketService) {
    // Subscribe to global market updates to keep chart data current
    _marketSubscription = _marketService.marketsStream.listen(_onMarketUpdate);
  }

  final MarketService _marketService;
  StreamSubscription<List<MarketDataEntity>>? _marketSubscription;

  // Chart data for each symbol
  final Map<String, MarketChartEntity> _chartData = {};

  // Stream controller for chart updates
  final StreamController<Map<String, MarketChartEntity>>
      _chartUpdateController =
      StreamController<Map<String, MarketChartEntity>>.broadcast();

  // Stream for external access
  Stream<Map<String, MarketChartEntity>> get chartUpdatesStream =>
      _chartUpdateController.stream;

  /// Update price data for a symbol
  void updatePrice(String symbol, double price, {double? volume}) {
    final now = DateTime.now();
    final newDataPoint = ChartDataEntity(
      timestamp: now,
      price: price,
      volume: volume ?? 0.0,
    );

    // Get existing chart or create new one with initial data
    MarketChartEntity chart;
    if (_chartData.containsKey(symbol)) {
      chart = _chartData[symbol]!.addDataPoint(newDataPoint);
    } else {
      // Generate some initial historical data for better chart visualization
      final initialData = _generateInitialChartData(symbol, price, now);
      chart = MarketChartEntity(
        symbol: symbol,
        dataPoints: [...initialData, newDataPoint],
      );
    }

    _chartData[symbol] = chart;

    // Emit update to stream
    _emitChartUpdate();
  }

  /// Safely emit a chart-data snapshot, swallowing post-dispose writes.
  /// Without this guard, the marketsStream subscription can fire after
  /// dispose() and trigger "Bad state: Cannot add new events after calling
  /// close" in the browser console.
  void _emitChartUpdate() {
    if (_chartUpdateController.isClosed) return;
    _chartUpdateController.add(Map.from(_chartData));
  }

  /// Get chart data for a specific symbol
  MarketChartEntity? getChartData(String symbol) {
    return _chartData[symbol];
  }

  /// Get all chart data
  Map<String, MarketChartEntity> getAllChartData() {
    return Map.from(_chartData);
  }

  /// Generate initial chart data for a symbol to provide context
  List<ChartDataEntity> _generateInitialChartData(
    String symbol,
    double currentPrice,
    DateTime currentTime,
  ) {
    final dataPoints = <ChartDataEntity>[];
    const pointCount = 30; // Generate 30 initial points

    // Generate realistic price movements
    final random = math.Random();
    final basePrice = currentPrice;
    double price = basePrice;

    for (int i = pointCount; i > 0; i--) {
      // Time points going backwards
      final timestamp = currentTime.subtract(Duration(minutes: i * 2));

      // Generate realistic price movement (±2% volatility)
      final volatility = 0.02; // 2% volatility
      final changePercent = (random.nextDouble() - 0.5) * volatility;
      price = price * (1 + changePercent);

      // Add some trend toward current price
      final trendFactor = 0.1;
      price = price + (basePrice - price) * trendFactor;

      dataPoints.add(ChartDataEntity(
        timestamp: timestamp,
        price: price,
        volume: random.nextDouble() * 1000000, // Random volume
      ));
    }

    return dataPoints;
  }

  /// Clear chart data for a symbol
  void clearChartData(String symbol) {
    _chartData.remove(symbol);
    _emitChartUpdate();
  }

  /// Clear all chart data
  void clearAllChartData() {
    _chartData.clear();
    _emitChartUpdate();
  }

  /// Initialize chart data for multiple symbols
  void initializeSymbols(
      List<String> symbols, Map<String, double> currentPrices) {
    final now = DateTime.now();
    for (final symbol in symbols) {
      final price = currentPrices[symbol];
      if (price != null && !_chartData.containsKey(symbol)) {
        final initialData = _generateInitialChartData(symbol, price, now);
        _chartData[symbol] = MarketChartEntity(
          symbol: symbol,
          dataPoints: initialData,
        );
      }
    }
    _emitChartUpdate();
  }

  /// Get chart data stream for a specific symbol
  Stream<MarketChartEntity?> getChartStreamForSymbol(String symbol) {
    return chartUpdatesStream.map((allCharts) => allCharts[symbol]);
  }

  /// Handle global market updates and update chart data
  void _onMarketUpdate(List<MarketDataEntity> markets) {
    for (final market in markets) {
      if (market.price > 0) {
        updatePrice(market.symbol, market.price, volume: market.baseVolume);
      }
    }
  }

  /// Dispose of the service
  void dispose() {
    _marketSubscription?.cancel();
    _chartUpdateController.close();
    _chartData.clear();
  }
}
