import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection/injection.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../bloc/market_bloc.dart';
import '../widgets/market_list_item.dart';
import '../widgets/market_list_header.dart';
import '../widgets/market_search_bar.dart';
import '../widgets/market_tab_bar.dart';
import '../widgets/market_filter_chips.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<MarketBloc>()..add(const MarketLoadRequested()),
      child: const _MarketPageContent(),
    );
  }
}

class _MarketPageContent extends StatefulWidget {
  const _MarketPageContent();

  @override
  State<_MarketPageContent> createState() => _MarketPageContentState();
}

class _MarketPageContentState extends State<_MarketPageContent>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;
  int _selectedFilter = 0;
  String _selectedCategory = 'All';
  bool _compactMode = true; // Default to compact mode
  MarketSortColumn _sortColumn = MarketSortColumn.none;
  bool _sortAscending = true;

  // Keep reference to BLoC for safe disposal
  MarketBloc? _marketBloc;

  final List<String> _tabTitles = [
    'All Markets',
    'Gainers',
    'Losers',
    'High Vol',
    'Trending',
    'Hot',
  ];

  // Dynamic categories will be populated from BLoC state
  List<String> _categoryTitles = ['All'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);

    // Subscribe to global real-time updates (don't control the WebSocket)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _marketBloc = context.read<MarketBloc>();
      // Don't start/stop WebSocket - it's managed globally
      // Just subscribe to the global stream
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();

    // Don't stop WebSocket - it's global and persistent
    // The WebSocket service manages its own lifecycle

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Don't control WebSocket based on app lifecycle
    // The global WebSocket service handles reconnection automatically
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // WebSocket stays connected globally
        break;
      case AppLifecycleState.resumed:
        // WebSocket should already be connected globally
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _onSearchChanged() {
    context.read<MarketBloc>().add(
          MarketSearchRequested(query: _searchController.text),
        );
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
    context.read<MarketBloc>().add(
          MarketFilterChanged(filter: _tabTitles[index]),
        );
  }

  void _onCategoryChanged(int index) {
    setState(() {
      _selectedFilter = index;
      _selectedCategory = _categoryTitles[index];
    });
    context.read<MarketBloc>().add(
          MarketCategoryChanged(category: _categoryTitles[index]),
        );
  }

  void _toggleDensity() {
    setState(() {
      _compactMode = !_compactMode;
    });
  }

  void _sortByColumn(MarketSortColumn column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
    // TODO: Add sorting implementation in BLoC if needed
  }

  Future<void> _onRefresh() async {
    context.read<MarketBloc>().add(const MarketRefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    final searchBarHeight = _compactMode ? 42.0 : 48.0;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar and Density Toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, 10, 16, 6), // Reduced vertical padding
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: MarketSearchBar(
                      controller: _searchController,
                      hintText: 'Search markets',
                      isCompact: _compactMode,
                    ),
                  ),

                  // Density Toggle Button - Improved, more elegant design
                  GestureDetector(
                    onTap: _toggleDensity,
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: searchBarHeight, // Match search bar height
                      height: searchBarHeight, // Match search bar height
                      decoration: BoxDecoration(
                        color: _compactMode
                            ? context.colors.primary.withValues(alpha: 0.08)
                            : context.cardBackground,
                        borderRadius:
                            BorderRadius.circular(_compactMode ? 12 : 14),
                        border: Border.all(
                          color: _compactMode
                              ? context.colors.primary.withValues(alpha: 0.3)
                              : context.dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _compactMode
                              ? Icons.view_list_rounded
                              : Icons.view_headline_rounded,
                          color: _compactMode
                              ? context.colors.primary
                              : context.textSecondary,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar (reduced vertical spacing)
            MarketTabBar(
              tabs: _tabTitles.map((title) => MarketTab(title: title)).toList(),
              currentIndex: _selectedTab,
              onTap: _onTabChanged,
              isCompact: _compactMode,
            ),

            // Filter Chips - Dynamic categories from BLoC (minimal vertical space)
            BlocBuilder<MarketBloc, MarketState>(
              buildWhen: (previous, current) {
                // Only rebuild when categories change
                if (previous is MarketLoaded && current is MarketLoaded) {
                  return previous.availableCategories !=
                      current.availableCategories;
                }
                return current is MarketLoaded;
              },
              builder: (context, state) {
                if (state is MarketLoaded) {
                  // Update local categories when state changes
                  if (_categoryTitles != state.availableCategories) {
                    _categoryTitles = state.availableCategories;
                    // Reset selected filter if it's out of bounds
                    if (_selectedFilter >= _categoryTitles.length) {
                      _selectedFilter = 0;
                      _selectedCategory = 'All';
                    }
                  }
                }

                return MarketFilterChips(
                  filters: _categoryTitles
                      .map((title) => MarketFilter(title: title))
                      .toList(),
                  selectedIndex: _selectedFilter,
                  onFilterTap: _onCategoryChanged,
                  isCompact: _compactMode,
                );
              },
            ),

            // Minimal space before header
            const SizedBox(height: 2),

            // List Header
            MarketListHeader(
              sortColumn: _sortColumn,
              ascending: _sortAscending,
              compact: _compactMode,
              onSortByPair: () => _sortByColumn(MarketSortColumn.pair),
              onSortByPrice: () => _sortByColumn(MarketSortColumn.price),
              onSortByChange: () => _sortByColumn(MarketSortColumn.change),
            ),

            // Market List
            Expanded(
              child: BlocBuilder<MarketBloc, MarketState>(
                builder: (context, state) {
                  if (state is MarketLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: context.colors.primary,
                      ),
                    );
                  }

                  if (state is MarketError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: context.colors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load markets',
                            style: context.h5.copyWith(
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.failure.message,
                            style: context.bodyM.copyWith(
                              color: context.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => context
                                .read<MarketBloc>()
                                .add(const MarketLoadRequested()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is MarketLoaded) {
                    final markets = state.filteredMarkets;

                    if (markets.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: context.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No markets found for "${_searchController.text}"'
                                  : 'No markets available',
                              style: context.bodyM.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: context.colors.primary,
                      backgroundColor: context.cardBackground,
                      child: Stack(
                        children: [
                          ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(
                              bottom: 16,
                              left: _compactMode ? 0 : 16,
                              right: _compactMode ? 0 : 16,
                            ),
                            itemCount: markets.length,
                            itemBuilder: (context, index) {
                              final market = markets[index];
                              return Column(
                                children: [
                                  MarketListItem(
                                    marketData: market,
                                    compact: _compactMode,
                                  ),
                                  if (!_compactMode &&
                                      index < markets.length - 1)
                                    const SizedBox(
                                        height:
                                            12), // Add spacing between items in normal mode
                                ],
                              );
                            },
                          ),
                          if (state.isLoading || state.isRefreshing)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: 2,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    context.colors.primary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
