import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/wallet_entity.dart';

class WalletOverviewWidget extends StatelessWidget {
  final Map<String, List<WalletEntity>> walletsByType;
  final bool isLoading;

  const WalletOverviewWidget({
    super.key,
    required this.walletsByType,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    // Flatten all wallets from the map
    final allWallets = <WalletEntity>[];
    for (final walletList in walletsByType.values) {
      allWallets.addAll(walletList);
    }

    if (allWallets.isEmpty) {
      return _buildEmptyState(context);
    }

    // Calculate wallet balances by type
    final walletBalancesByType = <String, double>{};
    double totalBalance = 0.0;

    for (final entry in walletsByType.entries) {
      final type = entry.key.toUpperCase();
      final wallets = entry.value;

      double typeBalance = 0.0;
      for (final wallet in wallets) {
        typeBalance += wallet.balance;
      }

      if (typeBalance > 0) {
        walletBalancesByType[type] = typeBalance;
        totalBalance += typeBalance;
      }
    }

    if (walletBalancesByType.isEmpty || totalBalance == 0) {
      return _buildNoBalanceState(context);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.cardBackground,
            context.cardBackground.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.pie_chart_rounded,
                color: context.colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Wallets Overview',
                style: context.h6.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pie Chart
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: _buildChartSections(
                        walletBalancesByType, totalBalance, context),
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        // Handle touch if needed
                      },
                    ),
                  ),
                ),
                // Center text
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: context.bodyS.copyWith(
                          color: context.textTertiary,
                        ),
                      ),
                      Text(
                        _formatBalance(totalBalance),
                        style: context.h5.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Legend
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: walletBalancesByType.length,
            itemBuilder: (context, index) {
              final type = walletBalancesByType.keys.elementAt(index);
              final balance = walletBalancesByType[type]!;
              final percentage =
                  (balance / totalBalance * 100).toStringAsFixed(1);

              return _buildLegendItem(
                type: type,
                balance: balance,
                percentage: percentage,
                color: _getWalletTypeColor(type),
                context: context,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: context.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Wallet Data Available',
            style: context.h6.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your wallet distribution will appear here',
            style: context.bodyS.copyWith(
              color: context.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoBalanceState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline_rounded,
            size: 48,
            color: context.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Balance Data Available',
            style: context.h6.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add funds to your wallets to see the distribution',
            style: context.bodyS.copyWith(
              color: context.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required String type,
    required double balance,
    required String percentage,
    required Color color,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                type,
                style: context.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              Text(
                '${_formatBalance(balance)} ($percentage%)',
                style: context.bodyS.copyWith(
                  color: context.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildChartSections(
    Map<String, double> balancesByType,
    double totalBalance,
    BuildContext context,
  ) {
    return balancesByType.entries.map((entry) {
      final percentage = (entry.value / totalBalance * 100);
      final color = _getWalletTypeColor(entry.key);

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 40,
        color: color,
        titleStyle: context.bodyS.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        titlePositionPercentageOffset: 0.5,
      );
    }).toList();
  }

  Color _getWalletTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'FIAT':
        return const Color(0xFF22c55e); // Green
      case 'SPOT':
        return const Color(0xFF3b82f6); // Blue
      case 'ECO':
        return const Color(0xFFa855f7); // Purple
      case 'FUTURES':
        return const Color(0xFFf59e0b); // Orange
      default:
        return const Color(0xFF9ca3af); // Gray
    }
  }

  String _formatBalance(double balance) {
    if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(2)}M';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(2)}K';
    } else {
      return balance.toStringAsFixed(2);
    }
  }
}
