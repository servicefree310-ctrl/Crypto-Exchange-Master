import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../../injection/injection.dart';
import '../bloc/market/market_bloc.dart';
import '../bloc/market/market_event.dart';
import '../bloc/market/market_state.dart';
import '../bloc/offers/offers_bloc.dart';
import '../bloc/offers/create_offer_bloc.dart';
import '../bloc/offers/create_offer_event.dart';
import 'p2p_buy_page.dart';
import 'offers/create_offer_page.dart';
import '../widgets/how_it_works/how_it_works_widget.dart';
import '../widgets/common/enhanced_p2p_card.dart';

/// P2P Home Page - Ultra compact design with proper navigation
class P2PHomePage extends StatelessWidget {
  const P2PHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<P2PMarketBloc>()..add(const P2PMarketRequested()),
        ),
        BlocProvider(
          create: (context) => getIt<OffersBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<CreateOfferBloc>(),
        ),
      ],
      child: const _P2PHomeContent(),
    );
  }
}

class _P2PHomeContent extends StatelessWidget {
  const _P2PHomeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cardBackground,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<P2PMarketBloc>().add(const P2PMarketRequested());
        },
        color: context.colors.primary,
        child: CustomScrollView(
          slivers: [
            // Compact App Bar
            _buildCompactAppBar(context),

            // Hero Section - Very Compact
            SliverToBoxAdapter(child: _buildCompactHero(context)),

            // Market Stats - Only if available
            SliverToBoxAdapter(child: _buildMarketStats(context)),

            // Features - Very Compact
            SliverToBoxAdapter(child: _buildCompactFeatures(context)),

            // Ready to Start? - Moved from How It Works
            SliverToBoxAdapter(child: _buildStartNowSection(context)),

            // How It Works - Comprehensive Guide
            const SliverToBoxAdapter(child: HowItWorksWidget()),

            // Safety padding
            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: context.cardBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: context.textPrimary, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'P2P Trading',
        style: context.bodyL.copyWith(
          fontWeight: FontWeight.bold,
          color: context.textPrimary,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: context.borderColor),
      ),
    );
  }

  Widget _buildCompactHero(BuildContext context) {
    return EnhancedP2PCard(
      margin: EdgeInsets.symmetric(
        horizontal: context.isSmallScreen ? 12.0 : 16.0,
        vertical: context.isSmallScreen ? 6.0 : 8.0,
      ),
      backgroundColor: context.colors.primary,
      showBorder: false,
      showShadow: true,
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          // Content
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'P2P Trading',
                      style: context.h6.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: context.isSmallScreen ? 18.0 : 20.0,
                      ),
                    ),
                    SizedBox(height: context.isSmallScreen ? 4.0 : 6.0),
                    Text(
                      'Trade directly with users worldwide',
                      style: context.bodyM.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: context.isSmallScreen ? 12.0 : 13.0,
                      ),
                    ),
                    SizedBox(height: context.isSmallScreen ? 8.0 : 10.0),
                    // Feature badges
                    Wrap(
                      spacing: context.isSmallScreen ? 6.0 : 8.0,
                      runSpacing: 4.0,
                      children: [
                        _buildFeatureBadge(context, Icons.shield, 'Secure'),
                        _buildFeatureBadge(context, Icons.flash_on, 'Fast'),
                        _buildFeatureBadge(
                            context, Icons.verified_user, 'Trusted'),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: context.isSmallScreen ? 48.0 : 56.0,
                height: context.isSmallScreen ? 48.0 : 56.0,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(
                      context.isSmallScreen ? 12.0 : 14.0),
                ),
                child: Icon(
                  Icons.people_alt_outlined,
                  color: Colors.white,
                  size: context.isSmallScreen ? 24.0 : 28.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(BuildContext context, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.isSmallScreen ? 6.0 : 8.0,
        vertical: context.isSmallScreen ? 3.0 : 4.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: context.isSmallScreen ? 10.0 : 12.0,
          ),
          SizedBox(width: context.isSmallScreen ? 3.0 : 4.0),
          Text(
            label,
            style: context.bodyS.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: context.isSmallScreen ? 9.0 : 10.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketStats(BuildContext context) {
    return BlocBuilder<P2PMarketBloc, P2PMarketState>(
      builder: (context, state) {
        if (state is P2PMarketLoading) {
          return _buildStatsLoading(context);
        }

        if (state is P2PMarketError) {
          return const SizedBox
              .shrink(); // Hide on error, don't show error message
        }

        if (state is P2PMarketLoaded) {
          final stats = state.stats;
          return EnhancedP2PCard(
            margin: EdgeInsets.symmetric(
              horizontal: context.isSmallScreen ? 12.0 : 16.0,
              vertical: context.isSmallScreen ? 6.0 : 8.0,
            ),
            showShadow: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.all(context.isSmallScreen ? 6.0 : 8.0),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: context.colors.primary,
                        size: context.isSmallScreen ? 16.0 : 18.0,
                      ),
                    ),
                    SizedBox(width: context.isSmallScreen ? 8.0 : 12.0),
                    Expanded(
                      child: Text(
                        'Market Overview',
                        style: context.h6.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                          fontSize: context.isSmallScreen ? 16.0 : 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),
                Row(
                  children: [
                    _buildMiniStat(
                        context,
                        'Volume',
                        _safeFormatNumber(stats.totalVolume),
                        context.colors.primary),
                    SizedBox(width: context.isSmallScreen ? 6.0 : 8.0),
                    _buildMiniStat(context, 'Trades',
                        _safeFormatNumber(stats.totalTrades), context.buyColor),
                    SizedBox(width: context.isSmallScreen ? 6.0 : 8.0),
                    _buildMiniStat(
                        context,
                        'Active',
                        _safeFormatNumber(stats.activeTrades),
                        context.colors.tertiary),
                  ],
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink(); // Hide if no data
      },
    );
  }

  Widget _buildMiniStat(
      BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: context.bodyS.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              label,
              style: context.bodyS.copyWith(
                color: context.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsLoading(BuildContext context) {
    return EnhancedP2PCard(
      margin: EdgeInsets.symmetric(
        horizontal: context.isSmallScreen ? 12.0 : 16.0,
        vertical: context.isSmallScreen ? 6.0 : 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: context.isSmallScreen ? 24.0 : 28.0,
                height: context.isSmallScreen ? 24.0 : 28.0,
                decoration: BoxDecoration(
                  color: context.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              SizedBox(width: context.isSmallScreen ? 8.0 : 12.0),
              Container(
                width: 120,
                height: context.isSmallScreen ? 16.0 : 18.0,
                decoration: BoxDecoration(
                  color: context.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),
          Row(
            children: [
              _buildSkeletonStat(context),
              SizedBox(width: context.isSmallScreen ? 6.0 : 8.0),
              _buildSkeletonStat(context),
              SizedBox(width: context.isSmallScreen ? 6.0 : 8.0),
              _buildSkeletonStat(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonStat(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: context.textSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 12,
              decoration: BoxDecoration(
                color: context.textSecondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 20,
              height: 8,
              decoration: BoxDecoration(
                color: context.textSecondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.isSmallScreen ? 12.0 : 16.0,
          ),
          child: Text(
            'Why P2P?',
            style: context.h6.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
              fontSize: context.isSmallScreen ? 16.0 : 18.0,
            ),
          ),
        ),
        SizedBox(height: context.isSmallScreen ? 8.0 : 12.0),
        _buildMiniFeature(context, Icons.security, 'Secure Escrow',
            'Military-grade protection for all trades', context.colors.primary),
        _buildMiniFeature(
            context,
            Icons.flash_on,
            'Fast Trading',
            'Complete trades in minutes with instant chat',
            context.colors.secondary),
        _buildMiniFeature(
            context,
            Icons.account_balance_wallet,
            'Low Fees (0.1%)',
            'Save up to 90% compared to traditional exchanges',
            context.warningColor),
      ],
    );
  }

  Widget _buildMiniFeature(BuildContext context, IconData icon, String title,
      String description, Color color) {
    return EnhancedP2PCard(
      margin: EdgeInsets.symmetric(
        horizontal: context.isSmallScreen ? 12.0 : 16.0,
        vertical: context.isSmallScreen ? 4.0 : 6.0,
      ),
      backgroundColor: color.withValues(alpha: 0.03),
      borderColor: color.withValues(alpha: 0.1),
      child: Row(
        children: [
          Container(
            width: context.isSmallScreen ? 36.0 : 40.0,
            height: context.isSmallScreen ? 36.0 : 40.0,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(context.isSmallScreen ? 8.0 : 10.0),
            ),
            child: Icon(
              icon,
              color: color,
              size: context.isSmallScreen ? 16.0 : 18.0,
            ),
          ),
          SizedBox(width: context.isSmallScreen ? 12.0 : 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodyL.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: context.isSmallScreen ? 13.0 : 14.0,
                  ),
                ),
                SizedBox(height: context.isSmallScreen ? 2.0 : 4.0),
                Text(
                  description,
                  style: context.bodyS.copyWith(
                    color: context.textSecondary,
                    fontSize: context.isSmallScreen ? 11.0 : 12.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartNowSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.isSmallScreen ? 12.0 : 16.0,
        vertical: context.isSmallScreen ? 6.0 : 8.0,
      ),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary.withValues(alpha: 0.1),
            context.colors.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: context.colors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to Start?',
                      style: context.bodyM.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Join thousands of satisfied traders',
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              // Find Best Offer Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showBuySellOptions(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Find Best Offer',
                        style: context.bodyS.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Create Offer Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _navigateToCreateOffer(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.primary,
                    side: BorderSide(color: context.colors.primary),
                    padding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Create Offer',
                        style: context.bodyS.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Navigation methods for dedicated P2P buy/sell pages
  void _navigateToSell(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const P2PBuyPage(initialTradeType: 'SELL'),
      ),
    );
  }

  void _navigateToBuy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const P2PBuyPage(initialTradeType: 'BUY'),
      ),
    );
  }

  void _navigateToCreateOffer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) =>
              getIt<CreateOfferBloc>()..add(const CreateOfferStarted()),
          child: const CreateOfferPage(),
        ),
      ),
    );
  }

  void _showBuySellOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Choose Your Action',
                  style: context.h6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Buy Option
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _navigateToBuy(context);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.buyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: context.buyColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.buyColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_cart,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buy Crypto',
                            style: context.bodyL.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.buyColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Purchase cryptocurrency from sellers',
                            style: context.bodyS.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: context.buyColor, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Sell Option
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _navigateToSell(context);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.sellColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: context.sellColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.sellColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Icons.sell, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sell Crypto',
                            style: context.bodyL.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.sellColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sell cryptocurrency to buyers',
                            style: context.bodyS.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: context.sellColor, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Safe number formatting to handle nulls
  String _safeFormatNumber(dynamic value) {
    if (value == null) return '0';

    double number;
    if (value is int) {
      number = value.toDouble();
    } else if (value is double) {
      number = value;
    } else if (value is String) {
      number = double.tryParse(value) ?? 0.0;
    } else {
      return '0';
    }

    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toInt().toString();
  }
}
