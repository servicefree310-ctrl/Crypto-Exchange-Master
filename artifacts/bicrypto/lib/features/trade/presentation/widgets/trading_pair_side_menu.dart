import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../bloc/trading_pair_selector_bloc.dart';
import 'trading_pair_list_item.dart';
import 'trading_pair_search_bar.dart';
import 'trading_pair_category_tabs.dart';

class TradingPairSideMenu extends StatelessWidget {
  const TradingPairSideMenu({
    super.key,
    required this.onPairSelected,
    this.currentSymbol,
  });

  final Function(String symbol) onPairSelected;
  final String? currentSymbol;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TradingPairSelectorBloc>()
        ..add(const TradingPairSelectorLoadRequested())
        ..add(const TradingPairSelectorStartRealtime()),
      child: _TradingPairSideMenuContent(
        onPairSelected: onPairSelected,
        currentSymbol: currentSymbol,
      ),
    );
  }
}

class _TradingPairSideMenuContent extends StatefulWidget {
  const _TradingPairSideMenuContent({
    required this.onPairSelected,
    this.currentSymbol,
  });

  final Function(String symbol) onPairSelected;
  final String? currentSymbol;

  @override
  State<_TradingPairSideMenuContent> createState() =>
      _TradingPairSideMenuContentState();
}

class _TradingPairSideMenuContentState
    extends State<_TradingPairSideMenuContent>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Setup slide animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<TradingPairSelectorBloc>().add(
          TradingPairSelectorSearchChanged(query: _searchController.text),
        );
  }

  void _onCategoryChanged(String category) {
    context.read<TradingPairSelectorBloc>().add(
          TradingPairSelectorCategoryChanged(category: category),
        );
  }

  void _onPairSelected(String symbol) {
    // Add to recent list
    final bloc = context.read<TradingPairSelectorBloc>();
    bloc.addToRecent(symbol);

    // Close menu with animation
    _animationController.reverse().then((_) {
      widget.onPairSelected(symbol);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final menuWidth = screenWidth * 0.85; // 85% of screen width

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value * menuWidth, 0),
          child: Container(
            width: menuWidth,
            height: double.infinity,
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                _buildHeader(context),

                const SizedBox(height: 16),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TradingPairSearchBar(
                    controller: _searchController,
                    hintText: 'Search pairs, symbols...',
                  ),
                ),

                const SizedBox(height: 12),

                // Category Tabs
                BlocBuilder<TradingPairSelectorBloc, TradingPairSelectorState>(
                  buildWhen: (previous, current) {
                    if (previous is TradingPairSelectorLoaded &&
                        current is TradingPairSelectorLoaded) {
                      return previous.availableCategories !=
                              current.availableCategories ||
                          previous.selectedCategory != current.selectedCategory;
                    }
                    return current is TradingPairSelectorLoaded;
                  },
                  builder: (context, state) {
                    if (state is TradingPairSelectorLoaded) {
                      return TradingPairCategoryTabs(
                        categories: state.availableCategories,
                        selectedCategory: state.selectedCategory,
                        onCategoryChanged: _onCategoryChanged,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 8),

                // Market stats header
                _buildMarketStatsHeader(context),

                const SizedBox(height: 8),

                // Pair List
                Expanded(
                  child: _buildPairList(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.theme.scaffoldBackgroundColor,
            context.inputBackground,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: context.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Premium gradient logo/icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.priceUpColor,
                      context.priceUpColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: context.priceUpColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: Colors.white,
                  size: 18,
                ),
              ),

              const SizedBox(width: 12),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spot Trading',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      'Select Trading Pair',
                      style: TextStyle(
                        color: context.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),

              // Market status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.priceUpColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: context.priceUpColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'LIVE',
                  style: TextStyle(
                    color: context.priceUpColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Close button
              GestureDetector(
                onTap: () {
                  _animationController.reverse().then((_) {
                    Navigator.of(context).pop();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: context.inputBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.close,
                    color: context.textSecondary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketStatsHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.inputBackground,
            context.theme.scaffoldBackgroundColor,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Pair',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Price',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(width: 40),
                    Text(
                      '24h Change',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPairList(BuildContext context) {
    return BlocBuilder<TradingPairSelectorBloc, TradingPairSelectorState>(
      builder: (context, state) {
        if (state is TradingPairSelectorLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: context.priceUpColor,
            ),
          );
        }

        if (state is TradingPairSelectorError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: context.priceDownColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load pairs',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                Text(
                  state.failure.message,
                  style: TextStyle(
                    color: context.textTertiary,
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context
                      .read<TradingPairSelectorBloc>()
                      .add(const TradingPairSelectorLoadRequested()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.priceUpColor,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is TradingPairSelectorLoaded) {
          final pairs = state.filteredPairs;

          if (pairs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: context.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isNotEmpty
                        ? 'No pairs found for "${_searchController.text}"'
                        : 'No pairs available',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: pairs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 0.5),
            itemBuilder: (context, index) {
              final pair = pairs[index];
              return TradingPairListItem(
                pair: pair,
                isSelected: pair.symbol == widget.currentSymbol,
                onTap: () => _onPairSelected(pair.symbol),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
