import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/wallet_entity.dart';

class BalanceBreakdownSheet extends StatefulWidget {
  final List<WalletEntity> wallets;
  final double totalBalanceUSD;

  const BalanceBreakdownSheet({
    super.key,
    required this.wallets,
    required this.totalBalanceUSD,
  });

  static void show(BuildContext context, List<WalletEntity> wallets,
      double totalBalanceUSD) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BalanceBreakdownSheet(
        wallets: wallets,
        totalBalanceUSD: totalBalanceUSD,
      ),
    );
  }

  @override
  State<BalanceBreakdownSheet> createState() => _BalanceBreakdownSheetState();
}

class _BalanceBreakdownSheetState extends State<BalanceBreakdownSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate data
    final walletTypeData = _calculateWalletTypeDistribution();
    final currencyData = _calculateCurrencyDistribution();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
              0, MediaQuery.of(context).size.height * _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.onSurface.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.borderColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                context.colors.primary.withValues(alpha: 0.2),
                                context.colors.primary.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.analytics_rounded,
                            color: context.colors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Portfolio Breakdown',
                                style: context.h6.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.textPrimary,
                                ),
                              ),
                              Text(
                                'Detailed asset distribution',
                                style: context.bodyS.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close_rounded,
                            color: context.textTertiary,
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                context.borderColor.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total Value Card
                          _buildTotalValueCard(),

                          const SizedBox(height: 20),

                          // Wallet Type Distribution
                          _buildWalletTypeSection(walletTypeData),

                          const SizedBox(height: 20),

                          // Currency Distribution
                          _buildCurrencySection(currencyData),

                          const SizedBox(height: 20),

                          // Info Section
                          _buildInfoSection(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalValueCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary.withValues(alpha: 0.15),
            context.colors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: context.colors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total Portfolio Value',
                      style: context.bodyM.copyWith(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '\$${_formatCurrency(widget.totalBalanceUSD)}',
                  style: context.h3.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'USD Equivalent',
                  style: context.bodyS.copyWith(
                    color: context.colors.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletTypeSection(Map<WalletType, WalletTypeInfo> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribution by Type',
          style: context.bodyL.copyWith(
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...data.entries.map((entry) {
          final type = entry.key;
          final info = entry.value;
          final percentage = (info.totalBalance / widget.totalBalanceUSD * 100);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getTypeColor(type).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getTypeIcon(type),
                        color: _getTypeColor(type),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type.name,
                            style: context.bodyM.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            '${info.count} wallet${info.count > 1 ? 's' : ''}',
                            style: context.bodyS.copyWith(
                              color: context.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: context.bodyM.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _getTypeColor(type),
                          ),
                        ),
                        Text(
                          '\$${_formatCurrency(info.totalBalance)}',
                          style: context.bodyS.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: context.borderColor.withValues(alpha: 0.2),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_getTypeColor(type)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCurrencySection(Map<String, CurrencyInfo> data) {
    final sortedCurrencies = data.entries.toList()
      ..sort((a, b) => b.value.totalAmount.compareTo(a.value.totalAmount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Holdings by Currency',
          style: context.bodyL.copyWith(
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: sortedCurrencies.asMap().entries.map((entry) {
              final index = entry.key;
              final currency = entry.value.key;
              final info = entry.value.value;
              final isLast = index == sortedCurrencies.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getCurrencyColor(currency),
                                _getCurrencyColor(currency).withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _getCurrencySymbol(currency),
                              style: context.bodyM.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currency.toUpperCase(),
                                style: context.bodyM.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary,
                                ),
                              ),
                              if (info.walletTypes.length > 1)
                                Text(
                                  info.walletTypes
                                      .map((t) => t.name)
                                      .join(', '),
                                  style: context.bodyS.copyWith(
                                    color: context.textTertiary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          _formatAmount(info.totalAmount, currency),
                          style: context.bodyM.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: context.borderColor.withValues(alpha: 0.1),
                      indent: 64,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    final infoColor = Colors.blue;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            infoColor.withValues(alpha: 0.1),
            infoColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: infoColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: infoColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio Valuation',
                  style: context.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                    color: infoColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All cryptocurrency holdings are converted to USD using real-time market prices for accurate portfolio valuation.',
                  style: context.bodyS.copyWith(
                    color: infoColor.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Map<WalletType, WalletTypeInfo> _calculateWalletTypeDistribution() {
    final Map<WalletType, WalletTypeInfo> distribution = {};

    for (final wallet in widget.wallets) {
      if (!distribution.containsKey(wallet.type)) {
        distribution[wallet.type] = WalletTypeInfo();
      }
      distribution[wallet.type]!.count++;
      distribution[wallet.type]!.totalBalance += wallet.balance;
    }

    return distribution;
  }

  Map<String, CurrencyInfo> _calculateCurrencyDistribution() {
    final Map<String, CurrencyInfo> distribution = {};

    for (final wallet in widget.wallets) {
      if (!distribution.containsKey(wallet.currency)) {
        distribution[wallet.currency] = CurrencyInfo();
      }
      distribution[wallet.currency]!.totalAmount += wallet.balance;
      distribution[wallet.currency]!.walletTypes.add(wallet.type);
    }

    return distribution;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  String _formatAmount(double amount, String currency) {
    if (amount == 0) return '0';
    if (amount < 0.01) return '<0.01';
    if (amount < 1) {
      return amount
          .toStringAsFixed(8)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    if (amount < 1000) return amount.toStringAsFixed(2);
    return _formatCurrency(amount);
  }

  Color _getTypeColor(WalletType type) {
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

  IconData _getTypeIcon(WalletType type) {
    switch (type) {
      case WalletType.FIAT:
        return Icons.account_balance_rounded;
      case WalletType.SPOT:
        return Icons.currency_exchange_rounded;
      case WalletType.ECO:
        return Icons.eco_rounded;
      case WalletType.FUTURES:
        return Icons.trending_up_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color _getCurrencyColor(String currency) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.green,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];

    return colors[currency.hashCode % colors.length];
  }

  String _getCurrencySymbol(String currency) {
    final upper = currency.toUpperCase();
    if (upper.length <= 3) return upper;
    return upper.substring(0, 2);
  }
}

class WalletTypeInfo {
  int count = 0;
  double totalBalance = 0;
}

class CurrencyInfo {
  double totalAmount = 0;
  Set<WalletType> walletTypes = {};
}
