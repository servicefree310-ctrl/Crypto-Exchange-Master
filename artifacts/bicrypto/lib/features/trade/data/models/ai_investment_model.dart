import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/ai_investment_entity.dart';

part 'ai_investment_model.freezed.dart';
part 'ai_investment_model.g.dart';

@freezed
class AiInvestmentModel with _$AiInvestmentModel {
  const factory AiInvestmentModel({
    required String id,
    required String userId,
    required String planId,
    required String durationId,
    required String symbol,
    required double amount,
    required double profit,
    required String result,
    required String status,
    required String type,
    required DateTime createdAt,
    DateTime? endedAt,
    double? profitPercentage,
    String? durationText,
    // Include related data for API response parsing
    Map<String, dynamic>? plan,
    Map<String, dynamic>? duration,
  }) = _AiInvestmentModel;

  factory AiInvestmentModel.fromJson(Map<String, dynamic> json) =>
      _$AiInvestmentModelFromJson(json);
}

// Extension method to convert between model and entity
extension AiInvestmentModelX on AiInvestmentModel {
  AiInvestmentEntity toEntity() {
    // Extract plan title from nested plan data
    String planTitle = plan?['title'] as String? ?? 'Unknown Plan';

    // Extract duration text from nested duration data
    String? extractedDurationText;
    if (duration != null) {
      final durationValue = duration!['duration'] as int?;
      final timeframe = duration!['timeframe'] as String?;

      if (durationValue != null && timeframe != null) {
        switch (timeframe.toLowerCase()) {
          case 'hour':
            extractedDurationText =
                durationValue == 1 ? '1 Hour' : '$durationValue Hours';
            break;
          case 'day':
            extractedDurationText =
                durationValue == 1 ? '1 Day' : '$durationValue Days';
            break;
          case 'week':
            extractedDurationText =
                durationValue == 1 ? '1 Week' : '$durationValue Weeks';
            break;
          case 'month':
            extractedDurationText =
                durationValue == 1 ? '1 Month' : '$durationValue Months';
            break;
          default:
            extractedDurationText = '$durationValue $timeframe';
        }
      }
    }

    return AiInvestmentEntity(
      id: id,
      userId: userId,
      planId: planId,
      planTitle: planTitle,
      durationId: durationId,
      symbol: symbol,
      amount: amount,
      profit: profit,
      result: result,
      status: status,
      type: type,
      createdAt: createdAt,
      endedAt: endedAt,
      profitPercentage: profitPercentage,
      durationText: extractedDurationText ?? durationText,
    );
  }
}
