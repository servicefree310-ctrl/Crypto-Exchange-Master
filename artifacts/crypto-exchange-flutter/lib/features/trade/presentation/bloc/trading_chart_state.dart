part of 'trading_chart_bloc.dart';

abstract class TradingChartState extends Equatable {
  const TradingChartState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TradingChartInitial extends TradingChartState {
  const TradingChartInitial();
}

/// Loading state
class TradingChartLoading extends TradingChartState {
  final String symbol;

  const TradingChartLoading({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}

/// Chart collapsed (hidden) state
class TradingChartCollapsed extends TradingChartState {
  final String symbol;

  const TradingChartCollapsed({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}

/// Chart expanded state with real data
class TradingChartExpanded extends TradingChartState {
  final String symbol;
  final List<ChartDataPoint> chartData;
  final ChartTimeframe timeframe;
  final double currentPrice;
  final double changePercent;

  const TradingChartExpanded({
    required this.symbol,
    required this.chartData,
    required this.timeframe,
    required this.currentPrice,
    required this.changePercent,
  });

  @override
  List<Object?> get props =>
      [symbol, chartData, timeframe, currentPrice, changePercent];

  TradingChartExpanded copyWith({
    String? symbol,
    List<ChartDataPoint>? chartData,
    ChartTimeframe? timeframe,
    double? currentPrice,
    double? changePercent,
  }) {
    return TradingChartExpanded(
      symbol: symbol ?? this.symbol,
      chartData: chartData ?? this.chartData,
      timeframe: timeframe ?? this.timeframe,
      currentPrice: currentPrice ?? this.currentPrice,
      changePercent: changePercent ?? this.changePercent,
    );
  }
}

/// Error state
class TradingChartError extends TradingChartState {
  final String message;
  final String symbol;

  const TradingChartError({
    required this.message,
    required this.symbol,
  });

  @override
  List<Object?> get props => [message, symbol];
}
