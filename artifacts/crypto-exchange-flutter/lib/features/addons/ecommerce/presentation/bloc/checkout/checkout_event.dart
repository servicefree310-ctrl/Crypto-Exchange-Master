import 'package:equatable/equatable.dart';

import '../../../domain/entities/cart_entity.dart';
import '../../../domain/entities/shipping_entity.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class CheckoutInitialized extends CheckoutEvent {
  final CartEntity cart;

  const CheckoutInitialized(this.cart);

  @override
  List<Object> get props => [cart];
}

class WalletsLoaded extends CheckoutEvent {
  final String walletType;
  final String currency;

  const WalletsLoaded({
    required this.walletType,
    required this.currency,
  });

  @override
  List<Object> get props => [walletType, currency];
}

class WalletSelected extends CheckoutEvent {
  final String walletKey;
  final String walletId;

  const WalletSelected({
    required this.walletKey,
    required this.walletId,
  });

  @override
  List<Object> get props => [walletKey, walletId];
}

class ShippingAddressUpdated extends CheckoutEvent {
  final AddressEntity address;

  const ShippingAddressUpdated(this.address);

  @override
  List<Object> get props => [address];
}

class ShippingMethodSelected extends CheckoutEvent {
  final ShippingMethodEntity method;

  const ShippingMethodSelected(this.method);

  @override
  List<Object> get props => [method];
}

class CouponApplied extends CheckoutEvent {
  final String couponCode;

  const CouponApplied(this.couponCode);

  @override
  List<Object> get props => [couponCode];
}

class CouponRemoved extends CheckoutEvent {}

class OrderPlaced extends CheckoutEvent {}

class CheckoutReset extends CheckoutEvent {}
