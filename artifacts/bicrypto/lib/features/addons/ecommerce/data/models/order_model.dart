import '../../../../../core/constants/api_constants.dart' hide OrderStatus;
import '../../domain/entities/order_entity.dart';
import 'product_model.dart';
import 'shipping_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.orderNumber,
    required super.status,
    required super.totalAmount,
    required super.currency,
    required super.walletType,
    required super.items,
    super.shipping,
    super.shippingAddress,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      status: _parseOrderStatus(json['status']),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      walletType: _parseWalletType(json['walletType']),
      items: (json['products'] as List<dynamic>?)?.map((item) {
            // Handle the special structure from backend where products are nested
            return OrderItemModel.fromJson({
              'id': item['id'] ?? '',
              'orderId': json['id'] ?? '',
              'productId': item['id'] ?? '',
              'product': item,
              'quantity': item['ecommerceOrderItems']?['quantity'] ?? 1,
              'price': (item['price'] as num?)?.toDouble() ?? 0.0,
              'key': item['ecommerceOrderItems']?['key'],
              'filePath': item['ecommerceOrderItems']?['filePath'],
            });
          }).toList() ??
          [],
      shipping: json['shipping'] != null
          ? ShippingMethodModel.fromJson(json['shipping'])
          : null,
      shippingAddress: json['shippingAddress'] != null
          ? AddressModel.fromJson(json['shippingAddress'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderNumber': orderNumber,
      'status': status.name,
      'totalAmount': totalAmount,
      'currency': currency,
      'walletType': walletType.name,
      'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
      'shipping':
          shipping != null ? (shipping as ShippingMethodModel).toJson() : null,
      'shippingAddress': shippingAddress != null
          ? (shippingAddress as AddressModel).toJson()
          : null,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static OrderStatus _parseOrderStatus(dynamic status) {
    if (status == null) return OrderStatus.pending;

    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'refunded':
        return OrderStatus.refunded;
      case 'closed':
        return OrderStatus.closed;
      default:
        return OrderStatus.pending;
    }
  }

  static WalletType _parseWalletType(dynamic walletType) {
    if (walletType == null) return WalletType.fiat;

    final walletTypeStr = walletType.toString().toLowerCase();
    switch (walletTypeStr) {
      case 'spot':
        return WalletType.spot;
      case 'eco':
        return WalletType.eco;
      case 'futures':
        return WalletType.futures;
      case 'fiat':
      default:
        return WalletType.fiat;
    }
  }

  OrderEntity toEntity() => this;
}

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    required super.productId,
    required super.product,
    required super.quantity,
    required super.price,
    super.key,
    super.filePath,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Ensure we have a product object
    final productData = json['product'] ?? {};

    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      productId:
          json['productId']?.toString() ?? productData['id']?.toString() ?? '',
      product: ProductModel.fromJson(productData).toEntity(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ??
          (productData['price'] as num?)?.toDouble() ??
          0.0,
      key: json['key']?.toString(),
      filePath: json['filePath']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'product': product,
      'quantity': quantity,
      'price': price,
      'key': key,
      'filePath': filePath,
    };
  }

  OrderItemEntity toEntity() => this;
}
