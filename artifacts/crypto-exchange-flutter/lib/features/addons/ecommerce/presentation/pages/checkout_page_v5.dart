import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/discount_entity.dart';
import '../../domain/entities/shipping_entity.dart';
import '../../domain/usecases/place_order_usecase.dart';
import '../../domain/usecases/validate_discount_usecase.dart';
import '../bloc/cart/cart_bloc.dart';

class CheckoutPageV5 extends StatefulWidget {
  const CheckoutPageV5({super.key});

  @override
  State<CheckoutPageV5> createState() => _CheckoutPageV5State();
}

class _CheckoutPageV5State extends State<CheckoutPageV5>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _couponController = TextEditingController();

  // State management
  bool _isProcessing = false;
  bool _orderComplete = false;
  bool _isApplyingCoupon = false;
  String _orderNumber = '';

  // Form data
  final _formData = <String, String>{};

  // Discount state
  DiscountEntity? _appliedDiscount;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeFormData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _initializeFormData() {
    _formData.addAll({
      'firstName': '',
      'lastName': '',
      'email': '',
      'phone': '',
      'address': '',
      'city': '',
      'state': '',
      'postalCode': '',
      'country': '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: context.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        backgroundColor: context.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          if (cartState is! CartLoaded || cartState.cart.items.isEmpty) {
            return _buildEmptyCart(context);
          }

          if (_orderComplete) {
            return _buildOrderComplete(context, cartState.cart);
          }

          return _buildCheckoutForm(context, cartState.cart);
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: context.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: context.h6.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to your cart before checking out',
            style: context.bodyM.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Browse Products',
              style: context.buttonText(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderComplete(BuildContext context, CartEntity cart) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.priceUpColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.check_circle,
              size: 40,
              color: context.priceUpColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Order Complete!',
            style: context.h4.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thank you for your order. We\'ve received your payment and will process your order shortly.',
            style: context.bodyL.copyWith(color: context.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              children: [
                Text(
                  'Order Number',
                  style: context.labelM.copyWith(color: context.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  _orderNumber,
                  style: context.h6.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: context.borderColor),
                  ),
                  child: Text(
                    'Continue Shopping',
                    style: context.buttonText(color: context.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop('orders'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'View Orders',
                    style: context.buttonText(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutForm(BuildContext context, CartEntity cart) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderColor),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: context.colors.primary,
            unselectedLabelColor: context.textSecondary,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: context.colors.primary.withValues(alpha: 0.1),
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment, size: 16),
                    const SizedBox(width: 8),
                    Text('Payment'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_shipping, size: 16),
                    const SizedBox(width: 8),
                    Text('Shipping'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPaymentTab(context, cart),
              _buildShippingTab(context, cart),
            ],
          ),
        ),

        // Order summary and checkout button
        _buildOrderSummary(context, cart),
      ],
    );
  }

  Widget _buildPaymentTab(BuildContext context, CartEntity cart) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: context.h6.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your items will be paid for using your cryptocurrency wallets',
            style: context.bodyM.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: 24),

          // Coupon section
          _buildCouponSection(context),
        ],
      ),
    );
  }

  Widget _buildCouponSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coupon Code (optional)',
            style: context.labelM.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  enabled: !_isApplyingCoupon,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed:
                    _isApplyingCoupon || _couponController.text.trim().isEmpty
                        ? null
                        : _validateCoupon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                child: _isApplyingCoupon
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'Apply',
                        style: context.buttonText(),
                      ),
              ),
            ],
          ),
          if (_appliedDiscount != null) ...[
            const SizedBox(height: 12),
            _buildDiscountAppliedWidget(context),
          ],
        ],
      ),
    );
  }

  Widget _buildDiscountAppliedWidget(BuildContext context) {
    if (_appliedDiscount == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.priceUpColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: context.priceUpColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _appliedDiscount!.message ?? 'Discount applied successfully!',
              style: context.bodyS.copyWith(color: context.priceUpColor),
            ),
          ),
          TextButton(
            onPressed: _removeCoupon,
            child: Text(
              'Remove',
              style: context.bodyS.copyWith(color: context.priceUpColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingTab(BuildContext context, CartEntity cart) {
    if (!_hasPhysicalProducts(cart)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_download,
              size: 80,
              color: context.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Shipping Required',
              style: context.h6.copyWith(color: context.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Your cart contains only digital products',
              style: context.bodyM.copyWith(color: context.textSecondary),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Information',
              style: context.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildFormField('firstName', 'First Name', isRequired: true),
            const SizedBox(height: 16),
            _buildFormField('lastName', 'Last Name', isRequired: true),
            const SizedBox(height: 16),
            _buildFormField('email', 'Email', isRequired: true),
            const SizedBox(height: 16),
            _buildFormField('phone', 'Phone', isRequired: true),
            const SizedBox(height: 16),
            _buildFormField('address', 'Street Address', isRequired: true),
            const SizedBox(height: 16),
            _buildFormField('city', 'City', isRequired: true),
            const SizedBox(height: 16),
            _buildFormField('state', 'State / Province', isRequired: true),
            const SizedBox(height: 16),
            _buildFormField('postalCode', 'Postal Code', isRequired: true),
            const SizedBox(height: 16),
            _buildFormField('country', 'Country', isRequired: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String key, String label, {bool isRequired = false}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: (value) => _formData[key] = value,
      validator: isRequired
          ? (value) {
              if (value?.isEmpty ?? true) {
                return '$label is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartEntity cart) {
    final subtotal = _calculateSubtotal(cart);
    final discountAmount = _calculateDiscountAmount(subtotal);
    final total = subtotal - discountAmount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBackground,
        border: Border(
          top: BorderSide(color: context.borderColor),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: context.bodyM),
              Text('\$${subtotal.toStringAsFixed(2)}', style: context.bodyM),
            ],
          ),
          if (discountAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Discount', style: context.bodyM),
                Text(
                  '-\$${discountAmount.toStringAsFixed(2)}',
                  style: context.bodyM.copyWith(color: context.priceUpColor),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Tax and shipping calculated by server',
            style: context.bodyS.copyWith(color: context.textTertiary),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Total',
                style: context.h6.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: context.h6.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () => _processOrder(cart),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Processing...',
                          style: context.buttonText(),
                        ),
                      ],
                    )
                  : Text(
                      'Complete Order',
                      style: context.buttonText(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool _hasPhysicalProducts(CartEntity cart) {
    return cart.items.any((item) => item.product.type == ProductType.physical);
  }

  double _calculateSubtotal(CartEntity cart) {
    return cart.items
        .fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double _calculateDiscountAmount(double subtotal) {
    if (_appliedDiscount == null || !_appliedDiscount!.isValid) return 0.0;
    return _appliedDiscount!.calculateDiscount(subtotal);
  }

  // Event handlers
  Future<void> _validateCoupon() async {
    if (_couponController.text.trim().isEmpty) return;

    setState(() {
      _isApplyingCoupon = true;
    });

    try {
      final validateDiscountUseCase = GetIt.instance<ValidateDiscountUseCase>();

      final result = await validateDiscountUseCase(
        ValidateDiscountParams(code: _couponController.text.trim()),
      );

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: context.colors.error,
            ),
          );
        },
        (discount) {
          if (discount.isValid) {
            setState(() {
              _appliedDiscount = discount;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(discount.message ?? 'Coupon applied successfully!'),
                backgroundColor: context.priceUpColor,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(discount.message ?? 'Invalid coupon code'),
                backgroundColor: context.colors.error,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to validate coupon: ${e.toString()}'),
          backgroundColor: context.colors.error,
        ),
      );
    } finally {
      setState(() {
        _isApplyingCoupon = false;
      });
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedDiscount = null;
      _couponController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon removed'),
      ),
    );
  }

  Future<void> _processOrder(CartEntity cart) async {
    // Validate shipping form for physical products
    if (_hasPhysicalProducts(cart)) {
      if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
        _tabController.animateTo(1); // Switch to shipping tab
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all required shipping fields'),
            backgroundColor: context.colors.error,
          ),
        );
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final placeOrderUseCase = GetIt.instance<PlaceOrderUseCase>();

      // Build shipping address for backend (only for physical products)
      Map<String, String>? shippingAddress;
      if (_hasPhysicalProducts(cart)) {
        shippingAddress = {
          'name': '${_formData['firstName'] ?? ''} ${_formData['lastName'] ?? ''}'.trim(),
          'email': _formData['email'] ?? '',
          'phone': _formData['phone'] ?? '',
          'street': _formData['address'] ?? '',
          'city': _formData['city'] ?? '',
          'state': _formData['state'] ?? '',
          'postalCode': _formData['postalCode'] ?? '',
          'country': _formData['country'] ?? '',
        };
      }

      final result = await placeOrderUseCase(PlaceOrderParams(
        items: cart.items,
        totalAmount: _calculateSubtotal(cart),
        currency: cart.currency,
        paymentMethod: 'wallet',
        shippingAddress: shippingAddress,
        discountId: _appliedDiscount?.id,
      ));

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _isProcessing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order failed: ${failure.message}'),
              backgroundColor: context.colors.error,
            ),
          );
        },
        (order) {
          // Clear cart after successful order
          context.read<CartBloc>().add(const ClearCartRequested());

          setState(() {
            _orderNumber = order.orderNumber;
            _orderComplete = true;
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: context.priceUpColor,
            ),
          );
        },
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order failed: ${e.toString()}'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }
}
