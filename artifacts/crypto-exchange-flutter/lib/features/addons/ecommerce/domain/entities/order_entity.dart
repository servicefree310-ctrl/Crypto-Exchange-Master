import 'package:equatable/equatable.dart';

import '../../../../../core/constants/api_constants.dart';
import 'product_entity.dart';
import 'shipping_entity.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
  closed,
}

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final String orderNumber;
  final OrderStatus status;
  final double totalAmount;
  final String currency;
  final WalletType walletType;
  final List<OrderItemEntity> items;
  final ShippingEntity? shipping;
  final ShippingAddressEntity? shippingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.currency,
    required this.walletType,
    required this.items,
    this.shipping,
    this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        orderNumber,
        status,
        totalAmount,
        currency,
        walletType,
        items,
        shipping,
        shippingAddress,
        createdAt,
        updatedAt,
      ];

  String get statusDisplay {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
      case OrderStatus.closed:
        return 'Closed';
    }
  }

  OrderEntity copyWith({
    String? id,
    String? userId,
    String? orderNumber,
    OrderStatus? status,
    double? totalAmount,
    String? currency,
    WalletType? walletType,
    List<OrderItemEntity>? items,
    ShippingEntity? shipping,
    ShippingAddressEntity? shippingAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      walletType: walletType ?? this.walletType,
      items: items ?? this.items,
      shipping: shipping ?? this.shipping,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OrderItemEntity extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final ProductEntity product;
  final int quantity;
  final double price;
  final String? key;
  final String? filePath;

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.price,
    this.key,
    this.filePath,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        product,
        quantity,
        price,
        key,
        filePath,
      ];

  double get total => price * quantity;

  OrderItemEntity copyWith({
    String? id,
    String? orderId,
    String? productId,
    ProductEntity? product,
    int? quantity,
    double? price,
    String? key,
    String? filePath,
  }) {
    return OrderItemEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      key: key ?? this.key,
      filePath: filePath ?? this.filePath,
    );
  }
}
