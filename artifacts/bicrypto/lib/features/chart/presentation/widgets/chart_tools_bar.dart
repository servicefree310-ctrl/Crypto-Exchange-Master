import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/chart_entity.dart';

class ChartToolsBar extends StatelessWidget {
  const ChartToolsBar({
    super.key,
    required this.chartType,
    required this.activeIndicators,
    required this.onChartTypeChanged,
    required this.onIndicatorToggled,
    required this.onOrderBookToggled,
    required this.onTradingInfoToggled,
    required this.onRecentTradesToggled,
    this.showOrderBook = false,
    this.showTradingInfo = false,
    this.showRecentTrades = false,
    this.volumeVisible = true,
    this.mainState = 'NONE',
    this.onVolumeToggled,
    this.onMainStateChanged,
  });

  final ChartType chartType;
  final Set<String> activeIndicators;
  final ValueChanged<ChartType> onChartTypeChanged;
  final ValueChanged<String> onIndicatorToggled;
  final VoidCallback onOrderBookToggled;
  final VoidCallback onTradingInfoToggled;
  final VoidCallback onRecentTradesToggled;
  final bool showOrderBook;
  final bool showTradingInfo;
  final bool showRecentTrades;
  final bool volumeVisible;
  final String mainState;
  final VoidCallback? onVolumeToggled;
  final ValueChanged<String>? onMainStateChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: context.borderColor.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Chart type and indicators section
          Expanded(
            child: Row(
              children: [
                // Chart type selector
                _buildChartTypeSelector(context),

                const SizedBox(width: 8),

                // Volume toggle button
                _buildVolumeButton(context),

                const SizedBox(width: 8),

                // Main states button (MA/BOLL/NONE)
                _buildMainStatesButton(context),

                const SizedBox(width: 8),

                // Indicators button
                _buildIndicatorsButton(context),
              ],
            ),
          ),

          // Right side actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Order Book button (first/default)
              _buildBottomSheetToggleButton(
                context,
                icon: Icons.layers_outlined,
                isActive: showOrderBook,
                onTap: onOrderBookToggled,
              ),

              const SizedBox(width: 8),

              // Recent Trades button
              _buildBottomSheetToggleButton(
                context,
                icon: Icons.compare_arrows,
                isActive: showRecentTrades,
                onTap: onRecentTradesToggled,
              ),

              const SizedBox(width: 8),

