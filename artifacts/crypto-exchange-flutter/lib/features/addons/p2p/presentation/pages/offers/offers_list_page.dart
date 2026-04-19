import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/common/p2p_state_widgets.dart';
import '../../widgets/offers/offer_card.dart';
import '../../widgets/offers/offers_filter_bar.dart';
import '../../bloc/offers/offers_bloc.dart';
import '../../bloc/offers/offers_event.dart';
import '../../bloc/offers/offers_state.dart';

/// P2P Offers List Page - KuCoin style compact design
/// Following v5 patterns with advanced filtering and search
class OffersListPage extends StatefulWidget {
  const OffersListPage({super.key});

  @override
  State<OffersListPage> createState() => _OffersListPageState();
}

class _OffersListPageState extends State<OffersListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  final String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};

  // Trading pair filter options (KuCoin style)
  final List<String> _tradingPairs = [
    'All',
    'BTC/USDT',
    'ETH/USDT',
    'BNB/USDT',
    'ADA/USDT',
    'SOL/USDT',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _searchController = TextEditingController();
    _loadOffers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadOffers() {
    // Load offers based on current tab and filters
    final offerType = _tabController.index == 0 ? 'BUY' : 'SELL';
    context.read<OffersBloc>().add(OffersLoadRequested(
          type: offerType,
        ));
  }

  void _onTabChanged() {
    _loadOffers();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Close to the bottom – load more if possible
      context.read<OffersBloc>().add(const OffersLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          context.colors.surface,
      body: Column(
        children: [
          // Trading Type Tabs (Buy/Sell)
          _buildTradingTypeTabs(isDark),

          // Filter Bar
          OffersFilterBar(
            tradingPairs: _tradingPairs,
            onFiltersChanged: (filters) {
              setState(() => _activeFilters = filters);
              _loadOffers();
            },
          ),

          // Search bar
          _buildSearchBar(isDark),

          // Offers List
          Expanded(
            child: _buildOffersList(),
          ),
        ],
      ),
      floatingActionButton: _buildCreateOfferFAB(),
    );
  }

  Widget _buildTradingTypeTabs(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(
            color: context.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => _onTabChanged(),
        indicatorColor: context.colors.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: context.colors.primary,
        unselectedLabelColor:
            context.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 18,
                  color: _tabController.index == 0
                      ? context.buyColor
                      : (isDark
                          ? context.textSecondary
                          : context.textSecondary),
                ),
                const SizedBox(width: 8),
                Text('Buy',
                    style: TextStyle(
                      color:
                          _tabController.index == 0 ? context.buyColor : null,
                    )),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sell_outlined,
                  size: 18,
                  color: _tabController.index == 1
                      ? context.sellColor
                      : (isDark
                          ? context.textSecondary
                          : context.textSecondary),
                ),
                const SizedBox(width: 8),
                Text('Sell',
                    style: TextStyle(
                      color:
                          _tabController.index == 1 ? context.sellColor : null,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: context.colors.surface,
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          context.read<OffersBloc>().add(OffersSearchRequested(value));
        },
        decoration: InputDecoration(
          hintText: 'Search offers…',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: context.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: context.borderColor,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildOffersList() {
    return BlocBuilder<OffersBloc, OffersState>(
      builder: (context, state) {
        if (state is OffersLoading) {
          return const P2PShimmerLoading(
            itemCount: 8,
            itemHeight: 120,
          );
        }

        if (state is OffersError) {
          return P2PErrorWidget(
            message: state.failure.message,
            onRetry: _loadOffers,
          );
        }

        if (state is OffersLoaded) {
          final offers = state.offers;

          if (offers.isEmpty) {
            return P2PEmptyStateWidget(
              title: 'No Offers Found',
              message: _tabController.index == 0
                  ? 'No buy offers available. Try adjusting your filters.'
                  : 'No sell offers available. Try adjusting your filters.',
              icon: Icons.search_off,
              actionText: 'Create Offer',
              onAction: () => Navigator.pushNamed(context, '/p2p/offer/create'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadOffers(),
            color: context.colors.primary,
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return OfferCard(
                  offer: offer,
                  onTap: () => _navigateToOfferDetail(offer.id),
                  onTrade: () => _initiateTradeDialog(offer),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCreateOfferFAB() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(context, '/p2p/offer/create'),
      backgroundColor: context.colors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add, size: 20),
      label: const Text(
        'Create Offer',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _navigateToOfferDetail(String offerId) {
    Navigator.pushNamed(
      context,
      '/p2p/offer/$offerId',
    );
  }

  void _initiateTradeDialog(dynamic offer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTradeBottomSheet(offer),
    );
  }

  Widget _buildTradeBottomSheet(dynamic offer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trade Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Trade form will be implemented in next steps
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(16),
                  children: [
                    Text(
                      'Trade form will be implemented in next steps',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
