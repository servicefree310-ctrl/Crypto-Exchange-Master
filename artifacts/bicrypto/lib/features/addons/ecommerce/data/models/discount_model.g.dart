// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiscountModelImpl _$$DiscountModelImplFromJson(Map<String, dynamic> json) =>
    _$DiscountModelImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      isValid: json['isValid'] as bool,
      message: json['message'] as String?,
      productId: json['productId'] as String?,
      validFrom: json['validFrom'] == null
          ? null
          : DateTime.parse(json['validFrom'] as String),
      validUntil: json['validUntil'] == null
          ? null
          : DateTime.parse(json['validUntil'] as String),
      maxUses: (json['maxUses'] as num?)?.toInt(),
      usedCount: (json['usedCount'] as num?)?.toInt(),
      status: json['status'] as bool? ?? true,
    );

Map<String, dynamic> _$$DiscountModelImplToJson(_$DiscountModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'type': instance.type,
      'value': instance.value,
      'isValid': instance.isValid,
      'message': instance.message,
      'productId': instance.productId,
      'validFrom': instance.validFrom?.toIso8601String(),
      'validUntil': instance.validUntil?.toIso8601String(),
      'maxUses': instance.maxUses,
      'usedCount': instance.usedCount,
      'status': instance.status,
    };
