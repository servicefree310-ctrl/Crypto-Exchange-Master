import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/cart_entity.dart';
import '../../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../../settings/presentation/bloc/settings_state.dart';

class CartSummaryWidget extends StatelessWidget {
  final CartEntity cart;
  final VoidCallback onCheckout;

  const CartSummaryWidget({
    super.key,
    required this.cart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    // Get settings directly from GetIt
    final settingsBloc = GetIt.instance<SettingsBloc>();
    final settingsState = settingsBloc.state;
    final settings =
        settingsState is SettingsLoaded ? settingsState.settings : null;

    final shippingEnabled = settings?.ecommerceShippingEnabled ?? true;
    final shippingCost = settings?.ecommerceDefaultShippingCost ?? 9.99;
    final freeShippingThreshold =
        settings?.ecommerceFreeShippingThreshold ?? 50.0;
    final taxEnabled = settings?.ecommerceTaxEnabled ?? false;
    final taxRate = settings?.ecommerceDefaultTaxRate ?? 0.08;

    final subtotal = cart.total;
    final shipping = !shippingEnabled
        ? 0.0
        : (subtotal >= freeShippingThreshold ? 0.0 : shippingCost);
    final tax = taxEnabled ? subtotal * taxRate : 0.0;
    final total = subtotal + shipping + tax;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Summary',
                style: context.h6.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${cart.itemCount} ${cart.itemCount != 1 ? 'items' : 'item'}',
                  style: context.labelS.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Price Breakdown Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.borderColor,
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                _buildPriceRow(context, 'Subtotal', subtotal, cart.currency),
                const SizedBox(height: 12),
                if (shippingEnabled) ...[
                  _buildPriceRow(
                    context,
                    'Shipping',
                    shipping,
                    cart.currency,
                    isDiscounted: shipping == 0,
                    originalPrice: shipping == 0 ? shippingCost : null,
                  ),
                  const SizedBox(height: 12),
                ],
                if (taxEnabled) ...[
                  _buildPriceRow(context, 'Tax (${(taxRate * 100).toInt()}%)',
                      tax, cart.currency),
                  const SizedBox(height: 12),
                ],

                // Divider (only show if we have shipping or tax)
                if (shippingEnabled || taxEnabled) ...[
                  Container(
                    height: 1,
                    color: context.borderColor,
                  ),
                  const SizedBox(height: 16),
                ],

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: context.h6.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${cart.currency} ${total.toStringAsFixed(2)}',
                      style: context.h6.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Shipping Notice (only if shipping is enabled and free shipping is offered)
          if (shippingEnabled &&
              _shouldShowFreeShippingNotice(freeShippingThreshold))
            _buildShippingNotice(
                context, subtotal, freeShippingThreshold, cart.currency),
          if (shippingEnabled &&
              _shouldShowFreeShippingNotice(freeShippingThreshold))
            const SizedBox(height: 20),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Proceed to Checkout',
                    style: context.buttonText(),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${cart.currency} ${total.toStringAsFixed(2)}',
                      style: context.labelS.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to determine if free shipping notice should be shown
  bool _shouldShowFreeShippingNotice(double freeShippingThreshold) {
    // Only show free shipping notices if:
    // 1. Threshold is greater than 0 (free shipping is offered)
    // 2. Threshold is reasonable (not extremely high to disable feature)
    return freeShippingThreshold > 0 && freeShippingThreshold <= 10000;
  }

  Widget _buildShippingNotice(BuildContext context, double subtotal,
      double freeShippingThreshold, String currency) {
    if (subtotal < freeShippingThreshold) {
      final remaining = freeShippingThreshold - subtotal;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                color: context.colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Free Shipping Available',
                    style: context.labelM.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Add $currency ${remaining.toStringAsFixed(2)} more to qualify',
                    style: context.bodyS.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.priceUpColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.priceUpColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.priceUpColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: context.priceUpColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Shipping Unlocked!',
                  style: context.labelM.copyWith(
                    color: context.priceUpColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Your order qualifies for free shipping',
                  style: context.bodyS.copyWith(
                    color: context.priceUpColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    double amount,
    String currency, {
    bool isDiscounted = false,
    double? originalPrice,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.bodyM.copyWith(
            color: context.textSecondary,
          ),
        ),
        Row(
          children: [
            if (isDiscounted && originalPrice != null) ...[
              Text(
                '$currency ${originalPrice.toStringAsFixed(2)}',
                style: context.bodyS.copyWith(
                  color: context.textTertiary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              isDiscounted && amount == 0
                  ? 'FREE'
                  : '$currency ${amount.toStringAsFixed(2)}',
              style: context.bodyM.copyWith(
                color:
                    isDiscounted ? context.priceUpColor : context.textPrimary,
                fontWeight: isDiscounted ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
