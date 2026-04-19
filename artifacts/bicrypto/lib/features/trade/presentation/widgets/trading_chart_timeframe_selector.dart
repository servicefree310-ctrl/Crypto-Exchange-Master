import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../chart/domain/entities/chart_entity.dart';
import '../../../../core/constants/api_constants.dart';

class TradingChartTimeframeSelector extends StatelessWidget {
  const TradingChartTimeframeSelector({
    super.key,
    required this.currentTimeframe,
    required this.onTimeframeChanged,
  });

  final ChartTimeframe currentTimeframe;
  final ValueChanged<ChartTimeframe> onTimeframeChanged;

  @override
  Widget build(BuildContext context) {
    // Get supported timeframes based on current exchange provider
    // Filter to shorter intervals suitable for trading context
    final allTimeframes = ChartTimeframe.getSupportedTimeframes(
      ApiConstants.exchangeProvider,
    );

    // Filter to trading-appropriate timeframes (shorter intervals)
    final timeframes = allTimeframes.where((tf) {
      return [
        ChartTimeframe.fiveMinutes,
        ChartTimeframe.fifteenMinutes,
        ChartTimeframe.thirtyMinutes,
        ChartTimeframe.oneHour,
        ChartTimeframe.fourHours,
        ChartTimeframe.oneDay,
      ].contains(tf);
    }).toList();

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: timeframes.map((timeframe) {
            final isSelected = timeframe == currentTimeframe;
            return GestureDetector(
              onTap: () => onTimeframeChanged(timeframe),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.priceUpColor.withValues(alpha: 0.2)
                      : context.inputBackground,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color:
                        isSelected ? context.priceUpColor : context.borderColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  timeframe.displayName, // Use the built-in displayName
                  style: TextStyle(
                    color: isSelected
                        ? context.priceUpColor
                        : context.textSecondary,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
