import 'package:equatable/equatable.dart';

/// Represents a discount/coupon entity
class DiscountEntity extends Equatable {
  const DiscountEntity({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.isValid,
    this.message,
    this.productId,
    this.validFrom,
    this.validUntil,
    this.maxUses,
    this.usedCount,
    this.status = true,
  });

  /// Unique identifier for the discount
  final String id;

  /// Discount code (e.g., "SAVE10", "WELCOME20")
  final String code;

  /// Type of discount: PERCENTAGE, FIXED, FREE_SHIPPING
  final DiscountType type;

  /// Value of the discount (percentage or fixed amount)
  final double value;

  /// Whether the discount is valid and can be applied
  final bool isValid;

  /// Message to display to user (e.g., "10% discount applied!")
  final String? message;

  /// Product ID if discount is product-specific
  final String? productId;

  /// When the discount becomes valid
  final DateTime? validFrom;

  /// When the discount expires
  final DateTime? validUntil;

  /// Maximum number of times discount can be used
  final int? maxUses;

  /// Number of times discount has been used
  final int? usedCount;

  /// Whether the discount is active
  final bool status;

  /// Calculate discount amount for a given subtotal
  double calculateDiscount(double subtotal) {
    if (!isValid) return 0.0;

    switch (type) {
      case DiscountType.percentage:
        return subtotal * (value / 100);
      case DiscountType.fixed:
        return value;
      case DiscountType.freeShipping:
        return 0.0; // Free shipping handled separately
    }
  }

  /// Check if discount is currently valid
  bool get isCurrentlyValid {
    if (!status || !isValid) return false;

    final now = DateTime.now();

    // Check valid from date
    if (validFrom != null && now.isBefore(validFrom!)) {
      return false;
    }

    // Check expiry date
    if (validUntil != null && now.isAfter(validUntil!)) {
      return false;
    }

    // Check usage limit
    if (maxUses != null && usedCount != null && usedCount! >= maxUses!) {
      return false;
    }

    return true;
  }

  @override
  List<Object?> get props => [
        id,
        code,
        type,
        value,
        isValid,
        message,
        productId,
        validFrom,
        validUntil,
        maxUses,
        usedCount,
        status,
      ];

  DiscountEntity copyWith({
    String? id,
    String? code,
    DiscountType? type,
    double? value,
    bool? isValid,
    String? message,
    String? productId,
    DateTime? validFrom,
    DateTime? validUntil,
    int? maxUses,
    int? usedCount,
    bool? status,
  }) {
    return DiscountEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      isValid: isValid ?? this.isValid,
      message: message ?? this.message,
      productId: productId ?? this.productId,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      maxUses: maxUses ?? this.maxUses,
      usedCount: usedCount ?? this.usedCount,
      status: status ?? this.status,
    );
  }
}

/// Types of discounts supported
enum DiscountType {
  percentage,
  fixed,
  freeShipping,
}

/// Extension to convert discount type to/from string
extension DiscountTypeExtension on DiscountType {
  String get name {
    switch (this) {
      case DiscountType.percentage:
        return 'PERCENTAGE';
      case DiscountType.fixed:
        return 'FIXED';
      case DiscountType.freeShipping:
        return 'FREE_SHIPPING';
    }
  }

  static DiscountType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PERCENTAGE':
        return DiscountType.percentage;
      case 'FIXED':
        return DiscountType.fixed;
      case 'FREE_SHIPPING':
        return DiscountType.freeShipping;
      default:
        return DiscountType.percentage;
    }
  }
}
