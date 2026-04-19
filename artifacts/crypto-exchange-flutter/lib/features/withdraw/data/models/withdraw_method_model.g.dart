// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdraw_method_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WithdrawMethodModelImpl _$$WithdrawMethodModelImplFromJson(
        Map<String, dynamic> json) =>
    _$WithdrawMethodModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      instructions: json['instructions'] as String?,
      fixedFee: (json['fixedFee'] as num?)?.toDouble(),
      percentageFee: (json['percentageFee'] as num?)?.toDouble(),
      minAmount: (json['minAmount'] as num?)?.toDouble(),
      maxAmount: (json['maxAmount'] as num?)?.toDouble(),
      network: json['network'] as String?,
      customFields: json['customFields'] as String?,
      image: json['image'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$WithdrawMethodModelImplToJson(
        _$WithdrawMethodModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'instructions': instance.instructions,
      'fixedFee': instance.fixedFee,
      'percentageFee': instance.percentageFee,
      'minAmount': instance.minAmount,
      'maxAmount': instance.maxAmount,
      'network': instance.network,
      'customFields': instance.customFields,
      'image': instance.image,
      'isActive': instance.isActive,
    };
