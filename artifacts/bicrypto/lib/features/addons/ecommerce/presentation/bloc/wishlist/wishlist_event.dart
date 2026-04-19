import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_entity.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWishlistRequested extends WishlistEvent {
  const LoadWishlistRequested();
}

class AddToWishlistRequested extends WishlistEvent {
  final ProductEntity product;

  const AddToWishlistRequested({required this.product});

  @override
  List<Object?> get props => [product];
}

class RemoveFromWishlistRequested extends WishlistEvent {
  final String productId;

  const RemoveFromWishlistRequested({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class AddWishlistItemToCartRequested extends WishlistEvent {
  final ProductEntity product;

  const AddWishlistItemToCartRequested({required this.product});

  @override
  List<Object?> get props => [product];
}

class ClearWishlistRequested extends WishlistEvent {
  const ClearWishlistRequested();
}
