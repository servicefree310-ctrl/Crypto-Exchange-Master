part of 'chart_bloc.dart';

// Import required for events

// Events
abstract class ChartEvent extends Equatable {
  const ChartEvent();

  @override
  List<Object?> get props => [];
}

class ChartLoadRequested extends ChartEvent {
  const ChartLoadRequested({required this.symbol});

  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

class ChartTimeframeChanged extends ChartEvent {
  const ChartTimeframeChanged({required this.timeframe});

  final ChartTimeframe timeframe;

  @override
  List<Object?> get props => [timeframe];
}

class ChartTypeChanged extends ChartEvent {
  const ChartTypeChanged({required this.chartType});

  final ChartType chartType;

  @override
  List<Object?> get props => [chartType];
}

class ChartIndicatorToggled extends ChartEvent {
  const ChartIndicatorToggled({required this.indicator});

  final String indicator;

  @override
  List<Object?> get props => [indicator];
}

class ChartRefreshRequested extends ChartEvent {
  const ChartRefreshRequested();
}

class ChartStartRealtimeRequested extends ChartEvent {
  const ChartStartRealtimeRequested();
}

class ChartStopRealtimeRequested extends ChartEvent {
  const ChartStopRealtimeRequested();
}

class ChartRealtimeDataReceived extends ChartEvent {
  const ChartRealtimeDataReceived({required this.chartData});

  final ChartEntity chartData;

  @override
  List<Object?> get props => [chartData];
}

class ChartVolumeToggled extends ChartEvent {
  const ChartVolumeToggled();
}

class ChartMainStateChanged extends ChartEvent {
  const ChartMainStateChanged({required this.mainState});

  final String mainState; // 'MA', 'BOLL', 'NONE'

  @override
  List<Object?> get props => [mainState];
}

class ChartRealtimeTickerReceived extends ChartEvent {
  const ChartRealtimeTickerReceived({required this.tickerData});

  final MarketDataEntity tickerData;

  @override
  List<Object?> get props => [tickerData];
}

class ChartHistoryLoadRequested extends ChartEvent {
  const ChartHistoryLoadRequested({
    required this.symbol,
    required this.interval,
    this.limit,
  });

  final String symbol;
  final ChartTimeframe interval;
  final int? limit;

  @override
  List<Object?> get props => [symbol, interval, limit];
}

class ChartSymbolChanged extends ChartEvent {
  const ChartSymbolChanged({required this.newSymbol});

  final String newSymbol;

  @override
  List<Object?> get props => [newSymbol];
}

class ChartCleanupRequested extends ChartEvent {
  const ChartCleanupRequested();
}
