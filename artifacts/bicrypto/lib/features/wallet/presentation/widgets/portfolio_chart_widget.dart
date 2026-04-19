import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/global_theme_extensions.dart';

class PortfolioChartWidget extends StatefulWidget {
  final List<double> chartData;
  final double currentValue;
  final double changeAmount;
  final double changePercentage;
  final bool isLoading;

  const PortfolioChartWidget({
    super.key,
    required this.chartData,
    required this.currentValue,
    required this.changeAmount,
    required this.changePercentage,
    this.isLoading = false,
  });

  @override
  State<PortfolioChartWidget> createState() => _PortfolioChartWidgetState();
}

class _PortfolioChartWidgetState extends State<PortfolioChartWidget> {
  List<FlSpot> _generateSpots() {
    if (widget.chartData.isEmpty) return [];

    return widget.chartData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.changeAmount >= 0;
    final chartColor =
        isPositive ? context.priceUpColor : context.priceDownColor;

    if (widget.isLoading) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(
            color: context.colors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final spots = _generateSpots();
    if (spots.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No chart data available',
            style: context.bodyM.copyWith(
              color: context.textTertiary,
            ),
          ),
        ),
      );
    }

    // Calculate min and max for Y axis
    final values = widget.chartData;
    var minY = values.reduce((a, b) => a < b ? a : b);
    var maxY = values.reduce((a, b) => a > b ? a : b);

    // Handle case where all values are the same
    if (minY == maxY) {
      // Add some variation to avoid division by zero
      minY = minY * 0.99;
      maxY = maxY * 1.01;
      // If value is 0, use a small range
      if (minY == 0 && maxY == 0) {
        minY = -1;
        maxY = 1;
      }
    } else {
      minY = minY * 0.98;
      maxY = maxY * 1.02;
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.only(
        left: 16,
        right: 24,
        top: 16,
        bottom: 8,
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 3 == 0 ? 1 : (maxY - minY) / 3,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: context.borderColor.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  // Show labels for first, middle and last
                  final index = value.toInt();
                  if (index == 0) {
                    return Text(
                      '24h ago',
                      style: context.bodyS.copyWith(
                        color: context.textTertiary,
                        fontSize: 10,
                      ),
                    );
                  } else if (index == spots.length - 1) {
                    return Text(
                      'Now',
                      style: context.bodyS.copyWith(
                        color: context.textTertiary,
                        fontSize: 10,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxY - minY) / 3 == 0 ? 1 : (maxY - minY) / 3,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatValue(value),
                    style: context.bodyS.copyWith(
                      color: context.textTertiary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: spots.length - 1.0,
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              color: chartColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    chartColor.withValues(alpha: 0.2),
                    chartColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: context.cardBackground,
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipBorder: BorderSide(
                color: context.borderColor,
                width: 1,
              ),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  return LineTooltipItem(
                    '\$${_formatValue(touchedSpot.y)}',
                    context.bodyM.copyWith(
                      color: chartColor,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((spotIndex) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: chartColor.withValues(alpha: 0.3),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                  ),
                  FlDotData(
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: context.cardBackground,
                        strokeWidth: 2,
                        strokeColor: chartColor,
                      );
                    },
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}
