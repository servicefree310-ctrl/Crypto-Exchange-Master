import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/chart_entity.dart';
import '../../../market/domain/entities/market_data_entity.dart';
import '../../../market/domain/entities/market_entity.dart';
import '../../../market/domain/entities/ticker_entity.dart';
import '../bloc/chart_bloc.dart';
import '../widgets/chart_header.dart';
import '../widgets/chart_canvas.dart';
import '../widgets/chart_tools_bar.dart';
import '../widgets/chart_bottom_sheet.dart';
import '../widgets/chart_trading_buttons.dart';
import 'fullscreen_chart_page.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({
    super.key,
    required this.symbol,
    this.marketData,
  });

  final String symbol;
  final dynamic marketData; // Will be MarketDataEntity from market feature

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // dev.log('🚀 CHART_PAGE: Creating new ChartBloc for symbol: $symbol');
        return getIt<ChartBloc>()..add(ChartLoadRequested(symbol: symbol));
      },
      child: _ChartPageContent(symbol: symbol, marketData: marketData),
    );
  }
}

class _ChartPageContent extends StatefulWidget {
  const _ChartPageContent({required this.symbol, this.marketData});

  final String symbol;
  final dynamic marketData;

  @override
  State<_ChartPageContent> createState() => _ChartPageContentState();
}

