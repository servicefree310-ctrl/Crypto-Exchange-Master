import 'package:flutter/material.dart';
// ignore_for_file: undefined_method, creation_with_non_type, unchecked_use_of_nullable_value, undefined_getter
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../injection/injection.dart';
import '../bloc/market/market_bloc.dart';
import '../bloc/market/market_event.dart';
import '../bloc/market/market_state.dart';
import '../bloc/offers/offers_bloc.dart';
import '../bloc/offers/offers_event.dart';
import '../bloc/offers/create_offer_bloc.dart';
import '../bloc/offers/create_offer_event.dart';
import '../pages/offers/offers_list_page.dart';
import '../pages/offers/create_offer_page.dart';
import 'common/enhanced_p2p_card.dart';
import 'how_it_works/how_it_works_widget.dart';

/// Enhanced P2P Home Widget
/// Follows dashboard-quality design standards with sophisticated layouts,
/// responsive design, and premium user experience patterns
class EnhancedP2PHomeWidget extends StatelessWidget {
  const EnhancedP2PHomeWidget({super.key});

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
      child: const _EnhancedP2PHomeContent(),
    );
  }
}

class _EnhancedP2PHomeContent extends StatelessWidget {
  const _EnhancedP2PHomeContent();

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
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Enhanced App Bar
            _buildEnhancedAppBar(context),

            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  context.isSmallScreen ? 16.0 : 20.0,
                  8.0,
                  context.isSmallScreen ? 16.0 : 20.0,
                  0.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section
                    _buildPremiumHeroSection(context),
                    SizedBox(height: context.isSmallScreen ? 16.0 : 20.0),

                    // Market Stats
                    _buildEnhancedMarketStats(context),
                    SizedBox(height: context.isSmallScreen ? 16.0 : 20.0),

                    // Quick Actions
                    _buildPremiumQuickActions(context),
                    SizedBox(height: context.isSmallScreen ? 16.0 : 20.0),

                    // Key Features
                    _buildKeyFeatures(context),
                    SizedBox(height: context.isSmallScreen ? 16.0 : 20.0),

                    // How It Works
                    const HowItWorksWidget(),
                    SizedBox(height: context.isSmallScreen ? 16.0 : 20.0),

