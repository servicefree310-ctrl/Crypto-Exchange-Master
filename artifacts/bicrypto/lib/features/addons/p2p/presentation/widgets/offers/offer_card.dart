import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../../core/theme/p2p_color_extensions.dart';
import '../../../domain/entities/p2p_offer_entity.dart';

/// Enum for different offer card display modes
enum OfferCardType {
  buy, // User is buying (show SELL offers)
  sell, // User is selling (show BUY offers)
  general, // General display
}

/// P2P Offer Card - KuCoin style compact design
/// Displays offer information with trader details and quick actions
class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    this.cardType = OfferCardType.general,
    this.onTap,
    this.onTrade,
    this.showTradeButton = true,
  });

  final P2POfferEntity offer;
  final OfferCardType cardType;
  final VoidCallback? onTap;
  final VoidCallback? onTrade;
  final bool showTradeButton;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.borderColor,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Header with trader info and type badge
              _buildHeader(context, isDark),

              const SizedBox(height: 12),

              // Main trading information
              _buildTradingInfo(context, isDark),

              const SizedBox(height: 12),

              // Payment methods and action button
              _buildFooter(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Trader avatar and info
        CircleAvatar(
          radius: 20,
          backgroundColor: context.colors.primary.withValues(alpha: 0.1),
          child: Text(
            offer.userId.substring(0, 2).toUpperCase(),
            style: TextStyle(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trader ${offer.userId.substring(0, 8)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 14,
                    color: context.warningColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '4.8 (156)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? context.textSecondary
                              : context.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Trade type badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: offer.type == P2PTradeType.buy
                ? context.buyColorLight
                : context.sellColorLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            offer.type == P2PTradeType.buy ? 'BUY' : 'SELL',
            style: TextStyle(
              color: offer.type == P2PTradeType.buy
                  ? context.buyColor
                  : context.sellColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTradingInfo(BuildContext context, bool isDark) {
    // Calculate price and amounts from configuration
    final price = offer.priceConfig.finalPrice;
    final availableAmount = offer.amountConfig.total;
    final minAmount = offer.amountConfig.min ?? 0.0;
    final maxAmount = offer.amountConfig.max ?? availableAmount;

    return Row(
      children: [
        // Currency and amount info
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.currency,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Available: ${availableAmount.toStringAsFixed(8)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? context.textSecondary
                          : context.textSecondary,
                    ),
              ),
            ],
          ),
        ),

        // Price info
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'per ${offer.currency}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? context.textSecondary
                          : context.textSecondary,
                    ),
              ),
            ],
          ),
        ),

        // Limits info
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Limits',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? context.textSecondary
                          : context.textSecondary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${minAmount.toStringAsFixed(2)} - ${maxAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Payment methods
        Expanded(
          child: Wrap(
            spacing: 6,
            children: (offer.paymentMethods ?? []).take(2).map((method) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? context.borderColor.withValues(alpha: 0.3)
                      : context.borderColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: context.borderColor,
                  ),
                ),
                child: Text(
                  method,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(width: 12),

        // Trade button
        if (showTradeButton)
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onTrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getTradeButtonColor(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                _getTradeButtonText(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getTradeButtonColor(BuildContext context) {
    switch (cardType) {
      case OfferCardType.buy:
        // User is buying, so this is a SELL offer - show buy color
        return context.buyColor;
      case OfferCardType.sell:
        // User is selling, so this is a BUY offer - show sell color
        return context.sellColor;
      case OfferCardType.general:
      default:
        // General case - opposite of offer type
        return offer.type == P2PTradeType.buy
            ? context.buyColor
            : context.sellColor;
    }
  }

  String _getTradeButtonText() {
    switch (cardType) {
      case OfferCardType.buy:
        // User is buying from a SELL offer
        return 'Buy';
      case OfferCardType.sell:
        // User is selling to a BUY offer
        return 'Sell';
      case OfferCardType.general:
      default:
        // General case - opposite of offer type
        return offer.type == P2PTradeType.buy ? 'Sell' : 'Buy';
    }
  }
}

/// Compact Offer Card for lists with minimal info
class CompactOfferCard extends StatelessWidget {
  const CompactOfferCard({
    super.key,
    required this.offer,
    this.onTap,
  });

  final P2POfferEntity offer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final price = offer.priceConfig.finalPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Type indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: offer.type == P2PTradeType.buy
                      ? context.buyColor
                      : context.sellColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(width: 12),

              // Currency
              Text(
                offer.currency,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const Spacer(),

              // Price
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.primary,
                    ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right,
                size: 16,
                color: isDark ? context.textSecondary : context.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
