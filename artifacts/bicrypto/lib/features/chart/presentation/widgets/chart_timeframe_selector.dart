import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/chart_entity.dart';
import '../../../../core/constants/api_constants.dart';

class ChartTimeframeSelector extends StatelessWidget {
  const ChartTimeframeSelector({
    super.key,
    required this.currentTimeframe,
    required this.onTimeframeChanged,
    this.isCompact = false,
  });

  final ChartTimeframe currentTimeframe;
  final ValueChanged<ChartTimeframe> onTimeframeChanged;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    // Get supported timeframes based on current exchange provider
    final timeframes = ChartTimeframe.getSupportedTimeframes(
      ApiConstants.exchangeProvider,
    );

    return Container(
      height: isCompact ? 28 : 36,
      margin: isCompact
          ? const EdgeInsets.symmetric(horizontal: 2, vertical: 0)
          : const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
        boxShadow: !isCompact
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 4 : 6,
          vertical: isCompact ? 2 : 3,
        ),
        child: Row(
          children: timeframes.map((timeframe) {
            final isSelected = timeframe == currentTimeframe;
            return GestureDetector(
              onTap: () => onTimeframeChanged(timeframe),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: EdgeInsets.only(right: isCompact ? 4 : 3),
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 8 : 12,
                  vertical: isCompact ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.priceUpColor.withValues(alpha: 0.4),
                            context.priceUpColor.withValues(alpha: 0.3),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.inputBackground.withValues(alpha: 0.6),
                            context.inputBackground.withValues(alpha: 0.8),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(isCompact ? 4 : 6),
                  border: Border.all(
                    color: isSelected
                        ? context.priceUpColor.withValues(alpha: 0.8)
                        : Colors.transparent,
                    width: isSelected ? 1.2 : 0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: context.priceUpColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  timeframe.displayName,
                  style: TextStyle(
                    color: isSelected
                        ? context.textPrimary
                        : context.textSecondary,
                    fontSize: isCompact ? 11 : 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    height: 1.0,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
