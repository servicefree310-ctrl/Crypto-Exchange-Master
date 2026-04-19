import '../../domain/entities/creator_stats_entity.dart';

class CreatorStatsModel {
  CreatorStatsModel({
    required this.totalOfferings,
    required this.pendingOfferings,
    required this.activeOfferings,
    required this.completedOfferings,
    required this.rejectedOfferings,
    required this.totalRaised,
    required this.offeringsGrowth,
    required this.raiseGrowth,
    required this.successRate,
    required this.successRateGrowth,
  });

  final int totalOfferings;
  final int pendingOfferings;
  final int activeOfferings;
  final int completedOfferings;
  final int rejectedOfferings;
  final double totalRaised;
  final double offeringsGrowth;
  final double raiseGrowth;
  final double successRate;
  final double successRateGrowth;

  factory CreatorStatsModel.fromJson(Map<String, dynamic> json) {
    return CreatorStatsModel(
      totalOfferings: json['totalOfferings'] ?? 0,
      pendingOfferings: json['pendingOfferings'] ?? 0,
      activeOfferings: json['activeOfferings'] ?? 0,
      completedOfferings: json['completedOfferings'] ?? 0,
      rejectedOfferings: json['rejectedOfferings'] ?? 0,
      totalRaised: (json['totalRaised'] as num?)?.toDouble() ?? 0,
      offeringsGrowth: (json['offeringGrowth'] as num?)?.toDouble() ?? 0,
      raiseGrowth: (json['raiseGrowth'] as num?)?.toDouble() ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0,
      successRateGrowth: (json['successRateGrowth'] as num?)?.toDouble() ?? 0,
    );
  }

  CreatorStatsEntity toEntity() => CreatorStatsEntity(
        totalOfferings: totalOfferings,
        pendingOfferings: pendingOfferings,
        activeOfferings: activeOfferings,
        completedOfferings: completedOfferings,
        rejectedOfferings: rejectedOfferings,
        totalRaised: totalRaised,
        offeringsGrowth: offeringsGrowth,
        raiseGrowth: raiseGrowth,
        successRate: successRate,
        successRateGrowth: successRateGrowth,
      );
}
