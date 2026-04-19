// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LaunchPlanModelImpl _$$LaunchPlanModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LaunchPlanModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      walletType: json['walletType'] as String,
      features: json['features'] as String,
    );

Map<String, dynamic> _$$LaunchPlanModelImplToJson(
        _$LaunchPlanModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'currency': instance.currency,
      'walletType': instance.walletType,
      'features': instance.features,
    };
