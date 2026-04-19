import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/cart/cart_bloc.dart';
import '../pages/product_detail_page.dart';
import '../bloc/wishlist/wishlist_bloc.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.width,
    this.aspectRatio = 1.2,
    this.showCategory = true,
    this.showRating = true,
    this.showWishlistIcon = false,
    this.isInWishlist = false,
    this.onAddToCart,
    this.onWishlistToggle,
  });

  final ProductEntity product;
  final double? width;
  final double aspectRatio;
  final bool showCategory;
  final bool showRating;
  final bool showWishlistIcon;
  final bool isInWishlist;
  final VoidCallback? onAddToCart;
  final VoidCallback? onWishlistToggle;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _navigateToDetail() async {
    try {
      // Try to access existing BLoCs from context
      final cartBloc = context.read<CartBloc>();
      final wishlistBloc = context.read<WishlistBloc>();

      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: cartBloc),
              BlocProvider.value(value: wishlistBloc),
            ],
            child: ProductDetailPage(product: widget.product),
          ),
        ),
      );

      // If user wants to view cart, try to find parent ShopPage and switch to cart tab
      if (result == 'show_cart' && mounted) {
        _switchToCartTab();
      }
    } catch (e) {
      if (!mounted) return;
      // If BLoCs are not available, create new instances for this navigation
      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => GetIt.instance<CartBloc>()),
              BlocProvider(create: (_) => GetIt.instance<WishlistBloc>()),
            ],
            child: ProductDetailPage(product: widget.product),
          ),
        ),
      );

      // If user wants to view cart, try to find parent ShopPage and switch to cart tab
      if (result == 'show_cart' && mounted) {
        _switchToCartTab();
      }
    }
  }

  void _switchToCartTab() {
    // Try to find the nearest ShopPage and switch to cart tab
    // Since we can't directly access the ShopPage state, we'll use a workaround
    // by popping until we find the shop page and passing the instruction
    Navigator.of(context).popUntil((route) {
      return route.settings.name == null || route.isFirst;
    });

    // Use a delayed call to ensure the shop page has time to rebuild
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        // Send a message to switch to cart tab through the root navigator
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (_) => Container(), // This will be popped immediately
            settings: const RouteSettings(name: '/switch_to_cart'),
          ),
        )
            .then((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _navigateToDetail,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width,
              decoration: BoxDecoration(
                color:
                    context.isDarkMode ? context.colors.surface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isHovered
                      ? context.colors.primary.withValues(alpha: 0.3)
                      : context.borderColor.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.isDarkMode
                        ? Colors.black.withValues(alpha: _isHovered ? 0.3 : 0.2)
                        : Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.04),
                    blurRadius: _isHovered ? 20 : 12,
                    offset: Offset(0, _isHovered ? 6 : 4),
                    spreadRadius: _isHovered ? -2 : -4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Section
                  _buildImageSection(context),

                  // Product Info Section
                  _buildInfoSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final imageHeight =
        widget.width != null ? widget.width! / widget.aspectRatio : 140.0;

    return Container(
      height: imageHeight,
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? context.colors.surfaceContainerHighest.withValues(alpha: 0.2)
            : context.colors.surfaceContainerHighest.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Product Image
          if (widget.product.image != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                _getImageUrl(widget.product.image!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(context),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: context.colors.surfaceContainerHighest.withValues(alpha: 0.1),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.colors.primary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            _buildImagePlaceholder(context),

          // Top badges
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side badges
                Row(
                  children: [
                    // Out of stock badge
                    if (widget.product.inventoryQuantity == 0)
                      _buildCompactBadge(
                        context,
                        label: 'Out of Stock',
                        color: context.priceDownColor,
                        icon: Icons.remove_shopping_cart,
                      )
                    // Low stock badge
                    else if (widget.product.inventoryQuantity <= 5)
                      _buildCompactBadge(
                        context,
                        label: '${widget.product.inventoryQuantity} left',
                        color: context.warningColor,
                        icon: Icons.local_fire_department,
                      ),

                    // Product type badge
                    if (widget.product.isDigital) ...[
                      if (widget.product.inventoryQuantity == 0 ||
                          widget.product.inventoryQuantity <= 5)
                        const SizedBox(width: 8),
                      _buildCompactBadge(
                        context,
                        label: widget.product.typeDisplayText,
                        color: context.colors.tertiary,
                        icon: Icons.cloud_download,
                      ),
                    ],
                  ],
                ),

                // Wishlist icon (right side)
                if (widget.showWishlistIcon)
                  GestureDetector(
                    onTap: widget.onWishlistToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isInWishlist
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: widget.isInWishlist
                            ? context.colors.error
                            : context.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category (if available) - made more compact
            if (widget.showCategory && widget.product.category != null) ...[
              Text(
                widget.product.category!.name.toUpperCase(),
                style: context.labelS.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontSize: 9,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
            ],

            // Product Name - reduced to 1 line for compact layout
            Tooltip(
              message: widget.product.name,
              child: Text(
                widget.product.name,
                style: context.labelM.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Flexible spacer to push content to bottom
            const Spacer(),

            // Rating (condensed) - only show if there's space
            if (widget.showRating &&
                widget.product.rating != null &&
                widget.product.rating! > 0) ...[
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 12,
                    color: context.warningColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    widget.product.rating!.toStringAsFixed(1),
                    style: context.labelS.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            // Price and Cart Row - more compact
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Price with responsive text
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatPrice(widget.product.price),
                          style: context.labelL.copyWith(
                            color: widget.product.isInStock
                                ? context.colors.primary
                                : context.textTertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Stock status text - smaller
                      if (!widget.product.isInStock)
                        Text(
                          'Out of Stock',
                          style: context.labelS.copyWith(
                            color: context.priceDownColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 9,
                          ),
                        ),
                    ],
                  ),
                ),

                // Add to Cart Button - smaller
                _buildAddToCartButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactBadge(
    BuildContext context, {
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.labelS.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 36,
            color: context.textTertiary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: context.labelS.copyWith(
              color: context.textTertiary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    final isEnabled = widget.product.isInStock;

    return GestureDetector(
      onTap: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              if (widget.onAddToCart != null) {
                widget.onAddToCart!();
              } else {
                try {
                  context.read<CartBloc>().add(
                        AddToCartRequested(
                          product: widget.product,
                          quantity: 1,
                        ),
                      );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${widget.product.name} added to cart! Check the Cart tab.'),
                      backgroundColor: context.priceUpColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: 'View Cart',
                        textColor: Colors.white,
                        onPressed: () {
                          // This message will guide users to use the Cart tab
                        },
                      ),
                    ),
                  );
                } catch (e) {
                  // If CartBloc is not available, show a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please go to main shop to add to cart'),
                      backgroundColor: context.colors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isEnabled
              ? (_isHovered
                  ? context.colors.primary.withValues(alpha: 0.9)
                  : context.colors.primary)
              : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isEnabled && _isHovered
              ? [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          Icons.add_shopping_cart_rounded,
          size: 16,
          color:
              isEnabled ? Colors.white : context.textTertiary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    // Format price based on value
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(2)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(2)}K';
    } else if (price < 0.01) {
      return price.toStringAsFixed(6);
    } else if (price < 1) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(2);
    }
  }

  String _getImageUrl(String imageUrl) {
    // Check if the URL is already absolute
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // If it's a relative URL, prepend the base URL
    if (imageUrl.startsWith('/')) {
      return '${ApiConstants.baseUrl}$imageUrl';
    }

    // Otherwise, assume it needs a leading slash
    return '${ApiConstants.baseUrl}/$imageUrl';
  }
}
