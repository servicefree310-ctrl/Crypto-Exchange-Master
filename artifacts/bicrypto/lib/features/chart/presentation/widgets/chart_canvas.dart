import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:k_chart_plus/k_chart_plus.dart';
import '../../../../core/theme/global_theme_extensions.dart';

import '../../domain/entities/chart_entity.dart';
import 'depth_chart_widget.dart';

class ChartCanvas extends StatefulWidget {
  const ChartCanvas({
    super.key,
    required this.chartData,
    required this.chartType,
    required this.timeframe,
    required this.activeIndicators,
    this.isLoading = false,
    this.volumeVisible = true,
    this.mainState = 'NONE',
  });

  final ChartEntity chartData;
  final ChartType chartType;
  final ChartTimeframe timeframe;
  final Set<String> activeIndicators;
  final bool isLoading;
  final bool volumeVisible;
  final String mainState;

  @override
  State<ChartCanvas> createState() => _ChartCanvasState();
}

class _ChartCanvasState extends State<ChartCanvas> {
  late List<KLineEntity> _kLineData;

  @override
  void initState() {
    super.initState();
    // dev.log(
    //     '🎯 CHART_CANVAS: initState called with indicators: ${widget.activeIndicators}');
    _prepareData();
  }

  @override
  void didUpdateWidget(ChartCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if chart data has changed (new timeframe data)
    final dataChanged = oldWidget.chartData.priceData.length !=
            widget.chartData.priceData.length ||
        oldWidget.chartData.priceData.isNotEmpty &&
            widget.chartData.priceData.isNotEmpty &&
            (oldWidget.chartData.priceData.first.timestamp !=
                    widget.chartData.priceData.first.timestamp ||
                oldWidget.chartData.priceData.last.timestamp !=
                    widget.chartData.priceData.last.timestamp);

    // Check if timeframe changed
    final timeframeChanged = oldWidget.timeframe != widget.timeframe;

    // Check if chart type changed (important for full rebuilds)
    final chartTypeChanged = oldWidget.chartType != widget.chartType;

    // Check if indicators changed
    final indicatorsChanged =
        oldWidget.activeIndicators != widget.activeIndicators;

    // Check if other display settings changed
    final displaySettingsChanged =
        oldWidget.volumeVisible != widget.volumeVisible ||
            oldWidget.mainState != widget.mainState;

    if (dataChanged || timeframeChanged || chartTypeChanged) {
      // dev.log(
      //     '🎯 CHART_CANVAS: Core chart data updated - Data changed: $dataChanged, Timeframe: ${oldWidget.timeframe.value} → ${widget.timeframe.value}, Chart type: $chartTypeChanged');

      // Full recalculation when data, timeframe or chart type changes
      _prepareData();
      setState(() {});
    } else if (indicatorsChanged || displaySettingsChanged) {
      // dev.log(
      //     '🎯 CHART_CANVAS: Display settings changed - Indicators: $indicatorsChanged, Display settings: $displaySettingsChanged');

      // Only recalculate indicators when needed, not the whole dataset
      _recalculateIndicators();
      setState(() {});
    }
  }

  /// Prepare all chart data from scratch (expensive operation)
  void _prepareData() {
    // dev.log(
    //     '🎯 CHART_CANVAS: Preparing FULL data for indicators: ${widget.activeIndicators}, volume: ${widget.volumeVisible}, main: ${widget.mainState}');

    // Convert real chart data points to KLineEntity format
    final chartDataPoints = widget.chartData.priceData;
    final volumeDataPoints = widget.chartData.volumeData;

    // dev.log(
    //     '🎯 CHART_CANVAS: Converting ${chartDataPoints.length} chart data points to KLineEntity');

    if (chartDataPoints.isEmpty) {
      // dev.log('🎯 CHART_CANVAS: No chart data available, using empty list');
      _kLineData = [];
      return;
    }

    _kLineData = chartDataPoints.map((dataPoint) {
      // Find matching volume data point
      double volume = 0.0;
      try {
        final matchingVolume = volumeDataPoints.firstWhere(
          (vol) =>
              vol.timestamp.millisecondsSinceEpoch ==
              dataPoint.timestamp.millisecondsSinceEpoch,
          orElse: () =>
              VolumeDataPoint(timestamp: dataPoint.timestamp, volume: 0.0),
        );
        volume = matchingVolume.volume;
      } catch (e) {
        volume = 0.0;
      }

      // Create KLineEntity from real data
      final Map<String, dynamic> data = {
        'open': dataPoint.open,
        'high': dataPoint.high,
        'low': dataPoint.low,
        'close': dataPoint.close,
        'vol': volume,
        'count': dataPoint.timestamp.millisecondsSinceEpoch,
        'amount': dataPoint.close * volume,
      };

      return KLineEntity.fromJson(data);
    }).toList();

    // dev.log(
    //     '🎯 CHART_CANVAS: Converted to ${_kLineData.length} KLineEntity objects');

    // Calculate the data for indicators
    DataUtil.calculate(_kLineData);
  }

