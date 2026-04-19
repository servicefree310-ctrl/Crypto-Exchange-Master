import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

import '../../domain/entities/launch_plan_entity.dart';

part 'launch_plan_model.freezed.dart';
part 'launch_plan_model.g.dart';

@freezed
class LaunchPlanModel with _$LaunchPlanModel {
  const factory LaunchPlanModel({
    required String id,
    required String name,
    required String description,
    required double price,
    required String currency,
    required String walletType,
    required String features,
  }) = _LaunchPlanModel;

  factory LaunchPlanModel.fromJson(Map<String, dynamic> json) =>
      _$LaunchPlanModelFromJson(json);
}

extension LaunchPlanModelX on LaunchPlanModel {
  LaunchPlanEntity toEntity() {
    Map<String, dynamic> parsed = {};
    try {
      parsed = (features.isNotEmpty)
          ? Map<String, dynamic>.from(
              jsonDecode(features) as Map<String, dynamic>)
          : {};
    } catch (_) {}

    return LaunchPlanEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      currency: currency,
      walletType: walletType,
      features: parsed,
    );
  }
}
