import 'package:equatable/equatable.dart';

import '../../../chart/domain/entities/chart_entity.dart';

abstract class FuturesChartState extends Equatable {
  const FuturesChartState();

  @override
  List<Object?> get props => [];
}

class FuturesChartInitial extends FuturesChartState {
  const FuturesChartInitial();
}

class FuturesChartLoading extends FuturesChartState {
  const FuturesChartLoading();
}

class FuturesChartCollapsed extends FuturesChartState {
  const FuturesChartCollapsed({
    required this.currentPrice,
    required this.changePercent,
    this.fundingRate,
  });

  final double currentPrice;
  final double changePercent;
  final double? fundingRate;

  @override
  List<Object?> get props => [currentPrice, changePercent, fundingRate];
}

class FuturesChartExpanded extends FuturesChartState {
  const FuturesChartExpanded({
    required this.symbol,
    required this.chartData,
    required this.timeframe,
    required this.currentPrice,
    required this.changePercent,
    this.fundingRate,
  });

  final String symbol;
  final List<ChartDataPoint> chartData;
  final ChartTimeframe timeframe;
  final double currentPrice;
  final double changePercent;
  final double? fundingRate;

  @override
  List<Object?> get props => [
        symbol,
        chartData,
        timeframe,
        currentPrice,
        changePercent,
        fundingRate,
      ];
}

class FuturesChartError extends FuturesChartState {
  const FuturesChartError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