              // Trading Info button
              _buildBottomSheetToggleButton(
                context,
                icon: Icons.info_outline,
                isActive: showTradingInfo,
                onTap: onTradingInfoToggled,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector(BuildContext context) {
    return PopupMenuButton<ChartType>(
      initialValue: chartType,
      onSelected: onChartTypeChanged,
      color: context.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: context.borderColor, width: 0.5),
      ),
      offset: const Offset(0, -8),
      itemBuilder: (context) => ChartType.values.map((type) {
        return PopupMenuItem<ChartType>(
          value: type,
          height: 40,
          child: Row(
            children: [
              Icon(
                _getChartTypeIcon(type),
                color: type == chartType
                    ? context.priceUpColor
                    : context.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                type.displayName,
                style: TextStyle(
                  color: type == chartType
                      ? context.priceUpColor
                      : context.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: context.inputBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: context.borderColor,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getChartTypeIcon(chartType),
              color: context.priceUpColor,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              _getShortDisplayName(chartType),
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              color: context.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorsButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showIndicatorsMenu(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: activeIndicators.isNotEmpty
              ? context.priceUpColor.withValues(alpha: 0.15)
              : context.inputBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: activeIndicators.isNotEmpty
                ? context.priceUpColor.withValues(alpha: 0.3)
                : context.borderColor,
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.analytics_outlined,
                color: activeIndicators.isNotEmpty
                    ? context.priceUpColor
                    : context.textSecondary,
                size: 16,
              ),
            ),
            if (activeIndicators.isNotEmpty)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: context.priceUpColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${activeIndicators.length}',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showIndicatorsMenu(BuildContext context) {
    final availableIndicators = ['RSI', 'MACD', 'KDJ', 'WR', 'CCI'];

    // Create a local copy of active indicators for manipulation within the modal
    final localActiveIndicators = Set<String>.from(activeIndicators);

    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close and apply buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Technical Indicators',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Apply button that commits all changes at once
                  GestureDetector(
                    onTap: () {
                      // Apply all changes at once and close the modal
                      Navigator.pop(context);

                      // Compare sets to find what needs to be toggled
                      for (final indicator in availableIndicators) {
                        final wasActive = activeIndicators.contains(indicator);
                        final isNowActive =
                            localActiveIndicators.contains(indicator);

                        if (wasActive != isNowActive) {
                          // Only toggle indicators that changed
                          onIndicatorToggled(indicator);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.priceUpColor,
                            context.priceUpColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: context.priceUpColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check,
                            color: context.textPrimary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Apply',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: availableIndicators.map((indicator) {
                  // Use the local copy for UI state
                  final isActive = localActiveIndicators.contains(indicator);
                  return GestureDetector(
                    onTap: () {
                      // Update local state only, without triggering BLoC events yet
                      setModalState(() {
                        if (isActive) {
                          localActiveIndicators.remove(indicator);
                        } else {
                          localActiveIndicators.add(indicator);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? context.priceUpColor.withValues(alpha: 0.1)
                            : context.inputBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? context.priceUpColor
                              : context.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        indicator,
                        style: TextStyle(
                          color: isActive
                              ? context.priceUpColor
                              : context.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeButton(BuildContext context) {
    return GestureDetector(
      onTap: onVolumeToggled,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: volumeVisible
              ? context.priceUpColor.withValues(alpha: 0.15)
              : context.inputBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: volumeVisible
                ? context.priceUpColor.withValues(alpha: 0.3)
                : context.borderColor,
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.bar_chart,
          color: volumeVisible ? context.priceUpColor : context.textSecondary,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildMainStatesButton(BuildContext context) {
    final isActive = mainState != 'NONE';

    return GestureDetector(
      onTap: () => _showMainStatesMenu(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? context.priceUpColor.withValues(alpha: 0.15)
              : context.inputBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive
                ? context.priceUpColor.withValues(alpha: 0.3)
                : context.borderColor,
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.timeline,
                color: isActive ? context.priceUpColor : context.textSecondary,
                size: 16,
              ),
            ),
            if (isActive)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.priceUpColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      mainState == 'MA' ? 'M' : 'B',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMainStatesMenu(BuildContext context) {
    final availableStates = [
      {'value': 'NONE', 'label': 'None', 'description': 'No overlay'},
      {'value': 'MA', 'label': 'Moving Averages', 'description': 'MA(5,10,20)'},
      {
        'value': 'BOLL',
        'label': 'Bollinger Bands',
        'description': 'Upper/Lower bands'
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Main Chart Overlays',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: availableStates.map((state) {
                final isActive = mainState == state['value'];
                return GestureDetector(
                  onTap: () {
                    onMainStateChanged?.call(state['value'] as String);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isActive
                          ? context.priceUpColor.withValues(alpha: 0.1)
                          : context.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive
                            ? context.priceUpColor
                            : context.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (isActive) ...[
                          Icon(
                            Icons.check_circle,
                            color: context.priceUpColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state['label'] as String,
                                style: TextStyle(
                                  color: isActive
                                      ? context.priceUpColor
                                      : context.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state['description'] as String,
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawingToolsButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Show drawing tools
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: context.inputBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: context.borderColor,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_outlined,
              color: context.textSecondary,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'DRAW',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetToggleButton(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? context.warningColor.withValues(alpha: 0.15)
              : context.inputBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive
                ? context.warningColor.withValues(alpha: 0.3)
                : context.borderColor,
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? context.warningColor : context.textSecondary,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildCompactToggleButton(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? context.priceUpColor.withValues(alpha: 0.15)
              : context.inputBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive
                ? context.priceUpColor.withValues(alpha: 0.3)
                : context.borderColor,
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? context.priceUpColor : context.textSecondary,
          size: 16,
        ),
      ),
    );
  }

  IconData _getChartTypeIcon(ChartType type) {
    switch (type) {
      case ChartType.candlestick:
        return Icons.candlestick_chart;
      case ChartType.line:
        return Icons.show_chart;
      case ChartType.area:
        return Icons.area_chart;
      case ChartType.depth:
        return Icons.layers;
    }
  }

  String _getShortDisplayName(ChartType type) {
    switch (type) {
      case ChartType.candlestick:
        return 'CANDLE';
      case ChartType.line:
        return 'LINE';
      case ChartType.area:
        return 'AREA';
      case ChartType.depth:
        return 'DEPTH';
    }
  }
}

extension ChartTypeExtension on ChartType {
  String get displayName {
    switch (this) {
      case ChartType.candlestick:
        return 'Candlestick';
      case ChartType.line:
        return 'Line Chart';
      case ChartType.area:
        return 'Area Chart';
      case ChartType.depth:
        return 'Depth Chart';
    }
  }
}
