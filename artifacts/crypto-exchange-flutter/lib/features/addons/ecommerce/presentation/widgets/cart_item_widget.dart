import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/cart_entity.dart';
import '../bloc/cart/cart_bloc.dart';

class CartItemWidget extends StatefulWidget {
  final CartItemEntity item;

  const CartItemWidget({
    super.key,
    required this.item,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.borderColor,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode
                ? Colors.black.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: widget.item.product.image != null
                      ? Image.network(
                          _getImageUrl(widget.item.product.image!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildImagePlaceholder(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildImagePlaceholder();
                          },
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.product.name,
                      style: context.labelL.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    if (widget.item.product.category != null) ...[
                      Text(
                        widget.item.product.category!.name,
                        style: context.bodyS.copyWith(
                          color: context.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ] else
                      const SizedBox(height: 8),

                    // Price per item
                    Row(
                      children: [
                        Text(
                          'Unit Price: ',
                          style: context.bodyS.copyWith(
                            color: context.textTertiary,
                          ),
                        ),
                        Text(
                          '${widget.item.product.currency} ${widget.item.product.price.toStringAsFixed(2)}',
                          style: context.bodyS.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quantity and Total Row
          Row(
            children: [
              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.borderColor,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onPressed: widget.item.quantity > 1
                          ? () => _updateQuantity(widget.item.quantity - 1)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${widget.item.quantity}',
                        style: context.labelM.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onPressed: () =>
                          _updateQuantity(widget.item.quantity + 1),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Remove Button
              IconButton(
                onPressed: _isLoading ? null : _removeItem,
                icon: Icon(
                  Icons.delete_outline,
                  color: _isLoading
                      ? context.textTertiary
                      : context.priceDownColor,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: context.priceDownColor.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(8),
                ),
              ),

              const SizedBox(width: 12),

              // Total Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: context.bodyS.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                  Text(
                    '${widget.item.product.currency} ${widget.item.total.toStringAsFixed(2)}',
                    style: context.labelL.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.primary,
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

  Widget _buildImagePlaceholder() {
    return Container(
      color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Icon(
        Icons.image_outlined,
        color: context.textTertiary,
        size: 32,
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color:
                onPressed != null ? context.textPrimary : context.textTertiary,
          ),
        ),
      ),
    );
  }

  void _updateQuantity(int newQuantity) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    context.read<CartBloc>().add(
          UpdateCartItemQuantityRequested(
            productId: widget.item.product.id,
            quantity: newQuantity,
          ),
        );

    // Reset loading state after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _removeItem() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    context.read<CartBloc>().add(
          RemoveFromCartRequested(productId: widget.item.product.id),
        );

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.item.product.name} removed from cart',
          style: context.bodyM.copyWith(color: Colors.white),
        ),
        backgroundColor: context.priceDownColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
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
