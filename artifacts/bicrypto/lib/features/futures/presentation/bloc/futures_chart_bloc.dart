import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/futures_websocket_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection/injection.dart';
import '../../../chart/domain/entities/chart_entity.dart';
import '../../data/datasources/futures_chart_remote_datasource.dart';
import '../../domain/entities/futures_market_entity.dart';
import '../../domain/usecases/get_futures_markets_usecase.dart';
import 'futures_chart_event.dart';
import 'futures_chart_state.dart';

@injectable
class FuturesChartBloc extends Bloc<FuturesChartEvent, FuturesChartState> {
  FuturesChartBloc(
    this._getFuturesMarketsUseCase,
    this._chartDataSource,
  ) : super(const FuturesChartInitial()) {
    on<FuturesChartInitialized>(_onInitialized);
    on<FuturesChartExpansionToggled>(_onExpansionToggled);
    on<FuturesChartTimeframeChanged>(_onTimeframeChanged);
    on<FuturesChartReset>(_onReset);
    on<FuturesChartDataReceived>(_onDataReceived);
  }

  final GetFuturesMarketsUseCase _getFuturesMarketsUseCase;
  final FuturesChartRemoteDataSource _chartDataSource;
  final _wsService = getIt<FuturesWebSocketService>();

  StreamSubscription? _tickerSubscription;
  Timer? _chartRefreshTimer;

  String? _currentSymbol;
  ChartTimeframe _currentTimeframe = ChartTimeframe.fifteenMinutes;
  double _currentPrice = 0.0;
  double _changePercent = 0.0;
  double? _fundingRate;
  bool _isExpanded = false;
  FuturesMarketEntity? _currentMarket;
  List<ChartDataPoint> _currentChartData = [];

  Future<void> _onInitialized(
    FuturesChartInitialized event,
    Emitter<FuturesChartState> emit,
  ) async {
    emit(const FuturesChartLoading());

    // Cancel existing subscriptions
    await _tickerSubscription?.cancel();
    _chartRefreshTimer?.cancel();

    _currentSymbol = event.symbol;
    _isExpanded = false; // Start collapsed by default

    try {
      // Get market info to extract funding rate
      final marketsResult = await _getFuturesMarketsUseCase(NoParams());

      marketsResult.fold(
        (failure) {
          dev.log('❌ FUTURES_CHART: Failed to get markets: $failure');
        },
        (markets) {
          // Find the current market
          _currentMarket = markets.firstWhere(
            (m) => m.symbol == event.symbol,
            orElse: () => markets.first,
          );

          if (_currentMarket != null && _currentMarket!.metadata != null) {
            _fundingRate = _currentMarket!.metadata!.fundingRate;
          }
        },
      );

      // Subscribe to ticker updates for real-time price
      _tickerSubscription = _wsService.tickerStream.listen((ticker) {
        if (ticker.symbol == _currentSymbol) {
          _currentPrice = ticker.last;
          _changePercent = ticker.change * 100; // Convert to percentage

          // Use add event instead of emitting directly from the listener
          if (!isClosed) {
            if (state is FuturesChartCollapsed) {
              add(FuturesChartDataReceived(
                chartData: _currentChartData,
                currentPrice: _currentPrice,
                changePercent: _changePercent,
                fundingRate: _fundingRate,
              ));
            } else if (state is FuturesChartExpanded) {
              add(FuturesChartDataReceived(
                chartData: _currentChartData,
                currentPrice: _currentPrice,
                changePercent: _changePercent,
                fundingRate: _fundingRate,
              ));
            }
          }
        }
      });

      // Emit collapsed state initially
      emit(FuturesChartCollapsed(
        currentPrice: _currentPrice,
        changePercent: _changePercent,
        fundingRate: _fundingRate,
      ));
    } catch (e) {
      emit(FuturesChartError(message: e.toString()));
    }
  }

