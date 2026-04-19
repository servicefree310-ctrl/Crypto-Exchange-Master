import 'package:flutter/material.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../pages/categories_page.dart';

class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({
    super.key,
    this.onSwitchToShop,
  });

  final VoidCallback? onSwitchToShop;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty Cart Illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 56,
                    color: context.colors.primary.withValues(alpha: 0.6),
                  ),
                  Positioned(
                    top: 30,
                    right: 30,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Your cart is empty',
              style: context.h5.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Looks like you haven\'t added anything to your cart yet. Start shopping to fill it up!',
              style: context.bodyM.copyWith(
                height: 1.5,
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Continue Shopping Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Use the callback to switch to shop tab
                  if (onSwitchToShop != null) {
                    onSwitchToShop!();
                  } else {
                    // Fallback: show message if callback not available
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tap on "Shop" tab below to browse products',
                          style: context.bodyM.copyWith(color: Colors.white),
                        ),
                        backgroundColor: context.colors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
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
                      'Continue Shopping',
                      style: context.buttonText(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Browse Categories Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CategoriesPage(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.primary,
                  side: BorderSide(
                    color: context.borderColor,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      size: 20,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Browse Categories',
                      style: context.buttonText(color: context.colors.primary),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quick suggestions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.borderColor,
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: context.colors.primary,
                    size: 20,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quick Tips',
                    style: context.labelM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• Browse featured products\n• Check out special offers\n• Explore different categories',
                    style: context.bodyS.copyWith(
                      color: context.textTertiary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
