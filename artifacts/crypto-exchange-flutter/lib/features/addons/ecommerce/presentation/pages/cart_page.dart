import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/widgets/app_loading_indicator.dart';
import '../../../../../core/widgets/app_error_widget.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/checkout/checkout_bloc.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/cart_summary_widget.dart';
import '../widgets/empty_cart_widget.dart';
import 'checkout_page_v5.dart';
import 'package:get_it/get_it.dart';

class CartPage extends StatefulWidget {
  const CartPage({
    super.key,
    this.onSwitchToShop,
    this.onSwitchToOrders,
  });

  final VoidCallback? onSwitchToShop;
  final VoidCallback? onSwitchToOrders;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // Load cart when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CartBloc>().add(const LoadCartRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildHeader(context),

            // Cart Content
            Expanded(
              child: _buildCartContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: context.horizontalPadding.copyWith(top: 16, bottom: 12),
      decoration: BoxDecoration(
        color: context.cardBackground,
        border: Border(
          bottom: BorderSide(
            color: context.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Cart Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_cart_rounded,
              color: context.colors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Title and Item Count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shopping Cart',
                  style: context.h5.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    if (state is CartLoaded) {
                      final itemCount = state.cart.itemCount;
                      return Text(
                        itemCount == 0
                            ? 'Cart is empty'
                            : '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                        style: context.bodyS.copyWith(
                          color: context.textTertiary,
                        ),
                      );
                    }
                    return Text(
                      'Loading...',
                      style: context.bodyS.copyWith(
                        color: context.textTertiary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Clear Cart Button
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.cart.items.isNotEmpty) {
                return TextButton.icon(
                  onPressed: () => _showClearCartDialog(context),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: context.priceDownColor,
                  ),
                  label: Text(
                    'Clear',
                    style: context.labelM.copyWith(
                      color: context.priceDownColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    backgroundColor: context.priceDownColor.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLoadingIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading your cart...',
                  style: context.bodyM.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is CartError) {
          return Center(
            child: AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<CartBloc>().add(const LoadCartRequested());
              },
            ),
          );
        }

        if (state is CartLoaded) {
          if (state.cart.items.isEmpty) {
            return EmptyCartWidget(onSwitchToShop: widget.onSwitchToShop);
          }

          return _buildCartItems(context, state);
        }

        return Center(
          child: Text(
            'Something went wrong',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartItems(BuildContext context, CartLoaded state) {
    return Column(
      children: [
        // Items List
        Expanded(
          child: CustomScrollView(
            slivers: [
              // Cart Items
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = state.cart.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CartItemWidget(item: item),
                      );
                    },
                    childCount: state.cart.items.length,
                  ),
                ),
              ),

              // Spacing for checkout button
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),

        // Cart Summary - Fixed at bottom
        Container(
          decoration: BoxDecoration(
            color: context.cardBackground,
            border: Border(
              top: BorderSide(
                color: context.borderColor,
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: context.isDarkMode
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: CartSummaryWidget(
              cart: state.cart,
              onCheckout: () => _handleCheckout(context),
            ),
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: context.warningColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Clear Cart',
              style: context.h6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart? This action cannot be undone.',
          style: context.bodyM,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: context.labelM.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<CartBloc>().add(const ClearCartRequested());
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: context.priceDownColor.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Clear Cart',
              style: context.labelM.copyWith(
                color: context.priceDownColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(BuildContext context) async {
    // Capture the CartBloc before navigation
    final cartBloc = context.read<CartBloc>();

    // Navigate to V5 checkout page
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cartBloc),
            BlocProvider(create: (context) => GetIt.instance<CheckoutBloc>()),
          ],
          child: const CheckoutPageV5(),
        ),
      ),
    );

    if (result == 'orders') {
      widget.onSwitchToOrders?.call();
    }
  }
}
