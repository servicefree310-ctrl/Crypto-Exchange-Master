import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/product_entity.dart';
import 'product_model.dart';

class CartModel extends CartEntity {
  const CartModel({
    required super.items,
    required super.total,
    required super.currency,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItemModel.fromJson(item))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
    );
  }

  factory CartModel.empty() {
    return const CartModel(
      items: [],
      total: 0.0,
      currency: 'USD',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => (item as CartItemModel).toJson()).toList(),
      'total': total,
      'currency': currency,
    };
  }

  CartEntity toEntity() {
    return CartEntity(
      items: items,
      total: total,
      currency: currency,
    );
  }
}

class CartItemModel extends CartItemEntity {
  CartItemModel({
    required super.product,
    required super.quantity,
    required super.total,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product']).toEntity(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'product': ProductModel.fromEntity(product).toJson(),
      'quantity': quantity,
      'total': total,
    };
  }

  factory CartItemModel.fromEntity(ProductEntity product, int quantity) {
    return CartItemModel(
      product: product,
      quantity: quantity,
      total: product.price * quantity,
    );
  }

  @override
  CartItemModel copyWith({
    ProductEntity? product,
    int? quantity,
    double? total,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
    );
  }

  CartItemEntity toEntity() {
    return CartItemEntity(
      product: product,
      quantity: quantity,
      total: total,
    );
  }
}
