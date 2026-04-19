import 'package:equatable/equatable.dart';

import '../../../chart/domain/entities/chart_entity.dart';

abstract class FuturesChartEvent extends Equatable {
  const FuturesChartEvent();

  @override
  List<Object?> get props => [];
}

class FuturesChartInitialized extends FuturesChartEvent {
  const FuturesChartInitialized({required this.symbol});

  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

class FuturesChartExpansionToggled extends FuturesChartEvent {
  const FuturesChartExpansionToggled();
}

class FuturesChartTimeframeChanged extends FuturesChartEvent {
  const FuturesChartTimeframeChanged({required this.timeframe});

  final ChartTimeframe timeframe;

  @override
  List<Object?> get props => [timeframe];
}

class FuturesChartReset extends FuturesChartEvent {
  const FuturesChartReset();
}

class FuturesChartDataReceived extends FuturesChartEvent {
  const FuturesChartDataReceived({
    required this.chartData,
    required this.currentPrice,
    required this.changePercent,
    this.fundingRate,
  });

  final List<ChartDataPoint> chartData;
  final double currentPrice;
  final double changePercent;
  final double? fundingRate;

  @override
  List<Object?> get props =>
      [chartData, currentPrice, changePercent, fundingRate];
}
