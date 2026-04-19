import 'package:equatable/equatable.dart';

import '../../../../../core/constants/api_constants.dart';
import 'product_entity.dart';

class CartEntity extends Equatable {
  final List<CartItemEntity> items;
  final double total;
  final String currency;

  const CartEntity({
    required this.items,
    required this.total,
    this.currency = 'USD',
  });

  @override
  List<Object?> get props => [items, total, currency];

  CartEntity copyWith({
    List<CartItemEntity>? items,
    double? total,
    String? currency,
  }) {
    return CartEntity(
      items: items ?? this.items,
      total: total ?? this.total,
      currency: currency ?? this.currency,
    );
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  // JSON Serialization - simplified
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'currency': currency,
    };
  }

  factory CartEntity.fromJson(Map<String, dynamic> json) {
    return CartEntity(
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItemEntity.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}

class CartItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;
  final double total;

  CartItemEntity({
    required this.product,
    required this.quantity,
    double? total,
  }) : total = total ?? (product.price * quantity);

  @override
  List<Object?> get props => [product, quantity, total];

  CartItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
    double? total,
  }) {
    final newProduct = product ?? this.product;
    final newQuantity = quantity ?? this.quantity;
    final newTotal = total ?? (newProduct.price * newQuantity);

    return CartItemEntity(
      product: newProduct,
      quantity: newQuantity,
      total: newTotal,
    );
  }

  // JSON Serialization - store essential product data only
  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'productName': product.name,
      'productPrice': product.price,
      'productCurrency': product.currency,
      'productImage': product.image,
      'quantity': quantity,
      'total': total,
    };
  }

  // For fromJson, we'll need to reconstruct a minimal ProductEntity
  // This is a simplified approach - in production you might want to fetch the full product
  factory CartItemEntity.fromJson(Map<String, dynamic> json) {
    final product = ProductEntity(
      id: json['productId'] as String,
      name: json['productName'] as String,
      slug: '', // We don't store slug in cart
      description: '',
      shortDescription: '',
      type: ProductType.downloadable, // Default, will be fetched if needed
      price: (json['productPrice'] as num).toDouble(),
      currency: json['productCurrency'] as String,
      walletType: WalletType.spot, // Default
      inventoryQuantity: 999, // Default high value
      status: true,
      image: json['productImage'] as String?,
    );

    return CartItemEntity(
      product: product,
      quantity: json['quantity'] as int,
      total: (json['total'] as num).toDouble(),
    );
  }
}
