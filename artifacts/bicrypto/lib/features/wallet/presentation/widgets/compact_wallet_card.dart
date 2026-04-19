import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/wallet_entity.dart';

class CompactWalletCard extends StatelessWidget {
  final WalletEntity wallet;
  final VoidCallback? onTap;

  const CompactWalletCard({
    super.key,
    required this.wallet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasBalance = wallet.balance > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: context.colors.onSurface.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Currency Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getTypeColor(wallet.type, context).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  wallet.currency.substring(0, 1).toUpperCase(),
                  style: context.bodyL.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTypeColor(wallet.type, context),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Currency Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        wallet.currency.toUpperCase(),
                        style: context.bodyL.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(wallet.type, context)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          wallet.type.name,
                          style: context.bodyS.copyWith(
                            fontSize: 10,
                            color: _getTypeColor(wallet.type, context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasBalance
                        ? '${wallet.balance.toStringAsFixed(wallet.balance < 1 ? 8 : 2)} ${wallet.currency}'
                        : 'No balance',
                    style: context.bodyS.copyWith(
                      color: hasBalance
                          ? context.textSecondary
                          : context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: context.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(WalletType type, BuildContext context) {
    switch (type) {
      case WalletType.FIAT:
        return context.priceUpColor;
      case WalletType.SPOT:
        return Colors.blue;
      case WalletType.ECO:
        return Colors.purple;
      case WalletType.FUTURES:
        return Colors.orange;
      default:
        return context.colors.primary;
    }
  }
}