class _ChartPageContentState extends State<_ChartPageContent>
    with WidgetsBindingObserver {
  bool _showOrderBook = true; // Default to true - Order Book is default
  bool _showTradingInfo = false;
  bool _showRecentTrades = false;
  ChartBloc?
      _chartBloc; // Store reference to avoid context access during disposal
  bool _isDisposed = false; // Flag to track disposal state
  final GlobalKey _screenshotKey = GlobalKey(); // Key for screenshot capture

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start real-time updates after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        try {
          _chartBloc = context.read<ChartBloc>();
          _chartBloc?.add(const ChartStartRealtimeRequested());
          // dev.log('✅ CHART_PAGE: Real-time updates started for ${widget.symbol}');
        } catch (e) {
          // dev.log('❌ CHART_PAGE: Error starting real-time updates: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    // dev.log('🧹 CHART_PAGE: Disposing chart page for ${widget.symbol}');

    // Use stored reference to safely trigger cleanup
    if (_chartBloc != null && !_chartBloc!.isClosed) {
      try {
        _chartBloc!.add(const ChartCleanupRequested());
        // dev.log('✅ CHART_PAGE: Cleanup event sent successfully');
      } catch (e) {
        // dev.log('⚠️ CHART_PAGE: Failed to send cleanup event: $e');
      }
    } else {
      // dev.log(
      //     '⚠️ CHART_PAGE: ChartBloc is null or already closed, skipping cleanup');
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (_isDisposed || _chartBloc == null || _chartBloc!.isClosed) {
      return;
    }

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        try {
          _chartBloc?.add(const ChartStopRealtimeRequested());
        } catch (e) {
          // dev.log('⚠️ CHART_PAGE: Error stopping real-time on app pause: $e');
        }
        break;
      case AppLifecycleState.resumed:
        try {
          _chartBloc?.add(const ChartStartRealtimeRequested());
        } catch (e) {
          // dev.log('⚠️ CHART_PAGE: Error starting real-time on app resume: $e');
        }
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _toggleOrderBook() {
    setState(() {
      _showOrderBook = !_showOrderBook;
      if (_showOrderBook) {
        _showTradingInfo = false;
        _showRecentTrades = false;
      }
    });
  }

  void _toggleTradingInfo() {
    setState(() {
      _showTradingInfo = !_showTradingInfo;
      if (_showTradingInfo) {
        _showOrderBook = false;
        _showRecentTrades = false;
      }
    });
  }

  void _toggleRecentTrades() {
    setState(() {
      _showRecentTrades = !_showRecentTrades;
      if (_showRecentTrades) {
        _showOrderBook = false;
        _showTradingInfo = false;
      }
    });
  }

  /// Calculate smart chart height based on number of active indicators
  double _calculateChartHeight(Set<String> activeIndicators) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Base chart height (50% of screen - increased from 40%)
    double baseHeight = screenHeight * 0.5;

    // Add height for each indicator (100px per indicator)
    double indicatorHeight = activeIndicators.length * 100.0;

    // Maximum height should not exceed 70% of screen
    double maxHeight = screenHeight * 0.7;

    // Return calculated height with constraints
    return (baseHeight + indicatorHeight).clamp(baseHeight, maxHeight);
  }

  /// Open fullscreen chart mode
  void _openFullscreenChart(ChartLoaded state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (newContext) => BlocProvider.value(
          value: context.read<ChartBloc>(),
          child: FullscreenChartPage(
            symbol: widget.symbol,
            marketData: widget.marketData,
          ),
        ),
      ),
    );
  }

  /// Convert ChartEntity to MarketDataEntity for compatibility
  MarketDataEntity _convertChartDataToMarketData(ChartEntity chartData) {
    // Create a mock MarketEntity
    final marketEntity = MarketEntity(
      id: chartData.symbol,
      symbol: chartData.symbol,
      currency: chartData.symbol.split('/').first,
      pair: chartData.symbol.split('/').length > 1
          ? chartData.symbol.split('/').last
          : 'USDT',
      isTrending: false,
      isHot: false,
      status: true,
      isEco: false,
    );

    // Create a TickerEntity from chart data
    final tickerEntity = TickerEntity(
      symbol: chartData.symbol,
      last: chartData.price,
      baseVolume: chartData.volume24h,
      quoteVolume: chartData.volume24h,
      change: chartData.change / 100, // Convert percentage to decimal
      high: chartData.high24h,
      low: chartData.low24h,
    );

    // Return combined MarketDataEntity
    return MarketDataEntity(
      market: marketEntity,
      ticker: tickerEntity,
    );
  }

  /// Safely add event to BLoC if it's not disposed
  void _safeAddEvent(ChartEvent event) {
    if (!_isDisposed &&
        mounted &&
        _chartBloc != null &&
        !_chartBloc!.isClosed) {
      try {
        _chartBloc!.add(event);
      } catch (e) {
        // dev.log('⚠️ CHART_PAGE: Error adding event $event: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: BlocBuilder<ChartBloc, ChartState>(
        builder: (context, state) {
          // dev.log(
          //     '🎯 CHART_PAGE: BlocBuilder called with state: ${state.runtimeType}');

          // ALWAYS show the UI layout immediately, regardless of state
          return RepaintBoundary(
            key: _screenshotKey,
            child: Column(
              children: [
                // ✅ ALWAYS show header immediately with available market data
                ChartHeader(
                  marketData:
                      widget.marketData ?? _createFallbackMarketData(state),
                  onBack: () => Navigator.of(context).pop(),
                  screenshotKey: _screenshotKey,
                ),

                // ✅ ALWAYS show scrollable content area
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // ✅ Chart area - show skeleton while loading, real chart when loaded
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: _calculateChartHeight(
                            state is ChartLoaded
                                ? state.activeIndicators
                                : <String>{},
                          ),
                          child: Stack(
                            children: [
                              // Show chart content based on state
                              if (state is ChartLoaded)
                                ChartCanvas(
                                  key: ValueKey(
                                      'chart_${state.activeIndicators.join('_')}_${state.volumeVisible}_${state.mainState}'),
                                  chartData: state.chartData,
                                  chartType: state.chartType,
                                  timeframe: state.timeframe,
                                  activeIndicators: state.activeIndicators,
                                  isLoading: state.isLoading,
                                  volumeVisible: state.volumeVisible,
                                  mainState: state.mainState,
                                )
                              else if (state is ChartError)
                                _buildChartErrorView(state)
                              else
                                _buildChartSkeletonView(),

                              // ✅ ALWAYS show fullscreen button (if chart is loaded)
                              if (state is ChartLoaded)
                                Positioned(
                                  top: 20,
                                  right: 20,
                                  child: GestureDetector(
                                    onTap: () => _openFullscreenChart(state),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: context.inputBackground
                                            .withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: context.borderColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.fullscreen,
                                        color: context.textSecondary,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // ✅ Show bottom sheet only when chart is loaded and user wants it
                        if (state is ChartLoaded &&
                            (_showOrderBook ||
                                _showTradingInfo ||
                                _showRecentTrades))
                          ChartBottomSheet(
                            symbol: state.chartData.symbol,
                            currentPrice: state.chartData.formattedPrice,
                            showOrderBook: _showOrderBook,
                            showTradingInfo: _showTradingInfo,
                            showRecentTrades: _showRecentTrades,
                          ),

                        // Padding for fixed elements
                        SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 20),
                      ],
                    ),
                  ),
                ),

                // ✅ ALWAYS show tools bar (with appropriate states)
                if (state is ChartLoaded)
                  ChartToolsBar(
                    chartType: state.chartType,
                    activeIndicators: state.activeIndicators,
                    volumeVisible: state.volumeVisible,
                    mainState: state.mainState,
                    onChartTypeChanged: (type) {
                      _safeAddEvent(ChartTypeChanged(chartType: type));
                    },
                    onIndicatorToggled: (indicator) {
                      _safeAddEvent(
                          ChartIndicatorToggled(indicator: indicator));
                    },
                    onVolumeToggled: () {
                      _safeAddEvent(const ChartVolumeToggled());
                    },
                    onMainStateChanged: (mainState) {
                      _safeAddEvent(
                          ChartMainStateChanged(mainState: mainState));
                    },
                    onOrderBookToggled: _toggleOrderBook,
                    onTradingInfoToggled: _toggleTradingInfo,
                    onRecentTradesToggled: _toggleRecentTrades,
                    showOrderBook: _showOrderBook,
                    showTradingInfo: _showTradingInfo,
                    showRecentTrades: _showRecentTrades,
                  )
                else
                  _buildSkeletonToolsBar(),

                // ✅ ALWAYS show trading buttons
                if (state is ChartLoaded)
                  ChartTradingButtons(
                    symbol: state.chartData.symbol,
                    currentPrice: state.chartData.formattedPrice,
                    marketData:
                        widget.marketData ?? _createFallbackMarketData(state),
                  )
                else
                  _buildSkeletonTradingButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Create fallback market data when no market data is passed
  MarketDataEntity _createFallbackMarketData(ChartState state) {
    final symbol = widget.symbol;

    if (state is ChartLoaded) {
      return _convertChartDataToMarketData(state.chartData);
    }

    // Create minimal market data for immediate display
    final marketEntity = MarketEntity(
      id: symbol,
      symbol: symbol,
      currency: symbol.split('/').first,
      pair: symbol.split('/').length > 1 ? symbol.split('/').last : 'USDT',
      isTrending: false,
      isHot: false,
      status: true,
      isEco: false,
    );

    final tickerEntity = TickerEntity(
      symbol: symbol,
      last: 0.0,
      baseVolume: 0.0,
      quoteVolume: 0.0,
      change: 0.0,
      high: 0.0,
      low: 0.0,
    );

    return MarketDataEntity(
      market: marketEntity,
      ticker: tickerEntity,
    );
  }

  /// Build skeleton view for chart area while loading
  Widget _buildChartSkeletonView() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Skeleton timeframe selector
          Container(
            height: 50,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(
                7,
                (index) => Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 40,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.inputBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          // Skeleton chart area with shimmer effect
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Animated shimmer effect
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: context.priceUpColor,
                          strokeWidth: 2,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading chart data...',
                          style: TextStyle(
                            color: context.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Skeleton bars
                  Positioned.fill(
                    child: CustomPaint(
                      painter: SkeletonChartPainter(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build error view for chart area
  Widget _buildChartErrorView(ChartError state) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: context.priceDownColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load chart',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                state.failure.message,
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  _safeAddEvent(ChartLoadRequested(symbol: widget.symbol)),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.priceUpColor,
                foregroundColor:
                    context.isDarkMode ? Colors.black : Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build skeleton tools bar while loading
  Widget _buildSkeletonToolsBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        border: Border(
          top: BorderSide(color: context.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: List.generate(
          5,
          (index) => Container(
            margin: const EdgeInsets.only(right: 12),
            width: 60,
            height: 38,
            decoration: BoxDecoration(
              color: context.inputBackground,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  /// Build skeleton trading buttons while loading
  Widget _buildSkeletonTradingButtons() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        border: Border(
          top: BorderSide(color: context.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: context.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: context.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for skeleton chart animation
class SkeletonChartPainter extends CustomPainter {
  final BuildContext context;

  SkeletonChartPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = context.borderColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = context.inputBackground.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Draw skeleton candlesticks
    final candleWidth = size.width / 30;
    final candleSpacing = candleWidth * 1.5;

    for (int i = 0; i < 20; i++) {
      final x = (i * candleSpacing) + (candleWidth / 2);
      if (x > size.width) break;

      // Random heights for skeleton effect
      final bodyHeight = (size.height * 0.1) + ((i % 3) * 10);
      final wickHeight = bodyHeight + ((i % 2) * 15);

      final centerY = size.height / 2;
      final bodyTop = centerY - (bodyHeight / 2);
      final bodyBottom = centerY + (bodyHeight / 2);

      // Draw wick
      canvas.drawLine(
        Offset(x, centerY - (wickHeight / 2)),
        Offset(x, centerY + (wickHeight / 2)),
        paint,
      );

      // Draw body
      canvas.drawRect(
        Rect.fromLTRB(
          x - (candleWidth / 4),
          bodyTop,
          x + (candleWidth / 4),
          bodyBottom,
        ),
        fillPaint,
      );
    }

    // Draw skeleton grid lines
    final gridPaint = Paint()
      ..color = context.borderColor.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    // Horizontal lines
    for (int i = 1; i < 5; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Vertical lines
    for (int i = 1; i < 6; i++) {
      final x = (size.width / 6) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
