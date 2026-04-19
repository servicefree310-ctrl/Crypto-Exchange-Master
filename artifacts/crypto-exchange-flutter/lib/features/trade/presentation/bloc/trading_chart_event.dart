part of 'trading_chart_bloc.dart';

abstract class TradingChartEvent extends Equatable {
  const TradingChartEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize chart with symbol
class TradingChartInitialized extends TradingChartEvent {
  final String symbol;

  const TradingChartInitialized({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}

/// Event to toggle chart expansion state
class TradingChartExpansionToggled extends TradingChartEvent {
  const TradingChartExpansionToggled();
}

/// Event to load chart history data
class TradingChartHistoryLoaded extends TradingChartEvent {
  final String symbol;
  final ChartTimeframe timeframe;

  const TradingChartHistoryLoaded({
    required this.symbol,
    required this.timeframe,
  });

  @override
  List<Object?> get props => [symbol, timeframe];
}

/// Event to change timeframe
class TradingChartTimeframeChanged extends TradingChartEvent {
  final ChartTimeframe timeframe;

  const TradingChartTimeframeChanged({required this.timeframe});

  @override
  List<Object?> get props => [timeframe];
}

/// Event for real-time data updates
class TradingChartRealtimeDataReceived extends TradingChartEvent {
  final int timestamp;
  final double open;
  final double high;
  final double low;
  final double close;

  const TradingChartRealtimeDataReceived({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  @override
  List<Object?> get props => [timestamp, open, high, low, close];
}

/// Event to reset chart state
class TradingChartReset extends TradingChartEvent {
  const TradingChartReset();
}
