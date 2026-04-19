import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../domain/entities/market_data_entity.dart';
import 'realtime_mini_chart.dart';
import '../../../chart/presentation/pages/chart_page.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';
import '../../../../core/widgets/animated_price.dart';

class MarketListItem extends StatelessWidget {
  const MarketListItem({
    super.key,
    required this.marketData,
    this.onTap,
    this.compact = true, // Default to compact mode
  });

  final MarketDataEntity marketData;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // Use compact or normal design based on setting
    return compact ? _buildCompactItem(context) : _buildNormalItem(context);
  }

  Widget _buildCompactItem(BuildContext context) {
    final isPositive = marketData.isPositive;
    final changeColor =
        isPositive ? context.priceUpColor : context.priceDownColor;

    // Split symbol to get base and quote currencies
    final parts = marketData.symbol.split('/');
    final baseCurrency = parts.isNotEmpty ? parts[0] : marketData.currency;
    final quoteCurrency = parts.length > 1 ? parts[1] : 'USDT';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ??
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChartPage(
                  key: ValueKey(
                      'chart_${marketData.symbol}_${DateTime.now().millisecondsSinceEpoch}'),
                  symbol: marketData.symbol,
                  marketData: marketData,
                ),
              ),
            );
          },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: context.dividerColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Left: Symbol and Volume - No avatar, more space efficient
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Symbol row with improved styling - same line, different heights
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      // Base currency in prominent, taller style
                      Text(
                        baseCurrency.toUpperCase(),
                        style: context.bodyL.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: -0.2,
                          height: 1.0,
                        ),
                      ),
                      // Quote currency smaller, baseline aligned
                      Text(
                        '/$quoteCurrency',
                        style: context.labelM.copyWith(
                          color: context.textTertiary,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Compact badges aligned to baseline
                      if (marketData.isTrending)
                        Container(
                          margin: const EdgeInsets.only(left: 2),
                          child: Icon(
                            Icons.trending_up,
                            size: 10,
                            color: context.warningColor,
                          ),
                        ),
                      if (marketData.isHot)
                        Container(
                          margin: const EdgeInsets.only(left: 2),
                          child: Icon(
                            Icons.local_fire_department,
                            size: 10,
                            color: context.priceDownColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Volume information instead of pair name
                  Text(
                    'Vol ${_formatVolumeCompact(marketData.baseVolume)}',
                    style: context.labelS.copyWith(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Center: Compact Chart - Properly aligned with content
            Expanded(
              flex: 2,
              child: Container(
                height: 24, // Match the row height for proper alignment
                margin: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center, // Center the chart vertically
                child: SizedBox(
                  height: 24,
                  child: RealtimeMiniChart(
                    symbol: marketData.symbol,
                    color: changeColor,
                    height: 24,
                    showGlow: false,
                    strokeWidth: 1.2,
                    isCompact: true,
                  ),
                ),
              ),
            ),

            // Right: Enhanced Price Display - More space for better visibility
            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Price with better formatting
                  AnimatedPrice(
                    symbol: marketData.symbol,
                    price: marketData.price,
                    style: context.bodyM.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: -0.3,
                    ),
                    decimalPlaces: _getOptimalDecimalPlaces(marketData.price),
                  ),
                  const SizedBox(height: 2),
                  // Compact change percentage with better styling
                  AnimatedPercentageContainer(
                    symbol: marketData.symbol,
                    percentage: marketData.changePercent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    borderRadius: BorderRadius.circular(3),
                    backgroundOpacity: 0.08,
                    child: AnimatedPercentage(
                      symbol: marketData.symbol,
                      percentage: marketData.changePercent,
                      style: context.labelS.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                      showSign: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalItem(BuildContext context) {
    // Enhanced full-sized item design with better visual hierarchy
    final isPositive = marketData.isPositive;
    final changeColor =
        isPositive ? context.priceUpColor : context.priceDownColor;

    // Split symbol for better display
    final parts = marketData.symbol.split('/');
    final baseCurrency = parts.isNotEmpty ? parts[0] : marketData.currency;
    final quoteCurrency = parts.length > 1 ? parts[1] : 'USDT';

    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChartPage(
                  key: ValueKey(
                      'chart_${marketData.symbol}_${DateTime.now().millisecondsSinceEpoch}'),
                  symbol: marketData.symbol,
                  marketData: marketData,
                ),
              ),
            );
          },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Row - Enhanced Main Info
            Row(
              children: [
                // Left side - Improved Crypto Info
                Expanded(
                  flex: 4,
                  child: _buildEnhancedCryptoInfo(
                      context, baseCurrency, quoteCurrency),
                ),

                // Right side - Enhanced Price Info
                Expanded(
                  flex: 3,
                  child: _buildEnhancedPriceInfo(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bottom Row - Enhanced Chart and Stats
            Row(
              children: [
                // Enhanced Sparkline Chart
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: context.inputBackground.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RealtimeMiniChart(
                      symbol: marketData.symbol,
                      color: changeColor,
                      height: 60,
                      showGlow: true,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Enhanced Trading Stats
                Expanded(
                  flex: 2,
                  child: _buildEnhancedTradingStats(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedCryptoInfo(
      BuildContext context, String baseCurrency, String quoteCurrency) {
    return Row(
      children: [
        // Enhanced Crypto Icon with better gradients
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getCryptoColor(marketData.currency),
                _getCryptoColor(marketData.currency).withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _getCryptoColor(marketData.currency).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              baseCurrency
                  .toUpperCase()
                  .substring(0, math.min(3, baseCurrency.length)),
              style: context.labelL.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Enhanced Symbol and Name with better typography
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Symbol with enhanced styling
              Row(
                children: [
                  Text(
                    baseCurrency.toUpperCase(),
                    style: context.bodyL.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '/$quoteCurrency',
                    style: context.bodyM.copyWith(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // Enhanced badges row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (marketData.isTrending)
                        _buildEnhancedTrendingBadge(context),
                      if (marketData.isHot) _buildEnhancedHotBadge(context),
                      if (marketData.isEco) _buildEnhancedEcoBadge(context),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Currency name with volume
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _getCryptoName(marketData.currency),
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Vol ${_formatVolumeCompact(marketData.baseVolume)}',
                    style: context.labelS.copyWith(
                      color: context.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedPriceInfo(BuildContext context) {
    final isPositive = marketData.isPositive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Enhanced Current Price
        AnimatedPrice(
          symbol: marketData.symbol,
          price: marketData.price,
          style: context.bodyL.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            fontSize: 18,
          ),
          decimalPlaces: _getOptimalDecimalPlaces(marketData.price),
        ),

        const SizedBox(height: 6),

        // Enhanced Change Percentage with better styling
        AnimatedPercentageContainer(
          symbol: marketData.symbol,
          percentage: marketData.changePercent,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          borderRadius: BorderRadius.circular(8),
          backgroundOpacity: 0.15,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedTrendArrow(
                symbol: marketData.symbol,
                percentage: marketData.changePercent,
                size: 12,
              ),
              const SizedBox(width: 4),
              AnimatedPercentage(
                symbol: marketData.symbol,
                percentage: marketData.changePercent,
                style: context.labelM.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                showSign: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTradingStats(BuildContext context) {
    // Calculate additional stats
    final high24h = marketData.ticker?.high ?? 0.0;
    final low24h = marketData.ticker?.low ?? 0.0;
    final quoteVolume =
        marketData.ticker?.quoteVolume ?? marketData.quoteVolume;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 24h High
        if (high24h > 0)
          _buildEnhancedStatRow(
            context,
            '24h High',
            '\$${_formatPrice(high24h)}',
            context.priceUpColor,
          ),

        const SizedBox(height: 4),

        // 24h Low
        if (low24h > 0)
          _buildEnhancedStatRow(
            context,
            '24h Low',
            '\$${_formatPrice(low24h)}',
            context.priceDownColor,
          ),

        const SizedBox(height: 4),

        // Quote Volume
        _buildEnhancedStatRow(
          context,
          'Volume',
          _formatVolumeCompact(quoteVolume),
          context.textSecondary,
        ),

        const SizedBox(height: 6),

        // Market status indicator
        if (marketData.baseVolume > 1000000)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: context.priceUpColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: context.priceUpColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt,
                  size: 10,
                  color: context.priceUpColor,
                ),
                const SizedBox(width: 2),
                Text(
                  'High Vol',
                  style: context.labelS.copyWith(
                    color: context.priceUpColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEnhancedStatRow(
      BuildContext context, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.labelS.copyWith(
            color: context.textTertiary,
            fontWeight: FontWeight.w400,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: context.labelS.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // Enhanced badge designs
  Widget _buildEnhancedTrendingBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.warningColor.withValues(alpha: 0.2),
            context.warningColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.warningColor.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Icon(
        Icons.trending_up,
        size: 10,
        color: context.warningColor,
      ),
    );
  }

  Widget _buildEnhancedHotBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.priceDownColor.withValues(alpha: 0.2),
            context.priceDownColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.priceDownColor.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Icon(
        Icons.local_fire_department,
        size: 10,
        color: context.priceDownColor,
      ),
    );
  }

  Widget _buildEnhancedEcoBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.priceUpColor.withValues(alpha: 0.2),
            context.priceUpColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.priceUpColor.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        'ECO',
        style: context.labelS.copyWith(
          color: context.priceUpColor,
          fontWeight: FontWeight.w700,
          fontSize: 8,
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 100) {
      return price.toStringAsFixed(3);
    } else if (price >= 10) {
      return price.toStringAsFixed(4);
    } else if (price >= 1) {
      return price.toStringAsFixed(5);
    } else {
      return price.toStringAsFixed(6);
    }
  }

  Color _getCryptoColor(String currency) {
    switch (currency.toLowerCase()) {
      case 'btc':
        return const Color(0xFFF7931A);
      case 'eth':
        return const Color(0xFF627EEA);
      case 'bnb':
        return const Color(0xFFF3BA2F);
      case 'usdt':
        return const Color(0xFF26A17B);
      case 'usdc':
        return const Color(0xFF2775CA);
      case 'ada':
        return const Color(0xFF0033AD);
      case 'sol':
        return const Color(0xFF9945FF);
      case 'dot':
        return const Color(0xFFE6007A);
      case 'matic':
        return const Color(0xFF8247E5);
      case 'avax':
        return const Color(0xFFE84142);
      case 'xrp':
        return const Color(0xFF23292F);
      case 'ton':
        return const Color(0xFF0088CC);
      case 'sui':
        return const Color(0xFF4DA2FF);
      case 'pepe':
        return const Color(0xFF27AE60);
      default:
        return const Color(0xFF00D4AA);
    }
  }

  String _getCryptoName(String currency) {
    switch (currency.toLowerCase()) {
      case 'btc':
        return 'Bitcoin';
      case 'eth':
        return 'Ethereum';
      case 'bnb':
        return 'BNB';
      case 'usdt':
        return 'Tether';
      case 'usdc':
        return 'USD Coin';
      case 'ada':
        return 'Cardano';
      case 'sol':
        return 'Solana';
      case 'dot':
        return 'Polkadot';
      case 'matic':
        return 'Polygon';
      case 'avax':
        return 'Avalanche';
      case 'xrp':
        return 'Ripple';
      case 'ton':
        return 'Toncoin';
      case 'sui':
        return 'Sui';
      case 'pepe':
        return 'Pepe';
      case 'mana':
        return 'Decentraland';
      case 'ronin':
        return 'Ronin';
      case 'meme':
        return 'Memecoin';
      case 'ltc':
        return 'Litecoin';
      case 'sushi':
        return 'SushiSwap';
      default:
        return currency.toUpperCase();
    }
  }

  String _formatVolumeCompact(double volume) {
    if (volume >= 1e9) {
      return '${(volume / 1e9).toStringAsFixed(2)}B';
    } else if (volume >= 1e6) {
      return '${(volume / 1e6).toStringAsFixed(2)}M';
    } else if (volume >= 1e3) {
      return '${(volume / 1e3).toStringAsFixed(2)}K';
    } else {
      return volume.toString();
    }
  }

  int _getOptimalDecimalPlaces(double price) {
    if (price >= 1000) {
      return 2;
    } else if (price >= 100) {
      return 3;
    } else if (price >= 10) {
      return 4;
    } else if (price >= 1) {
      return 5;
    } else if (price >= 0.1) {
      return 6;
    } else if (price >= 0.01) {
      return 7;
    } else if (price >= 0.001) {
      return 8;
    } else {
      return 9;
    }
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.25),
          color.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final minValue = data.reduce(math.min);
    final maxValue = data.reduce(math.max);
    final range = maxValue - minValue;

    if (range == 0) return;

    final stepX = size.width / (data.length - 1);
    final padding = size.height * 0.1; // 10% padding

    // Start the path
    final firstY = (size.height - padding) -
        ((data[0] - minValue) / range) * (size.height - 2 * padding);
    path.moveTo(0, firstY);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, firstY);

    // Draw the line with smooth curves
    for (int i = 1; i < data.length; i++) {
      final x = i * stepX;
      final y = (size.height - padding) -
          ((data[i] - minValue) / range) * (size.height - 2 * padding);

      if (i == 1) {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        // Create smooth curves
        final prevX = (i - 1) * stepX;
        final prevY = (size.height - padding) -
            ((data[i - 1] - minValue) / range) * (size.height - 2 * padding);

        final cp1x = prevX + stepX * 0.3;
        final cp1y = prevY;
        final cp2x = x - stepX * 0.3;
        final cp2y = y;

        path.cubicTo(cp1x, cp1y, cp2x, cp2y, x, y);
        fillPath.cubicTo(cp1x, cp1y, cp2x, cp2y, x, y);
      }
    }

    // Complete the fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill first, then stroke
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Add glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