  /// Only recalculate indicators without recreating the dataset (faster)
  void _recalculateIndicators() {
    // dev.log(
    //     '🎯 CHART_CANVAS: ONLY recalculating indicators: ${widget.activeIndicators}, volume: ${widget.volumeVisible}, main: ${widget.mainState}');

    if (_kLineData.isNotEmpty) {
      // Just recalculate indicators on existing data
      DataUtil.calculate(_kLineData);
    }
  }

  @override
  Widget build(BuildContext context) {
    // dev.log(
    //     '🎯 CHART_CANVAS: Building with indicators: ${widget.activeIndicators}');
    // dev.log('🎯 CHART_CANVAS: Secondary states: ${_getSecondaryStates()}');

    // If chart type is depth, show depth chart instead
    if (widget.chartType == ChartType.depth) {
      return DepthChartWidget(
        bidsData: widget.chartData.bidsData,
        asksData: widget.chartData.asksData,
        isLoading: widget.isLoading,
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF0A0A0A)
            : context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // K Chart Plus Widget - Use a more targeted key to avoid unnecessary rebuilds
          Container(
            key: ValueKey(
                'kchart_${widget.timeframe.value}_${widget.chartType.name}_${widget.volumeVisible}_${widget.mainState}'),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: KChartWidget(
                _kLineData,
                ChartStyle(),
                _buildChartColors(),
                isLine: widget.chartType == ChartType.line,
                mainState: _getMainState(),
                secondaryStateLi: _getSecondaryStates().toSet(),
                fixedLength: 2,
                timeFormat: TimeFormat.YEAR_MONTH_DAY,
                onLoadMore: (bool isLoadingMore) {
                  // TODO: Implement load more functionality
                },
                maDayList: const [5, 10, 20],
                volHidden: !widget.volumeVisible,
                showNowPrice: true,
                isOnDrag: (isDrag) {
                  // Handle drag state
                },
                isTrendLine: false,
                xFrontPadding: 100,
              ),
            ),
          ),

          // Loading overlay
          if (widget.isLoading)
            Container(
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? Colors.black.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00D4AA),
                ),
              ),
            ),

          // Chart type indicator
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.inputBackground.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.borderColor,
                  width: 1,
                ),
              ),
              child: Text(
                widget.chartType.displayName,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Active indicators badge
          if (widget.activeIndicators.isNotEmpty)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.priceUpColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: context.priceUpColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  '${widget.activeIndicators.length} Indicators',
                  style: TextStyle(
                    color: context.priceUpColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  ChartColors _buildChartColors() {
    return ChartColors(
      bgColor:
          context.isDarkMode ? const Color(0xFF0A0A0A) : context.cardBackground,
      defaultTextColor: context.textSecondary,
      gridColor: context.borderColor,
      hCrossColor: context.textPrimary,
      vCrossColor: context.borderColor.withValues(alpha: 0.3),
      crossTextColor: context.textPrimary,
      selectBorderColor: context.textSecondary,
      selectFillColor: context.inputBackground,
      infoWindowTitleColor: context.textSecondary,
      infoWindowNormalColor: context.textPrimary,
      upColor: context.priceUpColor,
      dnColor: context.priceDownColor,
      ma5Color: Colors.yellow,
      ma10Color: Colors.orange,
      ma30Color: Colors.purple,
      volColor: context.textSecondary.withValues(alpha: 0.6),
      macdColor: Colors.blue,
      difColor: Colors.red,
      deaColor: Colors.orange,
      kColor: Colors.blue,
      dColor: Colors.orange,
      jColor: Colors.purple,
      rsiColor: Colors.yellow,
      maxColor: context.priceUpColor,
      minColor: context.priceDownColor,
      nowPriceUpColor: context.priceUpColor,
      nowPriceDnColor: context.priceDownColor,
      nowPriceTextColor: context.textPrimary,
    );
  }

  MainState _getMainState() {
    switch (widget.mainState) {
      case 'MA':
        return MainState.MA;
      case 'BOLL':
        return MainState.BOLL;
      case 'NONE':
      default:
        return MainState.NONE;
    }
  }

  List<SecondaryState> _getSecondaryStates() {
    List<SecondaryState> states = [];

    // dev.log(
    //     '🎯 CHART_CANVAS: Building secondary states for indicators: ${widget.activeIndicators}');

    for (String indicator in widget.activeIndicators) {
      switch (indicator.toUpperCase()) {
        case 'RSI':
          states.add(SecondaryState.RSI);
          // dev.log('🎯 CHART_CANVAS: Added RSI indicator');
          break;
        case 'MACD':
          states.add(SecondaryState.MACD);
          // dev.log('🎯 CHART_CANVAS: Added MACD indicator');
          break;
        case 'KDJ':
          states.add(SecondaryState.KDJ);
          // dev.log('🎯 CHART_CANVAS: Added KDJ indicator');
          break;
        case 'WR':
          states.add(SecondaryState.WR);
          // dev.log('🎯 CHART_CANVAS: Added WR indicator');
          break;
        case 'CCI':
          states.add(SecondaryState.CCI);
          // dev.log('🎯 CHART_CANVAS: Added CCI indicator');
          break;
        default:
        // dev.log('🎯 CHART_CANVAS: Unknown indicator: $indicator');
      }
    }

    // dev.log('🎯 CHART_CANVAS: Final secondary states: $states');
    return states;
  }
}
