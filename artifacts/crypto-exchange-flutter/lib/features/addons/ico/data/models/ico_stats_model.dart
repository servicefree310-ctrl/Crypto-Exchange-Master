import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/ico_stats_entity.dart';

part 'ico_stats_model.freezed.dart';
part 'ico_stats_model.g.dart';

@freezed
class IcoStatsModel with _$IcoStatsModel {
  const IcoStatsModel._();

  const factory IcoStatsModel({
    required double totalRaised,
    required double raisedGrowth,
    required int successfulOfferings,
    required double offeringsGrowth,
    required int totalInvestors,
    required double investorsGrowth,
    required double averageROI,
    required double roiGrowth,
  }) = _IcoStatsModel;

  factory IcoStatsModel.fromJson(Map<String, dynamic> json) =>
      _$IcoStatsModelFromJson(json);

  IcoStatsEntity toEntity() {
    return IcoStatsEntity(
      totalRaised: totalRaised,
      raisedGrowth: raisedGrowth,
      successfulOfferings: successfulOfferings,
      offeringsGrowth: offeringsGrowth,
      totalInvestors: totalInvestors,
      investorsGrowth: investorsGrowth,
      averageROI: averageROI,
      roiGrowth: roiGrowth,
    );
  }
}
