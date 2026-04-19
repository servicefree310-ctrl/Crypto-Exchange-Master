import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/common/p2p_state_widgets.dart';
import '../../bloc/offers/offers_bloc.dart';
import '../../bloc/offers/offers_state.dart';
import '../../bloc/offers/offers_event.dart';
import '../../../domain/entities/p2p_offer_entity.dart';

/// P2P Offer Detail Page - KuCoin style comprehensive offer view
/// Shows complete offer information with trader profile and trading actions
class OfferDetailPage extends StatefulWidget {
  const OfferDetailPage({
    super.key,
    required this.offerId,
  });

  final String offerId;

  @override
  State<OfferDetailPage> createState() => _OfferDetailPageState();
}

class _OfferDetailPageState extends State<OfferDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOfferDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadOfferDetails() {
    context
        .read<OffersBloc>()
        .add(LoadOfferDetailsRequested(id: widget.offerId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          context.colors.surface,
      body: BlocBuilder<OffersBloc, OffersState>(
        builder: (context, state) {
          if (state is OfferDetailsLoading) {
            return const P2PShimmerLoading(
              itemCount: 5,
              itemHeight: 100,
            );
          }

          if (state is OfferDetailsError) {
            return P2PErrorWidget(
              message: state.failure.message,
              onRetry: _loadOfferDetails,
            );
          }

          if (state is OfferDetailsLoaded) {
            return _buildOfferDetail(state.offer, isDark);
          }

          return const P2PEmptyStateWidget(
            title: 'Offer Not Found',
            message: 'The requested offer could not be found.',
            icon: Icons.search_off,
          );
        },
      ),
      floatingActionButton: BlocBuilder<OffersBloc, OffersState>(
        builder: (context, state) {
          if (state is! OfferDetailsLoaded) return const SizedBox.shrink();

          final offer = state.offer;
          final isBuy = offer.type == P2PTradeType.buy;
          return FloatingActionButton.extended(
            heroTag: 'trade_now_btn',
            backgroundColor: isBuy ? context.buyColor : context.sellColor,
            foregroundColor: Colors.white,
            onPressed: () => _initiateTrade(offer),
            icon: const Icon(Icons.flash_on, size: 20),
            label: Text(
              isBuy ? 'Buy Now' : 'Sell Now',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildOfferDetail(P2POfferEntity offer, bool isDark) {
    return CustomScrollView(
      slivers: [
        // App Bar with offer type indicator
        SliverAppBar(
          backgroundColor:
              context.colors.surface,
          elevation: 0,
          pinned: true,
          expandedHeight: 120,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              onPressed: () => _showReportDialog(offer),
              icon: const Icon(Icons.flag_outlined),
              tooltip: 'Report Offer',
            ),
            IconButton(
              onPressed: () => _shareOffer(offer),
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share Offer',
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: offer.type == P2PTradeType.buy
                      ? [
                          context.buyColor.withValues(alpha: 0.8),
                          context.buyColor.withValues(alpha: 0.4),
                        ]
                      : [
                          context.sellColor.withValues(alpha: 0.8),
                          context.sellColor.withValues(alpha: 0.4),
                        ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 80, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            offer.type == P2PTradeType.buy
                                ? 'BUY OFFER'
                                : 'SELL OFFER',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          offer.currency,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${offer.priceConfig.finalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Tab bar
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverTabBarDelegate(
            TabBar(
              controller: _tabController,
              indicatorColor: context.colors.primary,
              indicatorWeight: 3,
              labelColor: context.colors.primary,
              unselectedLabelColor: isDark
                  ? context.textSecondary
                  : context.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Trader'),
                Tab(text: 'Terms'),
              ],
            ),
            isDark,
          ),
        ),

        // Tab content
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(offer, isDark),
              _buildTraderTab(offer, isDark),
              _buildTermsTab(offer, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(P2POfferEntity offer, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price and amount info
          _buildInfoCard(
            'Trading Information',
            [
              _InfoRow('Price',
                  '\$${offer.priceConfig.finalPrice.toStringAsFixed(2)} per ${offer.currency}'),
              _InfoRow('Available Amount',
                  '${offer.amountConfig.total.toStringAsFixed(8)} ${offer.currency}'),
              _InfoRow('Order Limit',
                  '${offer.amountConfig.min?.toStringAsFixed(2)} - ${offer.amountConfig.max?.toStringAsFixed(2)} USD'),
              if (offer.priceConfig.model == P2PPriceModel.margin)
                _InfoRow(
                    'Margin', '${offer.marginPercentage.toStringAsFixed(2)}%'),
            ],
            isDark,
          ),

          const SizedBox(height: 16),

          // Payment methods
          _buildInfoCard(
            'Payment Methods',
            (offer.paymentMethods ?? [])
                .map((method) => _InfoRow('', method))
                .toList(),
            isDark,
          ),

          const SizedBox(height: 16),

          // Trade settings
          _buildInfoCard(
            'Trade Settings',
            [
              _InfoRow(
                  'Auto Cancel', '${offer.tradeSettings.autoCancel} minutes'),
              _InfoRow('KYC Required',
                  offer.tradeSettings.kycRequired ? 'Yes' : 'No'),
              _InfoRow('Visibility',
                  offer.tradeSettings.visibility.name.toUpperCase()),
            ],
            isDark,
          ),

          const SizedBox(height: 120), // Space for floating button
        ],
      ),
    );
  }

  Widget _buildTraderTab(P2POfferEntity offer, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trader profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.borderColor,
              ),
            ),
            child: Column(
              children: [
                // Avatar and basic info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                      child: Text(
                        offer.userId.substring(0, 2).toUpperCase(),
                        style: TextStyle(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trader ${offer.userId.substring(0, 8)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: context.warningColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '4.8 (156 reviews)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
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
                    IconButton(
                      onPressed: () => _showTraderProfile(offer.userId),
                      icon: const Icon(Icons.person_outline),
                      tooltip: 'View Profile',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TraderStat(
                        'Completion Rate', '98.5%', Icons.check_circle_outline),
                    _TraderStat('Avg. Response', '2 min', Icons.access_time),
                    _TraderStat('Total Trades', '1,250', Icons.swap_horiz),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Trust indicators
          _buildInfoCard(
            'Trust & Verification',
            [
              _InfoRow('Email Verified', '✓', color: context.colors.primary),
              _InfoRow('Phone Verified', '✓', color: context.colors.primary),
              _InfoRow('KYC Verified', '✓', color: context.colors.primary),
              _InfoRow('Trusted Trader', '✓', color: context.colors.primary),
            ],
            isDark,
          ),

          const SizedBox(height: 120), // Space for floating button
        ],
      ),
    );
  }

  Widget _buildTermsTab(P2POfferEntity offer, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Terms of trade
          if (offer.tradeSettings.termsOfTrade != null)
            _buildInfoCard(
              'Terms of Trade',
              [_InfoRow('', offer.tradeSettings.termsOfTrade!)],
              isDark,
            ),

          if (offer.tradeSettings.termsOfTrade != null)
            const SizedBox(height: 16),

          // Additional notes
          if (offer.tradeSettings.additionalNotes != null)
            _buildInfoCard(
              'Additional Notes',
              [_InfoRow('', offer.tradeSettings.additionalNotes!)],
              isDark,
            ),

          if (offer.tradeSettings.additionalNotes != null)
            const SizedBox(height: 16),

          // User requirements
          if (offer.userRequirements != null)
            _buildInfoCard(
              'User Requirements',
              [
                if (offer.userRequirements!.minCompletedTrades != null)
                  _InfoRow('Min Completed Trades',
                      '${offer.userRequirements!.minCompletedTrades}'),
                if (offer.userRequirements!.minSuccessRate != null)
                  _InfoRow('Min Success Rate',
                      '${offer.userRequirements!.minSuccessRate}%'),
                if (offer.userRequirements!.minAccountAge != null)
                  _InfoRow('Min Account Age',
                      '${offer.userRequirements!.minAccountAge} days'),
                if (offer.userRequirements!.trustedOnly == true)
                  _InfoRow('Trusted Traders Only', 'Yes'),
              ],
              isDark,
            ),

          const SizedBox(height: 120), // Space for floating button
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<_InfoRow> rows, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ...rows
              .map((row) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (row.label.isNotEmpty)
                          Text(
                            row.label,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        if (row.label.isNotEmpty) const Spacer(),
                        Text(
                          row.value,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: row.color,
                                  ),
                        ),
                      ],
                    ),
                  ))
              ,
        ],
      ),
    );
  }

  Widget _TraderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: context.colors.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.colors.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showReportDialog(P2POfferEntity offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Offer'),
        content: const Text('Report this offer for violating platform rules?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement report functionality
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _shareOffer(P2POfferEntity offer) {
    // Implement share functionality
  }

  void _showTraderProfile(String userId) {
    // Navigate to trader profile
  }

  void _initiateTrade(P2POfferEntity offer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Text(
                      '${offer.currency} ${offer.type == P2PTradeType.buy ? 'BUY' : 'SELL'}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Quick trade form will be implemented in Step 7',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow(this.label, this.value, {this.color});
  final String label;
  final String value;
  final Color? color;
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _SliverTabBarDelegate(this.tabBar, this.isDark);

  final TabBar tabBar;
  final bool isDark;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: context.colors.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}
