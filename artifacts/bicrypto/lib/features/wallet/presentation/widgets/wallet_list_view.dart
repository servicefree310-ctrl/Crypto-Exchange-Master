import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/wallet_entity.dart';
import 'compact_wallet_card.dart';

class WalletListView extends StatelessWidget {
  final Map<String, List<WalletEntity>> walletsByType;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final Function(WalletEntity)? onWalletTap;

  const WalletListView({
    super.key,
    required this.walletsByType,
    this.isLoading = false,
    this.onRefresh,
    this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingView(context);
    }

    final hasWallets =
        walletsByType.values.any((wallets) => wallets.isNotEmpty);

    if (!hasWallets) {
      return _buildEmptyView();
    }

    return Column(
      children: [
        ...walletsByType.entries.map((entry) {
          final type = entry.key;
          final wallets = entry.value;

          if (wallets.isEmpty) return const SizedBox.shrink();

          return _buildWalletSection(context, type, wallets);
        }),
      ],
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return Column(
      children: [
        _buildLoadingSection(context, 'FIAT'),
        const SizedBox(height: 16),
        _buildLoadingSection(context, 'SPOT'),
        const SizedBox(height: 16),
        _buildLoadingSection(context, 'ECO'),
      ],
    );
  }

  Widget _buildLoadingSection(BuildContext context, String type) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact section header shimmer
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Compact wallet cards loading
          ...List.generate(
            2,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLoadingWalletCard(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWalletCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Currency icon loading
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Content loading
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ),

          // Arrow loading
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Builder(
      builder: (context) => SizedBox(
        height: 400,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container with theme colors
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.primary.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 56,
                    color: context.colors.primary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 28),

                // Title with theme text
                Text(
                  'No Wallets Found',
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Description with theme text
                Text(
                  'Your cryptocurrency wallets will appear here once they are created or activated.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Pull-to-refresh hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 16,
                      color: context.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pull down to refresh',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.textTertiary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletSection(
      BuildContext context, String type, List<WalletEntity> wallets) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getWalletTypeColor(type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getWalletTypeIcon(type),
                  color: _getWalletTypeColor(type),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                type.toUpperCase(),
                style: context.h6.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${wallets.length}',
                  style: context.bodyS.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Wallet cards using compact design
          ...wallets
              .map((wallet) => CompactWalletCard(
                    wallet: wallet,
                    onTap: () => onWalletTap?.call(wallet),
                  ))
              ,
        ],
      ),
    );
  }

  Widget _buildWalletCard(WalletEntity wallet) {
    final hasBalance = wallet.balance > 0;
    final currency = wallet.currency.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasBalance
              ? const Color(0xFF6C5CE7).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onWalletTap?.call(wallet),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Currency icon with status indicator
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getCurrencyColor(currency),
                            _getCurrencyColor(currency).withValues(alpha: 0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getCurrencyColor(currency).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getCurrencySymbol(currency),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (hasBalance)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0B0E18),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Wallet info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            currency,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getWalletTypeColor(wallet.type.name)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getWalletTypeColor(wallet.type.name)
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              wallet.type.name.toUpperCase(),
                              style: TextStyle(
                                color: _getWalletTypeColor(wallet.type.name),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatBalance(wallet.balance)} $currency',
                        style: TextStyle(
                          color: hasBalance
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (wallet.inOrder > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          'In orders: ${_formatBalance(wallet.inOrder)} $currency',
                          style: TextStyle(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action button
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for wallet type styling
  IconData _getWalletTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'FIAT':
        return Icons.account_balance;
      case 'SPOT':
        return Icons.currency_exchange;
      case 'ECO':
        return Icons.eco;
      case 'FUTURES':
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getWalletTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'FIAT':
        return const Color(0xFF10B981); // Green
      case 'SPOT':
        return const Color(0xFF3B82F6); // Blue
      case 'ECO':
        return const Color(0xFF8B5CF6); // Purple
      case 'FUTURES':
        return const Color(0xFFF59E0B); // Orange
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  Color _getCurrencyColor(String currency) {
    final colors = {
      'BTC': const Color(0xFFF7931A),
      'ETH': const Color(0xFF627EEA),
      'USD': const Color(0xFF10B981),
      'USDT': const Color(0xFF26A17B),
      'BNB': const Color(0xFFF3BA2F),
      'DOGE': const Color(0xFFC2A633),
      'MATIC': const Color(0xFF8247E5),
      'YFI': const Color(0xFF006AE3),
    };
    return colors[currency] ?? const Color(0xFF6B7280);
  }

  String _getCurrencySymbol(String currency) {
    final symbols = {
      'BTC': '₿',
      'ETH': 'Ξ',
      'USD': '\$',
      'USDT': '₮',
      'BNB': 'B',
      'DOGE': 'Ð',
      'MATIC': 'M',
      'YFI': 'Y',
    };
    return symbols[currency] ?? currency.substring(0, 1);
  }

  String _formatBalance(double balance) {
    if (balance == 0) return '0.00';
    if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(2)}M';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(2)}K';
    } else if (balance >= 1) {
      return balance.toStringAsFixed(2);
    } else {
      return balance.toStringAsFixed(6);
    }
  }
}
