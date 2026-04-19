// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ico_launch_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IcoLaunchPlanModelImpl _$$IcoLaunchPlanModelImplFromJson(
        Map<String, dynamic> json) =>
    _$IcoLaunchPlanModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
      features:
          (json['features'] as List<dynamic>).map((e) => e as String).toList(),
      isActive: json['isActive'] as bool? ?? true,
      isPopular: json['isPopular'] as bool? ?? false,
      discount: (json['discount'] as num?)?.toDouble(),
      maxOfferings: (json['maxOfferings'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$IcoLaunchPlanModelImplToJson(
        _$IcoLaunchPlanModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'duration': instance.duration,
      'features': instance.features,
      'isActive': instance.isActive,
      'isPopular': instance.isPopular,
      'discount': instance.discount,
      'maxOfferings': instance.maxOfferings,
    };
