import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/widgets/animated_price.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/services/screenshot_service.dart';
import '../../../../injection/injection.dart';
import '../../../market/domain/entities/market_data_entity.dart';
import '../../domain/entities/chart_entity.dart';
import '../bloc/chart_bloc.dart';
import '../../../../core/constants/api_constants.dart';

class ChartHeader extends StatefulWidget {
  const ChartHeader({
    super.key,
    required this.marketData,
    required this.onBack,
    this.onFavorite,
    this.onShare,
    this.isLandscape = false,
    this.showFullStats = true,
    this.screenshotKey,
  });

  final MarketDataEntity marketData;
  final VoidCallback onBack;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final bool isLandscape;
  final bool showFullStats;
  final GlobalKey? screenshotKey;

  @override
  State<ChartHeader> createState() => _ChartHeaderState();
}

class _ChartHeaderState extends State<ChartHeader> {
  final FavoritesService _favoritesService = getIt<FavoritesService>();
  final ScreenshotService _screenshotService = getIt<ScreenshotService>();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  @override
  void didUpdateWidget(ChartHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.marketData.symbol != widget.marketData.symbol) {
      _loadFavoriteStatus();
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.marketData.symbol);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      // Haptic feedback
      HapticFeedback.lightImpact();

      // Toggle favorite status
      await _favoritesService.toggleFavorite(widget.marketData.symbol);

