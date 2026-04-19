// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ico_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IcoStatsModelImpl _$$IcoStatsModelImplFromJson(Map<String, dynamic> json) =>
    _$IcoStatsModelImpl(
      totalRaised: (json['totalRaised'] as num).toDouble(),
      raisedGrowth: (json['raisedGrowth'] as num).toDouble(),
      successfulOfferings: (json['successfulOfferings'] as num).toInt(),
      offeringsGrowth: (json['offeringsGrowth'] as num).toDouble(),
      totalInvestors: (json['totalInvestors'] as num).toInt(),
      investorsGrowth: (json['investorsGrowth'] as num).toDouble(),
      averageROI: (json['averageROI'] as num).toDouble(),
      roiGrowth: (json['roiGrowth'] as num).toDouble(),
    );

Map<String, dynamic> _$$IcoStatsModelImplToJson(_$IcoStatsModelImpl instance) =>
    <String, dynamic>{
      'totalRaised': instance.totalRaised,
      'raisedGrowth': instance.raisedGrowth,
      'successfulOfferings': instance.successfulOfferings,
      'offeringsGrowth': instance.offeringsGrowth,
      'totalInvestors': instance.totalInvestors,
      'investorsGrowth': instance.investorsGrowth,
      'averageROI': instance.averageROI,
      'roiGrowth': instance.roiGrowth,
    };
