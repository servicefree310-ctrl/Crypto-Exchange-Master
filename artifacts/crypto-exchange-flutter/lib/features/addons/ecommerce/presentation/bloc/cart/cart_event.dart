part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class LoadCartRequested extends CartEvent {
  const LoadCartRequested();
}

class AddToCartRequested extends CartEvent {
  final ProductEntity product;
  final int quantity;

  const AddToCartRequested({
    required this.product,
    this.quantity = 1,
  });

  @override
  List<Object> get props => [product, quantity];
}

class UpdateCartItemQuantityRequested extends CartEvent {
  final String productId;
  final int quantity;

  const UpdateCartItemQuantityRequested({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object> get props => [productId, quantity];
}

class RemoveFromCartRequested extends CartEvent {
  final String productId;

  const RemoveFromCartRequested({required this.productId});

  @override
  List<Object> get props => [productId];
}

class ClearCartRequested extends CartEvent {
  const ClearCartRequested();
}