  Future<void> _onExpansionToggled(
    FuturesChartExpansionToggled event,
    Emitter<FuturesChartState> emit,
  ) async {
    if (_currentSymbol == null) return;

    if (_isExpanded) {
      // Collapse the chart
      _isExpanded = false;
      _chartRefreshTimer?.cancel();

      emit(FuturesChartCollapsed(
        currentPrice: _currentPrice,
        changePercent: _changePercent,
        fundingRate: _fundingRate,
      ));
    } else {
      // Expand the chart
      _isExpanded = true;
      emit(const FuturesChartLoading());

      try {
        // Fetch chart data for futures
        _currentChartData = await _chartDataSource.getChartData(
          symbol: _currentSymbol!,
          interval: _currentTimeframe,
        );

        emit(FuturesChartExpanded(
          symbol: _currentSymbol!,
          chartData: _currentChartData,
          timeframe: _currentTimeframe,
          currentPrice: _currentPrice,
          changePercent: _changePercent,
          fundingRate: _fundingRate,
        ));

        // Set up periodic refresh every 30 seconds
        _chartRefreshTimer = Timer.periodic(
          const Duration(seconds: 30),
          (_) => _refreshChartData(),
        );
      } catch (e) {
        emit(FuturesChartError(
            message: 'Failed to load chart: ${e.toString()}'));
      }
    }
  }

  Future<void> _onTimeframeChanged(
    FuturesChartTimeframeChanged event,
    Emitter<FuturesChartState> emit,
  ) async {
    if (_currentSymbol == null || !_isExpanded) return;

    _currentTimeframe = event.timeframe;
    emit(const FuturesChartLoading());

    try {
      // Fetch new chart data with new timeframe
      _currentChartData = await _chartDataSource.getChartData(
        symbol: _currentSymbol!,
        interval: _currentTimeframe,
      );

      emit(FuturesChartExpanded(
        symbol: _currentSymbol!,
        chartData: _currentChartData,
        timeframe: _currentTimeframe,
        currentPrice: _currentPrice,
        changePercent: _changePercent,
        fundingRate: _fundingRate,
      ));
    } catch (e) {
      emit(FuturesChartError(
          message: 'Failed to change timeframe: ${e.toString()}'));
    }
  }

  void _onReset(
    FuturesChartReset event,
    Emitter<FuturesChartState> emit,
  ) {
    // Cancel all subscriptions
    _tickerSubscription?.cancel();
    _chartRefreshTimer?.cancel();

    // Reset state
    _currentSymbol = null;
    _currentPrice = 0.0;
    _changePercent = 0.0;
    _fundingRate = null;
    _isExpanded = false;
    _currentMarket = null;
    _currentChartData = [];

    emit(const FuturesChartInitial());
  }

  void _onDataReceived(
    FuturesChartDataReceived event,
    Emitter<FuturesChartState> emit,
  ) {
    if (_currentSymbol != null) {
      _currentChartData = event.chartData;
      _currentPrice = event.currentPrice;
      _changePercent = event.changePercent;

      if (state is FuturesChartCollapsed) {
        emit(FuturesChartCollapsed(
          currentPrice: _currentPrice,
          changePercent: _changePercent,
          fundingRate: event.fundingRate,
        ));
      } else if (_isExpanded) {
        emit(FuturesChartExpanded(
          symbol: _currentSymbol!,
          chartData: event.chartData,
          timeframe: _currentTimeframe,
          currentPrice: event.currentPrice,
          changePercent: event.changePercent,
          fundingRate: event.fundingRate,
        ));
      }
    }
  }

  Future<void> _refreshChartData() async {
    if (!_isExpanded || _currentSymbol == null || isClosed) return;

    try {
      final chartData = await _chartDataSource.getChartData(
        symbol: _currentSymbol!,
        interval: _currentTimeframe,
      );

      if (!isClosed) {
        add(FuturesChartDataReceived(
          chartData: chartData,
          currentPrice: _currentPrice,
          changePercent: _changePercent,
          fundingRate: _fundingRate,
        ));
      }
    } catch (e) {
      dev.log('❌ FUTURES_CHART: Failed to refresh chart data: $e');
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    _chartRefreshTimer?.cancel();
    return super.close();
  }
}