                    // Final CTA
                    _buildPremiumCTA(context),
                    SizedBox(height: context.isSmallScreen ? 20.0 : 24.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: context.cardBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: context.textPrimary,
          size: context.isSmallScreen ? 18.0 : 20.0,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'P2P Trading',
        style: context.h6.copyWith(
          fontWeight: FontWeight.bold,
          color: context.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: EdgeInsets.only(right: context.isSmallScreen ? 12.0 : 16.0),
          child: IconButton(
            icon: Container(
              padding: EdgeInsets.all(context.isSmallScreen ? 6.0 : 8.0),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.help_outline,
                color: context.colors.primary,
                size: context.isSmallScreen ? 16.0 : 18.0,
              ),
            ),
            onPressed: () => _showInfoDialog(context),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: context.borderColor,
        ),
      ),
    );
  }

  Widget _buildPremiumHeroSection(BuildContext context) {
    return EnhancedP2PEnhancedP2PStatsCard(
      showShadow: true,
      backgroundColor: context.colors.primary,
      showBorder: false,
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peer-to-Peer Trading',
                          style: context.h5.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: context.isSmallScreen ? 20.0 : 22.0,
                          ),
                        ),
                        SizedBox(height: context.isSmallScreen ? 4.0 : 6.0),
                        Text(
                          'Trade directly with users worldwide',
                          style: context.bodyM.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: context.isSmallScreen ? 13.0 : 14.0,
                          ),
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
              SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),

              // Feature Badges
              Wrap(
                spacing: context.isSmallScreen ? 6.0 : 8.0,
                runSpacing: context.isSmallScreen ? 4.0 : 6.0,
                children: [
                  _buildFeatureBadge(context, Icons.shield, 'Secure'),
                  _buildFeatureBadge(context, Icons.flash_on, 'Fast'),
                  _buildFeatureBadge(context, Icons.verified_user, 'Trusted'),
                  _buildFeatureBadge(context, Icons.attach_money, '0.1% Fee'),
                ],
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
        horizontal: context.isSmallScreen ? 8.0 : 10.0,
        vertical: context.isSmallScreen ? 4.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
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
            size: context.isSmallScreen ? 12.0 : 14.0,
          ),
          SizedBox(width: context.isSmallScreen ? 4.0 : 6.0),
          Text(
            label,
            style: context.bodyS.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: context.isSmallScreen ? 10.0 : 11.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMarketStats(BuildContext context) {
    return BlocBuilder<P2PMarketBloc, P2PMarketState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Overview',
              style: context.h5.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: context.isSmallScreen ? 8.0 : 12.0),
            if (state is P2PMarketLoading) ...[
              _buildStatsLoadingGrid(context),
            ] else if (state is P2PMarketLoaded) ...[
              _buildStatsGrid(context, state),
            ] else if (state is P2PMarketError) ...[
              _buildStatsError(context),
            ] else ...[
              _buildStatsPlaceholder(context),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid(BuildContext context, P2PMarketLoaded state) {
    final stats = state.stats;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: context.isSmallScreen ? 8.0 : 12.0,
      mainAxisSpacing: context.isSmallScreen ? 8.0 : 12.0,
      childAspectRatio: context.isSmallScreen ? 1.8 : 2.0,
      children: [
        EnhancedP2PStatsCard(
          title: 'Total Volume',
          value: '\$${_safeFormatNumber(stats.totalVolume)}',
          icon: Icons.trending_up,
          color: context.colors.primary,
          changePercent: 12.5,
        ),
        EnhancedP2PStatsCard(
          title: 'Active Trades',
          value: _safeFormatNumber(stats.totalTrades),
          icon: Icons.swap_horiz,
          color: context.buyColor,
          changePercent: 8.3,
        ),
        EnhancedP2PStatsCard(
          title: 'Online Traders',
          value: _safeFormatNumber(stats.activeTrades),
          icon: Icons.people,
          color: context.colors.secondary,
          changePercent: -2.1,
        ),
        EnhancedP2PStatsCard(
          title: 'Avg Trade Size',
          value: '\$${_safeFormatNumber(stats.avgTradeSize)}',
          icon: Icons.account_balance_wallet,
          color: context.warningColor,
          changePercent: 5.7,
        ),
      ],
    );
  }

  Widget _buildStatsLoadingGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: context.isSmallScreen ? 8.0 : 12.0,
      mainAxisSpacing: context.isSmallScreen ? 8.0 : 12.0,
      childAspectRatio: context.isSmallScreen ? 1.8 : 2.0,
      children: List.generate(4, (index) {
        return const EnhancedP2PStatsCard(
          title: '',
          value: '',
          color: Colors.grey,
          isLoading: true,
        );
      }),
    );
  }

  Widget _buildStatsError(BuildContext context) {
    return EnhancedP2PEnhancedP2PStatsCard(
      backgroundColor: context.colors.error.withValues(alpha: 0.05),
      borderColor: context.colors.error.withValues(alpha: 0.2),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: context.colors.error,
            size: context.isSmallScreen ? 32.0 : 36.0,
          ),
          SizedBox(height: context.isSmallScreen ? 8.0 : 12.0),
          Text(
            'Unable to load market data',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.isSmallScreen ? 8.0 : 12.0),
          TextButton(
            onPressed: () {
              context.read<P2PMarketBloc>().add(const P2PMarketRequested());
            },
            child: Text(
              'Retry',
              style: context.bodyS.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPlaceholder(BuildContext context) {
    return EnhancedP2PEnhancedP2PStatsCard(
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_outlined,
            color: context.textTertiary,
            size: context.isSmallScreen ? 32.0 : 36.0,
          ),
          SizedBox(height: context.isSmallScreen ? 8.0 : 12.0),
          Text(
            'Market data will appear here',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: context.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        SizedBox(height: context.isSmallScreen ? 8.0 : 12.0),
        Row(
          children: [
            Expanded(
              child: EnhancedP2PStatsCard(
                title: 'Buy Crypto',
                icon: Icons.shopping_cart,
                color: context.buyColor,
                badge: 'Hot',
                showBadge: true,
                onTap: () => _navigateToBuy(context),
              ),
            ),
            SizedBox(width: context.isSmallScreen ? 8.0 : 12.0),
            Expanded(
              child: EnhancedP2PStatsCard(
                title: 'Sell Crypto',
                icon: Icons.sell,
                color: context.sellColor,
                onTap: () => _navigateToSell(context),
              ),
            ),
            SizedBox(width: context.isSmallScreen ? 8.0 : 12.0),
            Expanded(
              child: EnhancedP2PStatsCard(
                title: 'My Orders',
                icon: Icons.list_alt,
                color: context.colors.tertiary,
                onTap: () => _showComingSoon(context, 'My Orders'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Choose P2P?',
          style: context.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        SizedBox(height: context.isSmallScreen ? 8.0 : 12.0),
        _buildFeatureItem(
          context,
          Icons.security,
          'Advanced Security',
          'Military-grade escrow protection for all trades',
          context.colors.primary,
        ),
        SizedBox(height: context.isSmallScreen ? 8.0 : 10.0),
        _buildFeatureItem(
          context,
          Icons.flash_on,
          'Lightning Fast',
          'Complete trades in minutes with instant chat',
          context.colors.secondary,
        ),
        SizedBox(height: context.isSmallScreen ? 8.0 : 10.0),
        _buildFeatureItem(
          context,
          Icons.attach_money,
          'Ultra Low Fees',
          'Only 0.1% trading fee - save up to 90%',
          context.warningColor,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return EnhancedP2PEnhancedP2PStatsCard(
      backgroundColor: color.withValues(alpha: 0.03),
      borderColor: color.withValues(alpha: 0.1),
      child: Row(
        children: [
          Container(
            width: context.isSmallScreen ? 40.0 : 48.0,
            height: context.isSmallScreen ? 40.0 : 48.0,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(context.isSmallScreen ? 10.0 : 12.0),
            ),
            child: Icon(
              icon,
              color: color,
              size: context.isSmallScreen ? 20.0 : 24.0,
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
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
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

  Widget _buildPremiumCTA(BuildContext context) {
    return EnhancedP2PEnhancedP2PStatsCard(
      showShadow: true,
      backgroundColor: context.colors.primary.withValues(alpha: 0.05),
      borderColor: context.colors.primary.withValues(alpha: 0.2),
      child: Column(
        children: [
          Text(
            '🚀 Ready to Start Trading?',
            style: context.h6.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.isSmallScreen ? 6.0 : 8.0),
          Text(
            'Join thousands of traders in our secure P2P marketplace',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
              fontSize: context.isSmallScreen ? 13.0 : 14.0,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.isSmallScreen ? 16.0 : 20.0),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToBuy(context),
                  icon: Icon(
                    Icons.shopping_cart,
                    size: context.isSmallScreen ? 16.0 : 18.0,
                  ),
                  label: Text(
                    'Start Buying',
                    style: context.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.buyColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: context.isSmallScreen ? 12.0 : 14.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          context.isSmallScreen ? 8.0 : 10.0),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              SizedBox(width: context.isSmallScreen ? 8.0 : 12.0),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToSell(context),
                  icon: Icon(
                    Icons.sell,
                    size: context.isSmallScreen ? 16.0 : 18.0,
                  ),
                  label: Text(
                    'Start Selling',
                    style: context.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.sellColor,
                    side: BorderSide(color: context.sellColor),
                    padding: EdgeInsets.symmetric(
                      vertical: context.isSmallScreen ? 12.0 : 14.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          context.isSmallScreen ? 8.0 : 10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Navigation and utility methods
  void _navigateToSell(BuildContext context) {
    try {
      context.read<CreateOfferBloc>().add(const CreateOfferStarted());
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<CreateOfferBloc>(),
            child: const CreateOfferPage(),
          ),
        ),
      );
    } catch (e) {
      _showComingSoon(context, 'Create Offer');
    }
  }

  void _navigateToBuy(BuildContext context) {
    try {
      context.read<OffersBloc>().add(const OffersLoadRequested());
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<OffersBloc>(),
            child: const OffersListPage(),
          ),
        ),
      );
    } catch (e) {
      _showComingSoon(context, 'Browse Offers');
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.rocket_launch,
              color: Colors.white,
              size: context.isSmallScreen ? 18.0 : 20.0,
            ),
            SizedBox(width: context.isSmallScreen ? 6.0 : 8.0),
            Expanded(
              child: Text(
                '$feature feature coming soon!',
                style: context.bodyM.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: context.colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(context.isSmallScreen ? 12.0 : 16.0),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'P2P Trading Guide',
          style: context.h6.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'P2P (Peer-to-Peer) trading allows you to buy and sell cryptocurrencies directly with other users. All trades are protected by our escrow system.',
          style: context.bodyM,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: context.bodyM.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