      // Update UI
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }

      // Call original callback if provided
      widget.onFavorite?.call();
    } catch (e) {
      dev.log('❌ CHART_HEADER: Error toggling favorite: $e');
    }
  }

  Future<void> _shareScreenshot() async {
    try {
      // Haptic feedback
      HapticFeedback.selectionClick();

      if (widget.screenshotKey != null) {
        final filePath = await _screenshotService.captureToFile(
          key: widget.screenshotKey!,
          fileName:
              'chart_${widget.marketData.symbol}_${DateTime.now().millisecondsSinceEpoch}.png',
        );

        if (filePath != null) {
          // For now, copy the path to clipboard as fallback
          // In production, you would integrate with the device's native share
          await Clipboard.setData(ClipboardData(text: filePath));
          dev.log('📸 Screenshot saved: $filePath');

          // Additional haptic feedback for successful capture
          HapticFeedback.mediumImpact();
        }
      }

      // Call original callback if provided
      widget.onShare?.call();
    } catch (e) {
      dev.log('❌ CHART_HEADER: Error sharing screenshot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLandscape
        ? _buildLandscapeHeader(context)
        : _buildPortraitHeader(context);
  }

  Widget _buildPortraitHeader(BuildContext context) {
    return BlocBuilder<ChartBloc, ChartState>(
      builder: (context, chartState) {
        // Use real-time ticker data if available, fallback to passed marketData
        MarketDataEntity currentData = widget.marketData;

        if (chartState is ChartLoaded && chartState.tickerData != null) {
          // Use real-time ticker data from ChartBloc
          currentData = chartState.tickerData!;
          // dev.log(
          //     '📱 CHART_HEADER: Using REAL-TIME ticker data - Price: \$${currentData.price}, Change: ${currentData.changePercent}%');

          if (currentData.ticker != null) {
            // dev.log(
            //     '📱 CHART_HEADER: Ticker details - High: ${currentData.ticker!.high}, Low: ${currentData.ticker!.low}');
            // dev.log(
            //     '📱 CHART_HEADER: Volume details - Base: ${currentData.ticker!.baseVolume}, Quote: ${currentData.ticker!.quoteVolume}');
          }
        } else {
          // dev.log(
          //     '📱 CHART_HEADER: Using fallback marketData - Price: \$${currentData.price}');
        }

        // Extract change percentage for animations
        final changePercent = currentData.changePercent;

        return Container(
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: context.borderColor.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Compact navigation bar
                _buildCompactNavBar(context, currentData),

                // Single row with all info
                _buildCompactInfoRow(context, currentData),

                // Integrated timeframe selector
                if (chartState is ChartLoaded)
                  _buildTimeframeSelector(context, chartState.timeframe),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLandscapeHeader(BuildContext context) {
    return BlocBuilder<ChartBloc, ChartState>(
      builder: (context, chartState) {
        // Use real-time ticker data if available, fallback to passed marketData
        MarketDataEntity currentData = widget.marketData;

        if (chartState is ChartLoaded && chartState.tickerData != null) {
          // Use real-time ticker data from ChartBloc
          currentData = chartState.tickerData!;
          // dev.log(
          //     '📱 CHART_HEADER_LANDSCAPE: Using REAL-TIME ticker data - Price: \$${currentData.price}, Change: ${currentData.changePercent}%');
        } else {
          // dev.log(
          //     '📱 CHART_HEADER_LANDSCAPE: Using fallback marketData - Price: \$${currentData.price}');
        }

        // Get real-time ticker data if available, fallback to chart data
        final currentPrice = currentData.price;
        final changePercent = currentData.changePercent;
        final baseVolume = currentData.baseVolume;

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: context.cardBackground,
            border: Border(
              bottom: BorderSide(
                color: context.borderColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Left side - Essential trading info (takes priority)
              Flexible(
                flex: 6,
                child: Row(
                  children: [
                    // Symbol - Fixed width to prevent cutting
                    Container(
                      constraints:
                          const BoxConstraints(minWidth: 80, maxWidth: 120),
                      child: Text(
                        widget.marketData.symbol,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Price - Priority display with adequate space and animation
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AnimatedPrice(
                          symbol: widget.marketData.symbol,
                          price: currentPrice,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          decimalPlaces: _getPriceDecimalPlaces(currentPrice),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Change - Compact but visible with animation
                    Container(
                      constraints: const BoxConstraints(minWidth: 60),
                      child: AnimatedPercentageContainer(
                        symbol: widget.marketData.symbol,
                        percentage: changePercent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        borderRadius: BorderRadius.circular(4),
                        backgroundOpacity: 0.15,
                        child: Center(
                          child: AnimatedPercentage(
                            symbol: widget.marketData.symbol,
                            percentage: changePercent,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            showSign: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Center - Additional market info (show only when trading panel is hidden)
              if (widget.showFullStats)
                Flexible(
                  flex: 3,
                  child: _buildLandscapeMarketInfo(context, currentData),
                ),

              const SizedBox(width: 8),

              // Right - Timeframe selector (essential for trading)
              if (chartState is ChartLoaded)
                Flexible(
                  flex: 4,
                  child: _buildTimeframeSelector(context, chartState.timeframe,
                      isCompact: true),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Build landscape market info panel
  Widget _buildLandscapeMarketInfo(
      BuildContext context, MarketDataEntity currentData) {
    // Get ticker data with fallback values
    final high24h = currentData.ticker?.high ?? 0.0;
    final low24h = currentData.ticker?.low ?? 0.0;
    final baseVolume = currentData.ticker?.baseVolume ?? currentData.baseVolume;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // High
        _buildLandscapeInfoItem(
          context,
          'H',
          _formatCompactPrice(high24h),
          context.priceUpColor,
        ),
        const SizedBox(width: 6),
        // Low
        _buildLandscapeInfoItem(
          context,
          'L',
          _formatCompactPrice(low24h),
          context.priceDownColor,
        ),
        const SizedBox(width: 6),
        // Volume
        _buildLandscapeInfoItem(
          context,
          'Vol',
          _formatVolume(baseVolume),
          context.textSecondary,
        ),
      ],
    );
  }

  /// Build individual landscape info item
  Widget _buildLandscapeInfoItem(
      BuildContext context, String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.textTertiary,
            fontSize: 7,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Build integrated timeframe selector
  Widget _buildTimeframeSelector(
    BuildContext context,
    ChartTimeframe currentTimeframe, {
    bool isCompact = false,
  }) {
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
        color: isCompact ? context.inputBackground : context.inputBackground,
        borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
        border: Border.all(
          color: isCompact ? context.borderColor : context.borderColor,
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
              onTap: () {
                // Trigger timeframe change in ChartBloc
                // dev.log('🎯 TIMEFRAME_SELECTOR: Changing to ${timeframe.value}');
                try {
                  final chartBloc = context.read<ChartBloc>();
                  if (!chartBloc.isClosed) {
                    chartBloc.add(ChartTimeframeChanged(timeframe: timeframe));
                  }
                } catch (e) {
                  // dev.log('⚠️ TIMEFRAME_SELECTOR: Error changing timeframe: $e');
                }
              },
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

  Widget _buildCompactNavBar(
      BuildContext context, MarketDataEntity currentData) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: widget.onBack,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: context.inputBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: context.textPrimary,
                size: 14,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Symbol with currency and pair
          Expanded(
            child: Row(
              children: [
                Text(
                  currentData.currency.toUpperCase(),
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  '/${currentData.pair.toUpperCase()}',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                // Status badges
                if (currentData.isTrending)
                  _buildStatusBadge(context, '📈', context.warningColor),
                if (currentData.isHot)
                  _buildStatusBadge(context, '🔥', context.priceDownColor),
                if (currentData.isEco)
                  _buildStatusBadge(context, '🌱', context.priceUpColor),
              ],
            ),
          ),

          // Compact action buttons - Remove bell icon, make heart functional, make share take screenshot
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCompactButton(
                context,
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                _toggleFavorite,
                isActive: _isFavorite,
              ),
              const SizedBox(width: 4),
              _buildCompactButton(
                  context, Icons.share_outlined, _shareScreenshot),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        icon,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  Widget _buildCompactInfoRow(
      BuildContext context, MarketDataEntity currentData) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          // Left: Price and change - takes expandable space
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price with adaptive font size and animated color - single line
                AnimatedPrice(
                  symbol: currentData.symbol,
                  price: currentData.price,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1,
                  ),
                  decimalPlaces: _getPriceDecimalPlaces(currentData.price),
                ),
                const SizedBox(height: 3),

                // Change in compact row with animated styling
                AnimatedPercentageContainer(
                  symbol: currentData.symbol,
                  percentage: currentData.changePercent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  borderRadius: BorderRadius.circular(4),
                  backgroundOpacity: 0.1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedTrendArrow(
                        symbol: currentData.symbol,
                        percentage: currentData.changePercent,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      AnimatedPercentage(
                        symbol: currentData.symbol,
                        percentage: currentData.changePercent,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        showSign: true,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '24h',
                        style: TextStyle(
                          color: context.textTertiary,
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Flexible spacing between price and stats
          const SizedBox(width: 16),

          // Right: Compact stats grid - balanced positioning
          Expanded(
            flex: 2,
            child: _buildCompactStatsGrid(context, currentData),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatsGrid(
      BuildContext context, MarketDataEntity currentData) {
    // Get ticker data with fallback values
    final high24h = currentData.ticker?.high ?? 0.0;
    final low24h = currentData.ticker?.low ?? 0.0;
    final baseVolume = currentData.ticker?.baseVolume ?? currentData.baseVolume;
    final quoteVolume =
        currentData.ticker?.quoteVolume ?? currentData.quoteVolume;

    // Extract currency symbols for volume labels
    final parts = currentData.symbol.split('/');
    final baseCurrency = parts.isNotEmpty ? parts[0] : 'BTC';
    final quoteCurrency = parts.length > 1 ? parts[1] : 'USDT';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, // Right-align the entire grid
      mainAxisSize: MainAxisSize.min,
      children: [
        // First row of stats - High and Low
        Row(
          mainAxisSize: MainAxisSize.min, // Compact row
          children: [
            _buildMicroStat(
              context,
              'High (24h)',
              _formatCompactPrice(high24h),
              context.priceUpColor,
            ),
            const SizedBox(width: 12), // Space between stats
            _buildMicroStat(
              context,
              'Low (24h)',
              _formatCompactPrice(low24h),
              context.priceDownColor,
            ),
          ],
        ),
        const SizedBox(height: 3),

        // Second row of stats - Base Volume and Quote Volume
        Row(
          mainAxisSize: MainAxisSize.min, // Compact row
          children: [
            _buildMicroStat(
              context,
              'Vol $baseCurrency',
              _formatVolume(baseVolume),
              context.textSecondary,
            ),
            const SizedBox(width: 12), // Space between stats
            _buildMicroStat(
              context,
              'Vol $quoteCurrency',
              _formatVolume(quoteVolume),
              context.textSecondary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactButton(
      BuildContext context, IconData icon, VoidCallback onTap,
      {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isActive
              ? context.priceUpColor.withValues(alpha: 0.2)
              : context.inputBackground,
          borderRadius: BorderRadius.circular(5),
          border: isActive
              ? Border.all(
                  color: context.priceUpColor.withValues(alpha: 0.5),
                  width: 1,
                )
              : null,
        ),
        child: Icon(
          icon,
          color: isActive ? context.priceUpColor : context.textSecondary,
          size: 12,
        ),
      ),
    );
  }

  Widget _buildMicroStat(
      BuildContext context, String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, // Right-align text
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.textTertiary,
            fontSize: 8,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  String _formatMainPrice(double price) {
    // Format price based on value range for better readability
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 1) {
      return price.toStringAsFixed(4);
    } else if (price >= 0.01) {
      return price.toStringAsFixed(6);
    } else {
      return price.toStringAsFixed(8);
    }
  }

  String _formatCompactPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(2)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(2)}K';
    } else if (price >= 1) {
      return price.toStringAsFixed(2);
    } else {
      return price.toStringAsFixed(4);
    }
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(1)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }

  String _formatPrice(double price) {
    if (price >= 1) {
      return price.toStringAsFixed(2);
    } else if (price >= 0.01) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(6);
    }
  }

  int _getPriceDecimalPlaces(double price) {
    if (price >= 1000) {
      return 2;
    } else if (price >= 1) {
      return 4;
    } else if (price >= 0.01) {
      return 6;
    } else {
      return 8;
    }
  }
}
