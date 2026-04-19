import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/trading_pair_entity.dart';
import 'package:mobile/core/widgets/animated_price.dart';

class TradingPairListItem extends StatelessWidget {
  const TradingPairListItem({
    super.key,
    required this.pair,
    required this.onTap,
    this.isSelected = false,
  });

  final TradingPairEntity pair;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isPositive = pair.isPositive;
    final changeColor =
        isPositive ? context.priceUpColor : context.priceDownColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.priceUpColor.withValues(alpha: 0.08)
              : context.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: context.priceUpColor.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            // Crypto Icon
            _buildCryptoIcon(context),

            const SizedBox(width: 10),

            // Symbol and pair info
            Expanded(
              flex: 3,
              child: _buildSymbolInfo(context),
            ),

            // Price section
            Expanded(
              flex: 2,
              child: _buildPriceSection(context),
            ),

            // Change and actions
            _buildChangeAndActions(context, changeColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoIcon(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCryptoColor(pair.currency),
            _getCryptoColor(pair.currency).withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _getCryptoColor(pair.currency).withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          pair.currency
              .toUpperCase()
              .substring(0, math.min(2, pair.currency.length)),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSymbolInfo(BuildContext context) {
    final parts = pair.symbol.split('/');
    final baseCurrency = parts.isNotEmpty ? parts[0] : pair.currency;
    final quoteCurrency = parts.length > 1 ? parts[1] : 'USDT';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Full pair symbol on top line
        Row(
          children: [
            Flexible(
              child: Row(
                children: [
                  Text(
                    baseCurrency,
                    style: TextStyle(
                      color: isSelected
                          ? context.priceUpColor
                          : context.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    '/$quoteCurrency',
                    style: TextStyle(
                      color: context.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            if (pair.isRecent)
              _buildIndicatorBadge('NEW', context.priceUpColor),
            if (pair.marketData.isHot)
              _buildIndicatorBadge('HOT', context.priceDownColor),
            if (pair.marketData.isTrending)
              _buildIndicatorBadge('📈', const Color(0xFFFFA726)),
          ],
        ),

        const SizedBox(height: 1),

        // Volume on bottom line
        Text(
          'Vol ${pair.formattedVolume}',
          style: TextStyle(
            color: context.textTertiary,
            fontSize: 9,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Price
        AnimatedPrice(
          symbol: pair.symbol,
          price: pair.price,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
          decimalPlaces: 4,
        ),

        const SizedBox(height: 1),

        // 24h High/Low or Bid/Ask info
        _buildMarketInfo(context),
      ],
    );
  }

  Widget _buildMarketInfo(BuildContext context) {
    final ticker = pair.marketData.ticker;

    if (ticker?.high != null && ticker?.low != null) {
      // Show 24h High/Low
      final precision = pair.marketData.market.precision?.price ?? 4;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'H:',
            style: TextStyle(
              color: context.textTertiary,
              fontSize: 8,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            ticker!.high!.toStringAsFixed(precision),
            style: TextStyle(
              color: context.priceUpColor,
              fontSize: 8,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'L:',
            style: TextStyle(
              color: context.textTertiary,
              fontSize: 8,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            ticker.low!.toStringAsFixed(precision),
            style: TextStyle(
              color: context.priceDownColor,
              fontSize: 8,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      );
    } else if (ticker?.bid != null && ticker?.ask != null) {
      // Show Bid/Ask spread
      final precision = pair.marketData.market.precision?.price ?? 4;
      final spread = ((ticker!.ask! - ticker.bid!) / ticker.bid! * 100);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Spread:',
            style: TextStyle(
              color: context.textTertiary,
              fontSize: 8,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            '${spread.toStringAsFixed(2)}%',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 8,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      );
    } else {
      // Show quote volume as fallback
      return Text(
        'Vol: ${_formatVolume(pair.marketData.quoteVolume)}',
        style: TextStyle(
          color: context.textTertiary,
          fontSize: 8,
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.none,
        ),
      );
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

  Widget _buildChangeAndActions(BuildContext context, Color changeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Change percentage with compact design
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: changeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(3),
          ),
          child: AnimatedPercentage(
            symbol: pair.symbol,
            percentage: pair.changePercent,
            style: TextStyle(
              color: changeColor,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
            showSign: true,
          ),
        ),

        const SizedBox(height: 4),

        // Quick trade button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: context.priceUpColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: context.priceUpColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            'Trade',
            style: TextStyle(
              color: context.priceUpColor,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 3),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 7,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.none,
        ),
      ),
    );
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
      case 'doge':
        return const Color(0xFFC2A633);
      case 'link':
        return const Color(0xFF375BD2);
      case 'uni':
        return const Color(0xFFFF007A);
      case 'ltc':
        return const Color(0xFFBFBFBF);
      case 'bch':
        return const Color(0xFF8DC351);
      case 'xlm':
        return const Color(0xFF14B6E9);
      case 'etc':
        return const Color(0xFF328332);
      case 'eos':
        return const Color(0xFF443F54);
      case 'trx':
        return const Color(0xFFE51A31);
      case 'neo':
        return const Color(0xFF58BF00);
      default:
        return const Color(0xFF00D4AA);
    }
  }
}
