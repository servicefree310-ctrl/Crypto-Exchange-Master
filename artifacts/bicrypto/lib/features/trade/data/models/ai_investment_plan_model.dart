import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/ai_investment_plan_entity.dart';

part 'ai_investment_plan_model.freezed.dart';
part 'ai_investment_plan_model.g.dart';

@freezed
class AiInvestmentPlanModel with _$AiInvestmentPlanModel {
  const factory AiInvestmentPlanModel({
    required String id,
    required String title,
    String? description,
    String? image,
    required double minAmount,
    required double maxAmount,
    required double profitPercentage,
    required double invested,
    bool? trending,
    bool? status,
    List<AiInvestmentDurationModel>? durations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AiInvestmentPlanModel;

  factory AiInvestmentPlanModel.fromJson(Map<String, dynamic> json) =>
      _$AiInvestmentPlanModelFromJson(json);
}

@freezed
class AiInvestmentDurationModel with _$AiInvestmentDurationModel {
  const factory AiInvestmentDurationModel({
    required String id,
    required int duration,
    required String timeframe,
  }) = _AiInvestmentDurationModel;

  factory AiInvestmentDurationModel.fromJson(Map<String, dynamic> json) =>
      _$AiInvestmentDurationModelFromJson(json);
}

// Extension methods to convert between models and entities
extension AiInvestmentDurationModelX on AiInvestmentDurationModel {
  AiInvestmentDurationEntity toEntity() {
    return AiInvestmentDurationEntity(
      id: id,
      duration: duration,
      timeframe: timeframe,
    );
  }
}

extension AiInvestmentPlanModelX on AiInvestmentPlanModel {
  AiInvestmentPlanEntity toEntity() {
    return AiInvestmentPlanEntity(
      id: id,
      title: title,
      description: description ?? '',
      image: image,
      minAmount: minAmount,
      maxAmount: maxAmount,
      profitPercentage: profitPercentage,
      invested: invested,
      trending: trending ?? false,
      status: status ?? true ? 'ACTIVE' : 'INACTIVE',
      durations:
          durations?.map((duration) => duration.toEntity()).toList() ?? [],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
