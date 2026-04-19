import 'package:equatable/equatable.dart';
import '../../../../../core/constants/api_constants.dart';
import 'mlm_user_entity.dart';
import 'mlm_referral_entity.dart';
import 'mlm_reward_entity.dart';

class MlmDashboardEntity extends Equatable {
  const MlmDashboardEntity({
    required this.userProfile,
    required this.stats,
    required this.previousStats,
    required this.mlmSystem,
    this.upline,
    required this.recentReferrals,
    required this.recentRewards,
    required this.earningsChart,
    required this.referralChart,
    required this.networkSummary,
  });

  final MlmUserEntity userProfile;
  final MlmStatsEntity stats;
  final MlmStatsEntity previousStats;
  final MlmSystem mlmSystem;
  final MlmUserEntity? upline;
  final List<MlmReferralEntity> recentReferrals;
  final List<MlmRewardEntity> recentRewards;
  final List<MlmChartDataEntity> earningsChart;
  final List<MlmChartDataEntity> referralChart;
  final MlmNetworkSummaryEntity networkSummary;

  @override
  List<Object?> get props => [
        userProfile,
        stats,
        previousStats,
        mlmSystem,
        upline,
        recentReferrals,
        recentRewards,
        earningsChart,
        referralChart,
        networkSummary,
      ];

  MlmDashboardEntity copyWith({
    MlmUserEntity? userProfile,
    MlmStatsEntity? stats,
    MlmStatsEntity? previousStats,
    MlmSystem? mlmSystem,
    MlmUserEntity? upline,
    List<MlmReferralEntity>? recentReferrals,
    List<MlmRewardEntity>? recentRewards,
    List<MlmChartDataEntity>? earningsChart,
    List<MlmChartDataEntity>? referralChart,
    MlmNetworkSummaryEntity? networkSummary,
  }) {
    return MlmDashboardEntity(
      userProfile: userProfile ?? this.userProfile,
      stats: stats ?? this.stats,
      previousStats: previousStats ?? this.previousStats,
      mlmSystem: mlmSystem ?? this.mlmSystem,
      upline: upline ?? this.upline,
      recentReferrals: recentReferrals ?? this.recentReferrals,
      recentRewards: recentRewards ?? this.recentRewards,
      earningsChart: earningsChart ?? this.earningsChart,
      referralChart: referralChart ?? this.referralChart,
      networkSummary: networkSummary ?? this.networkSummary,
    );
  }
}

class MlmStatsEntity extends Equatable {
  const MlmStatsEntity({
    required this.totalReferrals,
    required this.activeReferrals,
    required this.pendingReferrals,
    required this.conversionRate,
    required this.totalEarnings,
    required this.weeklyGrowth,
  });

  final int totalReferrals;
  final int activeReferrals;
  final int pendingReferrals;
  final double conversionRate;
  final double totalEarnings;
  final double weeklyGrowth;

  @override
  List<Object?> get props => [
        totalReferrals,
        activeReferrals,
        pendingReferrals,
        conversionRate,
        totalEarnings,
        weeklyGrowth,
      ];
}

class MlmChartDataEntity extends Equatable {
  const MlmChartDataEntity({
    required this.period,
    required this.value,
    required this.date,
  });

  final String period;
  final double value;
  final DateTime date;

  @override
  List<Object?> get props => [period, value, date];
}

class MlmNetworkSummaryEntity extends Equatable {
  const MlmNetworkSummaryEntity({
    required this.totalNetworkSize,
    required this.activeMembers,
    required this.networkDepth,
    required this.topPerformers,
    required this.totalMembers,
    required this.maxDepth,
    required this.totalVolume,
  });

  final int totalNetworkSize;
  final int activeMembers;
  final int networkDepth;
  final List<MlmUserEntity> topPerformers;
  final int totalMembers;
  final int maxDepth;
  final double totalVolume;

  @override
  List<Object?> get props => [
        totalNetworkSize,
        activeMembers,
        networkDepth,
        topPerformers,
        totalMembers,
        maxDepth,
        totalVolume,
      ];
}
