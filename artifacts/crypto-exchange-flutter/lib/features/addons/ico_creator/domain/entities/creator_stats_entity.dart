import 'package:equatable/equatable.dart';

class CreatorStatsEntity extends Equatable {
  const CreatorStatsEntity({
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

  @override
  List<Object?> get props => [
        totalOfferings,
        pendingOfferings,
        activeOfferings,
        completedOfferings,
        rejectedOfferings,
        totalRaised,
        offeringsGrowth,
        raiseGrowth,
        successRate,
        successRateGrowth,
      ];
}
