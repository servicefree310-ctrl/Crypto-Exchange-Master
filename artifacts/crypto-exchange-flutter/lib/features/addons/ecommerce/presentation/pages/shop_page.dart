import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/widgets/app_loading_indicator.dart';
import '../../../../../core/widgets/app_error_widget.dart';
import '../bloc/shop/shop_bloc.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/wishlist/wishlist_bloc.dart';
import '../widgets/shop/category_section.dart';
import '../widgets/shop/featured_products_section.dart';
import '../widgets/shop/shop_header.dart';
import '../widgets/shop/products_grid.dart';
import '../widgets/shop/shop_search_bar.dart';
import 'wishlist_page.dart';
import 'orders_page.dart';
import 'cart_page.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.I<ShopBloc>()..add(const ShopLoadRequested()),
        ),
        BlocProvider(
          create: (_) => GetIt.instance<CartBloc>(),
        ),
        BlocProvider(
          create: (_) => GetIt.instance<WishlistBloc>(),
        ),
      ],
      child: const _ShopView(),
    );
  }
}

class _ShopView extends StatefulWidget {
  const _ShopView();

  @override
  State<_ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<_ShopView> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _ShopHomePage(onCartTap: _onCartTap, onOrdersTap: _onOrdersTap),
      CartPage(onSwitchToShop: _switchToShopTab, onSwitchToOrders: _onOrdersTap),
      WishlistPage(onSwitchToShop: _switchToShopTab),
      const OrdersPage(),
    ];
  }

  void _onCartTap() {
    setState(() {
      _currentIndex = 1; // Navigate to Cart tab
    });
  }

  void _onOrdersTap() {
    setState(() {
      _currentIndex = 3; // Navigate to Orders tab
    });
  }

  void _switchToShopTab() {
    setState(() {
      _currentIndex = 0; // Navigate to Shop tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.store_outlined,
                activeIcon: Icons.store,
                label: 'Shop',
              ),
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  int itemCount = 0;
                  if (state is CartLoaded) {
                    itemCount = state.cart.itemCount;
                  }

                  return _buildNavItemWithBadge(
                    context,
                    index: 1,
                    icon: Icons.shopping_cart_outlined,
                    activeIcon: Icons.shopping_cart,
                    label: 'Cart',
                    badgeCount: itemCount,
                  );
                },
              ),
              _buildNavItem(
                context,
                index: 2,
                icon: Icons.favorite_outline,
                activeIcon: Icons.favorite,
                label: 'Wishlist',
              ),
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'Orders',
              ),
              _buildNavItem(
                context,
                index: 4,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _currentIndex == index;
    final color = isActive ? context.colors.primary : context.textTertiary;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 4) {
            // Navigate back to main app when Home is tapped
            Navigator.of(context).pop();
          } else {
            setState(() => _currentIndex = index);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.labelS.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int badgeCount,
  }) {
    final isActive = _currentIndex == index;
    final color = isActive ? context.colors.primary : context.textTertiary;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 4) {
            // Navigate back to main app when Home is tapped
            Navigator.of(context).pop();
          } else {
            setState(() => _currentIndex = index);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: color,
                  size: 24,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.labelS.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopHomePage extends StatelessWidget {
  final VoidCallback onCartTap;
  final VoidCallback onOrdersTap;

  const _ShopHomePage({
    required this.onCartTap,
    required this.onOrdersTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: context.colors.surface,
            automaticallyImplyLeading: false,
            title: Text(
              '${AppConstants.appName} Shop',
              style: context.h5,
            ),
            actions: [
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  int itemCount = 0;
                  if (state is CartLoaded) {
                    itemCount = state.cart.itemCount;
                  }

                  return IconButton(
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          color: context.textPrimary,
                        ),
                        if (itemCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: context.colors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                itemCount > 99 ? '99+' : itemCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: onCartTap,
                  );
                },
              ),
            ],
          ),

          // Search Bar
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ShopSearchBar(),
            ),
          ),

          // Content
          BlocBuilder<ShopBloc, ShopState>(
            builder: (context, state) {
              if (state is ShopLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: AppLoadingIndicator(),
                  ),
                );
              }

              if (state is ShopError) {
                return SliverFillRemaining(
                  child: Center(
                    child: AppErrorWidget(
                      message: state.message,
                      onRetry: () {
                        context.read<ShopBloc>().add(const ShopLoadRequested());
                      },
                    ),
                  ),
                );
              }

              if (state is ShopLoaded) {
                return SliverList(
                  delegate: SliverChildListDelegate([
                    // Hero Banner
                    const ShopHeader(),

                    // Categories
                    if (state.categories.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      CategorySection(categories: state.categories),
                    ],

                    // Featured Products
                    if (state.featuredProducts.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      FeaturedProductsSection(
                        products: state.featuredProducts,
                      ),
                    ],

                    // All Products
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'All Products',
                            style: context.h6,
                          ),
                          _buildSortButton(context, state),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Products Grid
                    if (state.isLoadingProducts)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: AppLoadingIndicator(size: 32),
                        ),
                      )
                    else
                      ProductsGrid(products: state.products),

                    const SizedBox(height: 24),
                  ]),
                );
              }

              return const SliverFillRemaining(
                child: SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(BuildContext context, ShopLoaded state) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        context.read<ShopBloc>().add(ShopSortChanged(sortBy: value));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: context.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.sort,
              size: 16,
              color: context.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              _getSortLabel(state.sortBy),
              style: context.labelM.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => [
        _buildSortMenuItem('featured', 'Featured'),
        _buildSortMenuItem('price-low', 'Price: Low to High'),
        _buildSortMenuItem('price-high', 'Price: High to Low'),
        _buildSortMenuItem('newest', 'Newest First'),
        _buildSortMenuItem('rating', 'Top Rated'),
      ],
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(String value, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(label),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'price-low':
        return 'Price: Low to High';
      case 'price-high':
        return 'Price: High to Low';
      case 'newest':
        return 'Newest';
      case 'rating':
        return 'Top Rated';
      case 'featured':
      default:
        return 'Featured';
    }
  }
}
