import 'package:equatable/equatable.dart';

import '../../../../../../core/constants/api_constants.dart';
import '../../../../../../core/errors/failures.dart';
import '../../../domain/entities/cart_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/shipping_entity.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutLoaded extends CheckoutState {
  final CartEntity cart;
  final Map<String, List<WalletOption>> availableWallets;
  final Map<String, String> selectedWallets;
  final Map<String, String?> walletErrors;
  final Map<String, bool> walletLoading;
  final AddressEntity? shippingAddress;
  final ShippingMethodEntity? shippingMethod;
  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;
  final DiscountData? appliedDiscount;
  final List<ShippingMethodEntity> shippingMethods;
  final List<AddressEntity> shippingAddresses;

  const CheckoutLoaded({
    required this.cart,
    this.availableWallets = const {},
    this.selectedWallets = const {},
    this.walletErrors = const {},
    this.walletLoading = const {},
    this.shippingAddress,
    this.shippingMethod,
    required this.subtotal,
    this.shipping = 0.0,
    this.tax = 0.0,
    this.discount = 0.0,
    required this.total,
    this.appliedDiscount,
    this.shippingMethods = const [],
    this.shippingAddresses = const [],
  });

  @override
  List<Object?> get props => [
        cart,
        availableWallets,
        selectedWallets,
        walletErrors,
        walletLoading,
        shippingAddress,
        shippingMethod,
        subtotal,
        shipping,
        tax,
        discount,
        total,
        appliedDiscount,
        shippingMethods,
        shippingAddresses,
      ];

  bool get hasPhysicalProducts =>
      cart.items.any((item) => item.product.type == ProductType.physical);

  bool get isWalletSelectionComplete =>
      cartByWallet.keys.every((key) => selectedWallets.containsKey(key));

  bool get hasWalletErrors => walletErrors.values.any((error) => error != null);

  Map<String, CartGroup> get cartByWallet {
    final groups = <String, CartGroup>{};

    for (final item in cart.items) {
      final key = '${item.product.walletType.name}-${item.product.currency}';

      if (!groups.containsKey(key)) {
        groups[key] = CartGroup(
          walletType: item.product.walletType,
          currency: item.product.currency,
          items: [],
          total: 0.0,
        );
      }

      groups[key]!.items.add(item);
      groups[key]!.total += item.product.price * item.quantity;
    }

    return groups;
  }

  CheckoutLoaded copyWith({
    CartEntity? cart,
    Map<String, List<WalletOption>>? availableWallets,
    Map<String, String>? selectedWallets,
    Map<String, String?>? walletErrors,
    Map<String, bool>? walletLoading,
    AddressEntity? shippingAddress,
    ShippingMethodEntity? shippingMethod,
    double? subtotal,
    double? shipping,
    double? tax,
    double? discount,
    double? total,
    DiscountData? appliedDiscount,
    List<ShippingMethodEntity>? shippingMethods,
    List<AddressEntity>? shippingAddresses,
  }) {
    return CheckoutLoaded(
      cart: cart ?? this.cart,
      availableWallets: availableWallets ?? this.availableWallets,
      selectedWallets: selectedWallets ?? this.selectedWallets,
      walletErrors: walletErrors ?? this.walletErrors,
      walletLoading: walletLoading ?? this.walletLoading,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      subtotal: subtotal ?? this.subtotal,
      shipping: shipping ?? this.shipping,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      appliedDiscount: appliedDiscount ?? this.appliedDiscount,
      shippingMethods: shippingMethods ?? this.shippingMethods,
      shippingAddresses: shippingAddresses ?? this.shippingAddresses,
    );
  }
}

class CheckoutProcessing extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final OrderEntity order;

  const CheckoutSuccess(this.order);

  @override
  List<Object> get props => [order];
}

class CheckoutError extends CheckoutState {
  final Failure failure;

  const CheckoutError(this.failure);

  @override
  List<Object> get props => [failure];
}

// Helper classes
class WalletOption extends Equatable {
  final String id;
  final String name;
  final String type;
  final String currency;
  final double balance;

  const WalletOption({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.balance,
  });

  @override
  List<Object> get props => [id, name, type, currency, balance];
}

class CartGroup extends Equatable {
  final WalletType walletType;
  final String currency;
  final List<CartItemEntity> items;
  double total;

  CartGroup({
    required this.walletType,
    required this.currency,
    required this.items,
    required this.total,
  });

  @override
  List<Object> get props => [walletType, currency, items, total];
}

class DiscountData extends Equatable {
  final String id;
  final String code;
  final String type;
  final double value;
  final String message;

  const DiscountData({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.message,
  });

  @override
  List<Object> get props => [id, code, type, value, message];
}
