import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection/injection.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/wallet_entity.dart';
import '../bloc/wallet_bloc.dart';
import '../widgets/wallet_list_view.dart';
import '../widgets/wallet_overview_widget.dart';
import '../widgets/balance_breakdown_sheet.dart';
import '../widgets/portfolio_chart_widget.dart';
import '../pages/deposit/deposit_main_page.dart';
import '../../../transfer/presentation/pages/transfer_page.dart';
import '../../../withdraw/presentation/pages/withdraw_page.dart';
import '../../../history/presentation/pages/transaction_history_page.dart';
import '../../../history/presentation/bloc/transaction_bloc.dart';
import '../../../history/presentation/bloc/transaction_event.dart';

class WalletOverviewPage extends StatefulWidget {
  const WalletOverviewPage({super.key});

  @override
  State<WalletOverviewPage> createState() => _WalletOverviewPageState();
}

class _WalletOverviewPageState extends State<WalletOverviewPage>
    with SingleTickerProviderStateMixin {
  bool _showChart = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WalletBloc>()..add(const GetWalletsEvent()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: context.colors.surface,
          body: BlocBuilder<WalletBloc, WalletState>(
            builder: (context, state) {
              return RefreshIndicator(
                color: context.colors.primary,
                backgroundColor: context.cardBackground,
                onRefresh: () async {
                  context.read<WalletBloc>().add(const RefreshWalletsEvent());
                },
                child: CustomScrollView(
                  slivers: [
                    // Compact Portfolio Header
                    SliverToBoxAdapter(
                      child: _buildCompactPortfolioHeader(state),
                    ),

                    // Quick Actions (Horizontal Scroll)
                    SliverToBoxAdapter(
                      child: _buildQuickActionsScroll(),
                    ),

                    // Stats Cards (Horizontal Scroll)
                    SliverToBoxAdapter(
                      child: _buildStatsCards(state),
                    ),

                    // Only show wallet section when not in initial state
                    if (state is! WalletInitial) ...[
                      // Wallets Overview or List Toggle
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Asset Distribution',
                                style: context.h6.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.textPrimary,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _toggleWalletView(context),
                                icon: Icon(
                                  Icons.pie_chart_rounded,
                                  size: 18,
                                  color: context.colors.primary,
                                ),
                                label: Text(
                                  'View Chart',
                                  style: context.bodyM.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Wallets List
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: WalletListView(
                            walletsByType: _getWalletsByType(state),
                            isLoading: state is WalletLoading,
                            onRefresh: () {
                              context
                                  .read<WalletBloc>()
                                  .add(const RefreshWalletsEvent());
                            },
                            onWalletTap: (wallet) {
                              _showWalletDetails(wallet);
                            },
                          ),
                        ),
                      ),
                    ],

                    // Bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompactPortfolioHeader(WalletState state) {
    final totalBalance = _getTotalBalance(state);
    final totalChange = _getTotalChange(state);
    final totalChangePercent = _getTotalChangePercent(state);
    final isLoading = state is WalletLoading;
    final isPositive = totalChange >= 0;
    final chartData = _getChartData(state);

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        boxShadow: [
          BoxShadow(
            color: context.colors.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header with balance and toggle
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Portfolio',
                          style: context.bodyM.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _showBalanceBreakdown(state),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              if (isLoading)
                                Container(
                                  width: 120,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: context.colors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                )
                              else
                                Text(
                                  '\$${_formatCurrency(totalBalance)}',
                                  style: context.h4.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: context.textPrimary,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: context.textTertiary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 24h Change
                        if (!isLoading)
                          Row(
                            children: [
                              Icon(
                                isPositive
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 16,
                                color: isPositive
                                    ? context.priceUpColor
                                    : context.priceDownColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${isPositive ? '+' : ''}\$${_formatCurrency(totalChange.abs())}',
                                style: context.bodyM.copyWith(
                                  color: isPositive
                                      ? context.priceUpColor
                                      : context.priceDownColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${isPositive ? '+' : ''}${totalChangePercent.toStringAsFixed(2)}%)',
                                style: context.bodyS.copyWith(
                                  color: (isPositive
                                          ? context.priceUpColor
                                          : context.priceDownColor)
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Chart Toggle Button
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showChart = !_showChart;
                        if (_showChart) {
                          _animationController.forward();
                        } else {
                          _animationController.reverse();
                        }
                      });
                    },
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _showChart
                            ? Icons.account_balance_wallet_rounded
                            : Icons.show_chart_rounded,
                        key: ValueKey(_showChart),
                        color: context.colors.primary,
                      ),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          context.colors.primary.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),

            // Chart or Empty Space
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showChart ? 200 : 16,
              child: _showChart
                  ? FadeTransition(
                      opacity: _fadeAnimation,
                      child: PortfolioChartWidget(
                        chartData: chartData,
                        currentValue: totalBalance,
                        changeAmount: totalChange,
                        changePercentage: totalChangePercent,
                        isLoading: isLoading,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsScroll() {
    final actions = [
      {
        'icon': Icons.add_rounded,
        'label': 'Deposit',
        'color': context.priceUpColor,
        'onTap': () => _navigateToDeposit(context)
      },
      {
        'icon': Icons.swap_horiz_rounded,
        'label': 'Transfer',
        'color': context.warningColor,
        'onTap': () => _navigateToTransfer(context)
      },
      {
        'icon': Icons.remove_rounded,
        'label': 'Withdraw',
        'color': context.priceDownColor,
        'onTap': () => _navigateToWithdraw(context)
      },
      {
        'icon': Icons.history_rounded,
        'label': 'History',
        'color': Colors.purple,
        'onTap': () => _navigateToTransactionHistory(context)
      },
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 110,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: actions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final action = entry.value;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index < actions.length - 1 ? 8 : 0,
                      ),
                      child: _buildCompactActionCard(
                        action['label'] as String,
                        action['icon'] as IconData,
                        action['color'] as Color,
                        action['onTap'] as VoidCallback,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionCard(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: Text(
                label,
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(WalletState state) {
    final stats = [
      {
        'label': 'Active Wallets',
        'value': _getTotalWallets(state).toString(),
        'icon': Icons.account_balance_wallet_outlined,
        'color': context.colors.primary,
      },
      {
        'label': 'Total Assets',
        'value': _getAssetCount(state).toString(),
        'icon': Icons.pie_chart_outline_rounded,
        'color': Colors.orange,
      },
      {
        'label': 'Best Performer',
        'value': _getBestPerformer(state),
        'icon': Icons.rocket_launch_rounded,
        'color': context.priceUpColor,
      },
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (stat['color'] as Color).withValues(alpha: 0.1),
                  (stat['color'] as Color).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (stat['color'] as Color).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      stat['icon'] as IconData,
                      color: stat['color'] as Color,
                      size: 16,
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        stat['value'] as String,
                        style: context.h6.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  stat['label'] as String,
                  style: context.bodyS.copyWith(
                    color: context.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _toggleWalletView(BuildContext context) {
    final walletBloc = context.read<WalletBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => BlocProvider.value(
        value: walletBloc,
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) => Container(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            child: WalletOverviewWidget(
              walletsByType: _getWalletsByType(state),
              isLoading: state is WalletLoading,
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  double _getTotalBalance(WalletState state) {
    if (state is WalletLoaded) {
      return state.totalBalanceUSD;
    }
    return 0.0;
  }

  double _getTotalChange(WalletState state) {
    if (state is WalletLoaded) {
      return state.totalPnL;
    }
    return 0.0;
  }

  double _getTotalChangePercent(WalletState state) {
    if (state is WalletLoaded) {
      return state.totalPnLPercentage;
    }
    return 0.0;
  }

  int _getTotalWallets(WalletState state) {
    if (state is WalletLoaded) {
      return state.allWallets.length;
    }
    return 0;
  }

  int _getAssetCount(WalletState state) {
    if (state is WalletLoaded) {
      return state.allWallets.map((w) => w.currency).toSet().length;
    }
    return 0;
  }

  String _getBestPerformer(WalletState state) {
    if (state is WalletLoaded && state.allWallets.isNotEmpty) {
      // For now, return the highest balance currency
      final sorted = List<WalletEntity>.from(state.allWallets)
        ..sort((a, b) => b.balance.compareTo(a.balance));
      if (sorted.first.balance > 0) {
        return sorted.first.currency;
      }
    }
    return 'N/A';
  }

  List<double> _getChartData(WalletState state) {
    if (state is WalletLoaded && state.performance != null) {
      final chartData = state.performance!['chart'];
      if (chartData != null && chartData is List && chartData.isNotEmpty) {
        final data = chartData.map(_extractChartPointValue).toList();

        // Ensure we have at least 2 points
        if (data.isNotEmpty && data.length < 2) {
          final value = data.first;
          return [value * 0.99, value];
        }

        if (data.isNotEmpty) {
          return data;
        }
      }
    }

    // Generate dummy data based on current balance for demonstration
    final balance = _getTotalBalance(state);
    if (balance > 0) {
      return [
        balance * 0.98,
        balance * 0.99,
        balance * 0.995,
        balance,
      ];
    }

    return [100.0, 105.0, 103.0, 108.0];
  }

  double _extractChartPointValue(dynamic item) {
    if (item is num) {
      return item.toDouble();
    }

    if (item is Map) {
      final directValue = _toDouble(item['value']);
      if (directValue != null) {
        return directValue;
      }

      // Backend wallet chart points are objects like:
      // { date, FIAT, SPOT, FUNDING }.
      const bucketKeys = ['FIAT', 'SPOT', 'FUNDING', 'ECO', 'FUTURES'];
      var hasBucketValue = false;
      var bucketTotal = 0.0;
      for (final key in bucketKeys) {
        final value = _toDouble(item[key]);
        if (value != null) {
          bucketTotal += value;
          hasBucketValue = true;
        }
      }
      if (hasBucketValue) {
        return bucketTotal;
      }

      var fallbackTotal = 0.0;
      for (final value in item.values) {
        final parsed = _toDouble(value);
        if (parsed != null) {
          fallbackTotal += parsed;
        }
      }
      return fallbackTotal;
    }

    return 0.0;
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, List<WalletEntity>> _getWalletsByType(WalletState state) {
    if (state is WalletLoaded) {
      final Map<String, List<WalletEntity>> grouped = {};
      for (final entry in state.wallets.entries) {
        grouped[entry.key.name] = List<WalletEntity>.from(entry.value);
      }
      return grouped;
    }
    return {};
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

  void _navigateToDeposit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt<WalletBloc>(),
          child: const DepositMainPage(),
        ),
      ),
    );
  }

  void _navigateToTransfer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransferPage(),
      ),
    );
  }

  void _navigateToWithdraw(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WithdrawPage(),
      ),
    );
  }

  void _navigateToTransactionHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) =>
              getIt<TransactionBloc>()..add(const TransactionLoadRequested()),
          child: const TransactionHistoryPage(),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: context.colors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              '$feature Feature',
              style: context.h6.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          '$feature functionality is coming soon! Stay tuned for updates.',
          style: context.bodyM.copyWith(
            color: context.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: context.colors.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Got it',
                style: TextStyle(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBalanceBreakdown(WalletState state) {
    if (state is WalletLoaded) {
      BalanceBreakdownSheet.show(
        context,
        state.allWallets,
        state.totalBalanceUSD,
      );
    }
  }

  void _showWalletDetails(WalletEntity wallet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: context.colors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${wallet.currency} Wallet',
                        style: context.h6.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        wallet.type.toString().split('.').last,
                        style: context.bodyS.copyWith(
                          color: context.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance',
                    style: context.bodyS.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${wallet.balance.toStringAsFixed(8)} ${wallet.currency}',
                    style: context.h4.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToDeposit(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Deposit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showComingSoon('Withdraw');
                    },
                    icon: const Icon(Icons.remove),
                    label: const Text('Withdraw'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.textPrimary,
                      side: BorderSide(color: context.borderColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
