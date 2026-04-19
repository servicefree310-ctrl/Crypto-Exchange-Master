import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../injection/injection.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../domain/entities/wallet_entity.dart';
import '../../bloc/wallet_bloc.dart';
import '../../bloc/deposit_bloc.dart';
import '../../bloc/spot_deposit_bloc.dart';
import '../../bloc/eco_deposit_bloc.dart';
import '../../bloc/futures_deposit_bloc.dart';

import 'fiat_deposit_page.dart';
import '../spot_deposit_page.dart';
import '../eco_deposit_page.dart';
import '../futures_deposit_page.dart';

class DepositMainPage extends StatefulWidget {
  const DepositMainPage({super.key});

  @override
  State<DepositMainPage> createState() => _DepositMainPageState();
}

class _DepositMainPageState extends State<DepositMainPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create staggered animations for wallet type cards
    _fadeAnimations = List.generate(4, (index) {
      final start = index * 0.1;
      final end = start + 0.3;
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });

    _slideAnimations = List.generate(4, (index) {
      final start = index * 0.1;
      final end = start + 0.3;
      return Tween<Offset>(
        begin: const Offset(0.0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    // Load wallets when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletBloc>().add(const GetWalletsEvent());
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: context.colors.surface,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.borderColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: context.textPrimary,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deposit Funds',
                    style: context.h5.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose wallet type to deposit',
                    style: context.bodyS.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary.withValues(alpha: 0.05),
                      context.colors.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                if (state is WalletLoading) {
                  return _buildLoadingState();
                }

                if (state is WalletError) {
                  return _buildErrorState(state.message);
                }

                if (state is WalletLoaded) {
                  return _buildWalletTypesList(state.wallets);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              context.colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading wallets...',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.priceDownColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: context.priceDownColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Failed to load wallets',
            style: context.h6.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.read<WalletBloc>().add(const GetWalletsEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Retry',
              style: context.bodyM.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletTypesList(
      Map<WalletType, List<WalletEntity>> walletsByType) {
    final sortedEntries = walletsByType.entries.toList()
      ..sort((a, b) => a.key.index.compareTo(b.key.index));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primary.withValues(alpha: 0.1),
                  context.colors.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: context.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select the wallet type where you want to deposit funds',
                    style: context.bodyS.copyWith(
                      color: context.colors.primary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Wallet Type Cards
          ...sortedEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final type = entry.value.key;
            final typeWallets = entry.value.value;

            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimations[index % 4],
                  child: SlideTransition(
                    position: _slideAnimations[index % 4],
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildWalletTypeCard(
                        type: type,
                        wallets: typeWallets,
                        isImplemented: type == WalletType.FIAT ||
                            type == WalletType.SPOT ||
                            type == WalletType.ECO ||
                            type == WalletType.FUTURES,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWalletTypeCard({
    required WalletType type,
    required List<WalletEntity> wallets,
    required bool isImplemented,
  }) {
    final totalBalance = wallets.fold<double>(
      0.0,
      (sum, wallet) => sum + wallet.balance,
    );

    final nonZeroWallets = wallets.where((w) => w.balance > 0).length;

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.onSurface.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isImplemented
              ? () => _navigateToDeposit(type, wallets)
              : () => _showComingSoon(type),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getTypeColor(type).withValues(alpha: 0.2),
                        _getTypeColor(type).withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getTypeIcon(type),
                    color: _getTypeColor(type),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _getTypeDisplayName(type),
                              style: context.h6.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isImplemented
                                  ? context.priceUpColor.withValues(alpha: 0.15)
                                  : context.warningColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isImplemented ? 'AVAILABLE' : 'COMING SOON',
                              style: context.bodyS.copyWith(
                                color: isImplemented
                                    ? context.priceUpColor
                                    : context.warningColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTypeDescription(
                            type, wallets.length, nonZeroWallets),
                        style: context.bodyS.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      if (totalBalance > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Balance: ',
                              style: context.bodyS.copyWith(
                                color: context.textTertiary,
                              ),
                            ),
                            Text(
                              '\$${_formatCurrency(totalBalance)}',
                              style: context.bodyM.copyWith(
                                color: _getTypeColor(type),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.borderColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: context.textSecondary,
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

  String _getTypeDisplayName(WalletType type) {
    switch (type) {
      case WalletType.FIAT:
        return 'Fiat Currency';
      case WalletType.SPOT:
        return 'Spot Trading';
      case WalletType.ECO:
        return 'Funding Wallet';
      case WalletType.FUTURES:
        return 'Futures Trading';
      default:
        return type.name;
    }
  }

  String _getTypeDescription(WalletType type, int total, int active) {
    final walletText = total == 1 ? 'wallet' : 'wallets';
    final activeText = active > 0 ? ', $active active' : '';

    switch (type) {
      case WalletType.FIAT:
        return '$total $walletText$activeText • USD, EUR, etc.';
      case WalletType.SPOT:
        return '$total $walletText$activeText • BTC, ETH, etc.';
      case WalletType.ECO:
        return '$total $walletText$activeText • Ecosystem tokens';
      case WalletType.FUTURES:
        return '$total $walletText$activeText • Derivatives';
      default:
        return '$total $walletText$activeText';
    }
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

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  void _navigateToDeposit(WalletType type, List<WalletEntity> wallets) {
    if (type == WalletType.FIAT) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => getIt<DepositBloc>(),
            child: const FiatDepositPage(),
          ),
        ),
      );
    } else if (type == WalletType.SPOT) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => getIt<SpotDepositBloc>(),
            child: const SpotDepositPage(),
          ),
        ),
      );
    } else if (type == WalletType.ECO) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => getIt<EcoDepositBloc>(),
            child: const EcoDepositPage(),
          ),
        ),
      );
    } else if (type == WalletType.FUTURES) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => getIt<FuturesDepositBloc>(),
            child: const FuturesDepositPage(),
          ),
        ),
      );
    }
  }

  void _showComingSoon(WalletType type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: context.borderColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: context.warningColor,
            ),
            const SizedBox(height: 16),
            Text(
              '${_getTypeDisplayName(type)} Deposits',
              style: context.h6.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This feature is coming soon! We\'re working hard to bring you ${type.name.toLowerCase()} deposit functionality.',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Got it',
                  style: context.bodyM.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
