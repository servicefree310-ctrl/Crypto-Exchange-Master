import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_entity.dart';

abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {
  const WishlistInitial();
}

class WishlistLoading extends WishlistState {
  const WishlistLoading();
}

class WishlistLoaded extends WishlistState {
  final List<ProductEntity> products;

  const WishlistLoaded({required this.products});

  @override
  List<Object?> get props => [products];

  WishlistLoaded copyWith({
    List<ProductEntity>? products,
  }) {
    return WishlistLoaded(
      products: products ?? this.products,
    );
  }
}

class WishlistError extends WishlistState {
  final String message;
  final List<ProductEntity>? previousProducts;

  const WishlistError({
    required this.message,
    this.previousProducts,
  });

  @override
  List<Object?> get props => [message, previousProducts];
}

class WishlistItemAddedToCart extends WishlistState {
  final ProductEntity product;
  final List<ProductEntity> products;

  const WishlistItemAddedToCart({
    required this.product,
    required this.products,
  });

  @override
  List<Object?> get props => [product, products];
}
