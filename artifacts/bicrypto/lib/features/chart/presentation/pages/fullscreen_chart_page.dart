import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/utils/orientation_helper.dart';
import '../../../market/domain/entities/market_data_entity.dart';
import '../../../market/domain/entities/market_entity.dart';
import '../../../market/domain/entities/ticker_entity.dart';
import '../../domain/entities/chart_entity.dart';
import '../bloc/chart_bloc.dart';
import '../widgets/chart_canvas.dart';
import '../widgets/chart_header.dart';
import '../widgets/chart_tools_bar_landscape.dart';
import '../widgets/fullscreen_trading_panel.dart';

class FullscreenChartPage extends StatefulWidget {
  const FullscreenChartPage({
    super.key,
    required this.symbol,
    this.marketData,
  });

  final String symbol;
  final MarketDataEntity? marketData;

  @override
  State<FullscreenChartPage> createState() => _FullscreenChartPageState();
}

class _FullscreenChartPageState extends State<FullscreenChartPage> {
  bool _showTradingPanel = true;
  bool _showOrderBook = false;
  bool _showTradingInfo = false;
  bool _showRecentTrades = false;

  @override
  void initState() {
    super.initState();
    // 🔄 ORIENTATION OVERRIDE: Temporarily override global portrait lock for fullscreen chart
    dev.log(
        '🔄 FULLSCREEN_CHART: Overriding global portrait lock for landscape mode');
    OrientationHelper.enableFullscreenChart();
    dev.log(
        '✅ FULLSCREEN_CHART: Landscape orientation and immersive mode activated');
  }

  @override
  void dispose() {
    // 🔄 ORIENTATION RESTORE: Restore global portrait lock when exiting fullscreen
    dev.log('🔄 FULLSCREEN_CHART: Restoring global portrait orientation lock');
    OrientationHelper.restoreNormalMode();
    dev.log(
        '✅ FULLSCREEN_CHART: Portrait orientation lock and system UI restored');
    super.dispose();
  }

  void _toggleTradingPanel() {
    setState(() {
      _showTradingPanel = !_showTradingPanel;
    });
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

  void _exitFullscreen() {
    // 🔄 IMMEDIATE RESTORE: Immediately restore global portrait lock before popping
    dev.log(
        '🔄 FULLSCREEN_CHART: Immediately restoring portrait orientation before exit');
    OrientationHelper.restoreNormalMode();
    dev.log('✅ FULLSCREEN_CHART: Orientation and UI restored, navigating back');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: BlocBuilder<ChartBloc, ChartState>(
        builder: (context, state) {
          if (state is ChartLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: context.priceUpColor,
              ),
            );
          }

          if (state is ChartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: context.priceDownColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load chart',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.failure.message,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ChartBloc>()
                        .add(ChartLoadRequested(symbol: widget.symbol)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.priceUpColor,
                      foregroundColor:
                          context.isDarkMode ? Colors.black : Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ChartLoaded) {
            return Row(
              children: [
                // Main chart area (left side)
                Expanded(
                  flex: _showTradingPanel ? 65 : 100, // More precise control
                  child: Column(
                    children: [
                      // Top bar with symbol info and controls
                      ChartHeader(
                        marketData: widget.marketData ??
                            _convertChartDataToMarketData(state.chartData),
                        onBack: () {}, // No back button in landscape
                        onFavorite: () {},
                        onShare: () {},
                        isLandscape: true,
                        showFullStats:
                            !_showTradingPanel, // Show stats only when trading panel is hidden
                      ),

                      // Chart area
                      Expanded(
                        child: Stack(
                          children: [
                            // Chart canvas
                            ChartCanvas(
                              chartData: state.chartData,
                              chartType: state.chartType,
                              timeframe: state.timeframe,
                              activeIndicators: state.activeIndicators,
                              isLoading: state.isLoading,
                              volumeVisible: state.volumeVisible,
                              mainState: state.mainState,
                            ),

                            // Exit fullscreen button (top right)
                            Positioned(
                              top: 16,
                              right: 16,
                              child: _buildExitButton(context),
                            ),

                            // Trading panel toggle (bottom right)
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: _buildTradingPanelToggle(context),
                            ),
                          ],
                        ),
                      ),

                      // Bottom tools bar
                      _buildBottomToolsBar(state),
                    ],
                  ),
                ),

                // Trading panel (right side)
                if (_showTradingPanel)
                  Expanded(
                    flex: 35, // 35% of remaining space
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.cardBackground,
                        border: Border(
                          left: BorderSide(
                            color: context.borderColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: FullscreenTradingPanel(
                        symbol: state.chartData.symbol,
                        currentPrice: state.chartData.formattedPrice,
                        showOrderBook: _showOrderBook,
                        showTradingInfo: _showTradingInfo,
                        showRecentTrades: _showRecentTrades,
                        onOrderBookToggled: _toggleOrderBook,
                        onTradingInfoToggled: _toggleTradingInfo,
                        onRecentTradesToggled: _toggleRecentTrades,
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBottomToolsBar(ChartLoaded state) {
    return ChartToolsBarLandscape(
      chartType: state.chartType,
      activeIndicators: state.activeIndicators,
      volumeVisible: state.volumeVisible,
      mainState: state.mainState,
      onChartTypeChanged: (type) {
        context.read<ChartBloc>().add(
              ChartTypeChanged(chartType: type),
            );
      },
      onIndicatorToggled: (indicator) {
        context.read<ChartBloc>().add(
              ChartIndicatorToggled(indicator: indicator),
            );
      },
      onVolumeToggled: () {
        context.read<ChartBloc>().add(
              const ChartVolumeToggled(),
            );
      },
      onMainStateChanged: (mainState) {
        context.read<ChartBloc>().add(
              ChartMainStateChanged(mainState: mainState),
            );
      },
      onOrderBookToggled: _toggleOrderBook,
      onTradingInfoToggled: _toggleTradingInfo,
      showOrderBook: _showOrderBook,
      showTradingInfo: _showTradingInfo,
    );
  }

  Widget _buildExitButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8), // Add margin from borders
      child: GestureDetector(
        onTap: _exitFullscreen,
        child: Container(
          width: 28, // Smaller size
          height: 28,
          decoration: BoxDecoration(
            color: context.inputBackground.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: context.borderColor,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.fullscreen_exit,
            color: context.textSecondary, // Softer white
            size: 16, // Smaller icon
          ),
        ),
      ),
    );
  }

  Widget _buildTradingPanelToggle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8), // Add margin from borders
      child: GestureDetector(
        onTap: _toggleTradingPanel,
        child: Container(
          width: 28, // Smaller size
          height: 28,
          decoration: BoxDecoration(
            color: context.inputBackground
                .withValues(alpha: 0.8), // Same color for both states
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: context.borderColor, // No green color
              width: 1,
            ),
          ),
          child: Icon(
            _showTradingPanel
                ? Icons.keyboard_arrow_right
                : Icons.keyboard_arrow_left,
            color: context.textSecondary, // Softer white for both states
            size: 16, // Smaller icon
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
}
