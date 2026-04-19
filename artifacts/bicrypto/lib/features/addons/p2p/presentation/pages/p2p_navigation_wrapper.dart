import 'package:flutter/material.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/common/p2p_app_bar.dart';
import '../widgets/common/p2p_bottom_nav.dart';
import '../bloc/offers/offers_bloc.dart';
import '../bloc/offers/offers_event.dart';
import '../bloc/trades/trades_bloc.dart';
import 'p2p_home_page.dart';
import 'offers/offers_list_page.dart';
import 'offers/create_offer_page.dart';
import 'trades/trades_list_page.dart';
import 'guided_matching/matching_criteria_page.dart';
import 'package:get_it/get_it.dart';
import '../bloc/matching/guided_matching_bloc.dart';
import '../bloc/payment_methods/payment_methods_bloc.dart';
import '../bloc/offers/create_offer_bloc.dart';
import '../bloc/offers/create_offer_event.dart';

/// P2P Navigation Wrapper - Main entry point for P2P features
/// Follows v5 layout with tab-based navigation and KuCoin styling
class P2PNavigationWrapper extends StatefulWidget {
  const P2PNavigationWrapper({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<P2PNavigationWrapper> createState() => _P2PNavigationWrapperState();
}

class _P2PNavigationWrapperState extends State<P2PNavigationWrapper> {
  late int _currentIndex;
  late PageController _pageController;

  // Navigation items matching v5 structure
  final List<P2PNavItem> _navItems = [
    P2PNavItem(
      title: 'P2P Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    P2PNavItem(
      title: 'Offers',
      icon: Icons.local_offer_outlined,
      activeIcon: Icons.local_offer,
      label: 'Offers',
    ),
    P2PNavItem(
      title: 'My Trades',
      icon: Icons.swap_horiz_outlined,
      activeIcon: Icons.swap_horiz,
      label: 'Trades',
    ),
    P2PNavItem(
      title: 'Market',
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Market',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GetIt.instance<OffersBloc>(),
        ),
        BlocProvider(
          create: (context) => GetIt.instance<TradesBloc>(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? context.colors.surface
            : context.colors.surface,
        appBar: P2PAppBar(
          title: _navItems[_currentIndex].title,
          showSearch: _currentIndex == 1, // Show search on Offers page
          showFilters: _currentIndex == 1 ||
              _currentIndex == 2, // Show filters on Offers and Trades
          onSearchChanged: (query) {
            // Handle search
            if (_currentIndex == 1) {
              // Search offers
              context.read<OffersBloc>().add(OffersSearchRequested(query));
            }
          },
          onFiltersPressed: () {
            // Show filters bottom sheet
            _showFiltersBottomSheet(context);
          },
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: [
            const P2PHomePage(),
            const OffersListPage(),
            const TradesListPage(),
            const Center(child: Text('Market - Coming Soon')),
          ],
        ),
        bottomNavigationBar: P2PBottomNavigation(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    // Show create offer FAB on Home and Offers pages
    if (_currentIndex == 0 || _currentIndex == 1) {
      return FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create offer page with a fresh CreateOfferBloc
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider<CreateOfferBloc>(
                create: (_) =>
                    GetIt.I<CreateOfferBloc>()..add(const CreateOfferStarted()),
                child: const CreateOfferPage(),
              ),
            ),
          );
        },
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
    return null;
  }

  void _showFiltersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? context.colors.surface
                  : context.colors.surface,
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? context.borderColor
                        : context.borderColor,
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
                        'Filters',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Clear filters
                          if (_currentIndex == 1) {
                            context
                                .read<OffersBloc>()
                                .add(const OffersFiltersClearRequested());
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ),
                // Filters content would go here
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Text('Filter options will be implemented in next steps'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// P2P Navigation Item Model
class P2PNavItem {
  const P2PNavItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String title;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// P2P Route Generator
class P2PRoutes {
  static const String home = '/p2p';
  static const String offers = '/p2p/offers';
  static const String createOffer = '/p2p/offer/create';
  static const String offerDetail = '/p2p/offer';
  static const String trades = '/p2p/trades';
  static const String tradeDetail = '/p2p/trade';
  static const String market = '/p2p/market';
  static const String guidedMatching = '/p2p/guided-matching';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const P2PNavigationWrapper(),
          settings: settings,
        );
      case offers:
        return MaterialPageRoute(
          builder: (_) => const P2PNavigationWrapper(initialIndex: 1),
          settings: settings,
        );
      case trades:
        return MaterialPageRoute(
          builder: (_) => const P2PNavigationWrapper(initialIndex: 2),
          settings: settings,
        );
      case market:
        return MaterialPageRoute(
          builder: (_) => const P2PNavigationWrapper(initialIndex: 3),
          settings: settings,
        );
      case guidedMatching:
        return MaterialPageRoute(
          builder: (_) {
            final sl = GetIt.instance;
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<GuidedMatchingBloc>()),
                BlocProvider(create: (_) => sl<PaymentMethodsBloc>()),
              ],
              child: const MatchingCriteriaPage(),
            );
          },
          settings: settings,
        );
      default:
        return null;
    }
  }
}
