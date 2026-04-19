import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/cart_entity.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/orders/orders_bloc.dart';
import '../bloc/orders/orders_event.dart';
import '../widgets/cart_summary_widget.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  bool _orderComplete = false;
  String _orderNumber = '';

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _couponController = TextEditingController();

  // State variables
  bool _isApplyingCoupon = false;
  double _discountAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _couponController.dispose();
    super.dispose();
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
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate to orders tab in shop page
                  },
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

        // Bottom summary and checkout button
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.cardBackground,
            border: Border(
              top: BorderSide(color: context.borderColor),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CartSummaryWidget(
                cart: cart,
                onCheckout: _handleCheckout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTab(BuildContext context, CartEntity cart) {
    return Padding(
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

          // Wallet cards for each currency group
          Expanded(
            child: ListView.builder(
              itemCount: _getCartGroups(cart).length,
              itemBuilder: (context, index) {
                final group = _getCartGroups(cart)[index];
                return _buildWalletCard(context, group);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Coupon section
          _buildCouponSection(context),
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

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'Shipping Information',
              style: context.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your shipping details for physical products',
              style: context.bodyM.copyWith(color: context.textSecondary),
            ),
            const SizedBox(height: 24),

            // Name fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contact fields
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Email is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Phone number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Address fields
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Street Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'City is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      labelText: 'State/Province',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: InputDecoration(
                      labelText: 'Postal Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Postal code is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Country is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, CartGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
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
                      '${group.walletType} - ${group.currency}',
                      style: context.labelL.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      '${group.items.length} item(s) • ${group.total.toStringAsFixed(2)} ${group.currency}',
                      style:
                          context.bodyS.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
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
                Text(
                  'Payment will be processed using your ${group.currency} wallet',
                  style: context.bodyS.copyWith(color: context.priceUpColor),
                ),
              ],
            ),
          ),

          // Product list
          const SizedBox(height: 12),
          ...group.items.map((item) => _buildProductItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, CartItemEntity item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              item.product.isDigital ? Icons.cloud_download : Icons.inventory,
              size: 16,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.product.name,
              style: context.bodyS.copyWith(color: context.textPrimary),
            ),
          ),
          Text(
            '${item.product.price} ${item.product.currency} × ${item.quantity}',
            style: context.bodyS.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
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
            'Coupon Code (Optional)',
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isApplyingCoupon ? null : _applyCoupon,
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
          if (_discountAmount > 0) ...[
            const SizedBox(height: 12),
            Container(
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
                      'Coupon applied! You save \$${_discountAmount.toStringAsFixed(2)}',
                      style:
                          context.bodyS.copyWith(color: context.priceUpColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<CartGroup> _getCartGroups(CartEntity cart) {
    final groups = <String, CartGroup>{};

    for (final item in cart.items) {
      final key = '${item.product.walletType.name}-${item.product.currency}';

      if (!groups.containsKey(key)) {
        groups[key] = CartGroup(
          walletType: item.product.walletType.name,
          currency: item.product.currency,
          items: [],
          total: 0.0,
        );
      }

      groups[key]!.items.add(item);
      groups[key]!.total += item.product.price * item.quantity;
    }

    return groups.values.toList();
  }

  bool _hasPhysicalProducts(CartEntity cart) {
    return cart.items.any((item) => item.product.type == ProductType.physical);
  }

  Future<void> _applyCoupon() async {
    if (_couponController.text.trim().isEmpty) return;

    setState(() {
      _isApplyingCoupon = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _discountAmount = 10.0; // Mock discount
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coupon applied successfully!'),
            backgroundColor: context.priceUpColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply coupon'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isApplyingCoupon = false;
      });
    }
  }

  Future<void> _handleCheckout() async {
    final cartState = context.read<CartBloc>().state;
    if (cartState is! CartLoaded) return;

    // Validate form if shipping is required
    if (_hasPhysicalProducts(cartState.cart) &&
        _tabController.index == 1 &&
        !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate order processing
      await Future.delayed(const Duration(seconds: 3));

      // Generate order number
      _orderNumber =
          'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      if (!mounted) return;

      // Add order placed event
      context.read<OrdersBloc>().add(const LoadOrdersRequested());

      // Clear cart
      context.read<CartBloc>().add(const ClearCartRequested());

      setState(() {
        _orderComplete = true;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: context.priceUpColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order failed: ${e.toString()}'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }
}

class CartGroup {
  final String walletType;
  final String currency;
  final List<CartItemEntity> items;
  double total;

  CartGroup({
    required this.walletType,
    required this.currency,
    required this.items,
    required this.total,
  });
}
