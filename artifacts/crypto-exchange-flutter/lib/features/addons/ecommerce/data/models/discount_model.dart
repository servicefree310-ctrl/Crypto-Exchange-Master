import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/discount_entity.dart';

part 'discount_model.freezed.dart';
part 'discount_model.g.dart';

@freezed
class DiscountModel with _$DiscountModel {
  const factory DiscountModel({
    required String id,
    required String code,
    required String type,
    required double value,
    required bool isValid,
    String? message,
    String? productId,
    DateTime? validFrom,
    DateTime? validUntil,
    int? maxUses,
    int? usedCount,
    @Default(true) bool status,
  }) = _DiscountModel;

  factory DiscountModel.fromJson(Map<String, dynamic> json) =>
      _$DiscountModelFromJson(json);
}

/// Extension to convert DiscountModel to DiscountEntity
extension DiscountModelX on DiscountModel {
  DiscountEntity toEntity() {
    return DiscountEntity(
      id: id,
      code: code,
      type: DiscountTypeExtension.fromString(type),
      value: value,
      isValid: isValid,
      message: message,
      productId: productId,
      validFrom: validFrom,
      validUntil: validUntil,
      maxUses: maxUses,
      usedCount: usedCount,
      status: status,
    );
  }
}

/// Factory methods for creating DiscountModel from different API responses
extension DiscountModelFactory on DiscountModel {
  /// Creates a DiscountModel from the v5 discount validation API response
  static DiscountModel fromValidationResponse(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? 'PERCENTAGE',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      isValid: json['isValid'] ?? false,
      message: json['message'],
    );
  }

  /// Creates a DiscountModel from error response
  static DiscountModel fromErrorResponse(
      Map<String, dynamic> json, String code) {
    return DiscountModel(
      id: '',
      code: code,
      type: 'PERCENTAGE',
      value: 0.0,
      isValid: false,
      message: json['error'] ?? 'Invalid discount code',
    );
  }
}
