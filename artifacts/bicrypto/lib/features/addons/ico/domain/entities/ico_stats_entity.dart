import 'package:equatable/equatable.dart';

class IcoStatsEntity extends Equatable {
  const IcoStatsEntity({
    required this.totalRaised,
    required this.raisedGrowth,
    required this.successfulOfferings,
    required this.offeringsGrowth,
    required this.totalInvestors,
    required this.investorsGrowth,
    required this.averageROI,
    required this.roiGrowth,
  });

  final double totalRaised;
  final double raisedGrowth;
  final int successfulOfferings;
  final double offeringsGrowth;
  final int totalInvestors;
  final double investorsGrowth;
  final double averageROI;
  final double roiGrowth;

  @override
  List<Object?> get props => [
        totalRaised,
        raisedGrowth,
        successfulOfferings,
        offeringsGrowth,
        totalInvestors,
        investorsGrowth,
        averageROI,
        roiGrowth,
      ];
}
