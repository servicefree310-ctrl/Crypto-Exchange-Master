import 'package:equatable/equatable.dart';
import 'mlm_condition_entity.dart';

class MlmLandingEntity extends Equatable {
  const MlmLandingEntity({
    required this.stats,
    required this.conditions,
    required this.topAffiliates,
    required this.recentActivity,
    required this.mlmSystem,
  });

  final MlmLandingStatsEntity stats;
  final List<MlmConditionEntity> conditions;
  final List<MlmTopAffiliateEntity> topAffiliates;
  final List<MlmActivityEntity> recentActivity;
  final String mlmSystem;

  @override
  List<Object?> get props => [
        stats,
        conditions,
        topAffiliates,
        recentActivity,
        mlmSystem,
      ];

  MlmLandingEntity copyWith({
    MlmLandingStatsEntity? stats,
    List<MlmConditionEntity>? conditions,
    List<MlmTopAffiliateEntity>? topAffiliates,
    List<MlmActivityEntity>? recentActivity,
    String? mlmSystem,
  }) {
    return MlmLandingEntity(
      stats: stats ?? this.stats,
      conditions: conditions ?? this.conditions,
      topAffiliates: topAffiliates ?? this.topAffiliates,
      recentActivity: recentActivity ?? this.recentActivity,
      mlmSystem: mlmSystem ?? this.mlmSystem,
    );
  }
}

class MlmLandingStatsEntity extends Equatable {
  const MlmLandingStatsEntity({
    required this.totalAffiliates,
    required this.totalPaidOut,
    required this.avgMonthlyEarnings,
    required this.successRate,
  });

  final int totalAffiliates;
  final double totalPaidOut;
  final double avgMonthlyEarnings;
  final double successRate;

  @override
  List<Object?> get props => [
        totalAffiliates,
        totalPaidOut,
        avgMonthlyEarnings,
        successRate,
      ];

  MlmLandingStatsEntity copyWith({
    int? totalAffiliates,
    double? totalPaidOut,
    double? avgMonthlyEarnings,
    double? successRate,
  }) {
    return MlmLandingStatsEntity(
      totalAffiliates: totalAffiliates ?? this.totalAffiliates,
      totalPaidOut: totalPaidOut ?? this.totalPaidOut,
      avgMonthlyEarnings: avgMonthlyEarnings ?? this.avgMonthlyEarnings,
      successRate: successRate ?? this.successRate,
    );
  }
}

class MlmTopAffiliateEntity extends Equatable {
  const MlmTopAffiliateEntity({
    required this.rank,
    this.avatar,
    required this.displayName,
    required this.totalEarnings,
    required this.rewardCount,
    required this.joinedAgo,
  });

  final int rank;
  final String? avatar;
  final String displayName;
  final double totalEarnings;
  final int rewardCount;
  final String joinedAgo;

  @override
  List<Object?> get props => [
        rank,
        avatar,
        displayName,
        totalEarnings,
        rewardCount,
        joinedAgo,
      ];

  MlmTopAffiliateEntity copyWith({
    int? rank,
    String? avatar,
    String? displayName,
    double? totalEarnings,
    int? rewardCount,
    String? joinedAgo,
  }) {
    return MlmTopAffiliateEntity(
      rank: rank ?? this.rank,
      avatar: avatar ?? this.avatar,
      displayName: displayName ?? this.displayName,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      rewardCount: rewardCount ?? this.rewardCount,
      joinedAgo: joinedAgo ?? this.joinedAgo,
    );
  }
}

class MlmActivityEntity extends Equatable {
  const MlmActivityEntity({
    required this.type,
    required this.amount,
    required this.conditionType,
    required this.currency,
    required this.timeAgo,
  });

  final String type;
  final double amount;
  final String conditionType;
  final String currency;
  final String timeAgo;

  @override
  List<Object?> get props => [type, amount, conditionType, currency, timeAgo];

  MlmActivityEntity copyWith({
    String? type,
    double? amount,
    String? conditionType,
    String? currency,
    String? timeAgo,
  }) {
    return MlmActivityEntity(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      conditionType: conditionType ?? this.conditionType,
      currency: currency ?? this.currency,
      timeAgo: timeAgo ?? this.timeAgo,
    );
  }
}
