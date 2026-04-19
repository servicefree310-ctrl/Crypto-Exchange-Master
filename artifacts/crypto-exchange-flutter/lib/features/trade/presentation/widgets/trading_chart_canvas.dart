import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:k_chart_plus/k_chart_plus.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../chart/domain/entities/chart_entity.dart';

class TradingChartCanvas extends StatefulWidget {
  const TradingChartCanvas({
    super.key,
    required this.chartData,
    required this.timeframe,
    required this.currentPrice,
    required this.changePercent,
    this.isLoading = false,
  });

  final List<ChartDataPoint> chartData;
  final ChartTimeframe timeframe;
  final double currentPrice;
  final double changePercent;
  final bool isLoading;

  @override
  State<TradingChartCanvas> createState() => _TradingChartCanvasState();
}

class _TradingChartCanvasState extends State<TradingChartCanvas> {
  late List<KLineEntity> _kLineData;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  @override
  void didUpdateWidget(TradingChartCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if chart data has changed
    final dataChanged = oldWidget.chartData.length != widget.chartData.length ||
        oldWidget.chartData.isNotEmpty &&
            widget.chartData.isNotEmpty &&
            (oldWidget.chartData.first.timestamp !=
                    widget.chartData.first.timestamp ||
                oldWidget.chartData.last.timestamp !=
                    widget.chartData.last.timestamp);

    // Check if timeframe changed
    final timeframeChanged = oldWidget.timeframe != widget.timeframe;

    if (dataChanged || timeframeChanged) {
      dev.log('📈 TRADING_CHART_CANVAS: Data or timeframe changed, rebuilding');
      _prepareData();
      setState(() {});
    }
  }

  void _prepareData() {
    dev.log(
        '📈 TRADING_CHART_CANVAS: Preparing data for ${widget.chartData.length} data points');

    if (widget.chartData.isEmpty) {
      _kLineData = [];
      return;
    }

    _kLineData = widget.chartData.map((dataPoint) {
      // Create KLineEntity from chart data point
      final Map<String, dynamic> data = {
        'open': dataPoint.open,
        'high': dataPoint.high,
        'low': dataPoint.low,
        'close': dataPoint.close,
        'vol': 0.0, // No volume for trading chart
        'count': dataPoint.timestamp.millisecondsSinceEpoch,
        'amount': 0.0, // No amount for trading chart
      };

      return KLineEntity.fromJson(data);
    }).toList();

    // Calculate the data for k_chart_plus
    DataUtil.calculate(_kLineData);

    dev.log(
        '📈 TRADING_CHART_CANVAS: Prepared ${_kLineData.length} KLineEntity objects');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // K Chart Plus Widget - Simple configuration for trading
          if (_kLineData.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: KChartWidget(
                _kLineData,
                ChartStyle(),
                _buildChartColors(context),
                isLine: false, // Always use candlestick for trading
                mainState: MainState.NONE, // No main indicators
                secondaryStateLi: const <SecondaryState>{}, // No secondary indicators
                fixedLength: 4, // More precision for trading
                timeFormat: TimeFormat.YEAR_MONTH_DAY,
                onLoadMore: (bool isLoadingMore) {
                  // TODO: Implement load more functionality if needed
                },
                maDayList: const [], // No moving averages
                volHidden: true, // Hide volume for trading chart
                showNowPrice: true,
                isOnDrag: (isDrag) {
                  // Handle drag state if needed
                },
                isTrendLine: false,
                xFrontPadding: 50, // Less padding for compact chart
              ),
            )
          else
            _buildEmptyChart(context),

          // Loading overlay
          if (widget.isLoading)
            Container(
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: context.priceUpColor,
                  strokeWidth: 2,
                ),
              ),
            ),

          // Price indicator overlay
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: _getPriceColor(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _getPriceColor(context), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.changePercent >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: _getPriceColor(context),
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '\$${widget.currentPrice.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: _getPriceColor(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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

  Widget _buildEmptyChart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 32,
            color: context.textTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            'No chart data available',
            style: TextStyle(
              color: context.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriceColor(BuildContext context) {
    if (widget.changePercent > 0) {
      return context.priceUpColor; // Green for positive
    } else if (widget.changePercent < 0) {
      return context.priceDownColor; // Red for negative
    } else {
      return context.textPrimary; // Theme primary for no change
    }
  }

  ChartColors _buildChartColors(BuildContext context) {
    return ChartColors(
      bgColor: context.theme.scaffoldBackgroundColor,
      defaultTextColor: context.textSecondary,
      gridColor: context.borderColor,
      hCrossColor: context.textPrimary,
      vCrossColor: context.textTertiary.withValues(alpha: 0.1),
      crossTextColor: context.textPrimary,
      selectBorderColor: context.textTertiary,
      selectFillColor: context.theme.scaffoldBackgroundColor,
      infoWindowTitleColor: context.textSecondary,
      infoWindowNormalColor: context.textPrimary,
      upColor: context.priceUpColor,
      dnColor: context.priceDownColor,
      ma5Color: Colors.yellow,
      ma10Color: Colors.orange,
      ma30Color: Colors.purple,
      volColor: context.textTertiary.withValues(alpha: 0.6),
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
}
