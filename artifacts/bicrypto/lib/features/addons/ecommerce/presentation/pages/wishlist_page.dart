import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../../core/widgets/app_error_widget.dart';
import '../../../../../../core/widgets/app_loading_indicator.dart';
import '../bloc/wishlist/wishlist_bloc.dart';
import '../bloc/wishlist/wishlist_event.dart';
import '../bloc/wishlist/wishlist_state.dart';
import '../../domain/entities/product_entity.dart';
import '../widgets/product_card.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({
    super.key,
    this.onSwitchToShop,
  });

  final VoidCallback? onSwitchToShop;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<WishlistBloc>()..add(const LoadWishlistRequested()),
      child: _WishlistView(onSwitchToShop: onSwitchToShop),
    );
  }
}

class _WishlistView extends StatelessWidget {
  const _WishlistView({this.onSwitchToShop});

  final VoidCallback? onSwitchToShop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'My Wishlist',
          style: context.h5,
        ),
        actions: [
          BlocBuilder<WishlistBloc, WishlistState>(
            builder: (context, state) {
              if (state is WishlistLoaded && state.products.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    _showClearWishlistDialog(context);
                  },
                  child: Text(
                    'Clear All',
                    style: context.labelM.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<WishlistBloc, WishlistState>(
        listener: (context, state) {
          if (state is WishlistError && state.previousProducts != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.colors.error,
              ),
            );
          } else if (state is WishlistItemAddedToCart) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.product.name} added to cart'),
                backgroundColor: context.colors.primary,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WishlistLoading) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is WishlistError && state.previousProducts == null) {
            return Center(
              child: AppErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<WishlistBloc>().add(
                        const LoadWishlistRequested(),
                      );
                },
              ),
            );
          }

          final products = state is WishlistLoaded
              ? state.products
              : (state is WishlistError
                  ? state.previousProducts ?? []
                  : <ProductEntity>[]);

          if (products.isEmpty) {
            return _EmptyWishlist(
              context: context,
              onSwitchToShop: onSwitchToShop,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<WishlistBloc>().add(
                    const LoadWishlistRequested(),
                  );
            },
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${products.length} ${products.length == 1 ? 'item' : 'items'} saved',
                          style: context.bodyM.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Products Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          showWishlistIcon: true,
                          isInWishlist: true,
                          aspectRatio: 0.7,
                          onWishlistToggle: () {
                            context.read<WishlistBloc>().add(
                                  RemoveFromWishlistRequested(
                                    productId: product.id,
                                  ),
                                );
                          },
                          onAddToCart: () {
                            context.read<WishlistBloc>().add(
                                  AddWishlistItemToCartRequested(
                                    product: product,
                                  ),
                                );
                          },
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showClearWishlistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Clear Wishlist'),
          content: const Text(
            'Are you sure you want to remove all items from your wishlist?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<WishlistBloc>().add(
                      const ClearWishlistRequested(),
                    );
              },
              style: TextButton.styleFrom(
                foregroundColor: context.colors.error,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  final BuildContext context;
  final VoidCallback? onSwitchToShop;

  const _EmptyWishlist({
    required this.context,
    this.onSwitchToShop,
  });

  @override
  Widget build(BuildContext rootContext) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: rootContext.colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 60,
                color: rootContext.colors.onSurface.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your wishlist is empty',
              style: rootContext.h6,
            ),
            const SizedBox(height: 8),
            Text(
              'Save your favorite products here to buy them later',
              style: rootContext.bodyM.copyWith(
                color: rootContext.colors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Use the callback to switch to shop tab
                if (onSwitchToShop != null) {
                  onSwitchToShop!();
                } else {
                  // Fallback: navigate back if callback not available
                  Navigator.popUntil(rootContext, (route) => route.isFirst);
                }
              },
              child: const Text('Browse Products'),
            ),
          ],
        ),
      ),
    );
  }
}
