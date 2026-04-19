import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/chart_entity.dart';

class ChartToolsBarLandscape extends StatelessWidget {
  const ChartToolsBarLandscape({
    super.key,
    required this.chartType,
    required this.activeIndicators,
    required this.onChartTypeChanged,
    required this.onIndicatorToggled,
    required this.onOrderBookToggled,
    required this.onTradingInfoToggled,
    this.showOrderBook = false,
    this.showTradingInfo = false,
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
  final bool showOrderBook;
  final bool showTradingInfo;
  final bool volumeVisible;
  final String mainState;
  final VoidCallback? onVolumeToggled;
  final ValueChanged<String>? onMainStateChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44, // More compact height
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: context.borderColor.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Chart type selector
            _buildCompactChartTypeSelector(context),

            const SizedBox(width: 6),

            // Volume toggle
            _buildCompactButton(
              context,
              icon: Icons.bar_chart,
              isActive: volumeVisible,
              onTap: onVolumeToggled ?? () {},
              tooltip: 'Volume',
            ),

            const SizedBox(width: 6),

            // Main states (horizontal layout)
            ..._buildMainStateButtons(context),

            const SizedBox(width: 6),

            // Indicators (horizontal layout - now with context)
            ..._buildIndicatorButtons(context),

            const SizedBox(width: 12),

            // Right side controls
            _buildCompactButton(
              context,
              icon: Icons.format_list_bulleted,
              isActive: showOrderBook,
              onTap: onOrderBookToggled,
              tooltip: 'Order Book',
            ),

            const SizedBox(width: 6),

            _buildCompactButton(
              context,
              icon: Icons.show_chart,
              isActive: showTradingInfo,
              onTap: onTradingInfoToggled,
              tooltip: 'Trading Info',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactChartTypeSelector(BuildContext context) {
    return PopupMenuButton<ChartType>(
      initialValue: chartType,
      onSelected: onChartTypeChanged,
      color: context.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: context.borderColor, width: 0.5),
      ),
      offset: const Offset(0, -8),
      itemBuilder: (context) => ChartType.values.map((type) {
        return PopupMenuItem<ChartType>(
          value: type,
          height: 36,
          child: Row(
            children: [
              Icon(
                _getChartTypeIcon(type),
                color: type == chartType
                    ? context.priceUpColor
                    : context.textSecondary,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                type.displayName,
                style: TextStyle(
                  color: type == chartType
                      ? context.priceUpColor
                      : context.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: context.inputBackground,
          borderRadius: BorderRadius.circular(4),
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
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              _getShortDisplayName(chartType),
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.expand_more,
              color: context.textSecondary,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMainStateButtons(BuildContext context) {
    final states = [
      {'value': 'NONE', 'label': 'NONE', 'icon': Icons.remove},
      {'value': 'MA', 'label': 'MA', 'icon': Icons.trending_up},
      {'value': 'BOLL', 'label': 'BOLL', 'icon': Icons.show_chart},
    ];

    return states.map((state) {
      final isActive = mainState == state['value'];
      return Container(
        margin: const EdgeInsets.only(right: 6),
        child: _buildCompactButton(
          context,
          icon: state['icon'] as IconData,
          isActive: isActive,
          onTap: () => onMainStateChanged?.call(state['value'] as String),
          tooltip: state['label'] as String,
          label: state['label'] as String,
        ),
      );
    }).toList();
  }

  List<Widget> _buildIndicatorButtons(BuildContext context) {
    // Available indicators
    final indicators = [
      {
        'name': 'RSI',
        'icon': Icons.timeline,
        'tooltip': 'Relative Strength Index'
      },
      {
        'name': 'MACD',
        'icon': Icons.multiline_chart,
        'tooltip': 'Moving Average Convergence Divergence'
      },
      {'name': 'KDJ', 'icon': Icons.analytics, 'tooltip': 'KDJ Indicator'},
      {'name': 'WR', 'icon': Icons.show_chart, 'tooltip': 'Williams %R'},
      {
        'name': 'CCI',
        'icon': Icons.waves,
        'tooltip': 'Commodity Channel Index'
      },
    ];

    // Single button that opens indicator selection dialog
    return [
      Container(
        margin: const EdgeInsets.only(right: 6),
        child: Tooltip(
          message: 'Technical Indicators',
          child: GestureDetector(
            onTap: () => _showIndicatorsDialog(context, indicators),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: activeIndicators.isNotEmpty
                    ? context.priceUpColor.withValues(alpha: 0.15)
                    : context.inputBackground,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: activeIndicators.isNotEmpty
                      ? context.priceUpColor.withValues(alpha: 0.3)
                      : context.borderColor,
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: activeIndicators.isNotEmpty
                        ? context.priceUpColor
                        : context.textSecondary,
                    size: 12,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    activeIndicators.isNotEmpty
                        ? '${activeIndicators.length}'
                        : 'IND',
                    style: TextStyle(
                      color: activeIndicators.isNotEmpty
                          ? context.priceUpColor
                          : context.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  // Show indicator selection dialog with the passed context
  void _showIndicatorsDialog(
      BuildContext context, List<Map<String, dynamic>> indicators) {
    final availableIndicators =
        indicators.map((i) => i['name'] as String).toList();
    final localActiveIndicators = Set<String>.from(activeIndicators);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: context.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: context.borderColor),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              title: Text(
                'Technical Indicators',
                style: TextStyle(color: context.textPrimary, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: indicators.map((indicator) {
                    final name = indicator['name'] as String;
                    final isActive = localActiveIndicators.contains(name);

                    return ListTile(
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      visualDensity: VisualDensity.compact,
                      leading: Icon(
                        indicator['icon'] as IconData,
                        color: isActive
                            ? context.priceUpColor
                            : context.textSecondary,
                        size: 16,
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          color: isActive
                              ? context.priceUpColor
                              : context.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Switch(
                        value: isActive,
                        activeTrackColor: context.priceUpColor.withValues(alpha: 0.5),
                        activeColor: Colors.white,
                        inactiveTrackColor: context.inputBackground,
                        onChanged: (value) {
                          setModalState(() {
                            if (value) {
                              localActiveIndicators.add(name);
                            } else {
                              localActiveIndicators.remove(name);
                            }
                          });
                        },
                      ),
                      onTap: () {
                        setModalState(() {
                          if (isActive) {
                            localActiveIndicators.remove(name);
                          } else {
                            localActiveIndicators.add(name);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: context.textSecondary),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () {
                      // Apply all changes at once when user confirms
                      for (final indicator in availableIndicators) {
                        final wasActive = activeIndicators.contains(indicator);
                        final isNowActive =
                            localActiveIndicators.contains(indicator);

                        if (wasActive != isNowActive) {
                          onIndicatorToggled(indicator);
                        }
                      }
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Ink(
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
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
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCompactButton(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
    String? label,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: label != null ? 6 : 4,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? context.priceUpColor.withValues(alpha: 0.15)
                : context.inputBackground,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isActive
                  ? context.priceUpColor.withValues(alpha: 0.3)
                  : context.borderColor,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? context.priceUpColor : context.textSecondary,
                size: 12,
              ),
              if (label != null) ...[
                const SizedBox(width: 3),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        isActive ? context.priceUpColor : context.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
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

extension ChartTypeExtensionLandscape on ChartType {
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
