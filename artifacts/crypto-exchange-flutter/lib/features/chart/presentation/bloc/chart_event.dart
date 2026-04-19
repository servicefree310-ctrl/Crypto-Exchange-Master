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

// Internal events dispatched from WebSocket stream listeners. They funnel
// updates through Bloc's event pipeline so emit() is always called from a
// proper handler with an Emitter — required by Bloc 8 and avoids the
// "emit was called outside of a handler" / "add after close" race.
class ChartWsOhlcvReceived extends ChartEvent {
  const ChartWsOhlcvReceived(this.ohlcvData);
  final Map<String, dynamic> ohlcvData;
  @override
  List<Object?> get props => [ohlcvData];
}

class ChartWsTickerReceived extends ChartEvent {
  const ChartWsTickerReceived(this.marketData);
  final MarketDataEntity marketData;
  @override
  List<Object?> get props => [marketData];
}

class ChartWsOrderBookReceived extends ChartEvent {
  const ChartWsOrderBookReceived(this.orderBookData);
  final OrderBookData orderBookData;
  @override
  List<Object?> get props => [orderBookData];
}

class ChartWsTradesReceived extends ChartEvent {
  const ChartWsTradesReceived(this.tradesData);
  final List<TradeDataPoint> tradesData;
  @override
  List<Object?> get props => [tradesData];
}
