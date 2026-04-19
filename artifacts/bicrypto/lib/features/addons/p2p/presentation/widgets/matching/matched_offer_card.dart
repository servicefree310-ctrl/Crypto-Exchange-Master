import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../../core/theme/p2p_color_extensions.dart';

import '../../../domain/usecases/matching/guided_matching_usecase.dart';

/// Compact card displaying a matched P2P offer with match score badge.
class MatchedOfferCard extends StatelessWidget {
  const MatchedOfferCard({
    super.key,
    required this.offer,
    this.onTap,
    this.onTrade,
  });

  final MatchedOffer offer;
  final VoidCallback? onTap;
  final VoidCallback? onTrade;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: context.borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Currency + type indicator
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: offer.type.toLowerCase() == 'buy'
                        ? context.buyColorLight
                        : context.sellColorLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    offer.type.toUpperCase(),
                    style: TextStyle(
                      color: offer.type.toLowerCase() == 'buy'
                          ? context.buyColor
                          : context.sellColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  offer.coin,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                // Match score badge
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Score ${offer.matchScore}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.colors.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '\$${offer.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                ),
                SizedBox(width: 4),
                Text(
                  '• Limits ${offer.minLimit.toStringAsFixed(2)} - ${offer.maxLimit.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? context.textSecondary
                            : context.textSecondary,
                      ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: context.colors.secondary,
                  backgroundImage: offer.trader.avatar != null
                      ? NetworkImage(offer.trader.avatar!)
                      : null,
                  child: offer.trader.avatar == null
                      ? Text(
                          offer.trader.name.isNotEmpty
                              ? offer.trader.name[0]
                              : '?',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        )
                      : null,
                ),
                SizedBox(width: 6),
                Text(
                  offer.trader.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (offer.trader.verified) ...[
                  SizedBox(width: 4),
                  Icon(Icons.verified,
                      size: 14, color: context.colors.primary),
                ],
                const Spacer(),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: onTrade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: offer.type.toLowerCase() == 'buy'
                          ? context.sellColor
                          : context.buyColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      offer.type.toLowerCase() == 'buy' ? 'Sell' : 'Buy',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
