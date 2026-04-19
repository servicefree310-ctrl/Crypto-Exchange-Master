part of 'chart_bloc.dart';

// States
abstract class ChartState extends Equatable {
  const ChartState();

  @override
  List<Object?> get props => [];
}

class ChartInitial extends ChartState {
  const ChartInitial();
}

class ChartLoading extends ChartState {
  const ChartLoading();
}

class ChartLoaded extends ChartState {
  const ChartLoaded({
    required this.chartData,
    required this.timeframe,
    required this.chartType,
    required this.activeIndicators,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isRealtime = false,
    this.volumeVisible = true,
    this.mainState = 'NONE',
    this.tickerData,
  });

  final ChartEntity chartData;
  final ChartTimeframe timeframe;
  final ChartType chartType;
  final Set<String> activeIndicators;
  final bool isLoading;
  final bool isRefreshing;
  final bool isRealtime;
  final bool volumeVisible;
  final String mainState;
  final MarketDataEntity? tickerData;

  @override
  List<Object?> get props => [
        chartData,
        timeframe,
        chartType,
        activeIndicators,
        isLoading,
        isRefreshing,
        isRealtime,
        volumeVisible,
        mainState,
        tickerData,
      ];

  ChartLoaded copyWith({
    ChartEntity? chartData,
    ChartTimeframe? timeframe,
    ChartType? chartType,
    Set<String>? activeIndicators,
    bool? isLoading,
    bool? isRefreshing,
    bool? isRealtime,
    bool? volumeVisible,
    String? mainState,
    MarketDataEntity? tickerData,
  }) {
    return ChartLoaded(
      chartData: chartData ?? this.chartData,
      timeframe: timeframe ?? this.timeframe,
      chartType: chartType ?? this.chartType,
      activeIndicators: activeIndicators ?? this.activeIndicators,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isRealtime: isRealtime ?? this.isRealtime,
      volumeVisible: volumeVisible ?? this.volumeVisible,
      mainState: mainState ?? this.mainState,
      tickerData: tickerData ?? this.tickerData,
    );
  }
}

class ChartError extends ChartState {
  const ChartError({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
