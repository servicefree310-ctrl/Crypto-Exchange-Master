import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';


import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/add_review_cubit.dart';
import '../bloc/wishlist/wishlist_bloc.dart';
import '../bloc/wishlist/wishlist_event.dart';
import '../bloc/wishlist/wishlist_state.dart';
import '../widgets/review_form_modal.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  double _imageOpacity = 1.0;
  int _quantity = 1;
  bool _isAddingToCart = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    setState(() {
      _imageOpacity = 1 - (scrollOffset / 300).clamp(0, 1);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleAddToCart(BuildContext context) async {
    if (_isAddingToCart || !widget.product.isInStock) return;

    setState(() => _isAddingToCart = true);
    HapticFeedback.mediumImpact();

    // Add a small delay for better UX (similar to v5)
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    context.read<CartBloc>().add(
          AddToCartRequested(
            product: widget.product,
            quantity: _quantity,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.product.name} added to cart',
        ),
        backgroundColor: context.priceUpColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            // Close this page and show cart message
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Item added! Check the Cart tab to view all items.'),
                backgroundColor: const Color(0xFF6C5CE7),
                action: SnackBarAction(
                  label: 'Got it',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          },
        ),
      ),
    );

    setState(() => _isAddingToCart = false);
  }

  void _handleWishlistToggle(BuildContext context, bool isInWishlist) {
    HapticFeedback.lightImpact();

    if (isInWishlist) {
      context.read<WishlistBloc>().add(
            RemoveFromWishlistRequested(productId: widget.product.id),
          );
    } else {
      context.read<WishlistBloc>().add(
            AddToWishlistRequested(product: widget.product),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.instance<WishlistBloc>()
            ..add(const LoadWishlistRequested()),
        ),
      ],
      child: Scaffold(
        backgroundColor: context.background,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Modern Sliver App Bar with Image
                SliverAppBar(
                  expandedHeight: 350,
                  pinned: true,
                  backgroundColor: context.cardBackground,
                  surfaceTintColor: Colors.transparent,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? Colors.black.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: context.textPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    BlocBuilder<WishlistBloc, WishlistState>(
                      builder: (context, state) {
                        bool isInWishlist = false;
                        if (state is WishlistLoaded) {
                          isInWishlist = state.products
                              .any((p) => p.id == widget.product.id);
                        }

                        return Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.isDarkMode
                                ? Colors.black.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                isInWishlist
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey(isInWishlist),
                                color: isInWishlist
                                    ? context.colors.error
                                    : context.textPrimary,
                              ),
                            ),
                            onPressed: () =>
                                _handleWishlistToggle(context, isInWishlist),
                          ),
                        );
                      },
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? Colors.black.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.share,
                          color: context.textPrimary,
                        ),
                        onPressed: () {
                          // Share functionality
                          HapticFeedback.lightImpact();
                          // TODO: Implement share
                        },
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildImageGallery(context),
                  ),
                ),

                // Product Content
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      color: context.background,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Info Card
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: context.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: context.isDarkMode
                                      ? Colors.black.withValues(alpha: 0.2)
                                      : Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Name and Price
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.product.name,
                                            style: context.h4.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (widget.product.category != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: context.colors.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: context.colors.primary
                                                      .withValues(alpha: 0.3),
                                                ),
                                              ),
                                              child: Text(
                                                widget.product.category!.name,
                                                style: context.labelS.copyWith(
                                                  color: context.colors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          widget.product.currency,
                                          style: context.labelM.copyWith(
                                            color: context.textTertiary,
                                          ),
                                        ),
                                        if (widget.product.isOnSale) ...[
                                          Text(
                                            widget.product.price
                                                .toStringAsFixed(2),
                                            style: context.bodyM.copyWith(
                                              color: context.textTertiary,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                          Text(
                                            widget.product.effectivePrice
                                                .toStringAsFixed(2),
                                            style: context.h3.copyWith(
                                              color: context.priceUpColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ] else
                                          Text(
                                            widget.product.price
                                                .toStringAsFixed(2),
                                            style: context.h3.copyWith(
                                              color: context.colors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Rating and Reviews
                                if (widget.product.rating != null &&
                                    widget.product.rating! > 0)
                                  _buildRatingSection(context),

                                const SizedBox(height: 20),

                                // Stock Status
                                _buildStockStatus(context),

                                const SizedBox(height: 20),

                                // Description
                                _buildDescriptionSection(context),
                              ],
                            ),
                          ),

                          // Specifications
                          _buildSpecificationsCard(context),

                          // Reviews Section
                          _buildReviewsSection(context),

                          const SizedBox(height: 100), // Space for bottom sheet
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Action Sheet
            _buildBottomSheet(context),
          ],
        ),
      ),
    );
  }

  List<String> get _allImages {
    final images = <String>[];
    if (widget.product.image != null) {
      images.add(widget.product.image!);
    }
    for (final img in widget.product.images) {
      if (!images.contains(img)) {
        images.add(img);
      }
    }
    return images;
  }

  Widget _buildImageGallery(BuildContext context) {
    final images = _allImages;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (images.isNotEmpty)
          Opacity(
            opacity: _imageOpacity,
            child: images.length > 1
                ? PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        _getImageUrl(images[index]),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildImagePlaceholder(context),
                      );
                    },
                  )
                : Image.network(
                    _getImageUrl(images.first),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildImagePlaceholder(context),
                  ),
          )
        else
          _buildImagePlaceholder(context),

        // Image indicators
        if (images.length > 1)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentImageIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? context.colors.primary
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

        // Gradient Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  context.background.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ),

        // Sale Badge
        if (widget.product.isOnSale)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 16,
            child: _buildBadge(
              context,
              icon: Icons.local_offer_outlined,
              label: 'Sale',
              color: context.priceUpColor,
            ),
          ),

        // Type Badge
        if (widget.product.isDigital)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            right: 16,
            child: _buildBadge(
              context,
              icon: Icons.cloud_download_outlined,
              label: '${widget.product.typeDisplayText} Product',
              color: context.colors.tertiary,
            ),
          ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    if (widget.product.rating == null || widget.product.reviewsCount == null || widget.product.reviewsCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviews',
                style: context.h6.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => BlocProvider(
                      create: (_) => GetIt.instance<AddReviewCubit>(),
                      child: ReviewFormModal(productId: widget.product.id),
                    ),
                  );
                },
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text('Write a Review'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rating Summary
          Row(
            children: [
              Column(
                children: [
                  Text(
                    widget.product.rating!.toStringAsFixed(1),
                    style: context.h2.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      final rating = widget.product.rating!;
                      return Icon(
                        index < rating.floor()
                            ? Icons.star_rounded
                            : index < rating
                                ? Icons.star_half_rounded
                                : Icons.star_outline_rounded,
                        color: context.warningColor,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.product.reviewsCount} reviews',
                    style: context.labelS.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    final totalPrice = widget.product.price * _quantity;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total Price Display
            if (_quantity > 1)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total ($_quantity items)',
                      style: context.bodyM.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    Text(
                      '${widget.product.currency} ${totalPrice.toStringAsFixed(2)}',
                      style: context.labelL.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                // Quantity Selector
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1
                            ? () {
                                HapticFeedback.lightImpact();
                                setState(() => _quantity--);
                              }
                            : null,
                        icon: const Icon(Icons.remove),
                        color: _quantity > 1
                            ? context.textPrimary
                            : context.textTertiary,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _quantity > 99 ? 50 : 40,
                        child: Text(
                          _quantity.toString(),
                          style: context.h6.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: _quantity < widget.product.inventoryQuantity
                            ? () {
                                HapticFeedback.lightImpact();
                                setState(() => _quantity++);
                              }
                            : null,
                        icon: const Icon(Icons.add),
                        color: _quantity < widget.product.inventoryQuantity
                            ? context.textPrimary
                            : context.textTertiary,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Add to Cart Button
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton(
                      onPressed: widget.product.isInStock && !_isAddingToCart
                          ? () => _handleAddToCart(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isAddingToCart
                            ? Row(
                                key: const ValueKey('loading'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Adding...',
                                    style: context.labelL.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                key: const ValueKey('idle'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.shopping_cart_outlined),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.product.isInStock
                                        ? 'Add to Cart'
                                        : 'Out of Stock',
                                    style: context.labelL.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => BlocProvider(
            create: (_) => GetIt.instance<AddReviewCubit>(),
            child: ReviewFormModal(productId: widget.product.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ...List.generate(5, (index) {
              final rating = widget.product.rating ?? 0.0;
              return Icon(
                index < rating.floor()
                    ? Icons.star_rounded
                    : index < rating
                        ? Icons.star_half_rounded
                        : Icons.star_outline_rounded,
                color: context.warningColor,
                size: 24,
              );
            }),
            const SizedBox(width: 12),
            Text(
              widget.product.rating!.toStringAsFixed(1),
              style: context.h6.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${widget.product.reviewsCount} reviews)',
              style: context.bodyM.copyWith(
                color: context.textTertiary,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: context.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatus(BuildContext context) {
    final isInStock = widget.product.isInStock;
    final isLowStock = widget.product.isLowStock;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isInStock
            ? (isLowStock
                ? context.warningColor.withValues(alpha: 0.1)
                : context.priceUpColor.withValues(alpha: 0.1))
            : context.priceDownColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isInStock
              ? (isLowStock ? context.warningColor : context.priceUpColor)
              : context.priceDownColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isInStock ? Icons.check_circle : Icons.error,
            color: isInStock
                ? (isLowStock ? context.warningColor : context.priceUpColor)
                : context.priceDownColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isInStock
                      ? (isLowStock ? 'Low Stock' : 'In Stock')
                      : 'Out of Stock',
                  style: context.labelL.copyWith(
                    color: isInStock
                        ? (isLowStock
                            ? context.warningColor
                            : context.priceUpColor)
                        : context.priceDownColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isInStock)
                  Text(
                    '${widget.product.inventoryQuantity} units available',
                    style: context.labelS.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: context.h6.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.product.description.isNotEmpty
              ? widget.product.description
              : widget.product.shortDescription.isNotEmpty
                  ? widget.product.shortDescription
                  : 'No description available.',
          style: context.bodyM.copyWith(
            color: context.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecificationsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specifications',
            style: context.h6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildSpecRow(
              context, 'Product Type', widget.product.typeDisplayText),
          _buildSpecRow(context, 'Payment Type',
              widget.product.walletType.name.toUpperCase()),
          _buildSpecRow(context, 'Currency', widget.product.currency),
          if (widget.product.category != null)
            _buildSpecRow(context, 'Category', widget.product.category!.name),
        ],
      ),
    );
  }

  Widget _buildSpecRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.bodyM.copyWith(
              color: context.textTertiary,
            ),
          ),
          Text(
            value,
            style: context.bodyM.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.labelS.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: context.colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 80,
          color: context.textTertiary.withValues(alpha: 0.3),
        ),
      ),
    );
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
